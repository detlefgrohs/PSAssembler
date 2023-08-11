; ===========================================================================
CLEAR_SCREEN:
                ; offsetIndex := 0;
                LDA.#   $00
                STA     .INDEX
                STA     .INDEX + 1

                LDA.#   0
                STA     SET_CELL.TILE_NUMBER
                LDA.#   VICII_COLOR_BLACK
                STA     SET_CELL.COLOR_1
                LDA.#   VICII_COLOR_GREEN
                STA     SET_CELL.COLOR_2
                LDA.#   VICII_COLOR_PURPLE
                STA     SET_CELL.COLOR_3

                ; BEGIN
.LOOP:          ; SetCell(offsetIndex, #CharacterTileSet, 0, Screen_BG_Col, Black, Black);
                LDA     .INDEX
                STA     SET_CELL.OFFSET
                LDA     .INDEX + 1
                STA     SET_CELL.OFFSET + 1

                JSR     SET_CELL

                @INC_WORD_BY_ONE(.INDEX)            ; 	Inc(offsetIndex);		
                @CMP_WORD(.INDEX, 1000, .LOOP)      ; WHILE (offsetIndex < 1000) DO
                ; END;
                RTS

.INDEX:         DATA    $0000