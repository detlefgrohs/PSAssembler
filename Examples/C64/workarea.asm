* = $0801

#INCLUDE ..\includes\includes.h

BASIC_PRINT_INTEGER = $BDCD
BASIC_PRINT_NEWLINE = $AAD7

KERNEL_PRINT_CHAR = $FFD2

#MACRO PUSH_A()
                PHA
#ENDM

#MACRO PULL_A()
                PLA
#ENDM

#MACRO PUSH_AX()
                PHA
                TXA
                PHA
#ENDM

#MACRO PULL_AX()
                PLA
                TAX
                PLA

#ENDM

#MACRO PUSH_AXY()
                PHA
                TXA
                PHA
                TYA
                PHA
#ENDM

#MACRO PULL_AXY()
                PLA
                TAY
                PLA
                TAX
                PLA
#ENDM

#MACRO PRINT_INTEGER(ADDRESS)
                LDX     @ADDRESS
                LDA     @ADDRESS + 1
                JSR     BASIC_PRINT_INTEGER
#ENDM

#MACRO PRINT_NEWLINE()
                JSR     BASIC_PRINT_NEWLINE ; Print NewLine
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

START:          JSR     BINARY_TO_BCD_8
                @SET_BYTE(PRINTHEXBYTES.NUMBYTES,2)
                @SET_WORD(PRINTHEXBYTES.ADDRESS,BINARY_TO_BCD_8.RESULT)
                JSR     PRINTHEXBYTES
                @PRINT_NEWLINE()

                JSR     BINARY_TO_BCD_16
                @SET_BYTE(PRINTHEXBYTES.NUMBYTES,3)
                @SET_WORD(PRINTHEXBYTES.ADDRESS,BINARY_TO_BCD_16.RESULT)
                JSR     PRINTHEXBYTES
                @PRINT_NEWLINE()

                JSR     BINARY_TO_BCD_24
                @SET_BYTE(PRINTHEXBYTES.NUMBYTES,4)
                @SET_WORD(PRINTHEXBYTES.ADDRESS,BINARY_TO_BCD_24.RESULT)
                JSR     PRINTHEXBYTES
                @PRINT_NEWLINE()

                JSR     BINARY_TO_BCD_32
                @SET_BYTE(PRINTHEXBYTES.NUMBYTES,5)
                @SET_WORD(PRINTHEXBYTES.ADDRESS,BINARY_TO_BCD_32.RESULT)
                JSR     PRINTHEXBYTES
                @PRINT_NEWLINE()

                RTS

#INCLUDE binary_to_bcd.asm

PRINTHEXBYTES:  DEC     .NUMBYTES
                CLC                     ; Goto the end of byte array
                LDA     .ADDRESS
                ADC     .NUMBYTES
                STA     .ADDRESS
                BCC     .1
                INC     .ADDRESS + 1

.1:             INC     .NUMBYTES

.LOOP:          JSR     .LOADBYTE
                LSR.A
                LSR.A
                LSR.A
                LSR.A
                CLC
                ADC.#   $30
                JSR     KERNEL_PRINT_CHAR

                JSR     .LOADBYTE
                AND.#   $0F
                CLC
                ADC.#   $30
                JSR     KERNEL_PRINT_CHAR

                SEC                     ; Move back in the byte array
                LDA     .ADDRESS
                SBC.#   1
                STA     .ADDRESS
                LDA     .ADDRESS + 1
                SBC.#   0
                STA     .ADDRESS + 1

                DEC     .NUMBYTES
                BNE     .LOOP

                RTS

.LOADBYTE:      LDA     $0000           ; Get the current byte
                RTS

.NUMBYTES:      DATA.b  $00
PRINTHEXBYTES.ADDRESS =      .LOADBYTE + 1

MULTIPLY_TEST:  LDA.#   255
                STA     MULTIPLY.BY

                @SET_WORD(MULTIPLY.CURRENTVALUE, 123)

                @PRINT_INTEGER(MULTIPLY.BY)

                JSR PRINT_STRING
                #ASCIIZ " * "

                @PRINT_INTEGER(MULTIPLY.CURRENTVALUE)

                JSR PRINT_STRING
                #ASCIIZ " = "

                JSR     MULTIPLY

                @PRINT_INTEGER(MULTIPLY.FINALVALUE)
                @PRINT_NEWLINE()

                RTS

MULTIPLY:

.LOOP:          LDA     .BY
                AND.#   %00000001
                BEQ     .CONT

                CLC
                LDA     .FINALVALUE
                ADC     .CURRENTVALUE
                STA     .FINALVALUE
                LDA     .FINALVALUE + 1
                ADC     .CURRENTVALUE + 1
                STA     .FINALVALUE + 1

.CONT:          ROR     .BY
                BEQ     .DONE

                ASL     .CURRENTVALUE
                ROL     .CURRENTVALUE + 1

                JMP     .LOOP

.DONE:
                RTS

.FINALVALUE:    DATA    $0000
.CURRENTVALUE:  DATA    $0000
.BY:            DATA.b  $00
.ZERO:          DATA.b  $00


COMPARE:
                JSR PRINT_STRING
                #ASCIIZ "CMP TESTS:"
                @PRINT_NEWLINE()

                LDA.#   12
                CMP.#   11      ; 
                BCS     .1

                JSR PRINT_STRING
                #ASCIIZ "REG(12) < VAL(11)"
                @PRINT_NEWLINE()

                JMP     .2
.1:
                JSR PRINT_STRING
                #ASCIIZ "REG(12) > VAL(11)"
                @PRINT_NEWLINE()

.2:

                RTS

; Compare Instruction Results
; Compare Result	        N	Z	C
; A, X, or Y < Memory	    *	0	0
; A, X, or Y = Memory	    0	1	1
; A, X, or Y > Memory	    *	0	1


COMPARE_LESS:
                LDA.#   $7F
                CMP.#   $80
                BCC     .YES
                JMP     .NO
.YES:           ; A($7F) < $80    $7F - $80 = $FF ; Carry is clear (Borrow)
.NO:            ; 

COMPARE_EQUAL:  LDA.#   $80
                CMP.#   $80
                BEQ     .YES
                JMP     .NO
.YES:           ; A($80) = $80      $80 - $80 = $00 ; Z is set and Carry is Set (No Borrow)
.NO:

COMPARE_GREATER:LDA.#   $81
                CMP.#   $80
                BEQ     .NO
                BCS     .YES
                JMP     .NO
.YES:           ; A($81) > $80      $81 - $80 = $01 ; Carry is Set (No Borrow)
.NO:

                RTS

PRINT_STRING:   @PUSH_AX()

                TSX
                LDA,X   $103
                STA     .LD + 1
                LDA,X   $104
                STA     .LD + 2

                LDX.#   1
.LOOP:
.LD:            LDA,X   $0000
                BEQ     .DONE

                JSR     KERNEL_PRINT_CHAR
                INX
                JMP     .LOOP

.DONE:          TXA
                TSX
                CLC
                ADC,X   $103
                STA,X   $103
                BCC     CURADDR + 2 + 3
                INC,X   $104

                @PULL_AX()
                RTS

#STOP
                @PRINT_INTEGER(.WORD)
                @PRINT_NEWLINE()

#STATS.PUSH
                INC     .WORD
                BNE     CURADDR + 2 + 3
                INC     .WORD + 1
#STATS.SAVE INC
#STATS.POP

                @PRINT_INTEGER(.WORD)
                @PRINT_NEWLINE()

                INC     .WORD
                BNE     CURADDR + 2 + 3
                INC     .WORD + 1

                @PRINT_INTEGER(.WORD)
                @PRINT_NEWLINE()

                INC     .WORD
                BNE     CURADDR + 2 + 3
                INC     .WORD + 1

                @PRINT_INTEGER(.WORD)
                @PRINT_NEWLINE()


                @PRINT_INTEGER(.WORD2)
                @PRINT_NEWLINE()

#STATS.PUSH
                CLC
                LDA     .WORD2
                ADC.#   1
                STA     .WORD2
                BCC     CURADDR + 2 + 3
                INC     .WORD2 + 1
#STATS.SAVE ADC
#STATS.POP

                @PRINT_INTEGER(.WORD2)
                @PRINT_NEWLINE()

                CLC
                LDA     .WORD2
                ADC.#   1
                STA     .WORD2
                BCC     CURADDR + 2 + 3
                INC     .WORD2 + 1

                @PRINT_INTEGER(.WORD2)
                @PRINT_NEWLINE()

                RTS

.WORD:          DATA    254
.WORD2:         DATA    255

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

                ;bsout    =$ffd2 
                JSR     PRINT_2
                #ASCIIZ "A MESSAGE!"
                @PRINT_NEWLINE()

                JSR     PRINT_2
                #ASCIIZ "YET ANOTHER MESSAGE!"
                @PRINT_NEWLINE()

                JSR     PRINT_2
                #ASCIIZ "AND YET ANOTHER MESSAGE!!!"
                @PRINT_NEWLINE()


                LDA.#   @LO(MESSAGE)
                LDX.#   @HI(MESSAGE)
                JSR     PRINT
                @PRINT_NEWLINE()

                ;JMP     .TEMP
                JSR     ADD_WORDS
