
; ===========================================================================
DRAW_TILE:      LDA     .OFFSET
                STA     SET_CELL_NO_COLOR.OFFSET
                LDA     .OFFSET + 1
                STA     SET_CELL_NO_COLOR.OFFSET + 1

                LDA.#   0
                STA     .INDEX

.LOOP1:         LDX     .INDEX
                LDA,X   GENERATE_TILE.TILE_VALUE
                STA     SET_CELL_NO_COLOR.TILE_NUMBER
                JSR     SET_CELL_NO_COLOR

                @INC_WORD_BY_ONE(SET_CELL_NO_COLOR.OFFSET)
                INC     .INDEX
                LDA     .INDEX
                CMP.#   4
                BNE     .LOOP1

                @ADD_WORD(SET_CELL_NO_COLOR.OFFSET,36)

.LOOP2:         LDX     .INDEX
                LDA,X   GENERATE_TILE.TILE_VALUE
                STA     SET_CELL_NO_COLOR.TILE_NUMBER
                JSR     SET_CELL_NO_COLOR

                @INC_WORD_BY_ONE(SET_CELL_NO_COLOR.OFFSET)
                INC     .INDEX
                LDA     .INDEX
                CMP.#   8
                BNE     .LOOP2

                @ADD_WORD(SET_CELL_NO_COLOR.OFFSET,37)

.LOOP3:         LDX     .INDEX
                LDA,X   GENERATE_TILE.TILE_VALUE
                STA     SET_CELL_NO_COLOR.TILE_NUMBER
                JSR     SET_CELL_NO_COLOR

                @INC_WORD_BY_ONE(SET_CELL_NO_COLOR.OFFSET)
                INC     .INDEX
                LDA     .INDEX
                CMP.#   10
                BNE     .LOOP3

                RTS

.INDEX:         DATA.b  $00
.OFFSET:        DATA    $0000
