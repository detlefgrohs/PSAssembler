

; ===========================================================================

#MACRO CHECK2VALUE(MASK,VALUE1,VALUE0)
                LDA     .NEIGHBORS
                AND.#   @MASK
                BNE     CURADDR + 2 + 2 + 3
                LDA.#   @VALUE0
                JMP     CURADDR + 3 + 2
                LDA.#   @VALUE1
                STA,X   .TILE_VALUE
                INX
#ENDM

#MACRO CHECK4VALUE(MASK,CHECK11,VALUE11,CHECK10,VALUE10,CHECK01,VALUE01,VALUE00)
                LDA     .NEIGHBORS
                AND.#   @MASK
                CMP.#   @CHECK11
                BNE     CURADDR + 2 + 2 + 3
                LDA.#   @VALUE11
                JMP     CURADDR + 3 + 2 + 2 + 2 + 3 + 2 + 2 + 2 + 3 + 2
                CMP.#   @CHECK10
                BNE     CURADDR + 2 + 2 + 3
                LDA.#   @VALUE10
                JMP     CURADDR + 3 + 2 + 2 + 2 + 3 + 2
                CMP.#   @CHECK01
                BNE     CURADDR + 2 + 2 + 3
                LDA.#   @VALUE01
                JMP     CURADDR + 3 + 2
                LDA.#   @VALUE00
                STA,X   .TILE_VALUE
                INX
#ENDM

#MACRO SET_CELL(OFFSET,TILE_NUMBER,C1,C2,C3)
                LDA.#   @LO(@OFFSET)
                STA     SET_CELL.OFFSET
                LDA.#   @HI(@OFFSET)
                STA     SET_CELL.OFFSET + 1

                LDA.#   @TILE_NUMBER
                STA     SET_CELL.TILE_NUMBER

                LDA.#   @C1
                STA     SET_CELL.COLOR_1
                LDA.#   @C2
                STA     SET_CELL.COLOR_2
                LDA.#   @C3
                STA     SET_CELL.COLOR_3

                JSR     SET_CELL
#ENDM

#MACRO CHECK_NEIGHBOR(NEIGHBOR,MASK)

                    LDX.#   @NEIGHBOR
                    JSR     .GET_NEIGHBOR

                    AND.#   %00000001
                    BEQ     CURADDR + 2 + 3 + 2 + 3

                    LDA     $0000
                    ORA.#   @MASK
                    STA     $0000
                    
#ENDM