*=$1000

; Absolute
        LDA $1234
; AbsoluteX
        LDA $5678,X
; AbsoluteY
        LDA $9ABC,Y
; Accumulator
        ASL A
; Immediate
        LDA #$CD
; Implied
        NOP
; IndexedIndirectX
        LDA ($32,X)
; IndexedIndirectY
        LDA ($AD),Y
; Indirect
        JMP ($8000)
; Relative
LOOPA   NOP
        NOP
LOOPB   BCC LOOPA
        BEQ LOOPB+6
        NOP
        NOP
LOOPB2  NOP
; ZeroPage
        LDA $87
; ZeroPageX
        LDA $65,X
; ZeroPageY
        LDX $43,Y
