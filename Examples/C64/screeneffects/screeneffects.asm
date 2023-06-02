* = $0801

#INCLUDE ..\..\includes\includes.h

TEMP_SCREEN     = $C000
TEMP_COLOR      = TEMP_SCREEN + (VICII_SCREEN_TEXT_WIDTH * VICII_SCREEN_TEXT_HEIGHT)

                @BASICSTUB()

START:          ; Unpack Screen Text and Color to Temp Location
                LDA.#       UNPACK_MEMORY.MODE_BYTE
                STA         UNPACK_MEMORY.MODE
                @SET_WORD(UNPACK_MEMORY.SOURCE, SCREEN);
                @SET_WORD(UNPACK_MEMORY.SOURCE_END, SCREEN_END);
                @SET_WORD(UNPACK_MEMORY.TARGET, TEMP_SCREEN);
                JSR         UNPACK_MEMORY

                LDA.#       UNPACK_MEMORY.MODE_NIBBLE
                STA         UNPACK_MEMORY.MODE
                @SET_WORD(UNPACK_MEMORY.SOURCE, SCREENC);
                @SET_WORD(UNPACK_MEMORY.SOURCE_END, SCREENC_END);
                @SET_WORD(UNPACK_MEMORY.TARGET, TEMP_COLOR);
                JSR         UNPACK_MEMORY

                ; @SET_WORD(MEMORY_COPY_1K.SOURCE, TEMP_SCREEN);
                ; @SET_WORD(MEMORY_COPY_1K.TARGET, VICII_SCREEN_RAM);
                ; JSR         MEMORY_COPY_1K

                ; @SET_WORD(MEMORY_COPY_1K.SOURCE, TEMP_COLOR);
                ; @SET_WORD(MEMORY_COPY_1K.TARGET, VICII_COLOR_RAM);
                ; JSR         MEMORY_COPY_1K

                ; @SET_WORD(MEMORY_COPY_SCREEN.TEXT_SOURCE, TEMP_SCREEN);
                ; @SET_WORD(MEMORY_COPY_SCREEN.TEXT_TARGET, VICII_SCREEN_RAM);
                ; @SET_WORD(MEMORY_COPY_SCREEN.COLOR_SOURCE, TEMP_COLOR);
                ; @SET_WORD(MEMORY_COPY_SCREEN.COLOR_TARGET, VICII_COLOR_RAM);
                ; JSR         MEMORY_COPY_SCREEN

                LDA.#       0
                STA         .LINE_INDEX
.OUTER_LOOP:
                LDX.#       39
                STX         .COLUMN_INDEX
.INNER_LOOP:          
.FD:            LDA,X       FLIPDATA
                BMI         .BLANK_COLUMN

                STA         COLUMN_COPY.SOURCE_COLUMN
                TXA
                STA         COLUMN_COPY.TARGET_COLUMN
                @SET_WORD(COLUMN_COPY.SOURCE, TEMP_SCREEN);
                @SET_WORD(COLUMN_COPY.TARGET, VICII_SCREEN_RAM);
                @SET_WORD(COLUMN_COPY.SOURCE_COLOR, TEMP_COLOR);
                @SET_WORD(COLUMN_COPY.TARGET_COLOR, VICII_COLOR_RAM);
                JSR         COLUMN_COPY
                JMP         .CONTINUE

.BLANK_COLUMN:
                TXA
                STA         COLUMN_CLEAR.COLUMN
                @SET_WORD(COLUMN_CLEAR.TARGET, VICII_SCREEN_RAM);
                @SET_WORD(COLUMN_CLEAR.TARGET_COLOR, VICII_COLOR_RAM);
                JSR         COLUMN_CLEAR

.CONTINUE:
                DEC         .COLUMN_INDEX
                LDX         .COLUMN_INDEX
                BPL         .INNER_LOOP

.SPACECHECK:    LDA         $DC01
                CMP.#       $EF
                BEQ         .SPACECHECK

                LDA         .DIRECTION
                BNE         .DIR_DOWN

