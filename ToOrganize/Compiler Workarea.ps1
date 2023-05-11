
$Global:OPCodes = 
[Ordered] @{
    "LDA #b8" = @{
        Description = "Load Accumlator Immediate";
        Type = "opcode";
        Opcode = 0x10;
        Format = "LDA #`${op}";
    };
    "LDA zp" = @{
        Description = "Load Accumlator Zero Page";
        Type = "opcode";
        Opcode = 0x32;
        Format = "LDA `${op}";
    };
    "LDA a16" = @{
        Description = "Load Accumlator Absolute";
        Type = "opcode";
        Opcode = 0x48;
        Format = "LDA `${op}";
    };

    "RTS impl" = @{
        Description = "Return from Subroutine";
        Type = "opcode";
        Opcode = 0x60;
        Format = "RTS";
    };

    "WORD a16" = @{
        Description = "Array of Words";
        Type = "data";
        Format = "WORD `${op}"
    }
    "BYTE b8" = @{
        Description = "Array of Words";
        Type = "data";
        Format = "BYTE `${op}"
    }
}


$Global:Operands = [Ordered] @{
    "b8" =  "((?<hexbyte>\$[0-9a-fA-F]{2})|(?<byte>[0-9]{3})|(?<variable>[a-zA-Z_]\w*))";
    "a16" = "((?<hexword>\$[0-9a-fA-F]{4})|(?<word>[0-9]{4,5})|(?<variable>[a-zA-Z_]\w*))";
    "zp" =  "((?<hexbyte>\$[0-9a-fA-F]{2})|(?<byte>[0-9]{1,3})|(?<variable>[a-zA-Z_]\w*))";
    "impl" = "";
    #"b16*" = "(?<hexword>.*)"
}

$Global:Labels = @{};

function Word {
    param ($Word)

    return @(($Word -band 0x00FF), (( $Word -band 0xFF00 ) -shr 8))
}

function Parse-Assembly {
    param ($Command)

    #Write-Host "$($Command) " -NoNewline

    $bytes = @()
    $details = "";

    ($Global:OPCodes).Keys | ForEach-Object {
        $mnemonic = $_

        $Global:Operands.Keys | ForEach-Object {
            if ($mnemonic -match $_) {
                $mnemonicPattern = "^(?<label>[a-zA-Z_]\w*)?\s*" + $mnemonic.Replace(' ', '\s*').Replace($_, $Global:Operands[$_]) + "$";

                if ($Command -match $mnemonicPattern) {
                    if ($Matches.ContainsKey('label')) {
                        $Global:Labels.Add($Matches['label'], $Global:Address);
                    }

                    $details += $Global:OPCodes[$mnemonic].Format    

                    if ($Global:OPCodes[$mnemonic].Type -eq "data") {
                        if ($Matches.ContainsKey('hexbyte')) {
                            $value = [byte]"0x$($Matches['hexbyte'].Replace('$', ''))";
                            $bytes += $value;
                            $details = $details.Replace('{op}', $value.ToString('X2'));
                        } elseif ($Matches.ContainsKey('hexword')) {
                            $value = [uint16]"0x$($Matches['hexword'].Replace('$', ''))";
                            $bytes += (Word $value);
                            $details = $details.Replace('{op}', $value.ToString('X4'));
                        }
                    } else {
                        $bytes += $Global:OPCodes[$mnemonic].Opcode

                        if ($Matches.ContainsKey('byte')) {
                            $value = [byte]$Matches['byte'];
                            $bytes += $value;
                            $details = $details.Replace('{op}', $value.ToString('X2'));
                        } elseif ($Matches.ContainsKey('hexbyte')) {
                            $value = [byte]"0x$($Matches['hexbyte'].Replace('$', ''))";
                            $bytes += $value;
                            $details = $details.Replace('{op}', $value.ToString('X2'));
                        } elseif ($Matches.ContainsKey('word')) {
                            $value = [uint16]$Matches['word'];
                            $bytes += (Word $value);
                            $details = $details.Replace('{op}', $value.ToString('X4'));
                        } elseif ($Matches.ContainsKey('hexword')) {
                            $value = [uint16]"0x$($Matches['hexword'].Replace('$', ''))";
                            $bytes += (Word $value);
                            $details = $details.Replace('{op}', $value.ToString('X4'));
                        }
                    }
                }
            }
        }
    }
    $line = "$($Global:Address.ToString('X4')) : ";
    for ($index = 0; $index -lt 3; $index += 1) {
        if ($index -lt $bytes.Count) { $line += "$($bytes[$index].ToString('X2')) "; } else { $line += "   "; }
    }
    $line = $line + " : " + $details
    $line = $line.PadRight(32, ' ');
    $line += "; " + $Command
    $line

    $Global:Address += $bytes.Count;
}


$Global:Address = 0x0801

Parse-Assembly 'STUB  WORD $080B'
Parse-Assembly '      WORD $000A'
Parse-Assembly '      BYTE $9E' 
Parse-Assembly '      BYTE $32' 
Parse-Assembly '      BYTE $30' 
Parse-Assembly '      BYTE $36' 
Parse-Assembly '      BYTE $31' 
Parse-Assembly '      BYTE $00'
Parse-Assembly '      WORD $0000'

Parse-Assembly '      RTS'

#Parse-Assembly 'LABEL LDA #064'
#Parse-Assembly '      LDA 12'
#Parse-Assembly 'L1    LDA 32768'
#Parse-Assembly '      LDA   $ABCD'
#Parse-Assembly 'L2    LDA    $EE'

" "
"Labels:"
$Global:Labels.Keys | ForEach-Object {
    "$($_.PadRight(20, ' ')) : $($Global:Labels[$_].ToString('X4'))"
}

return;



'LDA #00' -match "LDA #(?<hexadecimal>\$[0-9a-fA-F]{1,2})?(?<decimal>[0-9]{1,2})?"
$Matches
" "

'LDA #$FF' -match "LDA #(?<hexadecimal>\$[0-9a-fA-F]{1,2})?(?<decimal>[0-9]{1,2})?"
$Matches
" "

'LDA #variable' -match "LDA #(?<hexadecimal>\$[0-9a-fA-F]{1,2})?(?<decimal>[0-9]{1,2})?(?<variable>\w+)?"
$Matches


