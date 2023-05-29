* = $0801

#INCLUDE ..\includes\basicstub.h

@BASICSTUB()

START:
        LDX.#       $00

.LOOP:
        LDA.#       32
        STA         .CHAR + 1

.CFIZZBUZZ:
        LDY.#       3 * 5
        TXA
        JSR         MODULUS

        CMP.#       $00
        BNE         .CFIZZ

        LDA.#       28
        STA         .CHAR + 1
        JMP         .CHAR

.CFIZZ:
        LDY.#       3
        TXA
        JSR         MODULUS

        CMP.#       $00
        BNE         .CBUZZ

        LDA.#       6
        STA         .CHAR + 1
        JMP         .CHAR

.CBUZZ:
        LDY.#       5
        TXA
        JSR         MODULUS

        CMP.#       $00
        BNE         .CHAR

        LDA.#       2
        STA         .CHAR + 1

.CHAR:  LDA.#       $00
        STA,X       $0400

        INX
        BNE         .LOOP

        RTS

MODULUS:; A MOD Y
        STY         .CMP + 1
        STY         .SBC + 1
.LOOP:
.CMP:   CMP.#       $00
        BCS         .1
        RTS

.1:     SEC
.SBC:   SBC.#       $00
        JMP         .LOOP
