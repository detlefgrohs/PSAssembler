* = $0801

#INCLUDE ..\..\includes\includes.h
#INCLUDE macros.h

                @BASICSTUB()

START:
                JSR     INITIALIZE
                @SCREEN_OFF()
                JSR     DRAW_SCREEN
                @SCREEN_ON()

                ; ==============================================================
                SEI                             ; Turn off Interrupts
                LDA.#   $7F
                STA     $DC0D
                STA     $DD0D
                ; ==============================================================

                LDA.#   0
                STA     GENERATE_TILE.CURRENT
                LDA.#   0 ; %11111111
                STA     GENERATE_TILE.NEIGHBORS
                JSR     GENERATE_TILE

                LDA.#   0
                STA     DRAW_TILE.OFFSET
                STA     DRAW_TILE.OFFSET + 1

                LDA.#   10
                STA     .COL_INDEX
.ROW_LOOP:      
.COL_LOOP:
                JSR     DRAW_TILE
                @ADD_WORD(DRAW_TILE.OFFSET, 4)

                DEC     .COL_INDEX
                BNE     .COL_LOOP

                INC     .ROW_INDEX
                LDA     .ROW_INDEX
                AND.#   %00000001
                BNE     .ODD_ROW

                LDA.#   10
                STA     .COL_INDEX
                @ADD_WORD(DRAW_TILE.OFFSET, 2)
                JMP     .CONTINUE

.ODD_ROW:       LDA.#   9
                STA     .COL_INDEX
                @ADD_WORD(DRAW_TILE.OFFSET, 2)

.CONTINUE:      LDA     .ROW_INDEX
                CMP.#   24
                BNE     .ROW_LOOP

                ; ==============================================================
                ; Now handle the bottom corner cells
                @SET_WORD(SET_CELL_NO_COLOR.OFFSET, (40*24))
                LDA.#   0 ; $06
                STA     SET_CELL_NO_COLOR.TILE_NUMBER
                JSR     SET_CELL_NO_COLOR

                @SET_WORD(SET_CELL_NO_COLOR.OFFSET, ((40*24) + 39))
                LDA.#   3 ; $05
                STA     SET_CELL_NO_COLOR.TILE_NUMBER
                JSR     SET_CELL_NO_COLOR
                ; ==============================================================

                LDA.#   0
                STA     GENERATE_TILE.CURRENT
                LDA.#   0 ; %11111111
                STA     GENERATE_TILE.NEIGHBORS

.ANIMATE_LOOP:  LDY.#   0
                JSR     WAIT_FOR_RASTER_LINE
                
                LDA.#   VICII_COLOR_BLACK
                STA     VICII_BORDER_COLOR

                LDY.#   50
                JSR     WAIT_FOR_RASTER_LINE

                LDX.#   5
.NOP_LOOP:      NOP
                DEX
                BPL     .NOP_LOOP

                LDA.#   VICII_COLOR_WHITE
                STA     VICII_BORDER_COLOR

                JSR     GENERATE_TILE

                ; @SET_WORD(DRAW_TILE.OFFSET, 180)
                @SET_WORD(DRAW_TILE.OFFSET, 180 + 240)
                JSR     DRAW_TILE

                ; @SET_WORD(DRAW_TILE.OFFSET, 180 - 16)
                ; JSR     DRAW_TILE

                ; @SET_WORD(DRAW_TILE.OFFSET, 180 + 16)
                ; JSR     DRAW_TILE

                ; @SET_WORD(DRAW_TILE.OFFSET, 180 + 240 - 16)
                ; JSR     DRAW_TILE

                LDA.#   VICII_COLOR_RED
                STA     VICII_BORDER_COLOR

                LDA     GENERATE_TILE.CURRENT
                BEQ     .SET

                ;JMP     .ANIMATE_LOOP

                LDA.#   0
                STA     GENERATE_TILE.CURRENT
                JMP     .ANIMATE_LOOP

.SET:           LDA.#   1
                STA     GENERATE_TILE.CURRENT
                JMP     .ANIMATE_LOOP

                JMP     CURADDR

.COL_INDEX:         DATA.b  $00
.ROW_INDEX:         DATA.b  $00

; ===========================================================================
#INCLUDE functions\setcell.asm
#INCLUDE functions\generatetile.asm
#INCLUDE functions\drawtile.asm
#INCLUDE functions\wait_for_raster_line.asm
#INCLUDE functions\initialize.asm
#INCLUDE functions\clear_screen.asm
#INCLUDE functions\draw_screen.asm
#INCLUDE functions\draw_board.asm
; ===========================================================================
CHARDATA:       #LOADBINARY     TileMaze-Chars.bin
MAPDATA:        #LOADBINARY     TileMaze-Map.bin
MAPEND:

TILEDATA:       #LOADBINARY     TileMaze-TileData.bin
TILEEND:

SCROFFSETLO:    #LOADBINARY     TileMaze-ScrOffsetLo.bin
SCROFFSETHI:    #LOADBINARY     TileMaze-ScrOffsetHi.bin

DUMMY1:         #TEXT           "Data"

ENDPRG: