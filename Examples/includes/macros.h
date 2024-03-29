#MACRO LO(VALUE)
@VALUE  & $00FF
#ENDM

#MACRO HI(VALUE)
((@VALUE) & $FF00) >> 8
#ENDM

#MACRO SET_BYTE(ADDRESS,VALUE)
            LDA.#   @VALUE
            STA     @ADDRESS
#ENDM

#MACRO SET_WORD(ADDRESS,VALUE)
            LDA.#   @LO(@VALUE)
            STA     @ADDRESS
            LDA.#   @HI(@VALUE)
            STA     @ADDRESS+1
#ENDM

#MACRO SET_ZP_WORD(ADDRESS,VALUE)
            LDA.#   @LO(@VALUE)
            STA.zp  @ADDRESS
            LDA.#   @HI(@VALUE)
            STA.zp  @ADDRESS+1
#ENDM

; To Rename etc...
#MACRO MACRO_SET_WORD_PARTS(ADDRESS,LOWBYTE,HIBYTE)
    LDA.#   @LOWBYTE
    STA     @ADDRESS
    LDA.#   @HIBYTE
    STA     @ADDRESS+1
#ENDM

#MACRO MACRO_INC_A()
    CLC
    ADC.#       $01
#ENDM

#MACRO MACRO_DEC_A()
            SEC
            SBC.#       $01
#ENDM

#MACRO ADD_WORD(ADDRESS,VALUE)
            CLC
            LDA         @ADDRESS
            ADC.#       @VALUE
            STA         @ADDRESS
            LDA         @ADDRESS+1
            ADC.#       $00
            STA         @ADDRESS+1
#ENDM


#MACRO ADD_MWORD(ADDRESS,MADDRESS)
                CLC
                LDA             @ADDRESS
                ADC             @MADDRESS
                STA             @ADDRESS
                BCC             CURADDR + 5     ; 2 BCC  3 INC
                INC             @ADDRESS + 1
#ENDM

#MACRO SUBTRACT_WORD(ADDRESS,VALUE)
            SEC
            LDA         @ADDRESS
            SBC.#       @VALUE
            STA         @ADDRESS
            LDA         @ADDRESS+1
            SBC.#       $00
            STA         @ADDRESS+1
#ENDM

#MACRO ADD_ZP_WORD(ADDRESS,VALUE)
            CLC
            LDA.zp      @ADDRESS
            ADC.#       @VALUE
            STA.zp      @ADDRESS
            BCC         CURADDR + 4  ; CURADDR is Before the Branch, so adding 2 bytes
            INC.zp      @ADDRESS+1
#ENDM

#MACRO MACRO_INY_UNTIL(VALUE,LOOP)
            INY
            CPY.#       @VALUE
            BNE         @LOOP
#ENDM

#MACRO MACRO_DEX_UNTIL_ZERO(LOOP)
            DEX
            BNE         @LOOP
#ENDM

#MACRO DEY_BPL(BRANCH)
            DEY
            BPL         @BRANCH
#ENDM

#MACRO DEX_BNE(BRANCH)
            DEX
            BNE         @BRANCH
#ENDM

; ; Not sure where I found this rand() code but it works...
; ; 15 Bytes...
; RAND:       LDA.#       31
;             ASL.A               ; ASL by itself fails, so when we can't parse propertly it causes bad lines...
; RAND_MASK:  EOR.#       53
;             STA         RAND + 1
;             ADC         RAND_MASK + 1
;             STA         RAND_MASK + 1
;             RTS

#MACRO RAND()
            LDA.#       31
            ASL.A
            EOR.#       53
            STA         CURADDR - 4
            ADC         CURADDR - 4
            STA         CURADDR - 7
#ENDM


#MACRO          INC_WORD_BY_ONE(ADDRESS)
                INC         @ADDRESS
                BNE         CURADDR + 5
                INC         @ADDRESS + 1
#ENDM

#MACRO          CMP_WORD(ADDRESS,VALUE,LOOP)
                LDA         @ADDRESS + 1
                CMP.#       @HI(@VALUE)
                BNE         @LOOP
                LDA         @ADDRESS
                CMP.#       @LO(@VALUE)
                BNE         @LOOP
#ENDM

#MACRO ROL_WORD(ADDRESS)
                ASL     @ADDRESS
                ;BCC     CURADDR + 5
                ROL     @ADDRESS + 1
#ENDM

#MACRO TURN_INTERRUPTS_OFF()
                SEI                             ; Turn off Interrupts
                LDA.#   $7F
                STA     $DC0D
                STA     $DD0D
#ENDM

#MACRO NOP_LOOP(COUNT)
                LDX.#   @COUNT
                NOP
                DEX
                BPL     CURADDR - 2
#ENDM
