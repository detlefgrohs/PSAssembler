; * = $0000

; Found problem with no * = where the labels only increase since the address counter does not reset...

#MACRO WithLabel(A)
            LDA     $1000
            CMP.#   @A
            BEQ     @MacroId.1
            NOP
            ;JMP     @MacroId.1
@MacroId.1:
#ENDM

@WithLabel(100)
@WithLabel(200)
@WithLabel(250)

@AfterUse()


#MACRO AfterUse()
    ; Worked
#ENDM

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
; FOR (~IndexName~ = ~StartValue~ ; 
            LDA.#       @StartValue
            STA         .~IndexName~
            JMP         .~IndexName~_Loop
.~IndexName~:   DATA.b  $00
.~IndexName~_Loop:            
#ENDM

#MACRO LOOP_NEXT(IndexName,Limit)
; ~IndexName~ < ~Limit~ ; ~IndexName~++)
            INC             .~IndexName~
            LDA             .~IndexName~
            CMP.#           @Limit
            BNE             .~IndexName~_Loop
#ENDM

@LOOP_START(IndexA, 0)
            LDA         .IndexA
@LOOP_NEXT(IndexA, 16)



@LOOP_START(Y,0)
@LOOP_START(X,0)

            ; A  = (Y << 4) + X
            LDA         .Y
            ROL.A
            ROL.A
            ROL.A
            ROL.A
            CLC
            ADC         .X

@LOOP_NEXT(X,16)
@LOOP_NEXT(Y,16)

; Testing Spaces in Macro Definition
#MACRO TEST( VarA , VarB )
        LDA     @VarA
        STA     @VarB
    ; '@VarA' => '@VarB'
#ENDM

X:      DATA.b  $00
Y:      DATA.b  $00

        @TEST( X , Y )


#MACRO CHECK2VALUE(ADDRESS,RESULT,VALUEA,VALUEB)
                LDA     .NEIGHBORS
                AND.#   %00100000
                BNE     CURADDR + 2 + 2 + 3
                LDA.#   @VALUEA
                JMP     CURADDR + 3 + 2
                LDA.#   @VALUEB
                STA,X   @RESULT
                INX
#ENDM

TEST_ROUTINE:
            @CHECK2VALUE(.NEIGHBORS,.TILE_VALUE,$00,$10)


.VALUE:      DATA.b $00
.CURRENT:       DATA.b  $00
.NEIGHBORS:     DATA.b  $00
.TILE_VALUE:    PAD     10