* = $0801

#INCLUDE ..\..\includes\includes.h

CHROUT  = $FFD2

#MACRO PRINT_INTEGER(ADDRESS)
                LDX     @ADDRESS
                LDA     @ADDRESS + 1
                JSR     $BDCD
#ENDM

#MACRO PRINT_BYTE(ADDRESS)
                LDX     @ADDRESS
                LDA.#   $00
                JSR     $BDCD
#ENDM

#MACRO PRINT_NEWLINE()
                JSR     $AAD7 ; Print NewLine
#ENDM

#MACRO ADD_MWORD_PLUS_MWORD(ADDRESS,MADDRESS)
                CLC
                LDA             @ADDRESS
                ADC             @MADDRESS
                STA             @ADDRESS
                LDA             @ADDRESS + 1
                ADC             @MADDRESS + 1
                STA             @ADDRESS + 1
#ENDM

#MACRO  NEGATIVE(VALUE)
($10000 - @VALUE)
#ENDM

                @BASICSTUB()
START:
                ; LDA.#   '0'
                ; JSR     CHROUT

                ; @PRINT_NEWLINE()

                ; @PRINT_BYTE(TILEDATA + ((23 * 0) + 10))
                ; @PRINT_NEWLINE()

                SEI                             ; Turn off Interrupts
                LDA.#   $7F
                STA     $DC0D
                STA     $DD0D

.MAINLOOP:
                LDY.#   0
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

                LDA.#   @LO(TILEDATA)
                STA     .LOCLD + 1
                LDA.#   @HI(TILEDATA)
                STA     .LOCLD + 2

                LDA.#   10
                STA     .ROWINDEX
.ROWLOOP:
                LDA.#   $FF
                STA     .COLINDEX

.COLLOOP:       INC     .COLINDEX
                LDX     .COLINDEX
                CPX.#   23
                BEQ     .NEXT_ROW

.LOCLD:         LDA,X   $0000

                BMI     .DIGIT1
                LDA.#   '0'
                JMP     .OUT
.DIGIT1:        LDA.#   '1'
.OUT:           ;JSR     CHROUT

                JMP     .COLLOOP
                ;@INC_WORD_BY_ONE(.LOCLD + 1)

                ; INC     .COLINDEX
                ; CMP.#   23
                ; BNE     .COLLOOP

.NEXT_ROW:
                ;@PRINT_NEWLINE();
                @ADD_WORD(.LOCLD + 1,23)

                DEC     .ROWINDEX
                BPL     .ROWLOOP

                LDA.#   VICII_COLOR_RED
                STA     VICII_BORDER_COLOR

                JMP     .MAINLOOP

                RTS

.COLINDEX:      DATA.b  $00
.ROWINDEX:      DATA.b  $00


WAIT_FOR_RASTER_LINE: ; Only works for Rasters < 256
                LDA.#   $80
.LOOP:          CPY     VICII_RASTER
                BNE     .LOOP
                AND     VICII_CONTROL_1
                BNE     .LOOP

                RTS

POPULATE_NEIGHBORS_FLAG:
#STATS.PUSH
                LDA.#   $00
                STA     NEIGHBORS

                LDA     LOCATION
                STA     GET_TILE_DATA.LOCATION
                LDA     LOCATION + 1
                STA     GET_TILE_DATA.LOCATION + 1

                @ADD_MWORD_PLUS_MWORD(GET_TILE_DATA.LOCATION,NEGATIVE24)

                CLC
                JSR     GET_TILE_DATA

                @INC_WORD_BY_ONE(GET_TILE_DATA.LOCATION)
                JSR     GET_TILE_DATA

                @INC_WORD_BY_ONE(GET_TILE_DATA.LOCATION)
                JSR     GET_TILE_DATA

                @ADD_WORD(GET_TILE_DATA.LOCATION,21)
                JSR     GET_TILE_DATA

                @ADD_WORD(GET_TILE_DATA.LOCATION,2)
                JSR     GET_TILE_DATA

                @ADD_WORD(GET_TILE_DATA.LOCATION,21)
                JSR     GET_TILE_DATA

                @INC_WORD_BY_ONE(GET_TILE_DATA.LOCATION)
                JSR     GET_TILE_DATA

                @INC_WORD_BY_ONE(GET_TILE_DATA.LOCATION)
                JSR     GET_TILE_DATA
#STATS.SAVE MAIN
#STATS.POP

                LDX     NEIGHBORS
                LDA.#   $00
                JSR     $BDCD

                RTS

; ===========================================================================
#STATS.PUSH
GET_TILE_DATA:
.LDX:           LDA     $0000
                AND.#   $7F
                BEQ     .1
                SEC
.1:             ROL     NEIGHBORS
                RTS
#STATS.LOOP 8
#STATS.SAVE GET_TILE_DATA
#STATS.POP

GET_TILE_DATA.LOCATION = GET_TILE_DATA.LDX + 1

; ===========================================================================

; Stat: 'GET_TILE_DATA'
;    Bytes: 12   MinCycles: 128   MaxCycles: 144
;    MinCycleTime: .13 mSec   MaxCycleTime: .14 mSec
;    Max FPS: 7,968.75   Min FPS: 7,083.33
; Stat: 'MAIN'
;    Bytes: 144   MinCycles: 188   MaxCycles: 196
;    MinCycleTime: .18 mSec   MaxCycleTime: .19 mSec
;    Max FPS: 5,425.53   Min FPS: 5,204.08
; 
; So 156 Bytes and 316 cycles...Not bad...
; ===========================================================================
LOCATION:       DATA    TILEDATA + ((23 * 1) + 10)
NEGATIVE24:     DATA    @NEGATIVE(24)
NEIGHBORS:      DATA.b  $00

CONST_VALUE:    DATA    12345

VALUE:          DATA    1000
OFFSET1:        DATA    @NEGATIVE(320)
OFFSET2:        DATA    640

SQUAREOFFSETS:  DATA    @NEGATIVE(24)
                DATA    @NEGATIVE(23)
                DATA    @NEGATIVE(22)
                DATA    @NEGATIVE(1)
                DATA    1
                DATA    22
                DATA    23
                DATA    24

TILEDATA:
#INCLUDE GenerateData.asm