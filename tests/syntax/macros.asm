#MACRO EMPTY()
    ; Line 1
    ; Line 2
#ENDM

#MACRO MIN(X,Y)
    if (@X -lt @Y) { @X } ELSE { @Y }
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
