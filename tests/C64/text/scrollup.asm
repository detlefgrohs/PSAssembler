* = $0801

#INCLUDE ..\includes.h

ZP_PTR_A            =   $FB
ZP_PTR_B            =   $FD
ZP_TEMP_BYTE        =   $FF

@BASICSTUB()

; This moves a letter across the bottom of the screen and scrolls the screen up
; Should be an approximate FPS of about 40... Need to Verify somehow...
LETTERSCROLL:   
            LDA.#       $01
            STA.zp      ZP_TEMP_BYTE

.LOOP:      LDA.zp      ZP_TEMP_BYTE
.1:         STA         $07C0
.2:         STA         $DBC0
            INC.zp      ZP_TEMP_BYTE
            JSR         TEXT.SCROLL_UP

            INC         .2 + 1
            INC         .1 + 1
            LDA         .1 + 1
            CMP.#       $c0 + 40
            BNE         .LOOP

            LDA.#       $C0
            STA         .1 + 1
            STA         .2 + 1

            JMP         LETTERSCROLL

; =========================================================================
#REGION TEXT.SCROLL_UP
#STATS.PUSH
TEXT.SCROLL_UP:  
            ; @SET_WORD(.TT+1,VICII_SCREEN_TEXT_LINE_00)
            ; @SET_WORD(.TS+1,VICII_SCREEN_TEXT_LINE_01)
            @SET_WORD(.TT+1,@VICII_SCREEN_TEXT_LINE(00))
            @SET_WORD(.TS+1,@VICII_SCREEN_TEXT_LINE(01))
            
            ; @SET_WORD(.CT+1,VICII_SCREEN_COLOR_LINE_00)
            ; @SET_WORD(.CS+1,VICII_SCREEN_COLOR_LINE_01)
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
            ;@SET_WORD(.4+1,VICII_SCREEN_TEXT_LINE_24)
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
#ENDR


; Main Loop
;    24 x 40 x 4 x 4 => 15,360 Cycles
;    24 x 40 x 2 x 2 =>  3,840 Cycles
;                    => 19,200 Cycles
; Lines x Chars x Operations x Cycles 

; Unwrapped
; STATS => Bytes: 307   MinCycles: 15,684   MaxCycles: 19,623
;          MinCycleTime: 15.38 mSec   MaxCycleTime: 19.24 mSec
;          Max FPS: 65.03   Min FPS: 51.98
; Absolute Indexing....
; STATS => Bytes: 154   MinCycles: 21,452   MaxCycles: 27,233
;          MinCycleTime: 21.03 mSec   MaxCycleTime: 26.70 mSec
;          Max FPS: 47.55   Min FPS: 37.45
; With ZP
; STATS => Bytes: 115   MinCycles: 28,336   MaxCycles: 30,526
;          MinCycleTime: 27.78 mSec   MaxCycleTime: 29.93 mSec
;          Max FPS: 36.00   Min FPS: 33.41
