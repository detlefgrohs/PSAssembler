$screenOffset = New-Object 'object[,]' 23,23
$screenOffsetLo = New-Object 'object[,]' 23,23
$screenOffsetHi = New-Object 'object[,]' 23,23
$tileData = New-Object 'object[,]' 23,23

for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        $screenOffset[$rowindex,$colIndex] = 0xFFFF;
        $tileData[$rowindex,$colIndex] = 0x81;
    }
}

$startRow = 10
$startCol = 1
$startOffset = 0

for ($index = 0; $index -lt 11; $index += 1) {
    $currentRow = $startRow;
    $currentCol = $startCol;
    $currentOffset = $startOffset;

    for ($colIndex = 0; $colIndex -lt 10; $colIndex += 1) {
        $screenOffset[$currentRow, $currentCol] = $currentOffset;
        $tileData[$currentRow, $currentCol] = 0x00;

        $currentRow -= 1;
        $currentCol += 1;
        $currentOffset += 4;
    }

    $startRow += 0;
    $startCol += 1;
    $startOffset += 42;

    $currentRow = $startRow;
    $currentCol = $startCol;
    $currentOffset = $startOffset;

    for ($colIndex = 0; $colIndex -lt 9; $colIndex += 1) {
        $screenOffset[$currentRow, $currentCol] = $currentOffset;
        $tileData[$currentRow, $currentCol] = 0x00;

        $currentRow -= 1;
        $currentCol += 1;
        $currentOffset += 4;
    }

    $startRow += 1;
    $startCol += 0;
    $startOffset += 38;
}

$currentRow = $startRow;
$currentCol = $startCol;
$currentOffset = $startOffset;

for ($colIndex = 0; $colIndex -lt 10; $colIndex += 1) {
    $screenOffset[$currentRow, $currentCol] = $currentOffset;
    $tileData[$currentRow, $currentCol] = 0x00;

    $currentRow -= 1;
    $currentCol += 1;
    $currentOffset += 4;
}


Write-Host "      " -NoNewline
for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
    Write-Host "$($colIndex.ToString('00'))   " -NoNewline
}
Write-Host

for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    Write-Host "$($rowIndex.ToString('00')) : " -NoNewLine
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        Write-Host "$($screenOffset[$rowindex,$colIndex].ToString('X4')) " -NoNewLine
    }
    Write-Host
}

Write-Host
Write-Host "     " -NoNewline
for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
    Write-Host "$($colIndex.ToString('00')) " -NoNewline
}
Write-Host

for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    Write-Host "$($rowIndex.ToString('00')) : " -NoNewLine
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        Write-Host "$($tileData[$rowindex,$colIndex].ToString('X2')) " -NoNewLine
    }
    Write-Host
}

for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        $value = $screenOffset[$rowindex,$colIndex]

        $valueLo = $value -band 0x00ff;
        $valueHi = ($value -band 0xff00) -shr 8;

        $screenOffsetLo[$rowindex,$colIndex] = $valueLo;
        $screenOffsetHi[$rowindex,$colIndex] = $valueHi;
    }
}

Write-Host
Write-Host "     " -NoNewline
for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
    Write-Host "$($colIndex.ToString('00')) " -NoNewline
}
Write-Host

for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    Write-Host "$($rowIndex.ToString('00')) : " -NoNewLine
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        Write-Host "$($screenOffsetLo[$rowindex,$colIndex].ToString('X2')) " -NoNewLine
    }
    Write-Host
}

Write-Host
Write-Host "     " -NoNewline
for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
    Write-Host "$($colIndex.ToString('00')) " -NoNewline
}
Write-Host

for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    Write-Host "$($rowIndex.ToString('00')) : " -NoNewLine
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        Write-Host "$($screenOffsetHi[$rowindex,$colIndex].ToString('X2')) " -NoNewLine
    }
    Write-Host
}

$out = @();
for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        $out += $tileData[$rowindex,$colIndex];
    }
}
Remove-Item "$($PWD)\TileMaze-TileData.bin" -Force -ErrorAction SilentlyContinue
[System.IO.File]::WriteAllBytes("$($PWD)\TileMaze-TileData.bin", $out);



$out = @();
for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        $out += $screenOffsetLo[$rowindex,$colIndex];
    }
}
Remove-Item "$($PWD)\TileMaze-ScrOffsetLo.bin" -Force -ErrorAction SilentlyContinue
[System.IO.File]::WriteAllBytes("$($PWD)\TileMaze-ScrOffsetLo.bin", $out);



$out = @();
for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        $out += $screenOffsetHi[$rowindex,$colIndex];
    }
}
Remove-Item "$($PWD)\TileMaze-ScrOffsetHi.bin" -Force -ErrorAction SilentlyContinue
[System.IO.File]::WriteAllBytes("$($PWD)\TileMaze-ScrOffsetHi.bin", $out);




