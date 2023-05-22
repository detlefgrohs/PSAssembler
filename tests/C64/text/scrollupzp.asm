* = $0801

#INCLUDE ..\includes.h

ZP_PTR_TEXT_SRC     =   $F7
ZP_PTR_TEXT_TGT     =   $F9

ZP_PTR_COLOR_SRC    =   $FB
ZP_PTR_COLOR_TGT    =   $FD

ZP_TEMP_BYTE        =   $FF

@BASICSTUB()

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

; =========================================================================
#STATS.PUSH
TEXT.SCROLL_UP:  
            @SET_ZP_WORD(ZP_PTR_TEXT_TGT,@VICII_SCREEN_TEXT_LINE(00))
            @SET_ZP_WORD(ZP_PTR_TEXT_SRC,@VICII_SCREEN_TEXT_LINE(01))
            @SET_ZP_WORD(ZP_PTR_COLOR_TGT,@VICII_SCREEN_COLOR_LINE(00))
            @SET_ZP_WORD(ZP_PTR_COLOR_SRC,@VICII_SCREEN_COLOR_LINE(01))
            LDX.#       VICII_SCREEN_TEXT_HEIGHT - 1
#STATS.PUSH
.1:         LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
#STATS.PUSH
.2:         LDA.i,Y     ZP_PTR_TEXT_SRC
            STA.i,Y     ZP_PTR_TEXT_TGT
            LDA.i,Y     ZP_PTR_COLOR_SRC
            STA.i,Y     ZP_PTR_COLOR_TGT

            @DEY_BPL(.2)        ; Char--
#STATS.LOOP     VICII_SCREEN_TEXT_WIDTH - 1
#STATS.POP
            @DEX_BNE(.3)        ; Line--
#STATS.LOOP     VICII_SCREEN_TEXT_HEIGHT - 1
#STATS.POP
            ; Clear Bottom Line
            @SET_ZP_WORD(ZP_PTR_TEXT_TGT,@VICII_SCREEN_TEXT_LINE(24))
            ;@SET_ZP_WORD(ZP_PTR_B,VICII_SCREEN_COLOR_LINE_24)
            
            LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
            LDA.#       32
#STATS.PUSH
.4:         STA.i,Y     ZP_PTR_TEXT_TGT
            @DEY_BPL(.4)
#STATS.LOOP VICII_SCREEN_TEXT_WIDTH - 1
#STATS.POP
            RTS

#STATS.PUSH
.3:         @ADD_ZP_WORD(ZP_PTR_TEXT_TGT,VICII_SCREEN_TEXT_WIDTH)
            @ADD_ZP_WORD(ZP_PTR_TEXT_SRC,VICII_SCREEN_TEXT_WIDTH)
            @ADD_ZP_WORD(ZP_PTR_COLOR_TGT,VICII_SCREEN_TEXT_WIDTH)
            @ADD_ZP_WORD(ZP_PTR_COLOR_SRC,VICII_SCREEN_TEXT_WIDTH)
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

; Absolute Indexing....
; STATS => Bytes: 154   MinCycles: 21,452   MaxCycles: 27,233
;          MinCycleTime: 21.03 mSec   MaxCycleTime: 26.70 mSec
;          Max FPS: 47.55   Min FPS: 37.45
; With ZP
; STATS => Bytes: 115   MinCycles: 28,336   MaxCycles: 30,526
;          MinCycleTime: 27.78 mSec   MaxCycleTime: 29.93 mSec
;          Max FPS: 36.00   Min FPS: 33.41