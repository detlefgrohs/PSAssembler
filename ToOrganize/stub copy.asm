* = $0801

SCREEN = $0400
SCREENX = $0400 + 40

STUB  WORD $080B        ; A Comment....
      WORD $000A
      BYTE $9E
      BYTE $32
      BYTE $30
      BYTE $36
      BYTE $31
      BYTE $00
      WORD $0000

START LDX #$30
      TXA
      STA SCREEN

      INX
      TXA
      STA SCREEN+1

      RTS

      STA $11

      LDA SCREEN
      STA $10 + 1
      LDY (100 + 200 + SCREENX)