.NUMBER1:       DATA    1234
.NUMBER2:       DATA    4567
.RESULT:        DATA    $0000

.TEMP:
                @PRINT_INTEGER(.NUMBER1)
                JSR     PRINT_2
                #ASCIIZ " + "

                @PRINT_INTEGER(.NUMBER2)

                JSR     PRINT_2
                #ASCIIZ " = "

                @PRINT_INTEGER(.RESULT)

                @PRINT_NEWLINE()

                JSR     ADD_WORDS_WITH_PRINT
                DATA    128
                DATA    64
                DATA    $0000

                JSR     ADD_WORDS_WITH_PRINT
                DATA    1000
                DATA    2000
                DATA    $0000


                RTS

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
#CONTINUE



#STOP
#STATS.PUSH
ADD_WORDS:      @PUSH_AXY()     ; Since we are saving A, X and Y the stack offset is +3
                                ; Normally $101 + SP => is RTS address low byte and
                                ; $102 + SP => is RTS address hi byte

                TSX             ; Get the Address that RTS is slated to come back from
                LDA,X   $104    ; Remember it is off by 1 for the cpu to increment after
                STA     $FB     ; a RTS...
                LDA,X   $105
                STA     $FC

                ; Now do the actual work...
                CLC             ; We have to use a ZP location so that we can access
                LDY.#   1       ; the parameter data because of what we are doing
                LDA.i,Y $FB     ; We could do something else with modifying code and 
                LDY.#   3       ; using absolute addresses but this proves the code
                ADC.i,Y $FB
                LDY.#   5
                STA.i,Y $FB
                LDY.#   2
                LDA.i,Y $FB
                LDY.#   4
                ADC.i,Y $FB
                LDY.#   6
                STA.i,Y $FB
                
                ; Now update the RTS address on the stack to skip the parameters
                LDA.#   6
                TSX
                CLC
                ADC,X   $104
                STA,X   $104
                BCC     CURADDR + 2 + 3
                INC,X   $105

                @PULL_AXY()
                RTS
#STATS.DETAILS
#STATS.SAVE ADD_WORDS
#STATS.POP

#STATS.PUSH
ADD_WORDS_WITH_PRINT:      
                @PUSH_AXY()     ; Since we are saving A, X and Y the stack offset is +3
                                ; Normally $101 + SP => is RTS address low byte and
                                ; $102 + SP => is RTS address hi byte

                TSX             ; Get the Address that RTS is slated to come back from
                LDA,X   $104    ; Remember it is off by 1 for the cpu to increment after
                STA     $FB     ; a RTS...
                LDA,X   $105
                STA     $FC

                ; Now do the actual work...
                CLC             ; We have to use a ZP location so that we can access
                LDY.#   1       ; the parameter data because of what we are doing
                LDA.i,Y $FB     ; We could do something else with modifying code and 
                LDY.#   3       ; using absolute addresses but this proves the code
                ADC.i,Y $FB
                LDY.#   5
                STA.i,Y $FB
                LDY.#   2
                LDA.i,Y $FB
                LDY.#   4
                ADC.i,Y $FB
                LDY.#   6
                STA.i,Y $FB

                ; Print the equation
                LDY.#   1
                LDA.i,Y $FB
                TAX
                INY
                LDA.i,Y $FB
                JSR     BASIC_PRINT_INTEGER

                JSR     PRINT_2
                #ASCIIZ " + "

                LDY.#   3
                LDA.i,Y $FB
                TAX
                INY
                LDA.i,Y $FB
                JSR     BASIC_PRINT_INTEGER

                JSR     PRINT_2
                #ASCIIZ " = "

                LDY.#   5
                LDA.i,Y $FB
                TAX
                INY
                LDA.i,Y $FB
                JSR     BASIC_PRINT_INTEGER

                @PRINT_NEWLINE()

                ; Now update the RTS address on the stack to skip the parameters
                TSX
                CLC
                LDA.#   6
                ADC,X   $104
                STA,X   $104
                BCC     CURADDR + 2 + 3
                INC,X   $105

                @PULL_AXY()
                RTS
#STATS.DETAILS
#STATS.SAVE ADD_WORDS_WITH_PRINT
#STATS.POP


#MACRO  NEGATIVE(VALUE)
($10000 - @VALUE)
#ENDM

CONST_VALUE:    DATA    12345

VALUE:          DATA    1000
OFFSET1:        DATA    @NEGATIVE(320)
OFFSET2:        DATA    640

MESSAGE:        #ASCIIZ "HELLO WORLD."

#CONTINUE