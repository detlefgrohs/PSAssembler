


MWord_Increment
MWord_Decrement
MWord_Add_Byte
MWord_Add_Word
MWord_Add_MByte
MWord_Add_MWord




#MACRO  MWord_Increment(Address)
                    INC     @Address
                    BNE     CURADDR + 2 + 2
                    INC     @Address + 1
#ENDM

#MACRO  MWord_Decrement(Address)


#ENDM


#MACRO  MWord_Add_Byte(Address,ByteValue)
                    CLC
                    LDA     @Address
                    ADC.#   @ByteValue
                    STA     @Address
                    BCC     CURADDR + 2 + 3
                    INC     @Address + 1
#ENDM

#MACRO  MWord_Add_Word(Address,WordValue)
                    CLC
                    LDA     @Address
                    ADC.#   @LO(@WordValue)
                    STA     @Address
                    LDA     @Address + 1
                    ADC.#   @HI(@WordValue)
                    STA     @Address + 1
#END

#MACRO  MWord_Add_MByte(Address,ByteAddress)

#ENDM

#MACRO  MWord_Add_MWord(Address,WordAddress)

#ENDM

#MACRO  ZPWord_Add_Byte

#MACRO  ZPWord_Add_Word

#MACRO  ZPWord_Add_MByte

#MACRO  ZPWord_Add_MWord

#MACRO  ZPWord_Add_ZP

From    To=>
            Word    Byte    ZPWord      ZPByte      MWord       MByte
Word        Math    Math
Byte        Math    Math
ZPWord
ZPByte
MWord
MByte



#MACRO  ZPByteLoopStart(Name,ZPAddress,StartingValue)
                    LDA.#   @StartingValue
                    STA.zp  @ZPAddress
.~Name~_Loop:
#ENDM

#MACRO  ZPWordLoopStart(Name,ZPAddress,StartingValue)
                    LDA.#   @LO(@StartingValue)
                    STA.zp  @ZPAddress
                    LDA.#   @HI(@StartingValue)
                    STA.zp  @ZPAddress + 1
.~Name~_Loop:
#ENDM


#MACRO  ByteLoopStart(Variable,StartingValue)
                    LDA.#   @StartingValue
                    STA     .~Variable~
                    JMP     CURADDR + 3 + 1
.~Variable~:        DATA.b  $00
.~Variable~_Loop:
#ENDM


#MACRO  ByteLoopEnd_Increment(Variable,Limit)
                    INC     .~Variable~
                    LDA     .~Variable~
                    CMP.#   @Limit
                    BEQ     CURADDR + 2 + 3
                    JMP     .~Variable~_Loop:
#ENDM

#MACRO WordLookStart(Variable,StartingValue)
                    LDA.#   @LO(@StartingValue)
                    STA     .~Variable~
                    LDA.#   @HI(@StartingValue)
                    STA     .~Variable~ + 1
                    JMP     CURADDR + 3 + 2
.~Variable~:        DATA    $0000
.~Variable~_Loop:
#ENDM




