#STATS.PUSH
                LDX.#   $20
.IDLE_LOOP:     NOP
                DEX
                BNE     .IDLE_LOOP
#STATS.LOOP $10
#STATS.SAVE Process-nop_loop
#STATS.POP

; Stat: 'Process-nop_loop'
;    Bytes: 6   MinCycles: 2,040   MaxCycles: 2,550
;    MinCycleTime: 2.00 mSec   MaxCycleTime: 2.50 mSec
;    Max FPS: 500.00   Min FPS: 400.00

; About 4 lines or 8*4 => 32 lines * 63 cycles
; 2016 cycles...