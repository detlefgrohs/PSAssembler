ZP_PTR_A            =   $FB
ZP_PTR_B            =   $FD
ZP_TEMP_BYTE        =   $FF

#MACRO TEXT_SETXY(X,Y)
                LDX.#       @X
                LDY.#       @Y
                JSR         TEXT.SETXY
#ENDM
#MACRO TEXT_FGCOLOR(COLOR)
                LDA.#       @COLOR
                STA         TEXT.FGCOLOR
#ENDM
#MACRO TEXT_PRINTCHAR(CHAR) 
                LDA.#       @CHAR
                JSR         TEXT.PRINTCHAR
#ENDM

#REGION TEXT
TEXT:
.FGCOLOR:               DATA.b      VICII_COLOR_GREEN

.CHAR_X_POS:            DATA.b      0
.CHAR_Y_POS:            DATA.b      0

.TEXT_PTR:              DATA        VICII_SCREEN_RAM
.COLOR_PTR:             DATA        VICII_COLOR_RAM

.START_X:               DATA.b      0
.START_Y:               DATA.b      0
.WIDTH:                 DATA.b      0
.HEIGHT:                DATA.b      0
;.COLOR                  DATA.b      0

#ENDR
#REGION TEXT.PTRS
TEXT.LINE_TEXT_PTRS: 
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
TEXT.LINE_COLOR_PTRS: 
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
#ENDR
#REGION TEXT.SET_PTRS
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
#ENDR
#REGION TEXT.HORIZONTALLINE
; =========================================================================
TEXT.HORIZONTALLINE:
            STA         .CHAR_VALUE + 1

            LDA         TEXT.START_Y
            ASL.A
            TAX
            LDA,X       TEXT.LINE_TEXT_PTRS
            STA         .TEXT_PTR + 1
            LDA,X       TEXT.LINE_COLOR_PTRS
            STA         .COLOR_PTR + 1

            INX
            LDA,X       TEXT.LINE_TEXT_PTRS
            STA         .TEXT_PTR + 2
            LDA,X       TEXT.LINE_COLOR_PTRS
            STA         .COLOR_PTR + 2

            LDX         TEXT.START_X
            LDY         TEXT.WIDTH
.1:
.CHAR_VALUE:LDA.#       $00
.TEXT_PTR:  STA,X       $0000
            LDA         TEXT.FGCOLOR
.COLOR_PTR: STA,X       $0000

            INX
            DEY
            BNE         .1

            RTS
#ENDR
#REGION TEXT.VERTICALLINE
; =========================================================================
TEXT.VERTICALLINE:
            STA         .CHAR_VALUE + 1

            LDA         TEXT.START_Y
            ASL.A
            TAX
            LDA,X       TEXT.LINE_TEXT_PTRS
            STA         .TEXT_PTR + 1
            LDA,X       TEXT.LINE_COLOR_PTRS
            STA         .COLOR_PTR + 1

            INX
            LDA,X       TEXT.LINE_TEXT_PTRS
            STA         .TEXT_PTR + 2
            LDA,X       TEXT.LINE_COLOR_PTRS
            STA         .COLOR_PTR + 2

            LDX         TEXT.START_X
            LDY         TEXT.HEIGHT

.1:
.CHAR_VALUE:LDA.#       $00
.TEXT_PTR:  STA,X       $0000
            LDA         TEXT.FGCOLOR
.COLOR_PTR: STA,X       $0000

            @ADD_WORD(.TEXT_PTR + 1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.COLOR_PTR + 1,VICII_SCREEN_TEXT_WIDTH)

            DEY
            BNE         .1

            RTS
#ENDR
#REGION TEXT.SETXY
; =========================================================================
TEXT.SETXY:
            STX         TEXT.CHAR_X_POS
            STY         TEXT.CHAR_Y_POS
            JSR         TEXT.SET_PTRS
            RTS
#ENDR
#REGION TEXT.CRLF
; =========================================================================
TEXT.CRLF:
            LDA.#       0
            STA         TEXT.CHAR_X_POS

            LDX         TEXT.CHAR_Y_POS
            INX
            CPX.#       25

            BNE         .1

            ; Need to Scroll screen
            JSR         TEXT.SCROLL_UP
            ; Clear bottom line
            JMP         .2

.1:         STX         TEXT.CHAR_Y_POS
.2:         JSR         TEXT.SET_PTRS
            RTS
#ENDR
#REGION TEXT.CLEARSCREEN
; =========================================================================
TEXT.CLEARSCREEN:
            @SET_ZP_WORD(ZP_PTR_A,VICII_SCREEN_RAM)
            LDA.#       32
            STA.zp      ZP_TEMP_BYTE
            JSR         TEXT.CLEAR
            RTS
#ENDR
#REGION TEXT.CLEAR
; =========================================================================
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
#ENDR
#REGION TEXT.SCROLL_UP
; =========================================================================
TEXT.SCROLL_UP:  
            @SET_WORD(.TT+1,@VICII_SCREEN_TEXT_LINE(00))
            @SET_WORD(.TS+1,@VICII_SCREEN_TEXT_LINE(01))
            @SET_WORD(.CT+1,@VICII_SCREEN_COLOR_LINE(00))
            @SET_WORD(.CS+1,@VICII_SCREEN_COLOR_LINE(01))
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
            @SET_WORD(.4+1,@VICII_SCREEN_TEXT_LINE(24))
            ;@SET_ZP_WORD(ZP_PTR_B,VICII_SCREEN_COLOR_LINE_24)
            
            LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
            LDA.#       32

.4:         STA,Y       $0000
            @DEY_BPL(.4)
            RTS

.3:         @ADD_WORD(.TT+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.TS+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.CT+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.CS+1,VICII_SCREEN_TEXT_WIDTH)
            JMP         .1
#ENDR
#REGION TEXT.PRINTHEXDIGIT
; ===========================================================================
TEXT.PRINTHEXDIGIT:
            CMP.#       $A
            BPL         .1
            CLC
            ADC.#       $30
            JMP         .2

.1:         SEC
            SBC.#       $09

.2:         JSR         TEXT.PRINTCHAR
            RTS
#ENDM
#REGION TEXT.PRINT
; ===========================================================================
TEXT.PRINT:
            LDY.#       0
.1:         LDA.i,Y     ZP_PTR_A
            BEQ         .2

            JSR         TEXT.PRINTCHAR

            INY
            JMP         .1

.2:         RTS
#ENDR
#REGION TEXT.PRINTCHAR
; ===========================================================================
TEXT.PRINTCHAR:
            STA         .A + 1
            PHA
            TXA
            PHA
            TYA
            PHA

            LDY         TEXT.CHAR_X_POS
            CPY.#       VICII_SCREEN_TEXT_WIDTH
            BNE         .1

            JSR         TEXT.CRLF

.1:         ;@SET_WORD(.2+1,TEXT.TEXT_PTR)
            ;@SET_WORD(.3+1,TEXT.COLOR_PTR)
            LDA         TEXT.TEXT_PTR
            STA         .2+1
            LDA         TEXT.TEXT_PTR+1
            STA         .2+2

            LDA         TEXT.COLOR_PTR
            STA         .3+1
            LDA         TEXT.COLOR_PTR+1
            STA         .3+2

.A:         LDA.#       $00
.2:         STA         $0000
            LDA         TEXT.FGCOLOR
.3:         STA         $0000

            INC         TEXT.CHAR_X_POS
            JSR         TEXT.SET_PTRS
            
            PLA
            TAY
            PLA
            TAX
            PLA

            RTS
#ENDR
