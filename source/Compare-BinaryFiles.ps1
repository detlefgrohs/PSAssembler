param ($Source1, $Source2)

Write-Host -ForegroundColor Green "Comparing '$($Source1)' with '$($Source1)'"

if ((Get-Host).Version.Major -lt 6) {
    $stream1 = Get-Content -Encoding Byte -Path $Source1
    $stream2 = Get-Content -Encoding Byte -Path $Source2
} else {
    $stream1 = Get-Content -AsByteStream -Path $Source1
    $stream2 = Get-Content -AsByteStream -Path $Source2
}

if ($stream1.Count -ne $stream2.Count) {
    Write-Host -ForegroundColor Red "'$($Source1)' $($stream1.Count) bytes != '$($Source2)' $($stream2.Count)"
    return -1;
} else {
    $areEqual = $true;



    if ($areEqual) {
        Write-Host -ForegroundColor Yellow "Equal..."
        return 0;
    } else {
        Write-Host -ForegroundColor Red "Not equal..."
        return -1;    
    }
}