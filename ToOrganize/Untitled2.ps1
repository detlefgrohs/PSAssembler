

$Global:OutFile = "C:\Users\detle\PSC64Compiler\out.prg"


Remove-Item -Path $outputFilename -Force -ErrorAction SilentlyContinue

function Out-Byte {
    param ($Byte)
    Add-Content -Value ([byte]$Byte) -Path $Global:OutFile -Encoding Byte
}

function Out-Word {
    param ($Word)
    [byte[]] $byteArray = ($Word -band 0x00FF), (( $Word -band 0xFF00 ) -shr 8);
    Add-Content -Value $byteArray -Path $Global:OutFile -Encoding Byte
}

Out-Word 0x0801

Out-Word 0x080B
Out-Word 0x000A

Out-Byte 0x9E
Out-Byte 0x32
Out-Byte 0x30
Out-Byte 0x36
Out-Byte 0x31

Out-Byte 0x00
Out-Word 0x0000

Out-Byte 0x60


. "C:\Program Files\GTK3VICE-3.7-win64\bin\x64sc.exe" $Global:OutFile

return;

function Convert-WordToByteArray {
    param($Word)

    [byte[]] $returnValue = ($Word -band 0x00FF), (( $Word -band 0xFF00 ) -shr 8); 
    return $returnValue;
}

Add-Content -Value (Convert-WordToByteArray 0x0801) $outputFilename -Encoding Byte

[byte]0x32 | Add-Content $outputFilename -Encoding Byte

[byte]0x30 | Add-Content $outputFilename -Encoding Byte

# [byte[]]0x801 | Add-Content $outputFilename -Encoding Byte
#[char]0x30 | Out-File $outputFilename
#[char]0x36 | Out-File $outputFilename
#[char]0x31 | Out-File $outputFilename

# 0x0801


# C:\Program Files\GTK3VICE-3.7-win64\bin\x64sc.exe with  "C:\Users\detle\Documents\New Solution\Test.prg"

# . "C:\Program Files\GTK3VICE-3.7-win64\bin\x64sc.exe" "C:\Users\detle\Documents\New Solution\Test.prg"


