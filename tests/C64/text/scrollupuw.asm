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
#STATS.PUSH
#STATS.PUSH
TEXT.SCROLL_UP:
            LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
            ; 1 => 0
.1:         LDA,Y       VICII_SCREEN_TEXT_LINE_01
            STA,Y       VICII_SCREEN_TEXT_LINE_00
            LDA,Y       VICII_SCREEN_COLOR_LINE_01
            STA,Y       VICII_SCREEN_COLOR_LINE_00
            ; 2 => 1
           LDA,Y       VICII_SCREEN_TEXT_LINE_02
           STA,Y       VICII_SCREEN_TEXT_LINE_01
           LDA,Y       VICII_SCREEN_COLOR_LINE_02
           STA,Y       VICII_SCREEN_COLOR_LINE_01
           ; 3 => 2
           LDA,Y       VICII_SCREEN_TEXT_LINE_03
           STA,Y       VICII_SCREEN_TEXT_LINE_02
           LDA,Y       VICII_SCREEN_COLOR_LINE_03
           STA,Y       VICII_SCREEN_COLOR_LINE_02
           ; 4 => 3
           LDA,Y       VICII_SCREEN_TEXT_LINE_04
           STA,Y       VICII_SCREEN_TEXT_LINE_03
           LDA,Y       VICII_SCREEN_COLOR_LINE_04
           STA,Y       VICII_SCREEN_COLOR_LINE_03
           ; 5 => 4
           LDA,Y       VICII_SCREEN_TEXT_LINE_05
           STA,Y       VICII_SCREEN_TEXT_LINE_04
           LDA,Y       VICII_SCREEN_COLOR_LINE_05
           STA,Y       VICII_SCREEN_COLOR_LINE_04
           ; 6 => 5
           LDA,Y       VICII_SCREEN_TEXT_LINE_06
           STA,Y       VICII_SCREEN_TEXT_LINE_05
           LDA,Y       VICII_SCREEN_COLOR_LINE_06
           STA,Y       VICII_SCREEN_COLOR_LINE_05
           ; 7 => 6
           LDA,Y       VICII_SCREEN_TEXT_LINE_07
           STA,Y       VICII_SCREEN_TEXT_LINE_06
           LDA,Y       VICII_SCREEN_COLOR_LINE_07
           STA,Y       VICII_SCREEN_COLOR_LINE_06
           ; 8 => 7
           LDA,Y       VICII_SCREEN_TEXT_LINE_08
           STA,Y       VICII_SCREEN_TEXT_LINE_07
           LDA,Y       VICII_SCREEN_COLOR_LINE_08
           STA,Y       VICII_SCREEN_COLOR_LINE_07
           ; 9 => 8
           LDA,Y       VICII_SCREEN_TEXT_LINE_09
           STA,Y       VICII_SCREEN_TEXT_LINE_08
           LDA,Y       VICII_SCREEN_COLOR_LINE_09
           STA,Y       VICII_SCREEN_COLOR_LINE_08
           ; 10 => 9
           LDA,Y       VICII_SCREEN_TEXT_LINE_10
           STA,Y       VICII_SCREEN_TEXT_LINE_09
           LDA,Y       VICII_SCREEN_COLOR_LINE_10
           STA,Y       VICII_SCREEN_COLOR_LINE_09
           ; 11 => 10
           LDA,Y       VICII_SCREEN_TEXT_LINE_11
           STA,Y       VICII_SCREEN_TEXT_LINE_10
           LDA,Y       VICII_SCREEN_COLOR_LINE_11
           STA,Y       VICII_SCREEN_COLOR_LINE_10
           ; 12 => 11
           LDA,Y       VICII_SCREEN_TEXT_LINE_12
           STA,Y       VICII_SCREEN_TEXT_LINE_11
           LDA,Y       VICII_SCREEN_COLOR_LINE_12
           STA,Y       VICII_SCREEN_COLOR_LINE_11
           ; 13 => 12
           LDA,Y       VICII_SCREEN_TEXT_LINE_13
           STA,Y       VICII_SCREEN_TEXT_LINE_12
           LDA,Y       VICII_SCREEN_COLOR_LINE_13
           STA,Y       VICII_SCREEN_COLOR_LINE_12
           ; 14 => 13
           LDA,Y       VICII_SCREEN_TEXT_LINE_14
           STA,Y       VICII_SCREEN_TEXT_LINE_13
           LDA,Y       VICII_SCREEN_COLOR_LINE_14
           STA,Y       VICII_SCREEN_COLOR_LINE_13
           ; 15 => 14
           LDA,Y       VICII_SCREEN_TEXT_LINE_15
           STA,Y       VICII_SCREEN_TEXT_LINE_14
           LDA,Y       VICII_SCREEN_COLOR_LINE_15
           STA,Y       VICII_SCREEN_COLOR_LINE_14
           ; 16 => 15
           LDA,Y       VICII_SCREEN_TEXT_LINE_16
           STA,Y       VICII_SCREEN_TEXT_LINE_15
           LDA,Y       VICII_SCREEN_COLOR_LINE_16
           STA,Y       VICII_SCREEN_COLOR_LINE_15
           ; 17 => 16
           LDA,Y       VICII_SCREEN_TEXT_LINE_17
           STA,Y       VICII_SCREEN_TEXT_LINE_16
           LDA,Y       VICII_SCREEN_COLOR_LINE_17
           STA,Y       VICII_SCREEN_COLOR_LINE_16
           ; 18 => 17
           LDA,Y       VICII_SCREEN_TEXT_LINE_18
           STA,Y       VICII_SCREEN_TEXT_LINE_17
           LDA,Y       VICII_SCREEN_COLOR_LINE_18
           STA,Y       VICII_SCREEN_COLOR_LINE_17
           ; 19 => 18
           LDA,Y       VICII_SCREEN_TEXT_LINE_19
           STA,Y       VICII_SCREEN_TEXT_LINE_18
           LDA,Y       VICII_SCREEN_COLOR_LINE_19
           STA,Y       VICII_SCREEN_COLOR_LINE_18
           ; 20 => 19
           LDA,Y       VICII_SCREEN_TEXT_LINE_20
           STA,Y       VICII_SCREEN_TEXT_LINE_19
           LDA,Y       VICII_SCREEN_COLOR_LINE_20
           STA,Y       VICII_SCREEN_COLOR_LINE_19
           ; 21 => 20
           LDA,Y       VICII_SCREEN_TEXT_LINE_21
           STA,Y       VICII_SCREEN_TEXT_LINE_20
           LDA,Y       VICII_SCREEN_COLOR_LINE_21
           STA,Y       VICII_SCREEN_COLOR_LINE_20
           ; 22 => 21
           LDA,Y       VICII_SCREEN_TEXT_LINE_22
           STA,Y       VICII_SCREEN_TEXT_LINE_21
           LDA,Y       VICII_SCREEN_COLOR_LINE_22
           STA,Y       VICII_SCREEN_COLOR_LINE_21
           ; 23 => 22
           LDA,Y       VICII_SCREEN_TEXT_LINE_23
           STA,Y       VICII_SCREEN_TEXT_LINE_22
           LDA,Y       VICII_SCREEN_COLOR_LINE_23
           STA,Y       VICII_SCREEN_COLOR_LINE_22
           ; 24 => 23
           LDA,Y       VICII_SCREEN_TEXT_LINE_24
           STA,Y       VICII_SCREEN_TEXT_LINE_23
           LDA,Y       VICII_SCREEN_COLOR_LINE_24
           STA,Y       VICII_SCREEN_COLOR_LINE_23

            ;@DEY_BPL(.1)        ; Char--
            DEY
            BMI         .2
            JMP         .1

.2:
#STATS.LOOP     VICII_SCREEN_TEXT_WIDTH - 1
#STATS.POP
            ; Clear Bottom Line
            LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
            LDA.#       32
#STATS.PUSH
.3:         STA,Y       VICII_SCREEN_TEXT_LINE_24
            @DEY_BPL(.3)
#STATS.LOOP VICII_SCREEN_TEXT_WIDTH - 1
#STATS.POP
            RTS

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