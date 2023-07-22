


..\..\..\source\PSAssembler.ps1 .\launcher.asm -GenerateLST -GeneratePRG

Remove-Item .\data0000.seq -Force -ErrorAction SilentlyContinue
..\..\..\source\PSAssembler.ps1 .\data0000.asm -GenerateLST -GenerateOUT
Move-Item .\data0000.out .\data0000.seq

if ($LASTEXITCODE -eq 0) {
    . "C:\Program Files\GTK3VICE-3.7-win64\bin\c1541.exe" `
        -format mydisk,99 d64 disk.d64 `
        -attach disk.d64 `
        -write launcher.prg `
        -write data0000.seq "data0000.seq,s"

    $fileName = ".\disk.d64"
    Write-Host -ForegroundColor Yellow "Launching'$($fileName)' in Vice."
    (. "C:\Program Files\GTK3VICE-3.7-win64\bin\x64sc.exe" $fileName) | Out-Null
} else {
    "Not packaging because of compilation errors..."
}

