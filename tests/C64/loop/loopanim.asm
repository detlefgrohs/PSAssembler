* = $0801

#INCLUDE ..\includes.h

@BASICSTUB()

START:          LDY.#           0
                LDA.#           $80
S0:             CPY             $D012
                BNE S0
                AND             $D011
                BNE S0

                @SET_BORDER_COLOR(VICII_COLOR_GREEN)

                @SET_WORD(LOOP1+1,$0400)
                LDA             OFFSET
                LDX.#           2
OUTER_LOOP1:        
                LDY.#           $00
LOOP1:          STA,Y           $FFFF                                     ; 5
                @MACRO_INC_A()                                     ; 4
                @MACRO_INY_UNTIL(200,LOOP1)                      ; 6 => 15 * 200 => 3000 Cycles x 5 => 15k Cycles...
                TAY
                @MACRO_ADD_WORD(LOOP1+1,200)
                TYA
                @MACRO_DEX_UNTIL_ZERO(OUTER_LOOP1)
               
                @SET_BORDER_COLOR(VICII_COLOR_YELLOW)
        
                @SET_WORD(LOOP2+1,$D800)
                LDA             OFFSET
                LDX.#           2
OUTER_LOOP2:       
                LDY.#           $00
LOOP2:          STA,Y           $FFFF       
                @MACRO_DEC_A()        
                @MACRO_INY_UNTIL(200,LOOP2)
                TAY
                @MACRO_ADD_WORD(LOOP2+1,200)
                TYA
                @MACRO_DEX_UNTIL_ZERO(OUTER_LOOP2)
                
                INC OFFSET
        
                @SET_BORDER_COLOR(VICII_COLOR_RED)
        
                JMP START
        
FOREVER:        JMP FOREVER

OFFSET:         DATA.b          $00