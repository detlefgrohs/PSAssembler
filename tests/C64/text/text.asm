* = $0801

#INCLUDE ..\includes.h

ZP_PTR_A            =   $FB
ZP_PTR_B            =   $FD
ZP_TEMP_BYTE        =   $FF

@BASICSTUB()


            ;JMP         HELLOWORLDSLIDER


; Scroll 1 line of Chars with color to the left takes about 1.2 mSec
; So scrolling 25 lines would take 30 mSec or 33 FPS

; To Keep under 50 FPS we could do 16.667 Lines or less

; Parallax would do regions at different rates...

; 6 x 1.2 mSec => 7.2 mSecs
; 18 x 1.2 mSec => 21.6 mSecs or46.2 FPS

; I think I could make a consistent 30 FPS easily
; Cycle 1   F           -  7.2 mSecs
; Cycle 2   F + M       - 14.4 mSecs
; Cycle 3   F + M + S   - 21.6 mSecs

; 60 FPS => 16.67 mSecs
; 50 FPS => 20    mSecs
; 30 FPS => 33.33 mSecs
; 25 FPS => 40    mSecs

; 00    Score Bar 1
; 01    Score Bar 2
; 02    Seperator
; 03
; 04
; 05    L1
; 06    L2
; 07    L3
; 08    L4
; 09    L5
; 10    L6
; 11    M1
; 12    M2
; 13    M3
; 14    M4
; 15    M5
; 16    M6
; 17    F1
; 18    F2
; 19    F3
; 20    F4
; 21    F5
; 22    F6
; 23    Seperator
; 24    Status Bar


#STOP
#STATS.PUSH
VERTICALSCROLL:
            ; Populate x lines on the screen
            LDY.#       0
#STATS.PUSH
.1:         TYA
            STA,Y       @VICII_SCREEN_TEXT_LINE(00)
            STA,Y       @VICII_SCREEN_COLOR_LINE(00)
            INY
            CPY.#       VICII_SCREEN_TEXT_WIDTH
            BNE         .1
#STATS.LOOP     VICII_SCREEN_TEXT_WIDTH
#STATS.POP

            ; Now rotate the chars left to right...
            ; 0 => T, 1 => 0, ... T => 39
.LINELOOP:  LDY.#       0
            LDA,Y       @VICII_SCREEN_TEXT_LINE(00)
            STA         .TEMP1
            LDA,Y       @VICII_SCREEN_COLOR_LINE(00)
            STA         .TEMP2

#STATS.PUSH
.CHARLOOP:  INY
            LDA,Y       @VICII_SCREEN_TEXT_LINE(00)
            DEY
            STA,Y       @VICII_SCREEN_TEXT_LINE(00)
            INY            
            LDA,Y       @VICII_SCREEN_COLOR_LINE(00)
            DEY
            STA,Y       @VICII_SCREEN_COLOR_LINE(00)
            INY
            CPY.#       VICII_SCREEN_TEXT_WIDTH
            BNE         .CHARLOOP
