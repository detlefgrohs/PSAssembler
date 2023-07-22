* = $0801

#INCLUDE includes\includes.h

@BASICSTUB()

START:

                RTS

#STATS.PUSH
                INC     WORD_VALUE
                BEQ     CURADDR + 2 + 3
                INC     WORD_VALUE + 1
#STATS.SAVE 00_INC_WORD
#STATS.POP

#STATS.PUSH
                CLC
                LDA     WVALUE_1
                ADC     BYTE_VALUE
                STA     WVALUE_1
                BCC     CURADDR + 2 + 3
                INC     WVALUE_2
#STATS.SAVE 01_ADC_WORD_PLUS_BYTE
#STATS.POP

#STATS.PUSH
                CLC
                LDA     WVALUE_1
                ADC     WVALUE_2
                STA     WVALUE_1
                LDA     WVALUE_1 + 1
                ADC     WVALUE_2 + 1
                STA     WVALUE_1 + 1
#STATS.SAVE 02_ADC_WORD_PLUS_WORD
#STATS.POP


WORD_VALUE:     DATA    $0000
BYTE_VALUE:     DATA.b  $00

WVALUE_1:       DATA    $0000
WVALUE_2:       DATA    $0000
