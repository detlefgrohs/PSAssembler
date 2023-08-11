


; ===========================================================================





                    ;
; ===========================================================================
DRAW_BOARD:         ; Reset Pointers
                    @SET_WORD(.TILEDATA_PTR,TILEDATA)
                    @SET_WORD(.SCROFFSETLO_PTR,SCROFFSETLO)
                    @SET_WORD(.SCROFFSETHI_PTR,SCROFFSETHI)


.TILEDATA_LD:       LDA     $0000
                    BMI     .JMP_INCREMENT      ; High bit set so ignore...
                    JMP     .PROCESS_TILE

.JMP_INCREMENT:     JMP     .INCREMENT

.PROCESS_TILE:      ; In a valid cell, set current...
                    
                    STA     $0000

                    ; Get neightbors...
                    LDA.#   %00000000
                    STA     $0000           ; Clear Neighbors Flag

                    LDA     .TILEDATA_PTR
                    STA     .NEIGHBOR_PTR
                    LDA     .TILEDATA_PTR + 1
                    STA     .NEIGHBOR_PTR + 1
                    @SUBTRACT_WORD(.NEIGHBOR_PTR,24)

                    ; Check NW
                    @CHECK_NEIGHBOR(00,%00000001)
                    ; Check N
                    @CHECK_NEIGHBOR(01,%00000010)
                    ; Check NE
                    @CHECK_NEIGHBOR(02,%00000100)
                    ; Check W
                    @CHECK_NEIGHBOR(23,%00001000)
                    ; Check E
                    @CHECK_NEIGHBOR(25,%00010000)
                    ; Check SW
                    @CHECK_NEIGHBOR(46,%00100000)
                    ; Check S
                    @CHECK_NEIGHBOR(47,%01000000)
                    ; Check SE
                    @CHECK_NEIGHBOR(48,%10000000)

                    ; so now set the offset and update the tile...
.SCROFFSETLO_LD:    LDA     $0000
                    STA     $0000
.SCROFFSETHI_LD:    LDA     $0000
                    STA     $0000 + 1

                    ; Generate Tile
                    ; Draw Tile

.INCREMENT:
                    ; Continue Until we hit TILEEND
                    ; Increment Pointers
                    @INC_WORD_BY_ONE(.TILEDATA_PTR)
                    LDA     .TILEDATA_PTR
                    CMP     @LO(TILEEND)
                    BNE     .CONTINUE_INCR
                    LDA     .TILEDATA_PTR + 1
                    CMP     @HI(TILEEND)
                    BEQ     .DONE

.CONTINUE_INCR:     ; Not done so increment the rest of the pointers...
                    @INC_WORD_BY_ONE(.SCROFFSETLO_PTR)
                    @INC_WORD_BY_ONE(.SCROFFSETHI_PTR)

                    JMP     $0000

.DONE:

                    RTS

.GET_NEIGHBOR:      LDA,X   $0000
                    RTS
DRAW_BOARD.NEIGHBOR_PTR = DRAW_BOARD.GET_NEIGHBOR + 1

; Local Variables
DRAW_BOARD.TILEDATA_PTR = DRAW_BOARD.TILEDATA_LD + 1
DRAW_BOARD.SCROFFSETLO_PTR = DRAW_BOARD.SCROFFSETLO_LD + 1
DRAW_BOARD.SCROFFSETHI_PTR = DRAW_BOARD.SCROFFSETHI_LD + 1

