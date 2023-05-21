* = $0801

#MACRO ASSERT_LAST_BYTE(BYTE0)
        #ASSERT         BYTES[BYTESLEN - 1] -eq @BYTE0
#ENDM

#MACRO ASSERT_LAST_TWO_BYTES(BYTE0,BYTE1)
        #ASSERT         BYTES[BYTESLEN - 1] -eq @BYTE0
#ENDM

#MACRO ASSERT_LAST_THREE_BYTES(BYTE0,BYTE1,BYTE2)
        #ASSERT         (BYTES[BYTESLEN - 3] -eq @BYTE0) -and (BYTES[BYTESLEN - 2] -eq @BYTE1) -and (BYTES[BYTESLEN - 1] -eq @BYTE2)
#ENDM

START:  LDA.#           $FF
        LDA.#           $AA

MSG:    #TEXT "0123456789"

        LDA             MSG
        LDA             ORG
        LDA             MSG-ORG

LDA     CURADDR
#ASSERT         BYTES[MSG-ORG] -eq '0'

STAGE = $D800

        LDA.# STAGE & $00FF 
        
LABEL:  #TEXT "HELLO WORLD!"


        DATA.b          $11
        @ASSERT_LAST_BYTE($11)

        LDA             LABEL
        @ASSERT_LAST_THREE_BYTES($AD,$1D,$08)
        
#STOP
        ; #ASSERT                 0
        ; #ASSERT                 1

        ; #ASSERT         LABEL -eq $0002
        ; #ASSERT         LABEL -eq $1000

MSG2:    #TEXT "0123456789"

        LDA.#           BYTESLEN
        LDA.#           BYTES[BYTESLEN - 1]
        LDA.#           BYTES[0]
        DATA.b          $11

        LDA             MSG2
        LDA             ORG
        LDA             MSG2-ORG

        #ASSERT         BYTES[LABEL] -eq 'H'
        #ASSERT         BYTES[MSG2 - ORG] -eq '0'