#STATS.LOOP     VICII_SCREEN_TEXT_WIDTH
; Main Loop
; 40 x ((4 x 4)  + (5 x 2) + (4) => 1200 Cycles
#STATS.DETAIL
#STATS.POP
            DEY
            LDA         .TEMP1
            STA,Y       @VICII_SCREEN_TEXT_LINE(00)
            LDA         .TEMP2
            STA,Y       @VICII_SCREEN_COLOR_LINE(00)

.SPACECHECK:LDA         $DC01
            CMP.#       $EF
            BEQ         .SPACECHECK

            JMP         .LINELOOP
#STATS.POP
            RTS

.TEMP1:     DATA.b      $00
.TEMP2:     DATA.b      $00

#CONTINUE
; This moves a letter across the bottom of the screen and scrolls the screen up
; Should be an approximate FPS of about 40... Need to Verify somehow...
LETTERSCROLL:   
            LDA.#       $01
.1:         STA         $07C0
            JSR         TEXT.SCROLL_UP

            INC         .1 + 1
            LDA         .1 + 1
            CMP.#       $c0 + 40
            BNE         LETTERSCROLL

            LDA.#       $C0
            STA         .1 + 1

            JMP         LETTERSCROLL
#STOP

; This repeatedly prints Hello World! in colors until the screen scrolls...
HELLOWORLDSCROLL:      ;LDA         TEXT.FGCOLOR
            JSR         TEXT.CLEARSCREEN
            JSR         TEXT.SET_PTRS

.1:         @SET_ZP_WORD(ZP_PTR_A,MSG_HELLO)
            JSR         TEXT.PRINT
            INC         TEXT.FGCOLOR
            
.SPACECHECK:LDA         $DC01
            CMP.#       $EF
            BEQ         .SPACECHECK

            JMP         .1

            RTS

; Prints Hello World! in colors sliding across the bottom of the screen and scrolls
HELLOWORLDSLIDER:      
            @SET_ZP_WORD(ZP_PTR_A,MSG_HELLO)
            JSR         TEXT.PRINT
            JSR         TEXT.CRLF
            
            INC         TEXT.FGCOLOR
            LDA         TEXT.FGCOLOR
            AND.#       $1F
            STA         TEXT.FGCOLOR
            STA         TEXT.CHAR_X_POS
            JSR         TEXT.SET_PTRS

            JMP         HELLOWORLDSLIDER



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
#CONTINUE
; =========================================================================
#STATS.PUSH
TEXT.SCROLL_UP:  
            @SET_WORD(.TT+1,@VICII_SCREEN_TEXT_LINE(00))
            @SET_WORD(.TS+1,@VICII_SCREEN_TEXT_LINE(01))
            @SET_WORD(.CT+1,@VICII_SCREEN_COLOR_LINE(00))
            @SET_WORD(.CS+1,@VICII_SCREEN_COLOR_LINE(01))
            LDX.#       VICII_SCREEN_TEXT_HEIGHT - 1
#STATS.PUSH
.1:         LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
#STATS.PUSH
.2:         
.TS:        LDA,Y       $0000
.TT:        STA,Y       $0000
.CS:        LDA,Y       $0000
.CT:        STA,Y       $0000

            @DEY_BPL(.2)        ; Char--
#STATS.LOOP     VICII_SCREEN_TEXT_WIDTH - 1
#STATS.POP
            @DEX_BNE(.3)        ; Line--
#STATS.LOOP     VICII_SCREEN_TEXT_HEIGHT - 1
#STATS.POP
            ; Clear Bottom Line
            @SET_WORD(.4+1,@VICII_SCREEN_TEXT_LINE(24))
            ;@SET_ZP_WORD(ZP_PTR_B,VICII_SCREEN_COLOR_LINE_24)
            
            LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
            LDA.#       32
#STATS.PUSH
.4:         STA,Y       $0000
            @DEY_BPL(.4)
#STATS.LOOP VICII_SCREEN_TEXT_WIDTH - 1
#STATS.POP
            RTS

#STATS.PUSH
.3:         @ADD_WORD(.TT+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.TS+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.CT+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.CS+1,VICII_SCREEN_TEXT_WIDTH)
            JMP         .1
#STATS.LOOP VICII_SCREEN_TEXT_HEIGHT - 1
#STATS.POP
; Main Loop
;    24 x 40 x 4 x 4 => 15,360 Cycles
;    24 x 40 x 2 x 2 =>  3,840 Cycles
;                    => 19,200 Cycles
; Lines x Chars x Operations x Cycles 
#STATS.DETAIL
#STATS.POP
#STOP
; ===========================================================================
TEXT.PRINT:
            LDY.#       0
.1:         LDA.i,Y     ZP_PTR_A
            BEQ         .2

            JSR         TEXT.PRINTCHAR

            INY
            JMP         .1

.2:         RTS

; ===========================================================================
#STATS.PUSH
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
#STATS.DETAIL
#STATS.POP
; ===========================================================================
;TEXT.PRINTCHAR:

