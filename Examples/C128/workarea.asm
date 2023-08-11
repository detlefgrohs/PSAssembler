*=$1C01

#INCLUDE ..\includes\includes.h

                @BASICSTUB128()

                LDA.#   $01
                STA     $0400

                RTS