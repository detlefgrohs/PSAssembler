* = $0801

INCLUDE include.asm

STUB  WORD $080B        ; A Comment....
      WORD $000A
      BYTE $9E
      BYTE $32
      BYTE $30
      BYTE $36
      BYTE $31
      BYTE $00
      WORD $0000

START LDX #$30          ; Put 0 in the 1st cell of the screen
      TXA
      STA SCREEN

      INX
      TXA
      STA SCREEN+1

      RTS