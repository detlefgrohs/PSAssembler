* = $0801

#INCLUDE ..\includes.h

@BASICSTUB()

TARGET_PTR     = $FB
SOURCE_PTR     = $FD

ZP_PTR_A     = $FB
ZP_PTR_B     = $FD

START:      LDY.#       250
            JSR         WAIT4RASTER
            
            ;INC         VICII_BORDER_COLOR

            LDX.#       VICII_SCREEN_TEXT_WIDTH - 1
CHAR_LOOP:  JSR         RAND    ;@RAND()     ; A will have a random byte

            BPL         RAND1_HIGH
            LDA.#       $69
            STA,X       VICII_SCREEN_TEXT_LINE_24
            LDA.#       VICII_COLOR_LIGHT_GREY
            STA,X       VICII_SCREEN_COLOR_LINE_24
            
            JMP         CONT1

RAND1_HIGH: LDA.#       $5F
            STA,X       VICII_SCREEN_TEXT_LINE_24
            LDA.#       VICII_COLOR_DARK_GREY
            STA,X       VICII_SCREEN_COLOR_LINE_24

CONT1:      DEX

            JSR         RAND    ;@RAND()     ; A will have a random byte

            BPL         RAND2_HIGH
            LDA.#       $E9
            STA,X       VICII_SCREEN_TEXT_LINE_24
            LDA.#       VICII_COLOR_LIGHT_GREY
            STA,X       VICII_SCREEN_COLOR_LINE_24
            
            JMP         CONT2

RAND2_HIGH: LDA.#       $DF
            STA,X       VICII_SCREEN_TEXT_LINE_24
            LDA.#       VICII_COLOR_DARK_GREY
            STA,X       VICII_SCREEN_COLOR_LINE_24

CONT2:      DEX

            BPL         CHAR_LOOP
            JSR         TEXT.SCROLL_UP

; Reversed Line
            LDX.#       VICII_SCREEN_TEXT_WIDTH - 1
CHAR2_LOOP: JSR         RAND    ;@RAND()     ; A will have a random byte

            BPL         RAND3_HIGH
            LDA.#       $E9
            STA,X       VICII_SCREEN_TEXT_LINE_24
            LDA.#       VICII_COLOR_LIGHT_GREY
            STA,X       VICII_SCREEN_COLOR_LINE_24
            
            JMP         CONT3

RAND3_HIGH: LDA.#       $DF
            STA,X       VICII_SCREEN_TEXT_LINE_24
            LDA.#       VICII_COLOR_DARK_GREY
            STA,X       VICII_SCREEN_COLOR_LINE_24

CONT3:      DEX

            JSR         RAND    ;@RAND()     ; A will have a random byte

            BPL         RAND4_HIGH
            LDA.#       $69
            STA,X       VICII_SCREEN_TEXT_LINE_24
            LDA.#       VICII_COLOR_LIGHT_GREY
            STA,X       VICII_SCREEN_COLOR_LINE_24
            
            JMP         CONT4

RAND4_HIGH: LDA.#       $5F
            STA,X       VICII_SCREEN_TEXT_LINE_24
            LDA.#       VICII_COLOR_DARK_GREY
            STA,X       VICII_SCREEN_COLOR_LINE_24

CONT4:      DEX

            BPL         CHAR2_LOOP

SPACECHECK: LDA         $DC01
            CMP.#       $EF
            BEQ         SPACECHECK

            JSR         TEXT.SCROLL_UP

            JMP         START



; SCROLL_UP:  @SET_ZP_WORD(TARGET_PTR,VICII_SCREEN_TEXT_LINE_00)
;             @SET_ZP_WORD(SOURCE_PTR,VICII_SCREEN_TEXT_LINE_01)

;             LDX.#       VICII_SCREEN_TEXT_HEIGHT - 1
; SU_L_LOOP:  LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
; SU_C_LOOP:  LDA.i,Y     SOURCE_PTR
;             STA.i,Y     TARGET_PTR
;             @DEY_BPL(SU_C_LOOP)     ; Char--
;             @DEX_BNE(SU_NEXT)       ; Line--
;             JMP         SU_COLOR

