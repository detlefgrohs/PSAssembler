

class Assembler {
    $OPCodes = [Ordered]@{};
    $Bytes = @();
    $Variables = @{};
    $Output = @();
    
    [UInt16]$Address;
    [UInt16]$StartingAddress = $null;


    Assembler([string]$CPU = '6502') {
        (Get-Content "Opcodes.$($CPU).json" | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $this.OPCodes.Add($_.Name, $_.Value); }
    }

    [void] Assemble($syntax) { $this.Assemble($syntax, $null); }
    [void] Assemble($syntax, $originalSyntax) {
        $codes = @()
        $details = "";

        if ($syntax -match '^\s*(?<left>[^\s]*)\s*=\s*(?<right>.*)\s*$') {
            $left = $Matches['left'];
            $right = $Matches['right'];

            #Write-Host "'$($left)'"
            #Write-Host "'$($right)'"

            if ($left -eq '*') {
                $this.Address = $this.EvaluateExpression($right);
                #if ($this.StartingAddress -eq $null) {
                    $this.StartingAddress = $this.Address;
                #} else {
                    # What do I do if they decide to change the address?
                #}
            } else {
                $this.Variables.Add($left, $this.EvaluateExpression($right));
            }
        } else {
            $matched = $false;

            foreach ($mnemonic in $this.OPCodes.Keys) {
                # '([-]?[\$]?[0-9a-fA-F]+)'
                $mnemonicPattern = "^(?<label>[a-zA-Z_]\w*)?\s*" + 
                                   $mnemonic.Replace('(', '\(').Replace(')', '\)').Replace('[d8]', '([\$]?[0-9a-fA-F]{2})').Replace('[r8]', '([\$]?[0-9a-fA-F]{4})').Replace('[a16]', '([\$]?[0-9a-fA-F]{4})') +
                                   "(.*\;.*)?$";

                if ($syntax -match $mnemonicPattern) {
                    $matched = $true;
                    
                    if ($Matches.ContainsKey('label')) {
                        $this.Variables.Add($Matches['label'], $this.Address);
                    }

                    if ($this.OPCodes[$mnemonic].OpCode -ne "") { $codes += [byte]$this.OPCodes[$mnemonic].OpCode; }

                    switch ($this.OPCodes[$mnemonic].AddressingMode) {
                        { $_ -eq 'Immediate' -or $_ -eq 'ZeroPage' -or 
                          $_ -eq 'ZeroPageX' -or $_ -eq 'ZeroPageY' -or 
                          $_ -eq 'IndirectIndexX' -or $_ -eq 'IndirectIndexY' -or 
                          $_ -eq 'IndexedIndirectX' -or $_ -eq 'IndexedIndirectY'} { 
                            $value = [byte]"0x$($Matches[1].Replace('$', ''))";
                            $codes += $value;
                            $details = $mnemonic.Replace('[d8]', '$' + $value.ToString('X2'));
                        }
                        { $_ -eq 'Absolute' -or $_ -eq 'AbsoluteX' -or $_ -eq 'AbsoluteY' -or 
                          $_ -eq 'Indirect'  } { 
                            $value = [uint16]"0x$($Matches[1].Replace('$', ''))";
                            $codes += ($this.WordToByteArray($value))
                            $details = $mnemonic.Replace('[a16]', '$' + $value.ToString('X4'));
                        }
                        { $_ -eq 'Relative'} {
                            $value = [uint16]"0x$($Matches[1].Replace('$', ''))";

                            $offset = $value - ($this.Address + 2);

                            if ($offset -lt -128 -or $offset -gt 127) {
                                Write-Host "Outside bounds...";
                            } else {
                                if ($offset -lt 0) { $offset += 0x100; }
                                $value = [byte]$offset;
                                $codes += $value;
                                $details = $mnemonic.Replace('[r8]', '$' + $value.ToString('X2'));
                            }                            
                        }
                        { $_ -eq 'Implied'} {
                            $details = $mnemonic;
                        }
                    }
                    break;
                } 
            }
            if (-not $matched ) { # Handle the variables...
                foreach($mnemonic in $this.OPCodes.Keys) {
                    #Write-Host $mnemonic
                    $mnemonicPattern = "^(?<label>[a-zA-Z_]\w*)?\s*" + 
                                       $mnemonic.Replace('(', '\(').Replace(')', '\)').Replace('[d8]', '([^;,]*)').Replace('[r8]', '([^;]*)').Replace('[a16]', '([^;,]*)') +
                                       "(.*\;.*)?$";
                   #Write-Host $mnemonicPattern
                    if ($syntax -match $mnemonicPattern) {
                        
                       # Write-Host $Matches[1]

                        $value = $this.EvaluateExpression($Matches[1]);
                        #Write-Host $Value

                        if ($value -lt 256) {
                            $this.Assemble($syntax.Replace($Matches[1], '$' + ([byte]$value).ToString('X2')), $syntax);
                        } else {
                            $this.Assemble($syntax.Replace($Matches[1], '$' + $value.ToString('X4')), $syntax);
                        }
                        return; 
                    }
                }
            }
        }

        $line = "$($this.Address.ToString('X4')) : ";
        for ($index = 0; $index -lt 3; $index += 1) {
            if ($index -lt $codes.Count) { $line += "$($codes[$index].ToString('X2')) "; } else { $line += "   "; }
        }
        $line = $line + " : " + $details
        $line = $line.PadRight(40, ' ');

        if ($originalSyntax -ne $null) {
            $line += "; " + $originalSyntax 
        } else {
            $line += "; " + $syntax
        }

        $this.Output += $line;
        $this.Bytes += $codes;
        $this.Address += $codes.Count;
    }

