param (
    $FileName,
    [Switch]$GeneratePRG,
    [Switch]$GenerateOUT,
    [Switch]$ExecutePRG,
    [Switch]$DumpVariables
)

$Global:AssemblerPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition);

class AssemblerV3 {
    $OPCodes = [Ordered]@{};
    $Bytes = @();
    $Variables = @{};
    $Output = @();
    $SyntaxPattern = $null;
    $Pass = 0;
    $Macros = @{};
    [UInt16]$Address;
    [UInt16]$StartingAddress;
    $InMacro = $false;
    $Errors = @();

    AssemblerV3([string]$CPU = '6502') {
        (Get-Content -Path "$($Global:AssemblerPath)\Opcodes.$($CPU).V2.json" | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $this.OPCodes.Add($_.Name, $_.Value); }
        $this.CreateSyntaxPattern();
    }
    [void]CreateSyntaxPattern() {
        $patterns = [ordered]@{ directive = '\s*#(?<command>[^\s]*)(?<parameters>[^;]*)?';
                                equation =  '\s*(?<left>[^\s]*)\s*=\s*(?<right>.*)?';
                                code =      '\s*((?<label>[^\s]*):)?\s*(?<mnemonic>[^\s]*)\s*(?<operand>.*)\s*';
                               };
        $this.SyntaxPattern = '^';
        $patterns.Keys | ForEach-Object { $this.SyntaxPattern += '(?<' + $_ + '>' + $patterns[$_] + ')|' }
        $this.SyntaxPattern += '$';
    }
    [array] ParseSyntax ($Syntax) {
        $parsedItems = @{};
        if (($Syntax -replace ';.*', '') -match $this.SyntaxPattern) {    # Remove Comments so they don't screw up the 'parsing'
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
        # The pattern still allows empty strings for Mnemonic and Operand so fix here until I can fix the pattern...
        if ($parsedItems['Mnemonic'] -eq '') { $parsedItems.Remove('Mnemonic'); }
        if ($parsedItems['Operand'] -eq '') { $parsedItems.Remove('Operand'); }
        return $parsedItems;
    }
    [uint16] EvaluateExpression($Expression, $Line) {
        $expressionVariables = @();
        ([RegEx]'[a-zA-Z_]\w*').Matches($Expression) | ForEach-Object {
            if (-not $expressionVariables.Contains($_.Value)) { $expressionVariables += $_.Value; }
        }
        $expressionVariables | Sort-Object { $_.Length } -Descending | ForEach-Object {
            if ($this.Variables.ContainsKey($_)) { $Expression = $Expression.Replace($_, $this.Variables[$_]); };
        }
        $Expression = $Expression.Replace('$', '0x');
        $Expression = $Expression -replace '%([0-1]+)', '[Convert]::ToInt16(''$1'', 2)'
        $Expression = $Expression -replace '''(.)''', '[byte][char]''$1'''
        $Expression = $Expression -replace '>>', ' -shr '
        $Expression = $Expression -replace '<<', ' -shl '
        $Expression = $Expression -replace '\|', ' -bor '
        $Expression = $Expression -replace '\&', ' -band '

        try { return [uint16]$(Invoke-Expression $Expression); }
        catch {
            $this.Output += "   Error in Expression: '$($expression)'"
            $this.Errors += @{ Message = "   Error in Expression: '$($expression)'"; Line = $Line }
            return [uint16]0; 
        }
    }
    [void]TernaryVoid($Test, [ScriptBlock] $T, [ScriptBlock] $F) {
        if ($Test) { &$T; } else { &$F; }
    }
    [object]TernaryObject($Test, [ScriptBlock] $T, [ScriptBlock] $F) {
        if ($Test) { return &$T; } else { return &$F; }
    }
    [array] ExpandMacros($Lines) {
        Write-Host -ForegroundColor Green "Expanding Macros Pass #$($this.Pass)"
        $this.Pass += 1;

        $processedLines = @();
        $this.InMacro = $false;
        $macroExpansionOccured = $false;

        $Lines | ForEach-Object {
            if ($this.InMacro) {
                $this.TernaryVoid($_.Line -match '#ENDM', { $this.InMacro = $false; }, { $this.Macros[$CurrentMacroName].Replacement += $_.Line; });
            } else {
                if ($_.Line -match '#MACRO\s+(?<macroname>[a-z]*)\((?<parameters>[^)]*)\)') { # Check for a Macro 
                    $this.InMacro = $true;
                    $CurrentMacroName = $Matches['macroname']
                    $this.Macros.Add($Matches['macroname'], @{ Replacement = @(); Parameters = @(); });
                    $Matches['parameters'] -split ',' | ForEach-Object { $this.Macros[$CurrentMacroName].Parameters += $_; }
                } else {
                    if (($_.Line -replace ';.*', '') -match '@(?<macroname>[a-z]*)\((?<parameters>[^)]*)\)') {
                        $replacementCode = @();

                        if ($this.Macros.ContainsKey($Matches['macroname'])) {
                            $macroExpansionOccured = $true;
                            $this.Macros[$Matches['macroname']].Replacement | ForEach-Object {
                                $parameterIndex = 0;
                                Write-Host "$($Matches['parameters'])"
                                Write-Host "$($this.Macros[$Matches['macroname']].Parameters)"
                                $cl = $_;
                                #if ($Matches['parameters'] -ne '') {
                                    $Matches['parameters'] -split ',' | ForEach-Object {
                                        if ($parameterIndex -lt $this.Macros[$Matches['macroname']].Parameters.Count) {
                                            $parameterName = $this.Macros[$Matches['macroname']].Parameters[$parameterIndex];
                                            $cl = $cl.Replace('@' + $parameterName, $_);
                                        }
                                        $parameterIndex += 1;
                                    }
                                #}
                                Write-Host "   $($cl)";
                                $replacementCode += $cl;
                            }
                        } else {
                            $this.Output += "   Macro '$($Matches['macroname'])' not found."
                            $replacementCode += '; ' + $Matches[0];
                        }
        
                        if ($replacementCode.Count -eq 1) {
                            $processedLines += @{ Line = $_.Line.Replace($Matches[0], $replacementCode); Source =  $_.Source + '.Macro'; LineNumber = $_.LineNumber; };
                        } else {
                            $processedLines += @{ Line = $_.Line.Replace($Matches[0], $replacementCode[0]); Source = $_.Source + '.Macro'; LineNumber = $_.LineNumber; };
                            for($index = 1; $index -lt $replacementCode.Count ; $index += 1) {
                                $processedLines += @{ Line = $replacementCode[$index]; Source = $_.Source + '.Macro'; LineNumber = $_.LineNumber; };
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
        $lineNumber = 0;
        $lines = @();
        $stopLoading = $false;
        Get-Content $FileName | ForEach-Object {
            if ($stopLoading -or $_ -match '#STOP') {
                if ($_ -match '#CONTINUE') {
                    $stopLoading = $false;
                } else {
                    $stopLoading = $true;
                }
            } else {
                $lines += @{  Line = $_; LineNumber = $lineNumber; Source = $FileName; }
                $lineNumber += 1;
                if ($_ -match '.*#INCLUDE\s+([^\s]*).*') {
                    $includeFileName = $Matches[1];
                    $lines += @{ Line = "; Start Including '$($includeFileName)'"; Source = 'Assembler'; };
                    $this.LoadFile($includeFileName) | ForEach-Object { $lines += $_; }
                    $lines += @{ Line = "; Ending Including '$($includeFileName)'"; Source = 'Assembler'; };
                }
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
        $this.Address = 0;
        Write-Host -ForegroundColor Green "Assembly Pass #$($this.Pass)"
        $lines | ForEach-Object { $this.Assemble($_); }     
    }
    [void] Export($FileName, $PrePendStartingAddress) {
        $out = $this.Bytes;
        if ($PrePendStartingAddress) { $out = $this.WordToByteArray($this.StartingAddress) + $this.Bytes; }

        Remove-Item -Path $FileName -Force -ErrorAction SilentlyContinue
        if ((Get-Host).Version.Major -lt 6) {
            $out | ForEach-Object { Add-Content -Value ([byte]$_) -Path $FileName -Encoding Byte } # PowerShell 5.x -Encoding Byte
        } else {
            $out | ForEach-Object { Add-Content -Value ([byte]$_) -Path $FileName -AsByteStream } # PowerShell 6.x AsByteStream
        }
    }
    [void] UpsertVariable($Name, $Value) {
        $this.TernaryVoid($this.Variables.ContainsKey($Name), { }, { $this.Variables.Add($Name, $Value); });
    }
    [void] Assemble($CurrentLine) {
        $codes = @();
        $details = "";
        $dataOffset = 0;
        $parsedSyntax = $this.ParseSyntax($CurrentLine.Line);
        
        if ($parsedSyntax.Label -ne $null) {
            $this.UpsertVariable($parsedSyntax.Label, $this.Address);
        }
        
        if ($parsedSyntax.Left -ne $null) {
            $value = $this.EvaluateExpression($parsedSyntax.Right, $CurrentLine);

            if ($parsedSyntax.Left -eq '*') {
                $this.Address = $value;
                $this.StartingAddress = $value;
            } else {
                $this.UpsertVariable($parsedSyntax.Left, $value);
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
                    $offset = $this.EvaluateExpression($parsedSyntax.Operand, $CurrentLine) - ($this.Address + 2);

                    if ($offset -lt -128 -or $offset -gt 127) {
                        $this.Output += "   Branch too large...";
                        $this.Errors += @{ Message = "   Branch too large..."; Line = $CurrentLine; }
                        $offset = [byte]0;
                    }

                    $value = $this.TernaryObject($offset -lt 0, { $offset + 0x100 }, { $offset });
                    $codes += [byte]$value;
                    $details = $details.Replace('[r8]', '$' + $value.ToString('X2'));   
                }
            } elseif ($operation.AddressingMode -eq 'Data') {
                $dataOffset = $this.EvaluateExpression($parsedSyntax.Operand, $CurrentLine);
            } else {
                if ($operation.Bytes -eq 1) {
                    $value = if ($this.Pass -eq 1) { 0; } else { $this.EvaluateExpression($parsedSyntax.Operand, $CurrentLine); }
                    $codes += [byte]$value;
                    $details = $operation.Format.Replace('[d8]', '$'+ $value.ToString('X2'));
                }
                if ($operation.Bytes -eq 2) {
                    $value = if ($this.Pass -eq 1) { 0; } else { $this.EvaluateExpression($parsedSyntax.Operand, $CurrentLine); }
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
            $this.Output += ($line + "| " + $details).PadRight(30, ' ') + "| " + $CurrentLine.Line;
            $this.Bytes += $codes;
        }
        $this.Address += $codes.Count + $dataOffset;
    }
}

$assembler = [AssemblerV3]::new('6502');

$lines = $assembler.LoadFile($FileName);

# | ForEach-Object {
#     "$($_.Source).$($_.LineNumber) : $($_.Line)";
# }

# $assembler.Pass = 1;
# $lines = $assembler.ExpandMacros($lines);

# $lines | ForEach-Object {
#      "$($_.Source).$($_.LineNumber) : $($_.Line)";
# }


# RETURN;
$assembler.AssembleFile($FileName);
$assembler.Output

if ($DumpVariables) {
    $assembler.Variables.Keys | Sort-Object | ForEach-Object {
        "   $($_) = `$$($assembler.Variables[$_].ToString('X4'))"
    }
}

if ($assembler.Errors.Count -gt 0) {
    Write-Host -ForegroundColor Red "$($assembler.Errors.Count) Errors during assembly."
    $assembler.Errors | ForEach-Object {
        Write-Host -ForegroundColor Red "$($_.Line.Source) : $($_.Line.LineNumber) : $($_.Line.Line) => $($_.Message)"
    }
}

if ($GeneratePRG -or $ExecutePRG) {
    $prgFileName = $FileName.Replace('.asm', '.prg')

    $assembler.Export($prgFileName, $true);
    if ($ExecutePRG) {
        . "C:\Program Files\GTK3VICE-3.7-win64\bin\x64sc.exe" $prgFileName
    }
}

if ($GenerateOUT) {
    $outFileName = $FileName.Replace('.asm', '.out');
    $assembler.Export($outFileName, $false);
}

# 285 Lines Before Optimizations
# Added FILL support...