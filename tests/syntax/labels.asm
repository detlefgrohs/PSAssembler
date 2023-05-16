* = $0801

START:

            LDA.#       $00
.1:         STA         $8000
.2:         BCC         .1
            JMP         .1

FUNCTION:


.LOOP:      LDA.#       $00
.X:         BCC         .X
            JMP         .LOOP

END:        JMP         START

            LDA         ORG
            LDA         BYTESLEN
            LDA         CURADDR
