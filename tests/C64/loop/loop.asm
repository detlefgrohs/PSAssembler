* = $0801

#INCLUDE ..\includes.h

@BASICSTUB()

QuarterPage = 1000 / 4

START:      LDX.#       QuarterPage

LOOP:       TXA
            
            STA,X       VICII_SCREEN_RAM + (QuarterPage * 0)
            STA,X       VICII_COLOR_RAM + (QuarterPage * 0)

            STA,X       VICII_SCREEN_RAM + (QuarterPage * 1)
            STA,X       VICII_COLOR_RAM + (QuarterPage * 1)
            
            STA,X       VICII_SCREEN_RAM + (QuarterPage * 2)
            STA,X       VICII_COLOR_RAM + (QuarterPage * 2)

            STA,X       VICII_SCREEN_RAM + (QuarterPage * 3)
            STA,X       VICII_COLOR_RAM + (QuarterPage * 3)

            DEX
            BNE         LOOP

            RTS