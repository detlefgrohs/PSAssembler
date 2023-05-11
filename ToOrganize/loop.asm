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

START LDA #$30
      LDX #$10

LOOP  STA SCREEN,X
      DEX
      BNE LOOP

      RTS