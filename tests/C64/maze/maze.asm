* = $0801

#INCLUDE ..\includes.h

@BASICSTUB()

TARGET_PTR     = $FB
SOURCE_PTR     = $FD

LINE_LOOP:  LDX.#       VICII_SCREEN_TEXT_WIDTH
CHAR_LOOP:  @RAND()     ; A will have a random byte

            BPL         RAND_HIGH
            LDA.#       $4D
            JMP         CONT
RAND_HIGH:  LDA.#       $4E
CONT:       
            STA,X       VICII_SCREEN_TEXT_LINE_24
            DEX
            BPL         CHAR_LOOP
            JSR         SCROLL_UP
            JMP         LINE_LOOP

SCROLL_UP:  @SET_ZP_WORD(TARGET_PTR,VICII_SCREEN_TEXT_LINE_00)
            @SET_ZP_WORD(SOURCE_PTR,VICII_SCREEN_TEXT_LINE_01)

            LDX.#       VICII_SCREEN_TEXT_HEIGHT - 1
SU_L_LOOP:  LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
SU_C_LOOP:  LDA.i,Y     SOURCE_PTR
            STA.i,Y     TARGET_PTR
            @DEY_BPL(SU_C_LOOP)     ; Char--
            @DEX_BNE(SU_NEXT)       ; Line--
            RTS
            
SU_NEXT:    @ADD_ZP_WORD(TARGET_PTR,VICII_SCREEN_TEXT_WIDTH)
            @ADD_ZP_WORD(SOURCE_PTR,VICII_SCREEN_TEXT_WIDTH)
JMP         SU_L_LOOP