.DIR_UP:        @ADD_WORD(.FD + 1, 40)

                INC         .LINE_INDEX
                LDA         .LINE_INDEX
                CMP.#       41
                BEQ         .CHANGE_DIR_DOWN
                JMP         .OUTER_LOOP

.CHANGE_DIR_DOWN:
                LDA.#       $FF
                STA         .DIRECTION

.DIR_DOWN:      SEC
                LDA         .FD + 1
                SBC.#       40
                STA         .FD + 1
                LDA         .FD + 2
                SBC.#       0
                STA         .FD + 2

                DEC         .LINE_INDEX
                LDA         .LINE_INDEX
                BMI         .CHANGE_DIR_UP
                JMP         .OUTER_LOOP

.CHANGE_DIR_UP: LDA.#       $00
                STA         .DIRECTION
                JMP         .DIR_UP

                RTS

.LINE_INDEX:    DATA.b      $00
.COLUMN_INDEX:  DATA.b      $00
.DIRECTION:     DATA.b      $00



                ; LDA.#       0
                ; STA         COLUMN_COPY.SOURCE_COLUMN
                ; LDA.#       20
                ; STA         COLUMN_COPY.TARGET_COLUMN
                ; @SET_WORD(COLUMN_COPY.SOURCE, TEMP_SCREEN);
                ; @SET_WORD(COLUMN_COPY.TARGET, VICII_SCREEN_RAM);
                ; @SET_WORD(COLUMN_COPY.SOURCE_COLOR, TEMP_COLOR);
                ; @SET_WORD(COLUMN_COPY.TARGET_COLOR, VICII_COLOR_RAM);
                ; JSR         COLUMN_COPY


                ; LDA.#       0
                ; STA         COLUMN_COPY.SOURCE_COLUMN
                ; LDA.#       8
                ; STA         COLUMN_COPY.TARGET_COLUMN
                ; @SET_WORD(COLUMN_COPY.SOURCE, TEMP_SCREEN);
                ; @SET_WORD(COLUMN_COPY.TARGET, VICII_SCREEN_RAM);
                ; @SET_WORD(COLUMN_COPY.SOURCE_COLOR, TEMP_COLOR);
                ; @SET_WORD(COLUMN_COPY.TARGET_COLOR, VICII_COLOR_RAM);
                ; JSR         COLUMN_COPY

                ; LDA.#       8
                ; STA         COLUMN_CLEAR.COLUMN
                ; @SET_WORD(COLUMN_CLEAR.TARGET, VICII_SCREEN_RAM);
                ; @SET_WORD(COLUMN_CLEAR.TARGET_COLOR, VICII_COLOR_RAM);
                ; JSR         COLUMN_CLEAR

                ; RTS

#REGION COLUMN_CLEAR
COLUMN_CLEAR:   CLC
                LDA             COLUMN_CLEAR.TARGET
                ADC             .COLUMN
                STA             COLUMN_CLEAR.TARGET
                BCC             .1
                INC             COLUMN_CLEAR.TARGET + 1
.1:
                CLC
                LDA             COLUMN_CLEAR.TARGET_COLOR
                ADC             .COLUMN
                STA             COLUMN_CLEAR.TARGET_COLOR
                BCC             .2
                INC             COLUMN_CLEAR.TARGET_COLOR + 1
.2:             
                LDY.#           5
.OUTER_LOOP:    LDX.#           $00
.INNER_LOOP:    LDA.#           $20
.ST:            STA,X           $0000
                LDA.#           $00
.STC:           STA,X           $0000

                TXA
                BMI             .CONTINUE
                CLC
                ADC.#           40
                TAX
                JMP             .INNER_LOOP
.CONTINUE:
                @ADD_WORD(.ST + 1, 200)
                @ADD_WORD(.STC + 1, 200)

                DEY
                BNE             .OUTER_LOOP
                RTS

.COLUMN:        DATA.b      $00

