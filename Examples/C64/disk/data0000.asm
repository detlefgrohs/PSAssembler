
#INCLUDE ..\..\includes\includes.h

KERNEL_PRINT_CHAR = $FFD2

; Not sure why the assembly load strips the 1st 2 bytes...
;                DATA    $2000

* = $2000

PRINT_FROM_STRING_TABLE:
                ASL.A
                TAX
                LDA,X   STRING_TABLE
                STA     .LD + 1
                LDA,X   STRING_TABLE + 1
                STA     .LD + 2
                LDX.#   $00
.LOOP:
.LD:            LDA,X   $0000
                BEQ     .DONE

                JSR     KERNEL_PRINT_CHAR
                INX
                JMP     .LOOP

.DONE:          RTS


STRING_TABLE:   DATA    STRING_1
                DATA    STRING_2
                DATA    STRING_3
                DATA    STRING_4

STRING_1:       #ASCIIZ "STRING 1 FROM DISK"
STRING_2:       #ASCIIZ "STRING 2 FROM DISK"
STRING_3:       #ASCIIZ "STRING 3 FROM DISK"
STRING_4:       #ASCIIZ "STRING 4 FROM DISK"
