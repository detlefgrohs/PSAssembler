* = $0801

#INCLUDE ..\includes.h

@BASICSTUB()

TARGET_PTR     = $FB
SOURCE_PTR     = $FD

START:      LDX.#       VICII_SCREEN_TEXT_WIDTH
.1:         @RAND()     ; A will have a random byte

            BPL         .2
            LDA.#       $4D
            JMP         .3

.2:         LDA.#       $4E
.3:         STA,X       VICII_SCREEN_TEXT_LINE_24
            DEX
            BPL         .1
            JSR         SCROLL_UP
            JMP         START

SCROLL_UP:  @SET_ZP_WORD(TARGET_PTR,VICII_SCREEN_TEXT_LINE_00)
            @SET_ZP_WORD(SOURCE_PTR,VICII_SCREEN_TEXT_LINE_01)

            LDX.#       VICII_SCREEN_TEXT_HEIGHT - 1
.1:         LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
.2:         LDA.i,Y     SOURCE_PTR
            STA.i,Y     TARGET_PTR
            @DEY_BPL(.2)     ; Char--
            @DEX_BNE(.3)       ; Line--
            RTS

.3:         @ADD_ZP_WORD(TARGET_PTR,VICII_SCREEN_TEXT_WIDTH)
            @ADD_ZP_WORD(SOURCE_PTR,VICII_SCREEN_TEXT_WIDTH)
            JMP         .1