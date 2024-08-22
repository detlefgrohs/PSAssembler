


$Global:Rows = @(
    @( 1, 6, 7, 13, 15, 12, 14 ),
    @( 1, 6, 7, 23, 29, 22 ),
    @( 1, 6, 7, 24, 31, 26 ),
    @( 1, 6, 7, 24, 27, 26 ),
    @( 1, 6, 7, 21, 28, 20 ),
    @( 1, 6, 7, 24, 30, 26 ),
    @( 1, 36, 35, 6, 7 ),
    @( 1, 34, 40, 2, 6 ),
    @( 1, 38, 37, 6, 7 ),
    @( 1, 34, 2, 6, 24 ),
    @( 1, 34, 2, 6, 39 ),
    @( 1, 6, 7, 24, 27 ),
    @( 1, 6, 7, 15, 14 ),
    @( 1, 10, 11, 6, 7 ),
    @( 1, 10, 6, 24, 26 ),
    @( 1, 34, 6, 7, 16 ),
    @( 1, 2, 6, 13, 12 ),
    @( 1, 34, 6, 7, 39 ),
    @( 1, 6, 24, 27, 26 ),
    @( 1, 6, 7, 13, 12 ),
    @( 1, 11, 6, 24, 26 ),
    @( 1, 6, 7, 21, 28 ),
    @( 1, 11, 6, 7, 19 ),
    @( 1, 11, 6, 7, 9 ),
    @( 1, 10, 6, 7, 8 ),
    @( 1, 6, 24, 26 ),
    @( 1, 11, 6, 9 ),
    @( 1, 3, 24, 27 ),
    @( 1, 6, 28, 20 ),
    @( 1, 10, 6, 7 ),
    @( 1, 2, 24, 26 ),
    @( 1, 11, 6, 7 ),
    @( 1, 10, 6, 9 ),
    @( 1, 6, 7, 18 ),
    @( 1, 6, 7, 3 ),
    @( 1, 3, 24, 26 ),
    @( 1, 3, 29, 22 ),
    @( 1, 6, 7, 17 ),
    @( 1, 6, 7, 25 ),
    @( 1, 3, 23, 29 ),
    @( 1, 11, 6, 22 ),
    @( 1, 10, 6, 20 ),
    @( 1, 10, 6, 8 ),
    @( 1, 34, 6, 7 ),
    @( 1, 2, 6, 7 ),
    @( 1, 6, 7, 19 ),
    @( 1, 6, 7, 8 ),
    @( 1, 6, 7, 9 ),
    @( 1, 6, 7, 27 ),
    @( 1, 3, 28, 20 ),
    @( 1, 3, 21, 28 ),
    @( 1, 11, 6, 8 ),
    @( 1, 19, 3 ),
    @( 1, 24, 27 ),
    @( 24, 28, 31 ),
    @( 1, 24, 31 ),
    @( 1, 24, 30 ),
    @( 1, 17, 3 ),
    @( 1, 4, 24 ),
    @( 24, 30, 29 ),
    @( 1, 6, 8 ),
    @( 1, 21, 28 ),
    @( 24, 28, 33 ),
    @( 1, 10, 6 ),
    @( 5, 6, 7 ),
    @( 1, 2, 6 ),
    @( 1, 6, 7 ),
    @( 1, 6, 19 ),
    @( 1, 24, 26 ),
    @( 1, 24, 32 ),
    @( 1, 6, 9 ),
    @( 1, 6, 18 ),
    @( 1, 11, 6 ),
    @( 6, 8, 24 ),
    @( 1, 6, 27 ),
    @( 1, 6, 17 ),
    @( 1, 6 ),
    @( 6, 24 ),
    @( 1, 2 ),
    @( 5, 6 ),
    @( 4, 29 ),
    @( 4, 24 ),
    @( 1, 18 ),
    @( 1, 3 ),
    @( 6, 7 ),
    @( 1 ),
    @( 28 ),
    @( 3 ),
    @( 24 ),
    @( 5 ),
    @( 6 )
);

$Global:RowSets = @()

function Array-ToString() {
    param($set)
    return "@( $($set -join ", ") )"
}

# Write-Host "`$Global:Rows = @("
# $Global:Rows | ForEach-Object {
#     Write-Host "   $(Array-ToString $_),"
# }
# Write-Host ")"

function Array-Intersection() {
    param($setA, $setB)

    $intersection = @();
    $setA | ForEach-Object {
        $aValue = $_;
        $setB | ForEach-Object {
            $bValue = $_;
            if ($aValue -eq $bValue) { $intersection += $aValue; }
        }
    }
    return $intersection
}
function Array-Difference() {
    param($setA, $setB)

    $difference = @();
    $setA | ForEach-Object {
        $aValue = $_;
        $found = $false;
        $setB | ForEach-Object {
            $bValue = $_;
            if ($aValue -eq $bValue) { $found = $true; }
        }
        if (-not $found) { $difference += $aValue; }
    }
    return $difference
}

function Find-RowTileSet() {
    param($row)

    $rowSet = -1;
    $index = 0;
    $Global:RowSets | ForEach-Object {
        if ($rowSet -eq -1) {
            $intersection = Array-Intersection $_ $row
            if ($intersection.Count -eq $row.Count) { $rowSet = $index; }
        }
        $index += 1;
    }
    return $rowSet;
}

$Global:Rows | ForEach-Object {
    $row = $_

    Write-Host "Checking $(Array-ToString $row)"

    $rowSet = Find-RowTileSet $row
    if ($rowSet -eq -1) {
        # Not found so add or wedge...
        Write-Host "   Not found in RowTileSet"
        # Search for a Wedge location
        $wedgeLocation = -1;
        $index = 0;
        $Global:RowSets | ForEach-Object {
            $Global:RowSets | ForEach-Object {
                $rowSet = $_;
                if ($wedgeLocation -eq -1 ) {
                    $difference = Array-Difference $row $rowSet
                    if ($difference.Count -le (8 - $rowSet.Count)) {
                        Write-Host "   $(Array-ToString $row) - $(Array-ToString $rowSet) => $(Array-ToString $difference)"
                        $wedgeLocation = $index;
                    }
                }
                $index += 1;
            }
        }
        if ($wedgeLocation -eq -1) {
            # Insert At End
            Write-Host "   Insert at end $(Array-ToString $row)"
            $Global:RowSets += @(,$row);
        } else {
            # Insert into Wedge location
            Write-Host "   Wedging at $($wedgeLocation)"

            $difference = Array-Difference $row $Global:RowSets[$wedgeLocation]
            $difference | ForEach-Object {
                $Global:RowSets[$wedgeLocation] += $_;
            }
        }
    } else {
        Write-Host "   Found at $($rowSet)"
    }
}

Write-Host
Write-Host "`$Global:RowSets = @("
$Global:RowSets | ForEach-Object {
    Write-Host "   $(Array-ToString $_),"
}
Write-Host ")"

Write-Host
$Global:Rows | ForEach-Object {
    Write-Host "$(Find-RowTileSet $_) : $(Array-ToString $_)"
}

#Array-Intersection (1, 2, 3) (1, 2, 4)
#Array-Difference (1, 2, 3, 4, 5) (1, 2, 4)

#Array-ToString (1, 3, 8)
