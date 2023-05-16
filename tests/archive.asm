; Archived Code







; =========================================================================
TEXT.SCROLL_UP2:  
            @SET_ZP_WORD(ZP_PTR_A,VICII_SCREEN_TEXT_LINE_00)
            @SET_ZP_WORD(ZP_PTR_B,VICII_SCREEN_TEXT_LINE_01)
            JSR         TEXT.SCROLL2
            @SET_ZP_WORD(ZP_PTR_A,VICII_SCREEN_COLOR_LINE_00)
            @SET_ZP_WORD(ZP_PTR_B,VICII_SCREEN_COLOR_LINE_01)
            JSR         TEXT.SCROLL2

            ; Clear Bottom Line
            @SET_ZP_WORD(ZP_PTR_A,VICII_SCREEN_TEXT_LINE_24)
            ;@SET_ZP_WORD(ZP_PTR_B,VICII_SCREEN_COLOR_LINE_24)
            
            LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
            LDA.#       32
.1:         STA.i,Y     ZP_PTR_A
            @DEY_BPL(.1)

            RTS

TEXT.SCROLL2:
            LDX.#       VICII_SCREEN_TEXT_HEIGHT - 1
.1:         LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
.2:         LDA.i,Y     ZP_PTR_B
            STA.i,Y     ZP_PTR_A
            @DEY_BPL(.2)        ; Char--
            @DEX_BNE(.3)        ; Line--
            RTS

.3:         @ADD_ZP_WORD(ZP_PTR_A,VICII_SCREEN_TEXT_WIDTH)
            @ADD_ZP_WORD(ZP_PTR_B,VICII_SCREEN_TEXT_WIDTH)
            JMP         .1




