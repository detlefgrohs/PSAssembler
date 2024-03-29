
#MACRO SET_BORDER_COLOR(COLOR)
                LDA.#       @COLOR
                STA         VICII_BORDER_COLOR
#ENDM

#MACRO EMPTY()

#ENDM


#MACRO CLEAR_RASTER_IRQ()
    LDA.#    $FF   ;this is the orthodox and safe way of clearing the interrupt condition of the VICII.
    STA     $D019
#ENDM

#MACRO SET_RASTER_IRQ(RASTER_LINE,NEW_IRQ)
    LDA.#       @RASTER_LINE
    STA         $D012
    
    LDA.#       @NEW_IRQ & $00FF    ; <{2}
    STA         $FFFE
    LDA.#       (@NEW_IRQ & $FF00) >> 8    ; >{2}
    STA         $FFFF
#ENDM

#MACRO SCREEN_OFF()
                LDA     $D011
                AND.#   %01101111
                STA     $D011
#ENDM

#MACRO SCREEN_ON()
                LDA     $D011
                ORA.#   %00010000
                AND.#   %01111111
                STA     $D011
#ENDM
