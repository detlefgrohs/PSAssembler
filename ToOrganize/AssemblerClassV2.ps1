param (
    $FileName,
    [Switch]$GeneratePRG,
    [Switch]$ExecutePRG
)


class AssemblerV2 {
    $OPCodes = [Ordered]@{};
    $Bytes = @();
    $Variables = @{};
    $Output = @();
    $SyntaxPattern = $null;
    $Pass = 0;
    $Macros = @{};
    
    [UInt16]$Address;
    [UInt16]$StartingAddress;

    AssemblerV2([string]$CPU = '6502') {
        (Get-Content "Opcodes.$($CPU).V2.json" | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $this.OPCodes.Add($_.Name, $_.Value); }
        $this.CreateSyntaxPattern();
    }

    [void]CreateSyntaxPattern() {
        $patterns = [ordered]@{ directive = '\s*#(?<command>[^\s]*)(?<parameters>[^;]*)?';
                                equation =  '\s*(?<left>[^\s]*)\s*=\s*(?<right>.*)?';
                                code =      '\s*((?<label>[^\s]*):)?\s*(?<mnemonic>[^\s]*)\s*(?<operand>.*)\s*';
                               };
        $this.SyntaxPattern = '^';
        $patterns.Keys | ForEach-Object {
            $this.SyntaxPattern += '(?<' + $_ + '>' + $patterns[$_] + ')|'
        }
        $this.SyntaxPattern += '$';
    }

    [array] ParseSyntax ($Syntax) {
        $Syntax = $Syntax -replace ';.*', ''    # Remove Comments so they don't screw up the 'parsing'

        $parsedItems = @{};
        if ($Syntax -match $this.SyntaxPattern) {
            switch ($Matches) {
                { $_.ContainsKey('label') }      { $parsedItems.Label = $_['label'].Trim(); }
                { $_.ContainsKey('mnemonic') }   { $parsedItems.Mnemonic = $_['mnemonic'].Trim(); }
                { $_.ContainsKey('operand') }    { $parsedItems.Operand = $_['operand'].Trim(); }
                { $_.ContainsKey('command') }    { $parsedItems.Command = $_['command'].Trim(); }
                { $_.ContainsKey('parameters') } { $parsedItems.Parameters = $_['parameters'].Trim(); }
                { $_.ContainsKey('left') }       { $parsedItems.Left = $_['left'].Trim(); }
                { $_.ContainsKey('right') }      { $parsedItems.Right = $_['right'].Trim();  }
            }
        }
        # The pattern still allows empty strings for Mnemonic and Operand so fix here until I can fix the patter...
        if ($parsedItems['Mnemonic'] -eq '') { $parsedItems.Remove('Mnemonic'); }
        if ($parsedItems['Operand'] -eq '') { $parsedItems.Remove('Operand'); }
        return $parsedItems;
    }
        
    [uint16] EvaluateExpression($Expression) {
        $expressionVariables = @();
        ([RegEx]'[a-zA-Z_]\w*').Matches($Expression) | ForEach-Object {
            if (-not $expressionVariables.Contains($_.Value)) { $expressionVariables += $_.Value; }
        }
        $expressionVariables | Sort-Object { $_.Length } -Descending | ForEach-Object {
            if ($this.Variables.ContainsKey($_)) {
                $Expression = $Expression.Replace($_, $this.Variables[$_]);
            };
        }
        $Expression = $Expression.Replace('$', '0x');
        $Expression = $Expression -replace '%([0-1]*)', '[Convert]::ToInt16(''$1'', 2)'
        $Expression = $Expression -replace '>>', ' -shr '
        $Expression = $Expression -replace '<<', ' -shl '
        $Expression = $Expression -replace '\|', ' -bor '
        $Expression = $Expression -replace '\&', ' -band '

        try { return [uint16]$(Invoke-Expression $Expression); }
        catch {
            $this.Output += "   Error in Expression: '$($expression)'" 
            return [uint16]0; 
        }
    }

