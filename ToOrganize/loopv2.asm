* = $0801

#INCLUDE include.asm

@BASICSTUB()

; @IgnoreThis()

; 40 x 25 => 1000 or 250 x 4
QuarterPage = 1000 / 4

START:      LDX.#       QuarterPage

LOOP:       TXA
            
            STA,X       SCREEN + (QuarterPage * 0)
            STA,X       COLOR + (QuarterPage * 0)

            STA,X       SCREEN + (QuarterPage * 1)
            STA,X       COLOR + (QuarterPage * 1)
            
            STA,X       SCREEN + (QuarterPage * 2)
            STA,X       COLOR + (QuarterPage * 2)

            STA,X       SCREEN + (QuarterPage * 3)
            STA,X       COLOR + (QuarterPage * 3)

            DEX
            BNE         LOOP

            JMP         END               ; Skip to End

            ; Test Syntax
            LDA.#       %1100 + %11
            LDA.#       HIGHNIBBLE | LOWNIBBLE
            LDA.#       HIGHNIBBLE & LOWNIBBLE
            LDA.#       NOVAR

            LDA.#       @SHIFTL(%10,2)
            LDA.#       %1 << 2

            BCC         $9000       ; Bad Branch

            NOP               ; Nothing
            NOP

            LDA,X       SCREEN

END:        RTS

@BadMacro()
