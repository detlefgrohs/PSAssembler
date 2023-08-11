param (
    $FileName,
    [Switch]$GeneratePRG,
    [Switch]$GenerateOUT,
    [Switch]$ExecutePRG,
    [Switch]$DumpVariables,
    [Switch]$DumpLabels,
    [Switch]$DumpMacros,
    [Switch]$IncludeHFilesInOutput,
    [Switch]$GenerateLST,
    [Switch]$VerboseLST,
    [Switch]$DumpRegions,
    [Switch]$C128
)

$Global:AssemblerPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition);

enum PassType {
    Collection = 1
    Allocation = 2
    Optimization = 3
    Relocation = 4
    Assembly = 5
}

class AssemblerV3 {
    $OPCodes = [Ordered]@{};
    $Bytes = @();
    $Variables = @{};
    $Output = @();
    $SyntaxPattern = $null;
    [PassType]$Pass = [PassType]::Collection;
    $Macros = @{};
    [UInt16]$Address;
    [UInt16]$StartingAddress;
    $Errors = @();
    $VerboseLST = $false;
    $LastLabel = "";
    $Stats = [System.Collections.ArrayList]@();
    $NamedStats = @{};
    $CycleTime = 1 / 1020000;
    $Regions = @{};
    $CurrentRegion = '<root>'
    $LoadedBinary = 0;

    # For Report
    $StartDTM = [DateTime]::Now;
    $EndDTM = [DateTime]::Now;
    $LoadedLines = 0;
    $AssembledLines = 0;

    $MainAssemblyFileName

    $ReservedVariableNames = @( "if", "else", "lt", "gt", "eq", "ne", "not", "and", "or" )

