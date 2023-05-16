* = $0801

#INCLUDE ..\includes.h

ZP_PTR_A            =   $FB
ZP_PTR_B            =   $FD
ZP_TEMP_BYTE        =   $FF

@BASICSTUB()

START:      ;LDA         TEXT.FGCOLOR
            JSR         TEXT.CLEARSCREEN

            @SET_ZP_WORD(ZP_PTR_A,MSG_HELLO)
            JSR         TEXT.PRINT
            JSR         TEXT.PRINT
            
            RTS

.LOOP:      @SET_ZP_WORD(ZP_PTR_A,MSG_HELLO)
            JSR         TEXT.PRINT
            JSR         TEXT.CRLF
            
            INC         TEXT.FGCOLOR
            LDA         TEXT.FGCOLOR
            AND.#       $1F
            STA         TEXT.FGCOLOR
            STA         TEXT.CHAR_X_POS
            JSR         TEXT.SET_PTRS

.SPACECHECK:LDA         $DC01
            CMP.#       $EF
            BEQ         .SPACECHECK

            JMP         .LOOP

            RTS

            JMP         CURADDR



MSG_HELLO:      #TEXT "HELLO WORLD!"
                DATA.b $00


; =========================================================================
TEXT:
.FGCOLOR:   DATA.b      VICII_COLOR_GREEN

.CHAR_X_POS:DATA.b      0
.CHAR_Y_POS:DATA.b      0

.TEXT_PTR:  DATA        VICII_SCREEN_RAM
.COLOR_PTR: DATA        VICII_COLOR_RAM

.LINE_TEXT_PTRS: 
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 0)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 1)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 2)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 3)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 4)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 5)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 6)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 7)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 8)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 9)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 10)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 11)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 12)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 13)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 14)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 15)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 16)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 17)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 18)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 19)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 20)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 21)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 22)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 23)
            DATA        VICII_SCREEN_RAM + (VICII_SCREEN_TEXT_WIDTH * 24)
.LINE_COLOR_PTRS: 
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 0)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 1)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 2)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 3)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 4)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 5)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 6)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 7)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 8)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 9)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 10)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 11)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 12)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 13)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 14)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 15)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 16)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 17)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 18)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 19)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 20)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 21)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 22)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 23)
            DATA        VICII_COLOR_RAM + (VICII_SCREEN_TEXT_WIDTH * 24)
; =========================================================================
TEXT.SET_PTRS:
            LDA         TEXT.CHAR_Y_POS
            ASL.A
            TAX
            LDA,X       TEXT.LINE_TEXT_PTRS
            STA         TEXT.TEXT_PTR
            LDA,X       TEXT.LINE_COLOR_PTRS
            STA         TEXT.COLOR_PTR

            INX
            LDA,X       TEXT.LINE_TEXT_PTRS
            STA         TEXT.TEXT_PTR + 1
            LDA,X       TEXT.LINE_COLOR_PTRS
            STA         TEXT.COLOR_PTR + 1

            CLC
            LDA         TEXT.TEXT_PTR
            ADC         TEXT.CHAR_X_POS
            STA         TEXT.TEXT_PTR
            LDA         TEXT.TEXT_PTR + 1
            ADC.#       0
            STA         TEXT.TEXT_PTR + 1

            CLC
            LDA         TEXT.COLOR_PTR
            ADC         TEXT.CHAR_X_POS
            STA         TEXT.COLOR_PTR
            LDA         TEXT.COLOR_PTR + 1
            ADC.#       0
            STA         TEXT.COLOR_PTR + 1

            RTS

; =========================================================================
TEXT.CRLF:
            LDA.#       0
            STA         TEXT.CHAR_X_POS

            LDX         TEXT.CHAR_Y_POS
            INX
            CPX.#       25
            ;JSR         TEXT.SCROLL_UP
 
            BNE         .CONT

            ; Need to Scroll screen
            JSR         TEXT.SCROLL_UP
            ; Clear bottom line

            JMP         .1

.CONT:      STX         TEXT.CHAR_Y_POS

.1:         JSR         TEXT.SET_PTRS
            ;@SET_WORD(TEXT.TEXT_PTR, VICII_SCREEN_TEXT_LINE_01)
            ;@SET_WORD(TEXT.COLOR_PTR, VICII_SCREEN_COLOR_LINE_01)
            RTS

; =========================================================================
TEXT.CLEARSCREEN:
            @SET_ZP_WORD(ZP_PTR_A,VICII_SCREEN_RAM)
            LDA.#       32
            STA.zp      ZP_TEMP_BYTE
            JSR         TEXT.CLEAR
            RTS

TEXT.CLEAR: 
            LDX.#       8
.1:         LDA.zp      ZP_TEMP_BYTE
            LDY.#       125
.2:         STA.i,Y     ZP_PTR_A
            @DEY_BPL(.2)
            @DEX_BNE(.3)
            RTS

.3:         @ADD_ZP_WORD(ZP_PTR_A,125)
            JMP         .1

; =========================================================================
TEXT.SCROLL_UP:  
            @SET_WORD(.TT+1,VICII_SCREEN_TEXT_LINE_00)
            @SET_WORD(.TS+1,VICII_SCREEN_TEXT_LINE_01)
            @SET_WORD(.CT+1,VICII_SCREEN_COLOR_LINE_00)
            @SET_WORD(.CS+1,VICII_SCREEN_COLOR_LINE_01)
            
            LDX.#       VICII_SCREEN_TEXT_HEIGHT - 1
.1:         LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
.2:         
.TS:        LDA,Y       $0000
.TT:        STA,Y       $0000
.CS:        LDA,Y       $0000
.CT:        STA,Y       $0000

            @DEY_BPL(.2)        ; Char--
            @DEX_BNE(.3)        ; Line--

            ; Clear Bottom Line
            @SET_ZP_WORD(ZP_PTR_A,VICII_SCREEN_TEXT_LINE_24)
            ;@SET_ZP_WORD(ZP_PTR_B,VICII_SCREEN_COLOR_LINE_24)
            
            LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
            LDA.#       32
.4:         STA.i,Y     ZP_PTR_A
            @DEY_BPL(.4)

            RTS

.3:         @ADD_WORD(.TT+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.TS+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.CT+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.CS+1,VICII_SCREEN_TEXT_WIDTH)
            JMP         .1

; ===========================================================================
TEXT.PRINT:
            LDA         TEXT.TEXT_PTR
            STA         .P1 + 1
            LDA         TEXT.TEXT_PTR + 1
            STA         .P1 + 2

            LDA         TEXT.COLOR_PTR
            STA         .P2 + 1
            LDA         TEXT.COLOR_PTR + 1
            STA         .P2 + 2

            LDY.#       0
.1:         LDA.i,Y     ZP_PTR_A
            BEQ         .2
.P1:        STA,Y       $FFFF
            LDA         TEXT.FGCOLOR
.P2:        STA,Y       $FFFF

            INY
            JMP         .1

            ; Add the length to TEXT.CHAR_X_POS
.2:         CLC
            TYA
            ADC         TEXT.CHAR_X_POS
            STA         TEXT.CHAR_X_POS
            ; Check if over TEXT_WIDTH...

            JSR         TEXT.SET_PTRS

            RTS

; ===========================================================================