    [array] ExpandMacros($Lines) {
        Write-Host -ForegroundColor Green "Expanding Macros Pass #$($this.Pass)"
        $this.Pass += 1;

        $processedLines = @();
        $InMacro = $false;
        $macroExpansionOccured = $false;

        $Lines | ForEach-Object {
            if ($InMacro) {
                if ($_ -match '#ENDM') {
                    $InMacro = $false;
                } else {
                    $this.Macros[$CurrentMacroName].Replacement += $_;
                }
            } else {    
                # Check for a Macro 
                if ($_ -match '#MACRO\s+(?<macroname>[a-z]*)\((?<parameters>[^)]*)\)') {
                    $InMacro = $true;
                    $CurrentMacroName = $Matches['macroname']
                    $this.Macros.Add($Matches['macroname'], @{ Replacement = @(); Parameters = @(); });
                    $Matches['parameters'] -split ',' | ForEach-Object {
                        $this.Macros[$CurrentMacroName].Parameters += $_;
                    }
                } else {
                    $cleanedLine = $_ -replace ';.*', ''   
                    if ($cleanedLine -match '@(?<macroname>[a-z]*)\((?<parameters>[^)]*)\)') {
                        $replacementCode = @();

                        if ($this.Macros.ContainsKey($Matches['macroname'])) {
                            $macroExpansionOccured = $true;
                            $this.Macros[$Matches['macroname']].Replacement | ForEach-Object {
                                $line = $_;

                                $parameterIndex = 0;
                                $Matches['parameters'] -split ',' | ForEach-Object {
                                    if ($parameterIndex -lt $this.Macros[$Matches['macroname']].Parameters.Count) {
                                        $parameterName = $this.Macros[$Matches['macroname']].Parameters[$parameterIndex];
                                        $line = $line.Replace('@' + $parameterName, $_);
                                    }
                                    $parameterIndex += 1;
                                } 
                                $replacementCode += $line;
                            }
                        } else {
                            $this.Output += "   Macro '$($Matches['macroname'])' not found."
                            "Macro not found..."
                            $replacementCode += '; ' + $Matches[0];
                        }
        
                        if ($replacementCode.Count -eq 1) {
                            $processedLines += $_.Replace($Matches[0], $replacementCode);
                        } else {
                            $processedLines += $_.Replace($Matches[0], $replacementCode[0]);
                            for($index = 1; $index -lt $replacementCode.Count ; $index += 1) {
                                $processedLines += $replacementCode[$index];
                            }
                        }
                    } else { # Nothing to do so pass-tru
                        $processedLines += $_
                    }
                }
            }
        }
        if ($macroExpansionOccured) { # Keep processing until no macro expansions...
            $processedLines = $this.ExpandMacros($processedLines);
        }
        return $processedLines;
    }

    [array] LoadFile($FileName) {
        Write-Host -ForegroundColor Green "Loading file '$($FileName)'"
        $lines = @();
        Get-Content $FileName | ForEach-Object {
            $lines += $_
            if ($_ -match '.*#INCLUDE\s+([^\s]*).*') {
                $includeFileName = $Matches[1]
                $lines += "; Start Including '$($includeFileName)'"
                $this.LoadFile($includeFileName) | ForEach-Object { $lines += $_; }
                $lines += "; Ending Including '$($includeFileName)'"
            } 
        }
        return $lines
    }

    [array] WordToByteArray($Word) {
        return @(($Word -band 0x00FF), (( $Word -band 0xFF00 ) -shr 8));
    }

    [void] AssembleFile($FileName) {
        $lines = $this.LoadFile($FileName);
        $this.Pass = 1;
        $lines = $this.ExpandMacros($lines);


        $this.Pass = 1;
        Write-Host -ForegroundColor Green "Assembly Pass #$($this.Pass)"
        $lines | ForEach-Object { $this.Assemble($_); }
        $this.Pass = 2;
        Write-Host -ForegroundColor Green "Assembly Pass #$($this.Pass)"
        $lines | ForEach-Object { $this.Assemble($_); }     
    }

