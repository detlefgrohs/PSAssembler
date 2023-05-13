* = $0801

#INCLUDE ..\includes.h

@BASICSTUB()
            LDX.#       $00
LOOP:       LDA,X       MSG_HELLO
            BEQ         DONE
            STA,X       VICII_SCREEN_TEXT_LINE_00

            LDA.#       VICII_COLOR_RED
            STA,X       VICII_COLOR_RAM

            INX
            JMP         LOOP
DONE:
            RTS

MSG_HELLO:      #TEXT "HELLO WORLD!"
                DATA.b $00