    [array] WordToByteArray($Word) {
        return @(($Word -band 0x00FF), (( $Word -band 0xFF00 ) -shr 8));
    }

    [uint16] EvaluateExpression($Expression) {
        $expressionVariables = @();
        $regex = [RegEx]'[a-zA-Z_]\w*';
        $regex.Matches($Expression) | ForEach-Object {
            if (-not $expressionVariables.Contains($_.Value)) { $expressionVariables += $_.Value; }
        }
        $expressionVariables | Sort-Object { $_.Length } -Descending | ForEach-Object {
            if ($this.Variables.ContainsKey($_)) {
                $Expression = $Expression.Replace($_, $this.Variables[$_]);
            };
        }
        $Expression = $Expression.Replace('$', '0x');

        return $(Invoke-Expression $Expression);
    }

    [array] LoadFile($FileName) {
        $lines = @();
        Get-Content $FileName | ForEach-Object {
            $lines += $_
            if ($_ -match '.*INCLUDE\s+([^\s]*).*') {
                $includeFileName = $Matches[1]
                $lines += "; Start Including '$($includeFileName)'"
                $this.LoadFile($includeFileName) | ForEach-Object { $lines += $_; }
                $lines += "; Ending Including '$($includeFileName)'"
            } 
        }
        return $lines
    }

    [void] AssembleFile($FileName) {
        $this.LoadFile($FileName) | ForEach-Object {
            $this.Assemble($_);
        }
    }
    [void] ExportPrg($FileName) {
        $prg = $this.WordToByteArray($this.StartingAddress) + $this.Bytes;
        Remove-Item -Path $FileName -Force -ErrorAction SilentlyContinue
        $prg | ForEach-Object { Add-Content -Value ([byte]$_) -Path $FileName -Encoding Byte }
    }
}

$assembler = [Assembler]::new('6502');

$assembler.AssembleFile("loop.asm");

$assembler.Output
""
$assembler.Variables

#""
#Dump-ByteArray -ByteArray $assembler.Bytes -Address 0x0801 -PrintHeader

#$prg = $assembler.WordToByteArray(0x0801) + $assembler.Bytes
#""
#Dump-ByteArray -ByteArray $prg -Address 0x0000 -PrintHeader

#Remove-Item -Path "stub.prg" -Force -ErrorAction SilentlyContinue
#$prg | ForEach-Object { Add-Content -Value ([byte]$_) -Path "stub.prg" -Encoding Byte }


$assembler.ExportPrg("stub.prg");

. "C:\Program Files\GTK3VICE-3.7-win64\bin\x64sc.exe" "stub.prg"



return;

'
ToDo: [x] Labels and Variables
      [x] Comments
      [x] Pass - Give file to Assembler
        [ ] double pass...
      [x] math (have a basic handle)
      [x] address setting (* = $0801)
      [x] branches (---, +++)
      [X] Include Files
      [x] Export PRG

        [x] All Addressing Modes Checked
Absolute
AbsoluteX
AbsoluteY
Accumulator
Immediate
Implied
IndexedIndirectX
IndexedIndirectY
Indirect
Relative
ZeroPage
ZeroPageX
ZeroPageY


    [ ] Code Cleanup
    [ ] Test Sets
        All Address Types
        With and without Variables
        Future Labels
    [ ] Error Handling

'