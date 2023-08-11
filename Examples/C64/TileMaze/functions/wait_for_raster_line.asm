; ===========================================================================
WAIT_FOR_RASTER_LINE: ; Only works for Rasters < 256
                LDA.#   $80
.LOOP:          CPY     VICII_RASTER
                BNE     .LOOP
                AND     VICII_CONTROL_1
                BNE     .LOOP

                RTS