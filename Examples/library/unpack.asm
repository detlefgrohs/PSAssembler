#REGION UNPACK_MEMORY
; ===========================================================================
; Load compressed bytes...
; ===========================================================================
UNPACK_MEMORY.MODE_BYTE    = $00
UNPACK_MEMORY.MODE_NIBBLE  = $FF

UNPACK_MEMORY:  LDA         .MODE
                CMP.#       UNPACK_MEMORY.MODE_NIBBLE
                BEQ         .COLOR

                @SET_WORD(.OUTPUT + 1,.OUTPUT_BYTE)
                JMP         .CONT_SETUP
.COLOR:         @SET_WORD(.OUTPUT + 1,.OUTPUT_NIBBLE)

.CONT_SETUP:    LDA         .SOURCE
                STA         .LD + 1
                LDA         .SOURCE + 1
                STA         .LD + 2
                LDA         .TARGET
                STA         .ST + 1
                LDA         .TARGET + 1
                STA         .ST + 2
                
.LOOP:          JSR         .GET_BYTE
                TAX
                BMI         .COMPRESSED

.RAW:
.RLOOP:         JSR         .GET_BYTE
                JSR         .OUTPUT
                DEX
                BNE         .RLOOP
                JMP         .CONTINUE

.COMPRESSED:    AND.#       $7F
                TAX
                JSR         .GET_BYTE
.CLOOP:         JSR         .OUTPUT
                DEX
                BNE         .CLOOP
                ; Check to See if We are done...
.CONTINUE:      LDA         .LD + 2
                CMP         .SOURCE_END + 1
                BNE         .LOOP
                LDA         .LD + 1
                CMP         .SOURCE_END
                BNE         .LOOP
                
                RTS

.GET_BYTE:
.LD:            LDA         $0000
                @INC_WORD_BY_ONE(.LD+1)
                RTS

.OUTPUT:        JMP         .OUTPUT_BYTE

.OUTPUT_BYTE:
.ST:            STA         $0000
                @INC_WORD_BY_ONE(.ST+1)
                RTS

.OUTPUT_NIBBLE: PHA
                ROR.A
                ROR.A
                ROR.A
                ROR.A
                JSR         .OUTPUT_BYTE
                PLA
                JSR         .OUTPUT_BYTE
                RTS

.SOURCE:        DATA        $0000
.SOURCE_END:    DATA        $0000
.TARGET:        DATA        $0000
.MODE:          DATA.b      $00
#ENDR