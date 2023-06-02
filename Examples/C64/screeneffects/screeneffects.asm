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

.RESET:         LDA.#       VICII_SCREEN_TEXT_WIDTH
                STA         SHIFTED_COPY.OFFSET

.LOOP:
                @SET_WORD(SHIFTED_COPY.SOURCE, TEMP_SCREEN)
                @SET_WORD(SHIFTED_COPY.TARGET, VICII_SCREEN_RAM)
                @SET_WORD(SHIFTED_COPY.SOURCE_COLOR, TEMP_COLOR)
                @SET_WORD(SHIFTED_COPY.TARGET_COLOR, VICII_COLOR_RAM)
                JSR         SHIFTED_COPY

                ; @SET_WORD(SHIFTED_COPY.SOURCE, TEMP_COLOR)
                ; @SET_WORD(SHIFTED_COPY.TARGET, VICII_COLOR_RAM)
                ; JSR         SHIFTED_COPY

; ; WAIT_FOR_RASTER_LINE: 
; ; Only works for Rasters < 256
;                 LDY.#       250
;                 LDA.#       $80
; .WRL:           CPY         VICII_RASTER
;                 BNE         .WRL
;                 AND         VICII_CONTROL_1
;                 BNE         .WRL

                INC         VICII_BORDER_COLOR

                DEC         SHIFTED_COPY.OFFSET
                LDA         SHIFTED_COPY.OFFSET
                CMP.#       $D8
                BEQ         .RESET

                JMP         .LOOP

                RTS

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

#INCLUDE ..\..\library\unpack.asm
