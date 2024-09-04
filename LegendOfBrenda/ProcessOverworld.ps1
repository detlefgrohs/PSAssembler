
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
function IncrementCount() {
    param($dictionary, $key)

    if ($dictionary.ContainsKey($key)) { $dictionary[$key] += 1; }
    else                               { $dictionary.Add($key, 1); }
}
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

    return $Global:rowTypeIndexes[$rowType];
}

function Audit-Screen() {
    param($screenX, $screenY)
    
    $localCellTypes = New-Object System.Collections.Generic.Dictionary"[String,Int]"
    $localRowTypes = New-Object System.Collections.Generic.Dictionary"[String,Int]"

    for ($x = 0; $x -lt 16; $x += 1) {
        $col = $leftOffset + $x + ($screenX * 16);

        $rowType = ""

        for ($y = 0; $y -lt 11; $y += 1) {
            $row = $topOffset + $y + ($screenY * 11);
        
            $value = $worksheet.cells.Item($row, $col).Text
            $value = $value.PadRight(4)
            $rowType = $rowType + $value;
    
            IncrementCount $Global:cellTypes $value
            IncrementCount $localCellTypes $value
        }

        IncrementCount $Global:rowTypes $rowType
        IncrementCount $localRowTypes $rowType
    }

    if ($localCellTypes.Count -gt $Global:MaxCellsPerScreen) {
        $Global:MaxCellsPerScreen = $localCellTypes.Count;
    }
}

function Output-Screen() {
    param($screenX, $screenY)
    
    $localCellTypes = New-Object System.Collections.Generic.Dictionary"[String,Int]"
    $localRowTypes = New-Object System.Collections.Generic.Dictionary"[String,Int]"

    Generate-Data "       ; Screen[$($screenX),$($screenY)]"
    Generate-Data "       #DATA.b `$00 ; Palette"

    for ($x = 0; $x -lt 16; $x += 1) {
        $col = $leftOffset + $x + ($screenX * 16);

        $rowType = ""

        for ($y = 0; $y -lt 11; $y += 1) {
            $row = $topOffset + $y + ($screenY * 11);
        
            $value = $worksheet.cells.Item($row, $col).Text
            $value = $value.PadRight(4)
            $rowType = $rowType + $value;
        }

        $indexOfRowType = Get-IndexOfRowType($rowType);
        Generate-Data "       DATA.b `$$($indexOfRowType.ToString("X2")) ; $($rowType)"
    }
    Generate-Data "       ; cellTypes $($localCellTypes.Count)"
    Generate-Data "       ; rowTypes $($localRowTypes.Count)"
    Generate-Data ""
}


$Global:lstFileName = "$($Global:AssemblerPath)\mapdata.asm"
Remove-Item $Global:lstFileName -ErrorAction SilentlyContinue

Write-Host
Write-Host "$([System.DateTime]::Now)"
Write-Host "Summarizing Cells and Columns"
$Global:cellTypes = New-Object System.Collections.Generic.Dictionary"[String,Int]"
$Global:rowTypes = New-Object System.Collections.Generic.Dictionary"[String,Int]"

$maxScreenRows = 8; # 8;
$maxScreenCols = 16; # 16;

# Audit the Screens to get the rowTypes...
for ($y = 0; $y -lt $maxScreenRows; $y += 1) {
    for ($x = 0; $x -lt $maxScreenCols; $x += 1) {
        Audit-Screen $x $y
    }
}

# Now assign the RowTypeIndexes
$Global:rowTypeCells = New-Object System.Collections.Generic.Dictionary"[String,Int]"
$Global:rowTypeIndexes = New-Object System.Collections.Generic.Dictionary"[String,Int]"
$indexNum = 0;
$Global:rowTypes.Keys | ForEach-Object {
    $key = $_;
    $Global:rowTypeIndexes.Add($key, $indexNum);
    $indexNum += 1;

    $rowCells = New-Object System.Collections.Generic.Dictionary"[String,Int]"
    for($index = 0; $index -lt ($key.Length / 4); $index += 1) {
        $part = $key.Substring(4 * $index, 4);
        IncrementCount $rowCells $part
    }

    $rowCellsKey = ""
    $rowCells.Keys | Sort-Object | ForEach-Object {
        $rowCellsKey += $_;
    }
    IncrementCount $Global:rowTypeCells $rowCellsKey
}

Write-Host
Write-Host "==========================================="
$sorted = @()
$Global:rowTypeCells.Keys | ForEach-Object {
    $sorted += @{ Key = $_; Count = ($_.Length / 4) }
}
$sorted | Sort-Object -Property Count -Descending | ForEach-Object {
    Write-Host "   $($_.Count) : $($_.Key)"
}
Write-Host
$sorted | Sort-Object -Property Count -Descending | ForEach-Object {
    $key = $_.Key
    $line = "   @( "
    for($index = 0; $index -lt ($key.Length / 4); $index += 1) {
        $part = $key.Substring(4 * $index, 4);

        $line += "$(Get-IndexOfCellType $part), "
    }
    # Write-Host "$($line.Trim(", ")) ),";
}
# Write-Host
# Write-Host "==========================================="
# Write-Host $Global:rowTypeIndexes

# Now actually output the screens
for ($y = 0; $y -lt $maxScreenRows; $y += 1) {
    for ($x = 0; $x -lt $maxScreenCols; $x += 1) {
        Output-Screen $x $y
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
Write-Host "==========================================="
Generate-Data ""
$maxRowCells = 0
$Global:rowTypes.Keys | ForEach-Object {
    Generate-Data "      ; $($_) : $($Global:rowTypes[$_])"
    $line = "      #DATA.b "
    $key = $_;
    $rowCells = New-Object System.Collections.Generic.Dictionary"[String,Int]";
    
    for($index = 0; $index -lt ($key.Length / 4); $index += 1) {
        $part = $key.Substring(4 * $index, 4);
        $cellTypeIndex = Get-IndexOfCellType $part
        $line += "`$$($cellTypeIndex.ToString("X2")), "

        IncrementCount $rowCells $part
    }
    # Write-Host $line.TrimEnd(", ")
    #Generate-Data $line.TrimEnd(", ")
    # 1st nibble => TileSet => 11 more nibbles for a total of 12 nibbles or 6 bytes
    Generate-Data "      ; # rowCells = $($rowCells.Count)"
    Generate-Data "      #DATA.b `$00, `$00, `$00, `$00, `$00, `$00"

    if ($rowCells.Count -gt $maxRowCells) { $maxRowCells = $rowCells.Count; }
}
Write-Host "==========================================="
Write-Host
Write-Host "$([System.DateTime]::Now)"
Write-Host "maxRowCells = $($maxRowCells)"
Generate-Data ""
Generate-Data "      ; Tilesets (16)"
for($index = 0; $index -lt 16; $index += 1) {
    Generate-Data "      #DATA.b `$00, `$00, `$00, `$00, `$00, `$00, `$00, `$00"
}

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