SETUP:
                    LDX.#   $00
.LOOP:              TXA
                    STA,X   VICII_SCREEN_RAM
                    STA,X   VICII_SCREEN_RAM + $100

                    EOR.#   $FF
                    STA,X   VICII_COLOR_RAM
                    STA,X   VICII_COLOR_RAM + $100

                    INX
                    BNE     .LOOP
