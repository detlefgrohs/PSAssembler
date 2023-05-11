* = $0801

#INCLUDE include.asm

@BASICSTUB()

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

            RTS