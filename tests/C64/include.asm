; include.asm file...
SCREEN = $0400
COLOR = $D800

HIGHNIBBLE = %11110000
LOWNIBBLE = %00001111

#MACRO BASICSTUB()

            DATA        $080B    ; Basic Stub
            DATA        $000A    ; 10 SYS2061
            DATA.B      $9E
            DATA.B      $32
            DATA.B      $30
            DATA.B      $36
            DATA.B      $31
            DATA.B      $00
            DATA        $0000

#ENDM

#MACRO SHIFTL(VALUE,AMOUNT)
    @VALUE << @AMOUNT
#ENDM