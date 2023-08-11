
#STATS.PUSH

                LDX.#   $00
.SCREEN_LOOP:   INC,X   VICII_SCREEN_RAM
                INC,X   VICII_SCREEN_RAM + $100

                INC,X   VICII_COLOR_RAM
                INC,X   VICII_COLOR_RAM + $100

                INX
                BNE     .SCREEN_LOOP

#STATS.LOOP $FF
#STATS.SAVE Process-screen_loop
#STATS.POP

; Stat: 'Process-screen_loop'
;    Bytes: 17   MinCycles: 8,670   MaxCycles: 10,200
;    MinCycleTime: 8.50 mSec   MaxCycleTime: 10.00 mSec
;    Max FPS: 117.65   Min FPS: 100.00

; 18.5 Rows => 18.5 * 8 => 148 lines
;   148 lines * 63 cycles => 9324 cycles