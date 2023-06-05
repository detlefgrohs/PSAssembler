* = $0801


#MACRO SET_CELL(OFFSET,TILE_NUMBER,C1,C2,C3)
                LDA.#   @LO(@OFFSET)
                STA     SET_CELL.OFFSET
                LDA.#   @HI(@OFFSET)
                STA     SET_CELL.OFFSET + 1

                LDA.#   @TILE_NUMBER
                STA     SET_CELL.TILE_NUMBER

                LDA.#   @C1
                STA     SET_CELL.COLOR_1
                LDA.#   @C2
                STA     SET_CELL.COLOR_2
                LDA.#   @C3
                STA     SET_CELL.COLOR_3

                JSR     SET_CELL
#ENDM

#INCLUDE ..\..\includes\includes.h

                @BASICSTUB()

START:

                JSR     INITIALIZE
                JSR     SCREEN_OFF
                JSR     DRAW_SCREEN
                JSR     SCREEN_ON

                SEI                             ; Turn off Interrupts
                LDA.#   $7F
                STA     $DC0D
                STA     $DD0D

.LOOP:          LDY.#   0
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

                JSR     ANIMATE

                LDA.#   VICII_COLOR_RED
                STA     VICII_BORDER_COLOR

;                 LDX.#   20
;                 LDY.#   250
                
; .WAIT_LOOP:     JSR     WAIT_FOR_RASTER_LINE
;                 DEX
;                 BPL     .WAIT_LOOP

                JMP     .LOOP

                RTS

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
                LDA.#   $3
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

SCREEN_OFF:     LDA     $D011
                AND.#   %01101111
                STA     $D011

                RTS

SCREEN_ON:      LDA     $D011
                ORA.#   %00010000
                AND.#   %01111111
                STA     $D011
                
                RTS

DRAW_SCREEN:
                JSR     CLEAR_SCREEN

                LDA.#   0
                STA     SET_CELL.OFFSET
                LDA.#   0
                STA     SET_CELL.OFFSET + 1
                
                LDA.#   225
                STA     SET_CELL.TILE_NUMBER
                LDA.#   VICII_COLOR_WHITE
                STA     SET_CELL.COLOR_1
                LDA.#   VICII_COLOR_BLACK
                STA     SET_CELL.COLOR_2
                LDA.#   VICII_COLOR_LIGHT_GREY
                STA     SET_CELL.COLOR_3

.LOOP:
                JSR     SET_CELL

                @ADD_WORD(SET_CELL.OFFSET, 40)

                LDA     SET_CELL.OFFSET + 1
                CMP.#   @HI(1000)
                BNE     .LOOP
                LDA     SET_CELL.OFFSET
                CMP.#   @LO(1000)
                BNE     .LOOP

                RTS

CLEAR_SCREEN:
                ; offsetIndex := 0;
                LDA.#   $00
                STA     .INDEX
                STA     .INDEX + 1

                LDA.#   0
                STA     SET_CELL.TILE_NUMBER
                LDA.#   VICII_COLOR_WHITE
                STA     SET_CELL.COLOR_1
                LDA.#   VICII_COLOR_BLACK
                STA     SET_CELL.COLOR_2
                LDA.#   VICII_COLOR_LIGHT_GREY
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

ANIMATE:        LDA     .IDLE_INDEX
                STA     DRAW_CHAR.CHAR_NUMBER
                JSR     DRAW_CHAR

                CLC
                LDA     .IDLE_INDEX
                ADC     .IDLE_INCREMENT
                CMP.#   9 * 25
                BNE     .CONTINUE

                LDA.#   6 * 25
.CONTINUE:      STA     .IDLE_INDEX

                RTS

.IDLE_INDEX:    DATA.b  $00
.IDLE_INCREMENT:DATA.b  25

DRAW_CHAR:      ; ToDo: Calculate offset by row and column
                LDA.#   8
                STA     SET_CELL_NO_COLOR.OFFSET
                LDA.#   0
                STA     SET_CELL_NO_COLOR.OFFSET + 1

                LDA    .CHAR_NUMBER
                STA     SET_CELL_NO_COLOR.TILE_NUMBER
                LDA.#   0
                STA     SET_CELL_NO_COLOR.TILE_NUMBER + 1

                LDA.#   (5 * 8) - 1
                STA     SET_CELL_NO_COLOR.LOOP_COUNT

                JSR     SET_CELL_NO_COLOR

                @ADD_WORD(SET_CELL_NO_COLOR.OFFSET, 40)
                @ADD_WORD(SET_CELL_NO_COLOR.TILE_NUMBER, 5)
                JSR     SET_CELL_NO_COLOR

                @ADD_WORD(SET_CELL_NO_COLOR.OFFSET, 40)
                @ADD_WORD(SET_CELL_NO_COLOR.TILE_NUMBER, 5)
                JSR     SET_CELL_NO_COLOR

                @ADD_WORD(SET_CELL_NO_COLOR.OFFSET, 40)
                @ADD_WORD(SET_CELL_NO_COLOR.TILE_NUMBER, 5)
                JSR     SET_CELL_NO_COLOR

                @ADD_WORD(SET_CELL_NO_COLOR.OFFSET, 40)
                @ADD_WORD(SET_CELL_NO_COLOR.TILE_NUMBER, 5)
                JSR     SET_CELL_NO_COLOR

                RTS

