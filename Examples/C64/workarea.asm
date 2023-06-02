* = $0801

VALUE = 12345

#INCLUDE ..\includes\includes.h

                @BASICSTUB()

                LDX.#   @LO(VALUE)
                LDA.#   @HI(VALUE)
                JSR     $BDCD

                RTS