; SU_NEXT:    @ADD_ZP_WORD(TARGET_PTR,VICII_SCREEN_TEXT_WIDTH)
;             @ADD_ZP_WORD(SOURCE_PTR,VICII_SCREEN_TEXT_WIDTH)
;             JMP         SU_L_LOOP



; SU_COLOR:   @SET_ZP_WORD(TARGET_PTR,VICII_SCREEN_COLOR_LINE_00)
;             @SET_ZP_WORD(SOURCE_PTR,VICII_SCREEN_COLOR_LINE_01)

;             LDX.#       VICII_SCREEN_TEXT_HEIGHT - 1
; SU_C_L_LOOP:LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
; SU_C_C_LOOP:LDA.i,Y     SOURCE_PTR
;             STA.i,Y     TARGET_PTR
;             @DEY_BPL(SU_C_C_LOOP)     ; Char--
;             @DEX_BNE(SU_C_NEXT)       ; Line--
;             RTS

; SU_C_NEXT:  @ADD_ZP_WORD(TARGET_PTR,VICII_SCREEN_TEXT_WIDTH)
;             @ADD_ZP_WORD(SOURCE_PTR,VICII_SCREEN_TEXT_WIDTH)
;             JMP         SU_C_L_LOOP

; TEXT.SCROLL_UP:  
;             @SET_ZP_WORD(ZP_PTR_A,VICII_SCREEN_TEXT_LINE_00)
;             @SET_ZP_WORD(ZP_PTR_B,VICII_SCREEN_TEXT_LINE_01)
;             JSR         TEXT.SCROLL
;             @SET_ZP_WORD(ZP_PTR_A,VICII_SCREEN_COLOR_LINE_00)
;             @SET_ZP_WORD(ZP_PTR_B,VICII_SCREEN_COLOR_LINE_01)
;             JSR         TEXT.SCROLL
;             RTS

; TEXT.SCROLL:
;             LDX.#       VICII_SCREEN_TEXT_HEIGHT - 1
; .1:         LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
; .2:         LDA.i,Y     ZP_PTR_B
;             STA.i,Y     ZP_PTR_A
;             @DEY_BPL(.2)        ; Char--
;             @DEX_BNE(.3)        ; Line--
;             RTS

; .3:         @ADD_ZP_WORD(ZP_PTR_A,VICII_SCREEN_TEXT_WIDTH)
;             @ADD_ZP_WORD(ZP_PTR_B,VICII_SCREEN_TEXT_WIDTH)
;             JMP         .1

; =========================================================================
TEXT.SCROLL_UP:  
            @SET_WORD(.TT+1,VICII_SCREEN_TEXT_LINE_00)
            @SET_WORD(.TS+1,VICII_SCREEN_TEXT_LINE_01)
            @SET_WORD(.CT+1,VICII_SCREEN_COLOR_LINE_00)
            @SET_WORD(.CS+1,VICII_SCREEN_COLOR_LINE_01)
            
            LDX.#       VICII_SCREEN_TEXT_HEIGHT - 1
.1:         LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
.2:         
.TS:        LDA,Y       $0000
.TT:        STA,Y       $0000
.CS:        LDA,Y       $0000
.CT:        STA,Y       $0000

            @DEY_BPL(.2)        ; Char--
            @DEX_BNE(.3)        ; Line--

            ; Clear Bottom Line
            @SET_ZP_WORD(ZP_PTR_A,VICII_SCREEN_TEXT_LINE_24)
            ;@SET_ZP_WORD(ZP_PTR_B,VICII_SCREEN_COLOR_LINE_24)
            
            LDY.#       VICII_SCREEN_TEXT_WIDTH - 1
            LDA.#       32
.4:         STA.i,Y     ZP_PTR_A
            @DEY_BPL(.4)

            RTS

.3:         @ADD_WORD(.TT+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.TS+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.CT+1,VICII_SCREEN_TEXT_WIDTH)
            @ADD_WORD(.CS+1,VICII_SCREEN_TEXT_WIDTH)
            JMP         .1




RAND:       @RAND()
            RTS

WAIT4RASTER: ; Only works for Rasters < 256
            LDA.#       $80
W4R_LOOP:   CPY         $D012
            BNE         W4R_LOOP
            AND         $D011
            BNE         W4R_LOOP
            RTS