    [void] ExportPrg($FileName) {
        $prg = $this.WordToByteArray($this.StartingAddress) + $this.Bytes;
        Remove-Item -Path $FileName -Force -ErrorAction SilentlyContinue
        if ((Get-Host).Version.Major -lt 6) {
            $prg | ForEach-Object { Add-Content -Value ([byte]$_) -Path $FileName -Encoding Byte } # PowerShell 5.x -Encoding Byte
        } else {
            $prg | ForEach-Object { Add-Content -Value ([byte]$_) -Path $FileName -AsByteStream } # PowerShell 6.x AsByteStream
        }
    }

    [void] Assemble($Syntax) {
        $codes = @();
        $details = "";
        $parsedSyntax = $this.ParseSyntax($Syntax);
        
        if ($parsedSyntax.Label -ne $null) {
            if ($this.Variables.ContainsKey($parsedSyntax.Label)) {

            } else {
                $this.Variables.Add($parsedSyntax.Label, $this.Address);
            } 
        }
        
        if ($parsedSyntax.Left -ne $null) {
            $value = $this.EvaluateExpression($parsedSyntax.Right);

            if ($parsedSyntax.Left -eq '*') {
                $this.Address = $value;
                $this.StartingAddress = $value;
            } else {
                if ($this.Variables.ContainsKey($parsedSyntax.Left)) {

                } else {
                    $this.Variables.Add($parsedSyntax.Left, $value);
                }
            }
        }
        
        if ($parsedSyntax.Mnemonic -ne $null) {
            $operation = $this.OPCodes[$parsedSyntax.Mnemonic];
            $details = $operation.Format;
            
            if ($operation.Opcode -ne '') { $codes += [byte]$operation.Opcode }    

            if ($operation.AddressingMode -eq 'Relative') {
                if ($this.Pass -eq 1) {
                    $codes += [byte]0x00;
                } else {
                    $offset = $this.EvaluateExpression($parsedSyntax.Operand) - ($this.Address + 2);

                    if ($offset -lt -128 -or $offset -gt 127) {
                        $this.Output += "   Branch too large...";
                        $offset = [byte]0;
                    }
                     
                    if ($offset -lt 0) { $offset += 0x100; }
                    $value = [byte]$offset;
                    $codes += $value;
                    $details = $details.Replace('[r8]', '$' + $value.ToString('X2'));   
                }
            } else {
                if ($operation.Bytes -eq 1) {
                    $value = if ($this.Pass -eq 1) { 0; } else { $this.EvaluateExpression($parsedSyntax.Operand); }
                    $codes += [byte]$value;
                    $details = $operation.Format.Replace('[d8]', '$'+ $value.ToString('X2'));
                }
                if ($operation.Bytes -eq 2) {
                    $value = if ($this.Pass -eq 1) { 0; } else { $this.EvaluateExpression($parsedSyntax.Operand); }
                    $codes += ($this.WordToByteArray($value))
                    $details = $details.Replace('[a16]', '$'+ $value.ToString('X4'));
                }
            }
        }

        if ($this.Pass -ne 1) {
            $line = "$($this.Address.ToString('X4')) | ";
            for ($index = 0; $index -lt 3; $index += 1) {
                if ($index -lt $codes.Count) { $line += "$($codes[$index].ToString('X2')) "; } else { $line += "   "; }
            }
            $line = ($line + "| " + $details).PadRight(30, ' ') + "| " + $Syntax;
        
            $this.Output += $line;
            $this.Bytes += $codes;
        }
        $this.Address += $codes.Count;
    }
}

$assembler = [AssemblerV2]::new('6502');
$assembler.AssembleFile($FileName);
$assembler.Output

if ($GeneratePRG -or $ExecutePRG) {
    $prgFileName = $FileName.Replace('.asm', '.prg')

    $assembler.ExportPrg($prgFileName);
    if ($ExecutePRG) {
        . "C:\Program Files\GTK3VICE-3.7-win64\bin\x64sc.exe" $prgFileName
    }
}