
#CODE
$screenOffset = New-Object 'object[,]' 23,23
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

$header = ";     "
for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
    $header += "$($colIndex.ToString('00')) "
}
$header

if ($false) {
    $tileData[0, 9] = 1;
    $tileData[0,10] = 0;
    $tileData[0,11] = 0;
    $tileData[1, 9] = 0
    $tileData[1,10] = 0xff;
    $tileData[1,11] = 1;
    $tileData[2, 9] = 0;
    $tileData[2,10] = 0;
    $tileData[2,11] = 0;
}

for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    $line = ";$($rowIndex.ToString('00')) : "
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        $line += "$($tileData[$rowindex,$colIndex].ToString('X2')) "
    }
    $line
}

for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
    for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
        "               DATA.b  `$$($tileData[$rowindex,$colIndex].ToString('X2')) ; $($colIndex), $($rowIndex)"
    }
}
#ENDC