    AssemblerV3([string]$CPU = '6502') {
        (Get-Content -Path "$($Global:AssemblerPath)\Opcodes.$($CPU).json" | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $this.OPCodes.Add($_.Name, $_.Value); }
        $this.CreateSyntaxPattern();
    }
    [void] CreateSyntaxPattern() {
        $patterns = [ordered]@{ directive = '\s*((?<label>[^\s]*):)?\s*#(?<command>[^\s]*)(?<parameters>[^;]*)?';
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
        $expressionVariables = @{};
        ([RegEx]'[$]?[\w.]+').Matches($Expression -replace '''.''', '') | ForEach-Object {
            $variableName = $_.Value;
            if (-not (($variableName.StartsWith('$')) -or ($variableName -match '^[0-9]*$'))) {
                if (-not $this.ReservedVariableNames.Contains($variableName)) {
                    if ($variableName.StartsWith('.')) { 
                        $variableName = $this.LastLabel + $variableName;
                    }
                    if (-not $expressionVariables.Contains($variableName)) { 
                        $expressionVariables.Add($variableName, $_.Value);
                    }
                }
            }
        }
        $expressionVariables.Keys | Sort-Object { $_.Length } -Descending | ForEach-Object {
            $variableName = $_;
            $replacementText = $expressionVariables[$variableName];

            if ($this.Variables.ContainsKey($variableName)) {
                if ($this.Pass -eq [PassType]::Allocation) {
                    $this.Variables[$variableName].ReferenceCount += 1;

                    if (-not $this.Variables[$variableName].CalledFromRegion.Contains($this.CurrentRegion)) {
                        $this.Variables[$variableName].CalledFromRegion += $this.CurrentRegion;
                    }
                }
                $Expression = $Expression.Replace($replacementText, $this.Variables[$variableName].Value); 
            } else {
                switch ($variableName) {
                    "ORG" { $Expression = $Expression.Replace($variableName, $this.StartingAddress); }
                    "CURADDR" { $Expression = $Expression.Replace($variableName, $this.Address); }
                    "BYTESLEN" { $Expression = $Expression.Replace($variableName, $this.Bytes.Length); }
                    "BYTES" { $Expression = $Expression.Replace($variableName, 'this.Bytes'); }
                    default {
                        $Expression = $Expression.Replace($variableName, '');
                        if ($this.Pass -eq [PassType]::Assembly) {
                            $this.Output += @{ Line = "   Variable not found: '$($variableName)'"; Type = "Error"; Source = "" }
                            $this.Errors += @{ Message = "   Variable not found: '$($variableName)'"; Line = $Line }
                        }
                    }
                }
            }
        }
        if ($Expression -eq '') { return [uint16]0; }

        $Expression = $Expression.Replace('$', '0x');
        $Expression = $Expression.Replace('this', '$this');  # Hacky...
        $Expression = $Expression -replace '%([0-1]+)', '[Convert]::ToInt16(''$1'', 2)'
        $Expression = $Expression -replace '''(.)''', '[byte][char]''$1'''
        $Expression = $Expression -replace '>>', ' -shr '
        $Expression = $Expression -replace '<<', ' -shl '
        $Expression = $Expression -replace '\|', ' -bor '
        $Expression = $Expression -replace '\&', ' -band '

        try { return [uint16]$(Invoke-Expression $Expression); }
        catch {
            if ($this.Pass -eq [PassType]::Assembly) {
                $this.Output += @{ Line = "   Error in Expression: '$($expression)'"; Type = "Error"; Source = "" }
                $this.Errors += @{ Message = "   Error in Expression: '$($expression)'"; Line = $Line }
            }
            return [uint16]0; 
        }
    }
    [array] ExecuteCode($Lines) {
        Write-Host -ForegroundColor Green "$([DateTime]::Now.ToString('HH:mm:ss')) : Executing Code"
        
        $processedLines = @();
        $inCodeBlock = $false;
        $codeLines = @();
        $codeLineRef = $null;

        $Lines | ForEach-Object {
            $currentLine = $_;

            if ($inCodeBlock) {
                if ($currentLine.Line -match '#ENDC') {
                    try {
                        Invoke-Expression ($codeBlock = $codeLines -join "`r`n") | ForEach-Object {
                            $processedLines += @{ Line = $_; Source =  $currentLine.Source + '.Code'; LineNumber = $macroLine.LineNumber; };
                        }
                    } catch {
                        $this.Errors += @{ Message = "   Code Exception '$($_)'"; Line = $codeLineRef; }
                    }
                    $inCodeBlock = $false;
                    $codeLines = @();
                } else {
                    $codeLines += $currentLine.Line;
                }
            } else {
                if ($currentLine.Line -match '#CODE') {
                    $inCodeBlock = $true;
                    $codeLineRef = $currentLine;
                } else {
                    $processedLines += $currentLine;
                }
            }
        }
        return $processedLines;
    }
    [array] ExpandMacros($Lines, $macroPass) {
        Write-Host -ForegroundColor Green "$([DateTime]::Now.ToString('HH:mm:ss')) : Expanding Macros Pass #$($macroPass)"

        $processedLines = @();
        $inMacro = $false;
        $continueExpansion = $false;

        $Lines | ForEach-Object {
            $currentLine = $_;
            if ($inMacro) {
                if ($currentLine.Line -match '#ENDM') {
                    $inMacro = $false;
                } else {
                    $this.Macros[$CurrentMacroName].Replacement += $currentLine.Line;
                }
            } else {
                if ($currentLine.Line -match '#MACRO\s+(?<macroname>[a-z_][a-z0-9_]*)\((?<parameters>[^\)]*)\)') { # Check for a Macro 
                    $inMacro = $true;
                    $CurrentMacroName = $Matches['macroname']
                    $this.Macros.Add($Matches['macroname'], @{ Replacement = @(); Parameters = @(); });
                    $Matches['parameters'] -split ',' | ForEach-Object { $this.Macros[$CurrentMacroName].Parameters += $_.Trim(); }
                } else {
                    if (($currentLine.Line -replace ';.*', '') -match '@(?<macroname>[a-z_][a-z0-9_]*)\((?<parameters>.*)\)') {
                        if (-not $this.Macros.ContainsKey($Matches['macroname'])) {
                            if ($macroPass -eq 1) { # Macro not found on 1st pass so continue...
                                $continueExpansion = $true;
                                $processedLines += $currentLine
                            } else {
                                $this.Output += @{ Line = "   Macro '$($Matches['macroname'])' not found."; Type = "Error"; Source = "" }
                                $this.Errors += @{ Message = "   Macro '$($Matches['macroname'])' not found."; Line = $currentLine; }
                                $processedLines += @{ Line = $currentLine.Line.Replace($Matches[0], '; ' + $Matches[0]); Source =  $currentLine.Source + '.Macro'; LineNumber = $currentLine.LineNumber; };
                            }    
                        } else {
                            $replacementCode = @();

                            $continueExpansion = $true;
                            $macroId = 'MacroId' + $currentLine.LineNumber.ToString('000');
                            $this.Macros[$Matches['macroname']].Replacement | ForEach-Object {
                                $parameterIndex = 0;
                                $replacementLine = $_;
                                $Matches['parameters'] -split ',' | ForEach-Object {
                                    if ($parameterIndex -lt $this.Macros[$Matches['macroname']].Parameters.Count) {
                                        $parameterName = $this.Macros[$Matches['macroname']].Parameters[$parameterIndex];
                                        $replacementLine = $replacementLine.Replace('@MacroId', $macroId);
                                        $replacementLine = $replacementLine.Replace('@' + $parameterName, $_.Trim());
                                        $replacementLine = $replacementLine.Replace('~' + $parameterName + '~', $_.Trim());
                                    }
                                    $parameterIndex += 1;
                                }
                                $replacementCode += $replacementLine;
                            }
                            if ($this.VerboseLST) {
                                $processedLines += @{ Line = '; ' + $currentLine.Line + ' ; @' + $CurrentMacroName; 
                                                      Source = $currentLine.Source; LineNumber = $currentLine.LineNumber; }
                            }
                            if ($replacementCode.Count -eq 1) {
                                $processedLines += @{ Line = $currentLine.Line.Replace($Matches[0], $replacementCode[0]); Source =  $currentLine.Source + '.Macro'; LineNumber = $currentLine.LineNumber; };
                            } else {
                                $processedLines += @{ Line = $currentLine.Line.Replace($Matches[0], $replacementCode[0]); Source = $currentLine.Source + '.Macro'; LineNumber = $currentLine.LineNumber; };
                                for($index = 1; $index -lt $replacementCode.Count ; $index += 1) {
                                    $processedLines += @{ Line = $replacementCode[$index]; Source = $currentLine.Source + '.Macro'; LineNumber = $currentLine.LineNumber; };
                                }
                            }
                        } 
                    } else { # Nothing to do so pass-thru
                        $processedLines += $currentLine
                    }
                }
            }
        }
        if ($continueExpansion) {   # Keep processing until no macro expansions...
            return $this.ExpandMacros($processedLines, $macroPass + 1); 
        }
        return $processedLines;
    }
    [array] LoadFile($FileName) {
        Write-Host -ForegroundColor Green "$([DateTime]::Now.ToString('HH:mm:ss')) : Loading file '$($FileName)'"
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
                if (($_ -replace ';.*', '') -match '.*#INCLUDE\s+([^\s]*).*') {
                    $includeFileName = $Matches[1];
                    $this.LoadFile([IO.Path]::Combine([IO.Path]::GetDirectoryName($FileName), $includeFileName)) | ForEach-Object { $lines += $_; }
                }
                $lineNumber += 1;
            }
        }
        return $lines
    }
    [array] WordToByteArray($Word) {
        return @(($Word -band 0x00FF), (( $Word -band 0xFF00 ) -shr 8));
    }
    [array] FindRegionsToInclude($RegionsToInclude) {
        $newRegionFound = $false;
    
        $RegionsToInclude | ForEach-Object {
            $regionToFind = $_;

            $this.Variables.Keys | ForEach-Object {
                if ($this.Variables[$_].CalledFromRegion.Contains($regionToFind)) {
                    if (-not $RegionsToInclude.Contains($this.Variables[$_].Region)) {
                        $RegionsToInclude += $this.Variables[$_].Region;
                        $newRegionFound = $true;
                    }
                }
            }
        }
        if ($newRegionFound) { return $this.FindRegionsToInclude($RegionsToInclude); }
        return $RegionsToInclude;
    }
    [array] EmptyLineReduction($Lines) {
        $cleanedLines = @();
        $lastLineWasEmpty = $false;

        $lines | ForEach-Object {
            if ($null -ne $_.Line -and $_.Line.Trim() -eq '') {
                if (-not $lastLineWasEmpty) {
                    $cleanedLines += $_;
                }
                $lastLineWasEmpty = $true;
            } else {
                $cleanedLines += $_;
                $lastLineWasEmpty = $false;
            }
        }
        return $cleanedLines;
    }
    [array] Optimize($Lines) {
        $regionsToInclude = $this.FindRegionsToInclude(@('<root>'));

        $regionsToInclude | ForEach-Object {
            if ($this.Regions.ContainsKey($_)) {
                $this.Regions[$_].ReferenceCount = 1;
            }
        }
        $includingLines = $true;
        $optimizedLines = @();
        $Lines | ForEach-Object {
            $currentLine = $_;
            $parsedSyntax = $this.ParseSyntax($currentLine.Line);
            if ($null -ne $parsedSyntax.Command) {
                switch ($parsedSyntax.Command) {
                    "REGION" {
                        $region = $parsedSyntax.Parameters;
                        if (-not $regionsToInclude.Contains($region)) {
                            Write-Host "   Removing Region '$($region)'"
                            $includingLines = $false;
                        }
                    }
                    "ENDR" {
                        $includingLines = $true;
                    }
                    default { if ($includingLines) { $optimizedLines += $currentLine; } }
                }
            } else {
                if ($includingLines ) { $optimizedLines += $currentLine; }
            }
        }
        return $optimizedLines;
    }
    [void] AssembleFile($FileName) {
        $this.MainAssemblyFileName = $FileName;

        $this.StartDTM = [DateTime]::Now;
        Write-Host -ForegroundColor Yellow "$([DateTime]::Now.ToString('HH:mm:ss')) : Starting Assembly..."
        $lines = $this.LoadFile($FileName);
        $this.LoadedLines = $lines.Count;

        $lines = $this.ExecuteCode($lines);
        $lines = $this.ExpandMacros($lines, 1);

        $this.Assemble([PassType]::Collection, $lines);
        $this.Assemble([PassType]::Allocation, $lines);

        $this.Pass = [PassType]::Optimization;
        Write-Host -ForegroundColor Green "$([DateTime]::Now.ToString('HH:mm:ss')) : Assembly Pass => $($this.Pass)"
        $lines = $this.Optimize($lines);

        $this.Assemble([PassType]::Relocation, $lines);

        $lines = $this.EmptyLineReduction($lines);

        $this.AssembledLines = 0;
        $this.Stats.Add(@{ Bytes = 0; MinCycles = 0; MaxCycles = 0; });
        $this.Assemble([PassType]::Assembly, $lines);
        
        Write-Host -ForegroundColor Yellow "$([DateTime]::Now.ToString('HH:mm:ss')) : Completed Assembly..."
        $this.EndDTM = [DateTime]::Now;
    }
    [void] Export($FileName, $PrePendStartingAddress) {
        $exportStartDTM = [DateTime]::Now
        $out = $this.Bytes;
        if ($PrePendStartingAddress) { $out = $this.WordToByteArray($this.StartingAddress) + $this.Bytes; }

        Remove-Item -Path $FileName -Force -ErrorAction SilentlyContinue
        [System.IO.File]::WriteAllBytes("$($PWD)\$($FileName)", $out);

        $elapsed = [DateTime]::Now - $exportStartDTM;
        Write-Host "   Wrote to '$($FileName)' in $($elapsed.TotalSeconds) seconds."
    }
    [void] UpsertVariable($Name, $Value, $Type) {
        if ($this.Variables.ContainsKey($Name)) {
            # ToDo - Handle changes because they will change later base on optimization...
            $oldValue = $this.Variables[$Name].Value;
            if ($oldValue -ne $Value) {
                Write-Host "   $($Name) Relocated from '`$$($oldValue.ToString('X4'))' to '`$$($Value.ToString('X4'))'"
                $this.Variables[$Name].Value = $Value;
            }
        } else {
            $this.Variables.Add($Name, @{ Value = $Value; Type = $Type; ReferenceCount = 0; 
                                          Region = $this.CurrentRegion; CalledFromRegion = @(); }); 
        }
    }
    [void] Assemble($pass, $lines) {
        Write-Host -ForegroundColor Green "$([DateTime]::Now.ToString('HH:mm:ss')) : Assembly Pass => $($pass)"
        $this.Address = 0;
        $this.Pass = $pass;
        $lines | ForEach-Object { $this.AssembleLine($_); }
    }
    [void] AssembleLine($CurrentLine) {
        $codes = @();
        $details = "";
        $dataOffset = 0;
        $parsedSyntax = $this.ParseSyntax($CurrentLine.Line);
        $skipOutput = $false;

        try {
            if ($null -ne $parsedSyntax.Label) {
                $label = $parsedSyntax.Label;
                if ($label.StartsWith('.')) {
                    $label = $this.LastLabel + $label;
                } else {
                    $this.LastLabel = $label;
                }
                $this.UpsertVariable($label, $this.Address, "Label");
            }
            
            if ($null -ne $parsedSyntax.Left) {
                $value = $this.EvaluateExpression($parsedSyntax.Right, $CurrentLine);

                if ($parsedSyntax.Left -eq '*') {
                    $this.Address = $value;
                    $this.StartingAddress = $value;
                } else {
                    $this.UpsertVariable($parsedSyntax.Left, $value, "Variable");
                }
            }
            if ($null -ne $parsedSyntax.Command) {
                switch ($parsedSyntax.Command) {
                    "REGION" {
                        $this.CurrentRegion = $parsedSyntax.Parameters;
                        if ($this.Pass -eq [PassType]::Collection) {
                            $this.Regions.Add($this.CurrentRegion, @{
                                Region = $this.CurrentRegion;
                                StartAddress = $this.Address;
                                EndAddress = 0;
                                ReferenceCount = 0;
                            });
                        }
                    }
                    "ENDR" {
                        if ($this.Pass -eq [PassType]::Collection) {
                            $this.Regions[$this.CurrentRegion].EndAddress = $this.Address - 1;
                        }
                        $this.CurrentRegion = '<root>';
                    }
                    "STATS" {
                        if ($this.Pass -eq [PassType]::Assembly) {
                            $currentStats = $this.Stats[$this.Stats.Count - 1];
                            $this.Output += @{ Line = "                              | ; STATS => Bytes: $($currentStats.Bytes)   MinCycles: $($currentStats.MinCycles.ToString('#,#'))   MaxCycles: $($currentStats.MaxCycles.ToString('#,#'))"; 
                                            Type = "Stats"; Source = "Stats" }
                            $skipOutput = $true;
                        }
                    }
                    "STATS.DETAIL" {
                        if ($this.Pass -eq [PassType]::Assembly) {
                            $currentStats = $this.Stats[$this.Stats.Count - 1];
                            $this.Output += @{ Line = "                              | ; STATS => Bytes: $($currentStats.Bytes)   MinCycles: $($currentStats.MinCycles.ToString('#,#'))   MaxCycles: $($currentStats.MaxCycles.ToString('#,#'))"; 
                                            Type = "Stats"; Source = "Stats" }
                            $minCycleTime = $currentStats.MinCycles * $this.CycleTime;
                            $maxCycleTime = $currentStats.MaxCycles * $this.CycleTime;
                            $this.Output += @{ Line = "                              | ;          MinCycleTime: $(($minCycleTime * 1000).ToString('#,#.00')) mSec   MaxCycleTime: $(($maxCycleTime * 1000).ToString('#,#.00')) mSec"; 
                                            Type = "Stats"; Source = "Stats" }
                            $this.Output += @{ Line = "                              | ;          Max FPS: $((1 / $minCycleTime).ToString('#,#.00'))   Min FPS: $((1 / $maxCycleTime).ToString('#,#.00'))"; 
                                            Type = "Stats"; Source = "Stats" }
                            $skipOutput = $true;
                        }
                    }
                    "STATS.PUSH" {
                        if ($this.Pass -eq [PassType]::Assembly) {
                            $this.Stats.Add(@{ Bytes = 0; MinCycles = 0; MaxCycles = 0; });
                            $skipOutput = $true;
                        }
                    }
                    "STATS.POP" {
                        if ($this.Pass -eq [PassType]::Assembly) {
                            if ($this.Stats.Count -ge 2) {
                                $currentStats = $this.Stats[$this.Stats.Count - 2];
                                $lastStats = $this.Stats[$this.Stats.Count - 1];

                                $currentStats.Bytes += $lastStats.Bytes;
                                $currentStats.MinCycles += $lastStats.MinCycles;
                                $currentStats.MaxCycles += $lastStats.MaxCycles;

                                $this.Stats.RemoveAt($this.Stats.Count - 1);
                                $skipOutput = $true;
                            }
                        }
                    }
                    "STATS.LOOP" {
                        if ($this.Pass -eq [PassType]::Assembly) {
                            $loop = $this.EvaluateExpression($parsedSyntax.Parameters, $currentLine);
                            $currentStats = $this.Stats[$this.Stats.Count - 1];
                            $currentStats.MinCycles *= $loop;
                            $currentStats.MaxCycles *= $loop;
                            $skipOutput = $true;
                        }
                    }
                    "STATS.SAVE" {
                        if ($this.Pass -eq [PassType]::Assembly) {
                            $this.NamedStats.Add($parsedSyntax.Parameters.Trim(), $this.Stats[$this.Stats.Count - 1]);
                            $skipOutput = $true;
                        }
                    }
                    { $_ -eq "TEXT" -or $_ -eq "TEXTZ" -or $_ -eq "ASCII" -or $_ -eq "ASCIIZ" } {
                        if ($parsedSyntax.Parameters -match '"(.*)"') {
                            if ($this.Pass -eq [PassType]::Assembly) {
                                $this.Output += @{ Line = ("$($this.Address.ToString('X4')) [      ]             | " + $details).PadRight(26, ' ') + $CurrentLine.Line; Type = "Code"; Source = $CurrentLine.Source; }
                            }
                            for($index = 0; $index -lt $Matches[1].Length; $index += 1) {
                                $charValue = [byte]$Matches[1][$index];
                                if ($_ -eq "TEXT" -or $_ -eq "TEXTZ") {
                                    if ($charValue -ge 64 -and $charValue -le 95) { $charValue -= 64; } 
                                }
                                $this.AssembleLine(@{ Line = "   DATA.b `$$($charValue.ToString('X2'))"; Source = $CurrentLine.Source; LineNumber = $CurrentLine.LineNumber });
                            }
                            if ($_ -eq "TEXTZ" -or $_ -eq "ASCIIZ") {
                                $this.AssembleLine(@{ Line = "   DATA.b `$00"; Source = $CurrentLine.Source; LineNumber = $CurrentLine.LineNumber });
                            }
                            $skipOutput = $true;
                        }
                    }
                    "ASSERT" {
                        if ($this.Pass -eq [PassType]::Assembly) {
                            if ($this.EvaluateExpression($parsedSyntax.Parameters, $currentLine) -eq 0) {
                                $this.Output += @{ Line = "   Failed assertion ($($parsedSyntax.Parameters))"; Type = "Error"; Source = "" }
                                $this.Errors += @{ Message = "   Failed assertion ($($parsedSyntax.Parameters))"; Line = $CurrentLine; }                            
                            } 
                        }
                    }
                    "LOADBINARY" {
                        $binaryFileName = [IO.Path]::Combine([IO.Path]::GetDirectoryName($this.MainAssemblyFileName), $parsedSyntax.Parameters);
                        $binaryBytes = [System.IO.File]::ReadAllBytes("$($PWD)\$($binaryFileName)");

                        $dataOffset = $binaryBytes.Count;
                        if ($this.Pass -eq [PassType]::Assembly) {
                            $this.LoadedBinary += $binaryBytes.Count;
                            $this.Bytes += $binaryBytes;
                            $this.Output += @{ Line = ("$($this.Address.ToString('X4')) [      ]             | " + $details).PadRight(26, ' ') + $CurrentLine.Line; Type = "Code"; Source = $CurrentLine.Source; }
                            $this.Output += @{ Line = "$($this.Address.ToString('X4')) [      ]             | ; '$($binaryFileName)' : $($dataOffset) bytes"; Type = "BinaryFile"; Source = "" }
                        }
                        $skipOutput = $true;
                    }
                }
            } elseif ($null -ne $parsedSyntax.Mnemonic) {
                $this.AssembledLines += 1;
                $operation = $this.OPCodes[$parsedSyntax.Mnemonic];

                if ($null -ne $operation) {
                    $details = $operation.Format;
                    
                    if ($operation.Opcode -ne '') { $codes += [byte]$operation.Opcode }

                    if ($operation.AddressingMode -eq 'Relative') {
                        if ($this.Pass -ne [PassType]::Assembly) {
                            $codes += [byte]0x00;
                        } else {
                            $offset = $this.EvaluateExpression($parsedSyntax.Operand, $CurrentLine) - ($this.Address + 2);

                            if ($offset -lt -128 -or $offset -gt 127) {
                                $this.Output += @{ Line = "   Branch too large..."; Type = "Error"; Source = "" }
                                $this.Errors += @{ Message = "   Branch too large..."; Line = $CurrentLine; }
                                $offset = [byte]0;
                            }

                            $value = $offset;
                            if ($offset -lt 0) { $value += 0x100; }

                            $codes += [byte]$value;
                            $details = $details.Replace('[r8]', '$' + $value.ToString('X2'));   
                        }
                    } elseif ($operation.AddressingMode -eq 'Data') {
                        $fillBytes = $this.EvaluateExpression($parsedSyntax.Operand, $CurrentLine);
                        if ($parsedSyntax.Mnemonic -eq 'PAD') {
                            for ($index = 0; $index -lt $fillBytes; $index += 1) {
                                $codes += [byte]0xEA    # NOP
                            }
                        } else {
                            $dataOffset = $fillBytes;
                        }
                    } else {
                        if ($operation.Bytes -eq 1) {
                            $value = if ($this.Pass -eq [PassType]::Collection) { 0; } else { 
                                if ($null -eq $parsedSyntax.Operand) {
                                    if ($this.Pass -eq [PassType]::Assembly) {
                                        $this.Output += @{ Line = "   Missing Byte Operand.."; Type = "Error"; Source = "" }
                                        $this.Errors += @{ Message = "   Missing Byte Operand..."; Line = $CurrentLine; }
                                    }
                                    0x00;
                                } else {
                                    $this.EvaluateExpression($parsedSyntax.Operand, $CurrentLine);
                                }
                            }
                            $codes += [byte]$value;
                            $details = $operation.Format.Replace('[d8]', '$'+ $value.ToString('X2'));
                        }
                        if ($operation.Bytes -eq 2) {
                            $value = if ($this.Pass -eq [PassType]::Collection) { 0; } else { 
                                if ($null -eq $parsedSyntax.Operand) {
                                    if ($this.Pass -eq [PassType]::Assembly) {
                                        $this.Output += @{ Line = "   Missing Word Operand.."; Type = "Error"; Source = "" }
                                        $this.Errors += @{ Message = "   Missing Word Operand..."; Line = $CurrentLine; }
                                    }
                                    0x0000;
                                } else {
                                    $this.EvaluateExpression($parsedSyntax.Operand, $CurrentLine);
                                }
                            }
                            $codes += ($this.WordToByteArray($value))
                            $details = $details.Replace('[a16]', '$'+ $value.ToString('X4'));
                        }
                    }

                    if ($this.Pass -eq [PassType]::Assembly) {
                        $currentStats = $this.Stats[$this.Stats.Count - 1];
                        $currentStats.Bytes += $codes.Count + $dataOffset;
                        $currentStats.MinCycles += $operation.MinCycles;
                        $currentStats.MaxCycles += $operation.MaxCycles;
                    }
                } else {
                    if ($this.Pass -eq [PassType]::Assembly) {
                        $this.Output += @{ Line = "   Parsing Error.."; Type = "Error"; Source = "" }
                        $this.Errors += @{ Message = "   Parsing Error..."; Line = $CurrentLine; }
                    }
                }
            }
        } catch {
            if ($this.Pass -eq [PassType]::Assembly) {
                $this.Output += @{ Line = "   Assembly Error: $($_)"; Type = "Error"; Source = "" }
                $this.Errors += @{ Message = "   Assembly Error: $($_)"; Line = $CurrentLine; }
            }
        }
        if ($this.Pass -eq [PassType]::Assembly -and -not $skipOutput) {
            $line = "$($this.Address.ToString('X4')) [";
            for ($index = 0; $index -lt 3; $index += 1) {
                if ($index -lt $codes.Count) { $line += "$($codes[$index].ToString('X2'))"; } else { $line += "  "; }
            }
            $this.Output += @{ Line = ($line + "] " + $details).PadRight(26, ' ') + "| " + $CurrentLine.Line; 
                            Type = "Code"; Source = $CurrentLine.Source; }
            $this.Bytes += $codes;
        }
        $this.Address += $codes.Count + $dataOffset;
    }
    [void] Report() {
        Write-Host -ForegroundColor Cyan "Assembly Report:"
        Write-Host -ForegroundColor Cyan "   Assembly Start  : $($this.StartDTM.ToString())"
        Write-Host -ForegroundColor Cyan "   Assembly End    : $($this.EndDTM.ToString())"
        $elapsed = $this.EndDTM - $this.StartDTM;
        Write-Host -ForegroundColor Cyan "   Elapsed Seconds : $($elapsed.TotalSeconds.ToString('0.00'))"
        Write-Host -ForegroundColor Cyan "   Loaded Lines    : $($this.LoadedLines.ToString('#,0'))"
        Write-Host -ForegroundColor Cyan "   Loaded Bytes    : $($this.LoadedBinary.ToString('#,0'))"
        Write-Host -ForegroundColor Cyan "   Assembled Lines : $($this.AssembledLines.ToString('#,0'))"
        $assembledBytes = $this.Bytes.Count - $this.LoadedBinary;
        Write-Host -ForegroundColor Cyan "   Assembled Bytes : $($assembledBytes.ToString('#,0'))"
        Write-Host -ForegroundColor Cyan "   Total Bytes     : $($this.Bytes.Count.ToString('#,0'))"
        Write-Host -ForegroundColor Cyan "   Starting Address: `$$($this.StartingAddress.ToString('X4'))"
        Write-Host -ForegroundColor Cyan "   Ending Address  : `$$(($this.StartingAddress + $this.Bytes.Count).ToString('X4'))"
        Write-Host -ForegroundColor Cyan "   Labels/Variables: $($this.Variables.Count.ToString('#,0'))"
        Write-Host -ForegroundColor Cyan "   Macros          : $($this.Macros.Count.ToString('#,0'))"

        $optimizedBytes = 0;
        $this.Regions.Keys | ForEach-Object {
            if ($this.Regions[$_].ReferenceCount -eq 0) {
                $size = ($assembler.Regions[$_].EndAddress - $assembler.Regions[$_].StartAddress) + 1;
                $optimizedBytes += $size;
            }
        }
        Write-Host -ForegroundColor Cyan "   Optimized Out   : $($optimizedBytes.ToString('#,0'))"

        if ($this.NamedStats.Length -gt 0) {
            $this.NamedStats.Keys | Sort-Object | ForEach-Object {
                $currentStats = $this.NamedStats[$_];
                Write-Host -ForegroundColor Cyan "Stat: '$($_)'"
                Write-Host -ForegroundColor Cyan "   Bytes: $($currentStats.Bytes)   MinCycles: $($currentStats.MinCycles.ToString('#,#'))   MaxCycles: $($currentStats.MaxCycles.ToString('#,#'))"
                $minCycleTime = $currentStats.MinCycles * $this.CycleTime;
                $maxCycleTime = $currentStats.MaxCycles * $this.CycleTime;
                Write-Host -ForegroundColor Cyan "   MinCycleTime: $(($minCycleTime * 1000).ToString('#,#.00')) mSec   MaxCycleTime: $(($maxCycleTime * 1000).ToString('#,#.00')) mSec"
                Write-Host -ForegroundColor Cyan "   Max FPS: $((1 / $minCycleTime).ToString('#,#.00'))   Min FPS: $((1 / $maxCycleTime).ToString('#,#.00'))"; 
            }
        }
    }
}

