* =  $0000 ; $0801

#INCLUDE ..\includes.h

@BASICSTUB()

            RTS

            FILL   10

            PAD    $100 - CURADDR

CHARSET:
#LOADBINARY     charset.bin

ENDOFASSEMBLY:
                LDA.#       $00
                STA         ENDOFASSEMBLY