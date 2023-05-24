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

* = $0801
; New Functionality
START:

#MACRO LOOP_START(IndexName,StartValue)
            LDA.#       @StartValue
            STA         .~IndexName~
            JMP         .~IndexName~_Loop
.~IndexName~:   DATA.b  $00
.~IndexName~_Loop:            
#ENDM

#MACRO LOOP_NEXT(IndexName,Limit)
            INC             .~IndexName~
            LDA             .~IndexName~
            CMP.#           @Limit
            BNE             .~IndexName~_Loop
#ENDM

@LOOP_START(IndexA, 0)

@LOOP_NEXT(IndexA, 16)
