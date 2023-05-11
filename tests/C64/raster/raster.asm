* = $0801

#INCLUDE ..\includes.h

@BASICSTUB()

START:      LDY.#       1
            JSR         WAIT_FOR_RASTER_LINE
            
            @SET_BORDER_COLOR(VICII_COLOR_RED)
            ;LDA.#       VICII_COLOR_RED      ; Set Border Color to Red
            ;STA         VICII_BORDER_COLOR
            
            LDY.#       VICII_TOP_SCREEN_RASTER_POS
            JSR         WAIT_FOR_RASTER_LINE
            
            @SET_BORDER_COLOR(VICII_COLOR_GREEN)
            ;LDA.#       VICII_COLOR_GREEN      ; Set Border Color to Green
            ;STA         VICII_BORDER_COLOR

            LDY.#       (VICII_TOP_SCREEN_RASTER_POS + VICII_SCREEN_RASTER_LINES)
            JSR         WAIT_FOR_RASTER_LINE
 
            @SET_BORDER_COLOR(VICII_COLOR_YELLOW)
            ;LDA.#       VICII_COLOR_YELLOW      ; Set Border Color to Yellow
            ;STA         VICII_BORDER_COLOR            
            
            JMP         START
            
WAIT_FOR_RASTER_LINE: ; Only works for Rasters < 256
            LDA.#       $80
WRL:        CPY         VICII_RASTER
            BNE WRL
            AND         VICII_CONTROL_1
            BNE WRL
            RTS
; 312 Raster Lines
; 200 From Vic-II

; 0 is Top of Screen
; 50 is Top of graphics area