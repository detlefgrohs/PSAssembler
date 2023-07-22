param ($Source1, $Source2,$Destination)

Write-Host -ForegroundColor Green "Joining '$($Source1)' + '$($Source2)' => '$($Destination)'"

Remove-Item -Path $Destination -Force -ErrorAction SilentlyContinue

if ((Get-Host).Version.Major -lt 6) {
    Get-Content -Encoding Byte -Path $Source1 | Add-Content -Path $Destination -Encoding Byte;
    Get-Content -Encoding Byte -Path $Source2 | Add-Content -Path $Destination -Encoding Byte;

    #$out | ForEach-Object { Add-Content -Value ([byte]$_) -Path $FileName -Encoding Byte } # PowerShell 5.x -Encoding Byte
} else {
    Get-Content -AsByteStream -Path $Source1 | Add-Content -Path $Destination -AsByteStream;
    Get-Content -AsByteStream -Path $Source2 | Add-Content -Path $Destination -AsByteStream;

    #$out | ForEach-Object { Add-Content -Value ([byte]$_) -Path $FileName -AsByteStream } # PowerShell 6.x AsByteStream
}