
; ===========================================================================
; Will load 10 bytes with the tiles for a tile that will be in the 
;            0 1 2 3
;            4 5 6 7
;              8 9
;
; ===========================================================================
                ; LDA.#   0
                ; STA     .TILE_VALUE
                ; LDA.#   1
                ; STA     .TILE_VALUE + 1
                ; LDA.#   2
                ; STA     .TILE_VALUE + 2
                ; LDA.#   3
                ; STA     .TILE_VALUE + 3
                
                ; RTS

GENERATE_TILE:
                LDA     .CURRENT
                BEQ     .CURRENT_0
                JMP     .CURRENT_1

.CURRENT_0:     LDX.#   0

        @CHECK2VALUE(%00010000,$10,$00)                                         ; 0
        @CHECK4VALUE(%10010000,%10010000,$11,%10000000,$12,%00010000,$11,$01)   ; 1
        @CHECK4VALUE(%11000000,%11000000,$0E,%10000000,$13,%01000000,$0E,$02)   ; 2
        @CHECK2VALUE(%01000000,$0F,$03)                                         ; 3

        @CHECK4VALUE(%00010010,%00010010,$08,%00010000,$13,%00000010,$0C,$02)   ; 4
        @CHECK2VALUE(%00000010,$0D,$03)                                         ; 5
        @CHECK2VALUE(%00001000,$0A,$00)                                         ; 6
        @CHECK4VALUE(%01001000,%01001000,$09,%01000000,$12,%00001000,$0B,$01)   ; 7
        
        @CHECK4VALUE(%00000011,%00000011,$07,%00000010,$11,%00000001,$0B,$01)   ; 9
        @CHECK4VALUE(%00001001,%00001001,$04,%00001000,$0E,%00000001,$0C,$02)   ; A

                RTS
#STATS.PUSH
.CURRENT_1:     LDX.#   0

        @CHECK2VALUE(%00010000,$06,$0A)                                         ; 0
        @CHECK4VALUE(%10010000,%10010000,$07,%10000000,$07,%00010000,$09,$0B)   ; 1
        @CHECK4VALUE(%11000000,%11000000,$04,%10000000,$08,%01000000,$04,$0C)   ; 2
        @CHECK2VALUE(%01000000,$05,$0D)                                         ; 3

        @CHECK4VALUE(%00010010,%00010010,$04,%00010000,$0E,%00000010,$04,$0E)   ; 4
        @CHECK2VALUE(%00000010,$05,$0F)                                         ; 5
        @CHECK2VALUE(%00001000,$06,$10)                                         ; 6
        @CHECK4VALUE(%01001000,%01001000,$07,%01000000,$11,%00001000,$07,$11)   ; 7
        
        @CHECK4VALUE(%00000011,%00000011,$07,%00000010,$11,%00000001,$09,$12)   ; 9
        @CHECK4VALUE(%00001001,%00001001,$04,%00001000,$08,%00000001,$0E,$13)   ; A

                RTS

.CURRENT:       DATA.b  $00
.NEIGHBORS:     DATA.b  $00
.TILE_VALUE:    PAD     10

#STATS.SAVE GENERATE_TILE
#STATS.POP


; ===========================================================================
; A has row of TILE_DATA
; X, Y has offset
GET_TILE_DATA_OFFSET:
                    ROL.A
                    TAX
                    LDA,X   TILE_DATA_OFFSETS + 1
                    TAY
                    LDA,X   TILE_DATA_OFFSETS
                    TAX
                    RTS

TILE_DATA_OFFSETS:
#CODE
"               ; Offsets into 23x23 3 Digit Array"
for ($index = 0; $index -lt 23; $index += 1) {
    $offset = $index * (23 * 3)
    "               DATA `$$($offset.ToString('X4'))     ; $($index.ToString('00')) => $offset"
}
#ENDC
; ===========================================================================

#CODE
"               ; Tile Data (23 x 23) x 3"
    for ($rowIndex = 0; $rowIndex -lt 23; $rowIndex += 1) {


    }
#ENDC
