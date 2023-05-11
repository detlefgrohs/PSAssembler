..\AssemblerClassV3.ps1 .\relocate.asm -GeneratePRG > relocate.txt


#..\AssemblerClassV3.ps1 .\supermon64v1.asm -GenerateOUT

..\AssemblerClassV3.ps1 .\supermon64v1_8000.asm -GenerateOUT > supermon64v1_8000.txt
..\AssemblerClassV3.ps1 .\supermon64v1_C000.asm -GenerateOUT > supermon64v1_C000.txt

# Now do the reloacation magic
# #36 is a magic number for some reason...

if ((Get-Host).Version.Major -lt 6) {
    $out8000 = Get-Content -Encoding Byte -Path 'supermon64v1_8000.out'
    $outC000 = Get-Content -Encoding Byte -Path 'supermon64v1_C000.out'
} else {
    $out8000 = Get-Content -AsByteStream -Path 'supermon64v1_8000.out'
    $outC000 = Get-Content -AsByteStream -Path 'supermon64v1_C000.out'
}

$out8000.Count
$out8000 | ForEach-Object {
    Write-Host "`$$($_.ToString('X2')) " -NoNewLine
}
""
$outC000.Count

$relocatedOut = @();

$relocatedOut += [byte]0x36;
$relocatedOut += [byte]0x36;

# Okay scan from the en

if ($out8000.Count -eq $outC000.Count) {
    for($index = 0 ; $index -lt $out8000.Count; $index += 1) {
        # If the next byte does not equal then we have an offset...
        if ((($index + 1) -lt $out8000.Count) -and ($out8000[$index + 1] -ne $outC000[$index + 1]) ) {
            # Ah got it...
            # Get address as word
            # subtract the end to get the offset
            # write back to stream;;;
            $loByte = [byte]$out8000[$index];
            $hiByte = [byte]$out8000[$index + 1];
            " loByte = $($loByte.ToString('X2'))    hiByte = $($hiByte.ToString('X2'))"
            $address = ([uint16]$hiByte -shl 8) + $loByte; # ([byte]$out8000[$index]) + ([byte]$out8000[$index + 1] -shl 8);

            $offset = [int16]($address - ($out8000.Count + 0x8000));
            "  Found Offset at $($index) : $($address.ToString('X4')) => $($offset.ToString('X4'))";

            $relocatedOut += [byte]($offset -band 0x00FF);
            $relocatedOut += [byte](($offset -band 0xFF00) -shr 8);

            $relocatedOut += [byte]0x36;
            $index += 1;
        } else {
            $relocatedOut += $out8000[$index];
        }
    }
}

$relocatedOut.Count;
$relocatedOut | ForEach-Object {
    Write-Host "`$$($_.ToString('X2')) " -NoNewLine
}
""

$outFileName = 'supermon64v1.out'
Remove-Item -Path $outFileName -Force -ErrorAction SilentlyContinue

if ((Get-Host).Version.Major -lt 6) {
    $relocatedOut | Add-Content -Path $outFileName -Encoding Byte;

} else {
    $relocatedOut | Add-Content -Path $outFileName -AsByteStream;
}

# Now Combine the 2 output files...
.\Join-BinaryFiles -Source1 relocate.prg -Source2 supermon64v1.out -Destination supermov64v1.prg


# Current Work
# ; [x] Export RAW
# ; [x] Split Source into modules to make it easier to work with
# ; [x] Move to a seperate area
# ; Source Control
# ; MultiByte Data
# ; TEXT
# ; [x] Concatenate Binaries...