COLUMN_CLEAR.TARGET = .ST + 1
COLUMN_CLEAR.TARGET_COLOR = .STC + 1

#ENDR

#REGION COLUMN_COPY
COLUMN_COPY:    CLC
                LDA             COLUMN_COPY.SOURCE
                ADC             .SOURCE_COLUMN
                STA             COLUMN_COPY.SOURCE
                BCC             .1
                INC             COLUMN_COPY.SOURCE + 1
.1:
                CLC
                LDA             COLUMN_COPY.SOURCE_COLOR
                ADC             .SOURCE_COLUMN
                STA             COLUMN_COPY.SOURCE_COLOR
                BCC             .2
                INC             COLUMN_COPY.SOURCE_COLOR + 1
.2:
                CLC
                LDA             COLUMN_COPY.TARGET
                ADC             .TARGET_COLUMN
                STA             COLUMN_COPY.TARGET
                BCC             .3
                INC             COLUMN_COPY.TARGET + 1
.3:
                CLC
                LDA             COLUMN_COPY.TARGET_COLOR
                ADC             .TARGET_COLUMN
                STA             COLUMN_COPY.TARGET_COLOR
                BCC             .4
                INC             COLUMN_COPY.TARGET_COLOR + 1
.4:             
                LDY.#           5
.OUTER_LOOP:    LDX.#           $00
.INNER_LOOP:
.LD:            LDA,X           $0000
.ST:            STA,X           $0000
.LDC:           LDA,X           $0000
.STC:           STA,X           $0000

                TXA
                BMI             .CONTINUE
                CLC
                ADC.#           40
                TAX
                JMP             .INNER_LOOP
.CONTINUE:
                @ADD_WORD(.LD + 1, 200)
                @ADD_WORD(.ST + 1, 200)
                @ADD_WORD(.LDC + 1, 200)
                @ADD_WORD(.STC + 1, 200)

                DEY
                BNE             .OUTER_LOOP

                RTS

.SOURCE_COLUMN:     DATA.b      $00
.TARGET_COLUMN:     DATA.b      $00

COLUMN_COPY.SOURCE = .LD + 1
COLUMN_COPY.SOURCE_COLOR = .LDC + 1
COLUMN_COPY.TARGET = .ST + 1
COLUMN_COPY.TARGET_COLOR = .STC + 1

#ENDR

; .RESET:         LDA.#       VICII_SCREEN_TEXT_WIDTH
;                 STA         SHIFTED_COPY.OFFSET

; .LOOP:
;                 @SET_WORD(SHIFTED_COPY.SOURCE, TEMP_SCREEN)
;                 @SET_WORD(SHIFTED_COPY.TARGET, VICII_SCREEN_RAM)
;                 @SET_WORD(SHIFTED_COPY.SOURCE_COLOR, TEMP_COLOR)
;                 @SET_WORD(SHIFTED_COPY.TARGET_COLOR, VICII_COLOR_RAM)
;                 JSR         SHIFTED_COPY

;                 DEC         SHIFTED_COPY.OFFSET
;                 LDA         SHIFTED_COPY.OFFSET
;                 CMP.#       $D8
;                 BEQ         .RESET

;                 JMP         .LOOP

;                 RTS

#REGION SHIFTED_COPY
SHIFTED_COPY:   LDA.#       VICII_SCREEN_TEXT_HEIGHT
                STA         .LINE_INDEX
.LINE_LOOP:     LDY.#       (VICII_SCREEN_TEXT_WIDTH - 1)

.CHAR_LOOP:     TYA
                SEC
                SBC         .OFFSET
                BMI         .OUTPUT_BLANK
                CMP.#       VICII_SCREEN_TEXT_WIDTH
                BPL         .OUTPUT_BLANK

                TAX
.LDC:           LDA,X       $0000
                STA         .TEMP_COLOR
.LD:            LDA,X       $0000
                JMP         .OUTPUT
.OUTPUT_BLANK:  LDA.#       $00
                STA         .TEMP_COLOR
                LDA.#       $20
