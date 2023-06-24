



#CODE
"; Code Line 1"
"; Code Line 2"
"; Code Line 3"
for ($index = 0; $index -lt 5; $index += 1) {
    "       LDA `$$($index)"
}

for ($index = 0; $index -lt 16; $index += 1) {
    "       DATA.b  `$$($index.ToString('X2'))"
}
#ENDC

; A
#STATS.PUSH
#STATS
; B
#CODE
"               ; Tile Data (23 x 23) x 3"
    for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {
        for ($colIndex = 0; $colIndex -lt 23; $colIndex += 1) {
            $offset = ($rowIndex * 3 *23) + ($colIndex * 3)
            "       DATA    `$$($offset.ToString('X4'))     ; $($rowIndex.ToString('00')),$($colIndex.ToString('00')) => $offset"
            "       DATA.b  `$0"
        }
    }
#ENDC
; C
#STATS
#STATS.POP
; D


#STATS.PUSH
            DATA    $0000
            DATA.b  $00
#STATS
#STATS.POP
; E
