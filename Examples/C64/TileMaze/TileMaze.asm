* = $0801

#INCLUDE ..\..\includes\includes.h
#INCLUDE macros.h

                @BASICSTUB()

START:
                JSR     INITIALIZE
                ;JSR     SCREEN_OFF
                JSR     DRAW_SCREEN
                ;JSR     SCREEN_ON

                SEI                             ; Turn off Interrupts
                LDA.#   $7F
                STA     $DC0D
                STA     $DD0D

                LDA.#   1
                STA     GENERATE_TILE.CURRENT
                LDA.#   %11111111
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
                @ADD_WORD(DRAW_TILE.OFFSET,2)
                JMP     .CONTINUE

.ODD_ROW:       LDA.#   9
                STA     .COL_INDEX
                @ADD_WORD(DRAW_TILE.OFFSET,2)

.CONTINUE:      LDA     .ROW_INDEX
                CMP.#   24
                BNE     .ROW_LOOP

                LDA.#   0
                STA     GENERATE_TILE.CURRENT
                LDA.#   %11111111
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

                @SET_WORD(DRAW_TILE.OFFSET,180)
                JSR     DRAW_TILE

                @SET_WORD(DRAW_TILE.OFFSET,180 - 16)
                JSR     DRAW_TILE

                @SET_WORD(DRAW_TILE.OFFSET,180 + 240)
                JSR     DRAW_TILE

                @SET_WORD(DRAW_TILE.OFFSET,180 + 240 - 16)
                JSR     DRAW_TILE

                LDA.#   VICII_COLOR_RED
                STA     VICII_BORDER_COLOR

                LDA     GENERATE_TILE.CURRENT
                BEQ     .SET

                LDA.#   0
                STA     GENERATE_TILE.CURRENT
                JMP     .ANIMATE_LOOP

.SET:           LDA.#   1
                STA     GENERATE_TILE.CURRENT
                JMP     .ANIMATE_LOOP

                JMP     CURADDR

.COL_INDEX:         DATA.b  $00
.ROW_INDEX:         DATA.b  $00

WAIT_FOR_RASTER_LINE: ; Only works for Rasters < 256
                LDA.#   $80
.LOOP:          CPY     VICII_RASTER
                BNE     .LOOP
                AND     VICII_CONTROL_1
                BNE     .LOOP

                RTS

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


; ===========================================================================
INITIALIZE:
	            ; jiffyTime := $A0;
		
	            ; SetBitMapMode();
                LDA.#   $3B
                STA     $D011

                ; SetMultiColorMode();
                LDA.#   16
                ORA     $D016
                STA     $D016

                ; SetBank(VIC_BANK1);
                LDA.#   $2
                STA     $DD00

                ; Poke(^$D018, 0, Peek(^$D018, 0) | $08);
                ; What is this?
                LDA     $D018
                ORA.#   $8
                STA     $D018

                ; Screen_BG_Col := Cyan;
                ; Screen_FG_Col := Cyan;
                LDA.#   VICII_COLOR_CYAN
                STA     $D020
                STA     $D021

                ; SetMemoryConfig(1, 1, 0);	// IO, Kernal, BASIC
                LDA.ZP  $01
                AND.#   %11111000
                ORA.#   %110
                STA.ZP  $01

                ; idleFrame := 0;
                ; walkingFrame := 0;

                RTS

; ===========================================================================
SCREEN_OFF:     LDA     $D011
                AND.#   %01101111
                STA     $D011

                RTS

; ===========================================================================
SCREEN_ON:      LDA     $D011
                ORA.#   %00010000
                AND.#   %01111111
                STA     $D011
                
                RTS

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


; ===========================================================================
#INCLUDE setcell.asm

#INCLUDE generatetile.asm

; ===========================================================================
CHARDATA:       
                #LOADBINARY     TileMaze-Chars.bin
MAPDATA:        
                #LOADBINARY     TileMaze-Map.bin
MAPEND:

TILEDATA:       #LOADBINARY     TileMaze-TileData.bin
SCROFFSETLO:    #LOADBINARY     TileMaze-ScrOffsetLo.bin
SCROFFSETHI:    #LOADBINARY     TileMaze-ScrOffsetHi.bin
