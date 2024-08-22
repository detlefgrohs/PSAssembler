
$Global:AssemblerPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition);

# LegendOfBrenda/Copy of LegendOfBrenda Map Workarea Beta Version.xlsx
$excel = New-Object -ComObject Excel.Application
$Workbook = $excel.Workbooks.Open("$($Global:AssemblerPath)\LegendOfBrenda Map Workarea Beta Version.xlsx")

$worksheet = $Workbook.Sheets.Item("Overworld")

$topOffset = 3
$leftOffset = 3

$Global:MaxCellsPerScreen = 0
# $screenCol = 0
# $screenRow = 0

# for($y = 0; $y -lt 11; $y += 1) {
#     $row = $topOffset + ($screenRow * 11) + $y;

#     for($x = 0; $x -lt 16; $x += 1) {
#         $col = $leftOffset + ($screenCol * 16) + $x;

#         $value = $worksheet.cells.Item($row, $col).Text

#         Write-Host $value.PadRight(4) -NoNewline
#     }
#     Write-Host ""
# }

function Generate-Data() {
    param($line)

    $line | Add-Content $Global:lstFileName
}

function Get-IndexOfCellType() {
    param($cellType)

    return $Global:tileTypes[$cellType].Index;
}

function Get-IndexOfRowType() {
    param($rowType)

    return 0;
}


function Audit-Screen() {
    param($screenX, $screenY)
    $localCellTypes = New-Object System.Collections.Generic.Dictionary"[String,Int]"
    $localRowTypes = New-Object System.Collections.Generic.Dictionary"[String,Int]"

    Generate-Data "       ; Screen[$($screenX),$($screenY)]"


    for ($y = 0; $y -lt 11; $y += 1) {
        $row = $topOffset + $y + ($screenY * 11);

        $rowType = ""

        for ($x = 0; $x -lt 16; $x += 1) {
            $col = $leftOffset + $x + ($screenX * 16);
        
            $value = $worksheet.cells.Item($row, $col).Text
            $value = $value.PadRight(4)
            $rowType = $rowType + $value;
    
            if ($Global:cellTypes.ContainsKey($value)) {
                $Global:cellTypes[$value] += 1;
            } else {
                $Global:cellTypes.Add($value, 1);
            }

            if ($localCellTypes.ContainsKey($value)) {
                $localCellTypes[$value] += 1;
            } else {
                $localCellTypes.Add($value, 1);
            }
        }

        Generate-Data "       ; $($rowType)"
        $size = $rowType.Length / 4
        $rowTypeA = $rowType.Substring(0, $size);
        $rowTypeB = $rowType.Substring($size, $size);
        $rowTypeC = $rowType.Substring($size * 2, $size);
        $rowTypeD = $rowType.Substring($size * 3, $size);

        $indexOfRowType = Get-IndexOfRowType($rowTypeA);
        Generate-Data "       DATA.b `$$($indexOfRowType.ToString("X2")) ; $($rowTypeA)"
        $indexOfRowType = Get-IndexOfRowType($rowTypeB);
        Generate-Data "       DATA.b `$$($indexOfRowType.ToString("X2")) ; $($rowTypeB)"
        $indexOfRowType = Get-IndexOfRowType($rowTypeC);
        Generate-Data "       DATA.b `$$($indexOfRowType.ToString("X2")) ; $($rowTypeC)"
        $indexOfRowType = Get-IndexOfRowType($rowTypeD);
        Generate-Data "       DATA.b `$$($indexOfRowType.ToString("X2")) ; $($rowTypeD)"

        IncrementCount $Global:rowTypes $rowTypeA
        IncrementCount $Global:rowTypes $rowTypeB
        IncrementCount $Global:rowTypes $rowTypeC
        IncrementCount $Global:rowTypes $rowTypeD

        IncrementCount $localRowTypes $rowTypeA
        IncrementCount $localRowTypes $rowTypeB
        IncrementCount $localRowTypes $rowTypeC
        IncrementCount $localRowTypes $rowTypeD

        # if ($Global:rowTypes.ContainsKey($rowTypeA)) {
        #     $Global:rowTypes[$rowTypeA] += 1;
        # } else {
        #     $Global:rowTypes.Add($rowTypeA, 1);
        # }

        # if ($localRowTypes.ContainsKey($rowTypeA)) {
        #     $localRowTypes[$rowTypeA] += 1;
        # } else {
        #     $localRowTypes.Add($rowTypeA, 1);
        # }

        # if ($Global:rowTypes.ContainsKey($rowTypeB)) {
        #     $Global:rowTypes[$rowTypeB] += 1;
        # } else {
        #     $Global:rowTypes.Add($rowTypeB, 1);
        # }

        # if ($localRowTypes.ContainsKey($rowTypeB)) {
        #     $localRowTypes[$rowTypeB] += 1;
        # } else {
        #     $localRowTypes.Add($rowTypeB, 1);
        # }
    }
    Generate-Data "       ; cellTypes $($localCellTypes.Count)"
    Generate-Data "       ; rowTypes $($localRowTypes.Count)"
    Generate-Data ""

    if ($localCellTypes.Count -gt $Global:MaxCellsPerScreen) {
        $Global:MaxCellsPerScreen = $localCellTypes.Count;
    }
}

function IncrementCount() {
    param($dictionary, $key)

    if ($dictionary.ContainsKey($key)) { $dictionary[$key] += 1; }
    else                               { $dictionary.Add($key, 1); }
}


$Global:lstFileName = "$($Global:AssemblerPath)\mapdata.asm"
Remove-Item $Global:lstFileName -ErrorAction SilentlyContinue

Write-Host
Write-Host "$([System.DateTime]::Now)"
Write-Host "Summarizing Cells and Columns"
$Global:cellTypes = New-Object System.Collections.Generic.Dictionary"[String,Int]"
$Global:rowTypes = New-Object System.Collections.Generic.Dictionary"[String,Int]"

for ($y = 0; $y -lt 8; $y += 1) {
    for ($x = 0; $x -lt 16; $x += 1) {
        Audit-Screen $x $y
    }
    # Write-Host $col
}

$Global:tileTypes = @{
    "    " = @{ Description = "Blank"; Index = 0 }
    ".   " = @{ Description = "Ground"; Index = 1 }
    "L   " = @{ Description = "Ladder"; Index = 2 }
    "T   " = @{ Description = "Tree"; Index = 3 }
    "B   " = @{ Description = "Bridge"; Index = 4 }
    "D   " = @{ Description = "Dirt"; Index = 5 }

    "MC  " = @{ Description = "Moutain Center"; Index = 6 }
    "MT  " = @{ Description = "Mountain Top"; Index = 7 }
    "MTL " = @{ Description = "Mountain Top Left"; Index = 8 }
    "MTR " = @{ Description = "Mountain Top Right"; Index = 9 }
    "MBL " = @{ Description = "Mountain Bottom Left"; Index = 10 }
    "MBR " = @{ Description = "Mountain Bottom Right"; Index = 11 }

    "TTL " = @{ Description = "Tree Top Left"; Index = 12 }
    "TBL " = @{ Description = "Tree Bottom Left"; Index = 13 }
    "TTR " = @{ Description = "Tree Top Right"; Index = 14 }
    "TBR " = @{ Description = "Tree Bottom Right"; Index = 15 }
    "TT  " = @{ Description = "Tree Top (Eyes)"; Index = 16 }

    "S   " = @{ Description = "Statue"; Index = 17 }
    "TS  " = @{ Description = "Tombstone"; Index = 18 }
    "R   " = @{ Description = "Rock"; Index = 19 }

    "WTL " = @{ Description = "Water Top Left"; Index = 20 }
    "WBL " = @{ Description = "Water Bottom Left"; Index = 21 }
    "WTR " = @{ Description = "Water Top Right"; Index = 22 }
    "WBR " = @{ Description = "Water Bottom Right"; Index = 23 }
    "W   " = @{ Description = "Water"; Index = 24 }
    "WF  " = @{ Description = "Water Fall"; Index = 25 }
    "WT  " = @{ Description = "Water Top"; Index = 26 }
    "WB  " = @{ Description = "Water Bottom"; Index = 27 }
    "WL  " = @{ Description = "Water Left"; Index = 28 }
    "WR  " = @{ Description = "Water Right"; Index = 29 }

    "WOTL" = @{ Description = "Water Outside Top Left"; Index = 30 }
    "WOTR" = @{ Description = "Water Outside Top Right"; Index = 31 }
    "WOBL" = @{ Description = "Water Outside Bottom Left"; Index = 32 }
    "WOBR" = @{ Description = "Water Outside Bottom Right"; Index = 33 }

    "C   " = @{ Description = "Cave Entrance"; Index = 34 }
    "DTL " = @{ Description = "Dungeon Top Left"; Index = 35 }
    "DBL " = @{ Description = "Dungeon Bottom Left"; Index = 36 }
    "DTR " = @{ Description = "Dungeon Top Right"; Index = 37 }
    "DBR " = @{ Description = "Dungeon Bottom Right"; Index = 38 }
    "SE  " = @{ Description = "Single Eye"; Index = 39 }
    "DE  " = @{ Description = "Double Eye"; Index = 40 }
}

Write-Host
$assignedCells = 0
$totalCells = 0
$cellTypes.Keys | Sort-Object | ForEach-Object {
    Generate-Data "; $($_) : `$$($Global:tileTypes[$_].Index.ToString("X2")) : $($Global:tileTypes[$_].Description.ToString().PadRight(30)) => $($cellTypes[$_])"
    if ($_ -ne "    ") { $assignedCells += $cellTypes[$_]; }
    $totalCells += $cellTypes[$_]
}
Write-Host
Generate-Data ""
$Global:rowTypes.Keys | ForEach-Object {
    Generate-Data "; $($_) : $($Global:rowTypes[$_])"
    $line = "      #DATA.b "
    $key = $_;
    for($index = 0; $index -lt ($key.Length / 4); $index += 1) {
        $part = $key.Substring(4 * $index, 4);
        $cellTypeIndex = Get-IndexOfCellType $part
        $line += "`$$($cellTypeIndex.ToString("X2")), "
    }
    Generate-Data $line.TrimEnd(", ")
}
Write-Host "$([System.DateTime]::Now)"

Write-Host
Write-Host "assignedCells = $($assignedCells)"
Write-Host "totalCells    = $($totalCells)"

$percentDone = $assignedCells / $totalCells
Write-Host "percentDone   = $($percentDone)"

Write-Host "Total CellTypes = $($Global:cellTypes.Count)"
Write-Host "Total RowTypes  = $($Global:rowTypes.Count)"
Write-Host "Max Cells Per Screen  = $($Global:MaxCellsPerScreen)"
#$worksheet.cells.Item(3, 258).Text


$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
# no $ needed on variable name in Remove-Variable call
Remove-Variable excel