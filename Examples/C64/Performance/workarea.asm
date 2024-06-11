* = $0801

#INCLUDE ..\..\includes\includes.h
#INCLUDE macros.h

                @BASICSTUB()

START:

#INCLUDE process\screen_loop-setup.asm

                @TURN_INTERRUPTS_OFF()

.LOOP:          @WAIT_FOR_RASTER_LINE(0)
                @SET_BORDER_COLOR(VICII_COLOR_BLACK)
                @WAIT_FOR_RASTER_LINE(50)
                @NOP_LOOP(5)
                @SET_BORDER_COLOR(VICII_COLOR_WHITE)

; #INCLUDE process\nop_loop.asm
#INCLUDE process\screen_loop.asm

                @SET_BORDER_COLOR(VICII_COLOR_RED)
                JMP     .LOOP

; ===========================================================================
#INCLUDE functions\wait_for_raster_line.asm
; ===========================================================================