.CHAR_NUMBER:   DATA.b  $00

; ===========================================================================
SET_CELL:       ; screenLocation := $4400 + offset;
                @SET_WORD(.SL_ST + 1, $4400)
                CLC
                LDA     .SL_ST + 1
                ADC     .OFFSET
                STA     .SL_ST + 1
                LDA     .SL_ST + 2
                ADC     .OFFSET + 1
                STA     .SL_ST + 2
                ; colorLocation := $D800 + offset;
                @SET_WORD(.CL_ST + 1, $D800)
                CLC
                LDA     .CL_ST + 1
                ADC     .OFFSET
                STA     .CL_ST + 1
                LDA     .CL_ST + 2
                ADC     .OFFSET + 1
                STA     .CL_ST + 2

                ; bitmapLocation := $6000 + (offset * 8);
                LDA     .OFFSET
                STA     .BMP_ST + 1
                LDA     .OFFSET + 1
                STA     .BMP_ST + 2
                @ROL_WORD(.BMP_ST + 1)
                @ROL_WORD(.BMP_ST + 1)
                @ROL_WORD(.BMP_ST + 1)
                CLC
                LDA     .BMP_ST + 1
                ADC.#   @LO($6000)
                STA     .BMP_ST + 1
                LDA     .BMP_ST + 2
                ADC.#   @HI($6000)
                STA     .BMP_ST + 2

                ; tileLocation := tilesetLocation + (tileNumber << 3);
                LDA     .TILE_NUMBER
                STA     .TL_LD + 1
                LDA.#   0
                STA     .TL_LD + 2
                @ROL_WORD(.TL_LD + 1)
                @ROL_WORD(.TL_LD + 1)
                @ROL_WORD(.TL_LD + 1)
                CLC
                LDA     .TL_LD + 1
                ADC.#   @LO(CHARDATA)
                STA     .TL_LD + 1
                LDA     .TL_LD + 2
                ADC.#   @HI(CHARDATA)
                STA     .TL_LD + 2

                LDX.#   7
.LOOP:          ; FOR bitmapIndex := 0 TO 8 DO
                ; 	bitmapLocation[bitmapIndex] := tileLocation[bitmapIndex];
.TL_LD:         LDA,X   $0000
.BMP_ST:        STA,X   $0000
                DEX
                BPL     .LOOP

                ; colorLocation[0] := c1;
                LDA     .COLOR_1
.CL_ST:         STA     $0000
                ; screenLocation[0] := (c2 << 4) | c3;
                LDA     .COLOR_2
                ASL.A
                ASL.A
                ASL.A
                ASL.A
                ORA     .COLOR_3
.SL_ST:         STA     $0000

                RTS

.OFFSET:        DATA    $0000
.TILE_NUMBER:   DATA    $0000
.COLOR_1:       DATA.b  $00
.COLOR_2:       DATA.b  $00
.COLOR_3:       DATA.b  $00


; ===========================================================================
#STATS.PUSH
SET_CELL_NO_COLOR:       ; bitmapLocation := $6000 + (offset * 8);
                LDA     .OFFSET
                STA     .BMP_ST + 1
                LDA     .OFFSET + 1
                STA     .BMP_ST + 2
                @ROL_WORD(.BMP_ST + 1)
                @ROL_WORD(.BMP_ST + 1)
                @ROL_WORD(.BMP_ST + 1)
                CLC
                LDA     .BMP_ST + 1
                ADC.#   @LO($6000)
                STA     .BMP_ST + 1
                LDA     .BMP_ST + 2
                ADC.#   @HI($6000)
                STA     .BMP_ST + 2

                ; tileLocation := tilesetLocation + (tileNumber << 3);
                LDA     .TILE_NUMBER
                STA     .TL_LD + 1
                LDA.#   0
                STA     .TL_LD + 2
                @ROL_WORD(.TL_LD + 1)
                @ROL_WORD(.TL_LD + 1)
                @ROL_WORD(.TL_LD + 1)
                CLC
                LDA     .TL_LD + 1
                ADC.#   @LO(CHARDATA)
                STA     .TL_LD + 1
                LDA     .TL_LD + 2
                ADC.#   @HI(CHARDATA)
                STA     .TL_LD + 2

                LDX     .LOOP_COUNT
#STATS.PUSH
.LOOP:          ; FOR bitmapIndex := 0 TO 8 DO
                ; 	bitmapLocation[bitmapIndex] := tileLocation[bitmapIndex];
.TL_LD:         LDA,X   $0000
.BMP_ST:        STA,X   $0000
                DEX
                BPL     .LOOP
#STATS.LOOP (5 * 8) - 1
#STATS.DETAIL
#STATS.POP
                RTS
#STATS.DETAIL
#STATS.POP

.OFFSET:        DATA    $0000
.TILE_NUMBER:   DATA    $0000
.LOOP_COUNT:    DATA.b  7


WAIT_FOR_RASTER_LINE: ; Only works for Rasters < 256
                LDA.#   $80
.LOOP:          CPY     VICII_RASTER
                BNE     .LOOP
                AND     VICII_CONTROL_1
                BNE     .LOOP

                RTS

CHARDATA:       #LOADBINARY     aleahdumasklop-character.bin



