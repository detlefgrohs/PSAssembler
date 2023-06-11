* = $0801

#INCLUDE ..\includes\includes.h

#MACRO PRINT_INTEGER(ADDRESS)
                LDX     @ADDRESS
                LDA     @ADDRESS + 1
                JSR     $BDCD
#ENDM

#MACRO PRINT_NEWLINE()
                JSR     $AAD7 ; Print NewLine
#ENDM

#MACRO ADD_MWORD_PLUS_MWORD(ADDRESS,MADDRESS)
                CLC
                LDA             @ADDRESS
                ADC             @MADDRESS
                STA             @ADDRESS
                LDA             @ADDRESS + 1
                ADC             @MADDRESS + 1
                STA             @ADDRESS + 1
#ENDM

                @BASICSTUB()

                @PRINT_INTEGER(CONST_VALUE)
                @PRINT_NEWLINE()

                @PRINT_INTEGER(VALUE)
                @PRINT_NEWLINE()

                @PRINT_INTEGER(OFFSET1)
                @PRINT_NEWLINE()

                @PRINT_INTEGER(OFFSET2)
                @PRINT_NEWLINE()

                @ADD_MWORD_PLUS_MWORD(VALUE,OFFSET1)
                @PRINT_INTEGER(VALUE)
                @PRINT_NEWLINE()

                @ADD_MWORD_PLUS_MWORD(VALUE,OFFSET2)
                @PRINT_INTEGER(VALUE)
                @PRINT_NEWLINE()

                RTS

#MACRO  NEGATIVE(VALUE)
($10000 - @VALUE)
#ENDM

CONST_VALUE:    DATA    12345

VALUE:          DATA    1000
OFFSET1:        DATA    @NEGATIVE(320)
OFFSET2:        DATA    640
