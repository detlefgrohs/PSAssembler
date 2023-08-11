
#MACRO WAIT_FOR_RASTER_LINE(LINE)
                LDY.#   @LINE
                JSR     WAIT_FOR_RASTER_LINE
#ENDM

; ===========================================================================
WAIT_FOR_RASTER_LINE: ; Only works for Rasters < 256
                LDA.#   $80
.LOOP:          CPY     VICII_RASTER
                BNE     .LOOP
                AND     VICII_CONTROL_1
                BNE     .LOOP

                RTS