.OUTPUT:
.ST:            STA,Y       $0000
                LDA         .TEMP_COLOR
.STC:           STA,Y       $0000

                DEY
                BPL         .CHAR_LOOP

                @ADD_WORD(.LD + 1, 40)
                @ADD_WORD(.ST + 1, 40)
                @ADD_WORD(.LDC + 1, 40)
                @ADD_WORD(.STC + 1, 40)

                DEC         .LINE_INDEX
                BNE         .LINE_LOOP

                RTS

.OFFSET:        DATA.b      $00
.LINE_INDEX:    DATA.b      $00
.TEMP_COLOR:    DATA.b      $00

SHIFTED_COPY.SOURCE = .LD + 1
SHIFTED_COPY.SOURCE_COLOR = .LDC + 1
SHIFTED_COPY.TARGET = .ST + 1
SHIFTED_COPY.TARGET_COLOR = .STC + 1

#ENDR

#REGION MEMORY_COPY_SCREEN
MEMORY_COPY_SCREEN:
                LDY.#       8 - 1
.OUTER_LOOP:    LDX.#       125 - 1
.INNER_LOOP:
.LDS:           LDA,X       $0000
.STS:           STA,X       $0000

.LDC:           LDA,X       $0000
.STC:           STA,X       $0000

                DEX
                BPL         .INNER_LOOP

                @ADD_WORD(.LDS + 1,125)
                @ADD_WORD(.STS + 1,125)
                @ADD_WORD(.LDC + 1,125)
                @ADD_WORD(.STC + 1,125)

                DEY
                BPL         .OUTER_LOOP

                RTS

MEMORY_COPY_SCREEN.TEXT_SOURCE = .LDS + 1
MEMORY_COPY_SCREEN.TEXT_TARGET = .STS + 1
MEMORY_COPY_SCREEN.COLOR_SOURCE = .LDC + 1
MEMORY_COPY_SCREEN.COLOR_TARGET = .STC + 1

#ENDR

#REGION MEMORY_COPY_1K
MEMORY_COPY_1K: LDY.#       (8 - 1)
.OUTER_LOOP:    LDX.#       (125 - 1)
.INNER_LOOP:
.LD:            LDA,X       $0000
.ST:            STA,X       $0000

                DEX
                BPL         .INNER_LOOP

                @ADD_WORD(.LD + 1, 125)
                @ADD_WORD(.ST + 1, 125)

                DEY
                BPL         .OUTER_LOOP

                RTS

MEMORY_COPY_1K.SOURCE   = .LD + 1
MEMORY_COPY_1K.TARGET   = .ST + 1

#ENDR

; ===========================================================================
; Old Examples
; ===========================================================================
#STOP
START:          LDA.#       UNPACK_MEMORY.MODE_BYTE
                STA         UNPACK_MEMORY.MODE
                @SET_WORD(UNPACK_MEMORY.SOURCE, SCREEN);
                @SET_WORD(UNPACK_MEMORY.SOURCE_END, SCREEN_END);
                @SET_WORD(UNPACK_MEMORY.TARGET, VICII_SCREEN_RAM);
                JSR         UNPACK_MEMORY

                LDA.#       UNPACK_MEMORY.MODE_NIBBLE
                STA         UNPACK_MEMORY.MODE
                @SET_WORD(UNPACK_MEMORY.SOURCE, SCREENC);
                @SET_WORD(UNPACK_MEMORY.SOURCE_END, SCREENC_END);
                @SET_WORD(UNPACK_MEMORY.TARGET, VICII_COLOR_RAM);
                JSR         UNPACK_MEMORY

                RTS
#CONTINUE

SCREEN:         #LOADBINARY     screeneffects.binc
SCREEN_END:

SCREENC:        #LOADBINARY     screeneffectsc.binc
SCREENC_END:

FLIPDATA:       #LOADBINARY     flipdata.bin

#INCLUDE ..\..\library\unpack.asm