$assembler = [AssemblerV3]::new('6502');
$assembler.VerboseLST = $VerboseLST;
$assembler.AssembleFile([IO.Path]::Combine($Global:ScriptRoot, $FileName));

if ($GenerateLST) {
    $assembler.Output | ForEach-Object {
        if ($IncludeHFilesInOutput -or ($_.Source -ne $null -and -not $_.Source.EndsWith('.h'))) {
            $_.Line
        }
    }
}

$assembler.Report();

if ($DumpVariables) {
    Write-Host -ForegroundColor Yellow "Variables:"
    $assembler.Variables.Keys | Sort-Object | ForEach-Object {
        if ($assembler.Variables[$_].Type -eq "Variable") {
            "   $($_) = `$$($assembler.Variables[$_].Value.ToString('X4')): $($assembler.Variables[$_].ReferenceCount)";
        }
    }
}

if ($DumpLabels) {
    Write-Host -ForegroundColor Yellow "Labels:"
    $assembler.Variables.Keys | Sort-Object | ForEach-Object {
        if ($assembler.Variables[$_].Type -eq "Label") {
            "   $($_) = `$$($assembler.Variables[$_].Value.ToString('X4')) : $($assembler.Variables[$_].ReferenceCount) => $($assembler.Variables[$_].Region) ; $($assembler.Variables[$_].CalledFromRegion -join ',')";
        }
    }
}

