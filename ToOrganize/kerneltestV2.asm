* = $0801

#INCLUDE include.asm

@BASICSTUB()

; -----------------------------------------------------------------------------
; kernal entry points
SETMSG  = $FF90             ; set kernel message control flag
SECOND  = $FF93             ; set secondary address after LISTEN
TKSA    = $FF96             ; send secondary address after TALK
LISTEN  = $FFB1             ; command serial bus device to LISTEN
TALK    = $FFB4             ; command serial bus device to TALK
SETLFS  = $FFBA             ; set logical file parameters
SETNAM  = $FFBD             ; set filename
ACPTR   = $FFA5             ; input byte from serial bus
CIOUT   = $FFA8             ; output byte to serial bus
UNTLK   = $FFAB             ; command serial bus device to UNTALK
UNLSN   = $FFAE             ; command serial bus device to UNLISTEN
CHKIN   = $FFC6             ; define input channel
CLRCHN  = $FFCC             ; restore default devices
INPUT   = $FFCF             ; input a character (official name CHRIN)
CHROUT  = $FFD2             ; output a character
LOAD    = $FFD5             ; load from device
SAVE    = $FFD8             ; save to device
STOP    = $FFE1             ; check the STOP key
GETIN   = $FFE4             ; get a character

START:  LDX.#   0

LOOP:   LDA,X   MSG
        BMI     DONE
        AND.#   %01111111
        JSR     CHROUT
        INX
        JMP     LOOP

DONE:   AND.#   %01111111
        JSR     CHROUT

        LDA.#   '!'
        JSR     CHROUT
        RTS

MSG:    DATA.B      'H'
        DATA.B      'E'
        DATA.B      'L'
        DATA.B      'L'
        DATA.B      'O' | %10000000
        ; DATA.B      $00
