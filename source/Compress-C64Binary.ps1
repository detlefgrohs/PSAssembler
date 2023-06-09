param (
    $FileName,
    [Switch]$Color,
    [Switch]$Verbose,
    [Switch]$Verify,
    [Switch]$Force
)

$destination = $FileName + 'c'

Write-Host -ForegroundColor Green "Compressing '$($FileName)' to '$($destination)'"

if (-not (Test-Path -Path $FileName)) {
    Write-Host -ForegroundColor Red "   File '$($FileName)' does not exist..."
    return;
}

if ((Test-Path -Path $destination)) {
    $sourceLastWriteTime = (Get-Item -Path $FileName).LastWriteTime
    $targetLastWriteTime = (Get-Item -Path $destination -ErrorAction SilentlyContinue).LastWriteTime
    
    if ($targetLastWriteTime -gt $sourceLastWriteTime -and -not $Force) {
        Write-Host -ForegroundColor Yellow "   Skipping because generated file is older than source file..."   
        return;
    }    
}

$binary = [System.IO.File]::ReadAllBytes("$($PWD)\$($FileName)");

"   Loaded $($binary.Length) bytes from '$($FileName)'"
if ($Color) {
    $newBinary = @()
    for($index = 0; $index -lt $binary.Length; $index += 2) {
        $newBinary += ($binary[$index] -shl 4) -bor $binary[$index + 1];
    }
    $binary = $newBinary;
    "   Color Stacked to $($binary.Length)"
}

if ($Verbose) {
    $binary | ForEach-Object {
        Write-Host "$($_.ToString('X2')) " -NoNewline
    }
    Write-Host
}

$stream = @();
$output = @();

$index = 0;
$done = $false;

enum Mode {
    Raw = 0
    Compressed = 1
}

$limit = 126
$mode = [Mode]::Raw;

while (-not $done) {
    $currentByte = $binary[$index];
    if ($index -eq ($binary.Length - 1)) {
        $nextByte = $null;
        $done = $true;
    } else {
        $nextByte = $binary[$index + 1];
    }

    switch ($mode) {
        Raw {
            if ($nextByte -eq $null) {
                if ($stream.Count -eq 0) {
                    #$output += 0xFF;
                    $output += 1;
                    $output += $currentByte;                    
                } else {
                    #$output += 0xFF;
                    $output += $stream.Count + 1;
                    $output += $stream;         
                    $output += $currentByte;           
                }
            } else {
                if ($currentByte -eq $nextByte) {
                    # switch to compressed mode...
                    if ($stream.Count -ne 0) {
                        # Output the Stream...
                        #$output += 0xFF;
                        $output += $stream.Count;
                        $output += $stream;
                    }
                    $stream = @();
                    $stream += $currentByte;
                    $mode = [Mode]::Compressed;
                } else {
                    if ($stream.Count -eq $limit) {
                        # Hit Limit
                        $output += $stream.Count;
                        $output += $stream;
                        $stream = @();
                    }
                    $stream += $currentByte;
                }
            }
        }
        Compressed {
            if ($nextByte -eq $null) {
                #$output += 0x80
                $output += ($stream.Count + 1) -bor 0x80;
                $output += $stream[0];
            } else {
                if ($currentByte -ne $nextByte) {
                    # Switch to Raw mode...
                    if ($stream.Count -ne 0) {
                        # output the compressed stream
                        #$output += 0x80
                        $output += ($stream.Count + 1) -bor 0x80;
                        $output += $stream[0];
                    }
                    $stream = @();
                    #$stream += $nextByte;
                    $mode = [Mode]::Raw;
                } else {
                    if ($stream.Count -eq $limit) {
                        # Hit Limit
                        $output += $stream.Count -bor 0x80;
                        $output += $stream[0];
                        $stream = @();
                    }
                    $stream += $currentByte;
                }
            }
        }
    }
    $index += 1;
}

"   Compressed to $($output.Length) bytes"
    if ($Verbose) {
    $output | ForEach-Object {
        Write-Host "$($_.ToString('X2')) " -NoNewline
    }
    Write-Host
}
$uncompressed = @()

if ($Verify) {
    $index = 0;
    $done = $false;

    while (-not $done) {
        $command = $output[$index];
        #"$($index) $($command)"

        if ($command -band 0x80) { # Compressed
            $index += 1;
            $value = $output[$index];
            $count = $command -band 0x7F;
            while ($count -gt 0) {
                $uncompressed += $value;
                $count -= 1;
            }
        } else { # Raw
            $count = $command;
            while ($count -gt 0) {
                $index += 1;
                $uncompressed += $output[$index];
                $count -= 1;
            }
        }
        $index += 1;
        if ($index -ge $output.Count) { $done = $true; }
    }

    "Uncompressed to $($uncompressed.Length) bytes"
    if ($Verbose) {
    $uncompressed | ForEach-Object {
        Write-Host "$($_.ToString('X2')) " -NoNewline
    }
    Write-Host
    }

    $equal = $true
    if ($binary.Count -eq $uncompressed.Count) {
        for ($index = 0; $index -lt $binary.Count; $index += 1) {
            if ($binary[$index] -ne $uncompressed[$index]) {
                $equal = $false;
            }
        }
    } else {
        $equal = $false;
    }

    if ($equal) { "      Are Equal"} else { "      Not Equal" }
}

$startDTM = [DateTime]::Now

Remove-Item -Path $destination -Force -ErrorAction SilentlyContinue
[System.IO.File]::WriteAllBytes("$($PWD)\$($destination)", $output);
$elapsed = [DateTime]::Now - $startDTM
"   Wrote to '$($destination)' in $($elapsed.TotalSeconds) seconds."
