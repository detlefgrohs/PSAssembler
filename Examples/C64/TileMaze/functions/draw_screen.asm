; ===========================================================================
DRAW_SCREEN:
                JSR     CLEAR_SCREEN

                LDA.#   0
                STA     SET_CELL_NO_COLOR.OFFSET
                STA     SET_CELL_NO_COLOR.OFFSET + 1

                LDA.#   @LO(MAPDATA)
                STA     .LD + 1
                LDA.#   @HI(MAPDATA)
                STA     .LD + 2

.LOOP:
.LD:            LDA     $0000
                STA     SET_CELL_NO_COLOR.TILE_NUMBER
                JSR     SET_CELL_NO_COLOR

                @INC_WORD_BY_ONE(SET_CELL_NO_COLOR.OFFSET) 
                @INC_WORD_BY_ONE(.LD + 1) 

                LDA     .LD + 2
                CMP.#   @HI(MAPEND)
                BNE     .LOOP
                LDA     .LD + 1
                CMP.#   @LO(MAPEND)
                BNE     .LOOP

                RTS