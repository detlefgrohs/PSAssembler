#MACRO EMPTY()
    ; Line 1
    ; Line 2
#ENDM

#MACRO MIN(X,Y)
    if (@X -lt @Y) { @X } else { @Y }
#ENDM

#MACRO SET_BORDER_COLOR(COLOR)
                LDA.#       @COLOR 
                STA         VICII_BORDER_COLOR
#ENDM

VICII_BORDER_COLOR = $D800

@EMPTY()

            LDA.zp         @MIN(1,2)
            LDA.zp         @MIN(3,2)
            LDA.zp         @MIN(4,4)

@SET_BORDER_COLOR($02)


#MACRO LO(VALUE)
(@VALUE & $00FF)
#ENDM

#MACRO HI(VALUE)
((@VALUE & $FF00) >> 8)
#ENDM

ADDRESS = $ABCD

                LDA.#           @LO(ADDRESS)
                LDA.#           @HI(ADDRESS)

#MACRO SET_WORD(ADDRESS,VALUE)
    LDA.#   @LO(@VALUE)
    ; Test
    STA     @ADDRESS
    LDA.#   @HI(@VALUE)
    ; Test
    STA     @ADDRESS+1
#ENDM

            @SET_WORD($ABCD,$1234)


