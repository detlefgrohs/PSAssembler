* = $0801

#STATS.PUSH

            LDA.#       $00
#STATS.PUSH

            LDA,Y       $0000
#STATS.LOOP     40
#STATS
#STATS.POP
#STATS
#STATS.LOOP     24
#STATS
#STATS.POP
#STATS.Detail

#STOP

START:          LDA.#       $00
                LDY.#       120
#STATS.Push
.1:             STA         $0400
                STA         $0401

                DEY
                BPL         .1
#STATS.Loop 120
#STATS.Pop
                JMP         CURADDR
#STATS
