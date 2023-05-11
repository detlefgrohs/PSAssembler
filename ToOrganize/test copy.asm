STUB  WORD $080B
      WORD $000A
      BYTE $9E
      BYTE $32
      BYTE $30
      BYTE $36
      BYTE $31
      BYTE $00
      WORD $0000

START RTS

      lda #$ff
      lda $A1
      lda $B2,X
      lda $ABCD
      lda $6789,X
      lda $1234,Y
      lda ($12,X)
      lda ($34),Y
