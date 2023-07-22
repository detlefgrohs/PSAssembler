* = $0801

#INCLUDE ..\..\includes\includes.h


KERNEL_PRINT_CHAR = $FFD2
BASIC_PRINT_NEWLINE = $AAD7

#MACRO PRINT_NEWLINE()
                JSR     BASIC_PRINT_NEWLINE ; Print NewLine
#ENDM

                @BASICSTUB()

START:
                LDA.#   @LO(STRING_1)
                LDX.#   @HI(STRING_1)
                JSR     PRINT
                @PRINT_NEWLINE()

                LDA.#   @LO(LOADING_0000)
                LDX.#   @HI(LOADING_0000)
                JSR     PRINT
                @PRINT_NEWLINE()

                LDA.#   14
                LDX.#   @LO(FILENAME)
                LDY.#   @HI(FILENAME)
                JSR     $FFBD     ; call SETNAM

                LDA.#   $01
                LDX.#   $08      ; default to device 8
                LDY.#   $02      ; $00 means: load to new address
                JSR     $FFBA     ; call SETLFS

                JSR     $FFC0   ; Open

                LDX.#   $01
                JSR     $FFC6  ; CALL CHKIN

.LOOP:          JSR     $FFB7 ; CALL READST
                BNE     .CONTINUE ; IF ZERO BIT IS 0 QUIT READING

                JSR     $FFCF

.LF_ST:         STA     $2000
                @INC_WORD_BY_ONE(.LF_ST + 1)

                LDA     .LF_ST + 1
                AND.#   %00000111
                BNE     .LOOP

                LDA.#   $2A
                JSR     KERNEL_PRINT_CHAR

                JMP     .LOOP

.CONTINUE:
                ; CLOSE FILE
                ; A: LOGICAL FILENUMBER
                LDA.#   $01  ; LOGICAL FILENUMBER 2
                JSR     $FFC3     ; CALL CLOSE

                ; RESET DEFAULT INPUT AND OUTPUT TO KEYBOARD AND SCREEN AND RESET SERIAL BUS
                JSR     $FFCC     ; CALL CLRCHN

                @PRINT_NEWLINE()
                ; LDX.#   @LO($2000)
                ; LDY.#   @HI($2000)
                ; LDA.#   $00      ; $00 means: load to memory (not verify)
                ; JSR     $FFD5     ; call LOAD

                LDA.#   0
                JSR     $2000
                @PRINT_NEWLINE()

                LDA.#   1
                JSR     $2000
                @PRINT_NEWLINE()

                LDA.#   2
                JSR     $2000
                @PRINT_NEWLINE()

                LDA.#   3
                JSR     $2000
                @PRINT_NEWLINE()

                RTS
    
STRING_1:       #ASCIIZ "STRING 1"
LOADING_0000:   #ASCIIZ "LOADING DATA0000.SEQ"

FILENAME:       #ASCIIZ "DATA0000.SEQ,S"


PRINT:          STA     .LD + 1
                STX     .LD + 2
                LDX.#   $00
.LOOP:
.LD:            LDA,X   $0000
                BEQ     .DONE

                JSR     KERNEL_PRINT_CHAR
                INX
                JMP     .LOOP

.DONE:          RTS