if ($DumpRegions) {
    Write-Host -ForegroundColor Yellow "Regions:"
    $assembler.Regions.Keys | Sort-Object | ForEach-Object {
        $size = ($assembler.Regions[$_].EndAddress - $assembler.Regions[$_].StartAddress) + 1;
        "   $($_) = `$$($assembler.Regions[$_].StartAddress.ToString('X4')) - `$$($assembler.Regions[$_].EndAddress.ToString('X4')) Size $($size): $($assembler.Regions[$_].ReferenceCount)";
    }
}

if ($DumpMacros) {
    Write-Host -ForegroundColor Yellow "Macros:"
    $assembler.Macros.Keys | Sort-Object | ForEach-Object {
        $macro = $assembler.Macros[$_];
        $parameters = $macro.Parameters -Join ','
        "   $($_)($($parameters))"
        $macro.Replacement | ForEach-Object {
            "   => $($_)"
        }
    }
}

if ($assembler.Errors.Count -gt 0) {
    Write-Host -ForegroundColor Red "$([DateTime]::Now.ToString('HH:mm:ss')) : $($assembler.Errors.Count) Error(s) during assembly."
    $assembler.Errors | ForEach-Object {
        Write-Host -ForegroundColor Red "$($_.Line.Source) : $($_.Line.LineNumber) : $($_.Line.Line) => $($_.Message)"
    }
    exit 1;
}

if ($GenerateOUT) {
    $outFileName = $FileName.Replace('.asm', '.out');
    Write-Host -ForegroundColor Yellow "$([DateTime]::Now.ToString('HH:mm:ss')) : Writing '$($outFileName)'"
    $assembler.Export($outFileName, $false);
}

if ($GeneratePRG -or $ExecutePRG) {
    $prgFileName = $FileName.Replace('.asm', '.prg').ToLower();
    Write-Host -ForegroundColor Yellow "$([DateTime]::Now.ToString('HH:mm:ss')) : Writing '$($prgFileName)'"
    $assembler.Export($prgFileName, $true);
    if ($ExecutePRG) {
        Write-Host -ForegroundColor Yellow "Launching'$($prgFileName)' in Vice."
        if ($C128) {
            (. "C:\Program Files\GTK3VICE-3.7-win64\bin\x128.exe" $prgFileName) | Out-Null
        } else {
            (. "C:\Program Files\GTK3VICE-3.7-win64\bin\x64sc.exe" $prgFileName) | Out-Null
        }
    }
}

exit 0;