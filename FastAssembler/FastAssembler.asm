* = $0801

#INCLUDE ..\Examples\includes\includes.h

CHRGET      =   $0073
BUF         =   $0200     ; BASIC Line Editor Input Buffer
HIGHDS = $58 ; Destination of highest element in BLT.  

HIGHTR = $5A ; 	Source of highest element to move. 

LOWTR = $5F  ; 	Last thing to move in BLT.

BLTU = $A3BB
IMAIN = $0302

R6510 = $01     ; 6510 On-Chip I/O Port

ENDCHR = $08
DORES = $0F

                ;@BASICSTUB()

            DATA        $080C   ; $0801 Pointer to Next Line
            DATA        $000A   ; $0803 Line Number '10'
            DATA.B      $9E     ; $0805 BASIC Token for SYS
            DATA.B      $20     ; $0806 ' '
            DATA.B      $34     ; $0807 '2'
            DATA.B      $34     ; $0808 '0'
            DATA.B      $30     ; $0809 '6'
            DATA.B      $38     ; $080A '1'  - 2061 is $080D
            DATA.B      $00     ; $080B End of current line
            DATA        $0000   ; $080C Next Line (NULL no more lines)

                ;JMP STARTUP


ICRNCH_PATCH:   LDA.#       $36
                STA.zp      R6510           ; $01 
                LDX.zp      $7A 

BRANCHB:
                DEX 
                BMI         BRANCHA

                LDA,X       BUF             ;$0200           ; Basic Parsing Buffer
                CMP.#       $20             ; Space
                BEQ         BRANCHB

                INX 
                LDA,x       BUF             ; $0200
                CMP.#       $20
                BNE         BRANCHC
BRANCHA:
                INX 

BRANCHC:
                LDY.#       $04
                STY.zp      DORES           ; $0F



L_BRS_082B084F:
L_BRS_082B0867:
L_BRS_082B086F:
L_JMP_082B091A:
                LDA,x       BUF             ; $0200
                BPL         L_BRS_083A082E
                CMP.#       $FF
                BEQ         L_BRS_083A0832
                SBC.#       $9F
                BNE         L_BRS_084E0836
                LDA.#       $20

L_BRS_083A082E:
L_BRS_083A0832:
                CMP.#       $20
                BEQ         L_BRS_084A083C
                STA.zp      $08 
                CMP.#       $22
                BEQ         L_BRS_088E0842
                CMP.#       $3F
                BNE         L_BRS_08970846
                LDA.#       $99

L_BRS_084A083C:
L_BRS_084A0881:
                INY 
                STA,y       $01FB

L_BRS_084E0836:
                INX 
                BNE         L_BRS_082B084F

L_BRS_085108BD:
                LDY.zp      $71 
                BIT.zp      $0B 
                BPL         L_BRS_085D0855
                INY 
                LDA.#       $90
                STA,y       $01FB

L_BRS_085D0855:
                LDA.zp      $0B 
                ORA.#       $80
                INY 
                STA,y       $01FB
                BIT.zp      $0B 
                BMI         L_BRS_082B0867
                CMP.#       $83
                BEQ         L_BRS_0872086B + 1 ; This goes into the middle of the BIT below L_BRS_0872086B
                EOR.#       $8F
                BNE         L_BRS_082B086F

L_BRS_0872086B:
                BIT         $3AA9 
                STA.zp      $08 

L_BRS_08760893:
                LDA,x       $0200
                BEQ         L_BRS_08950879
                BIT.zp      $0F 
                BVS         L_BRS_0883087D
                CMP.zp      $08 
                BEQ         L_BRS_084A0881

L_BRS_0883087D:
                CMP.#      $22
                BNE        L_BRS_088E0885
                ASL.A 
                EOR.zp     $0F 
                STA.zp     $0F 
                LDA.#      $22

L_BRS_088E0842:
L_BRS_088E0885:
                INY 
                STA,y       $01FB
                INX 
                BNE         L_BRS_08760893

L_BRS_08950879:
                BEQ         L_BRS_08F50895

L_BRS_08970846:
                STY.zp     $71 
                STX.zp     $7A 
                LDY.#      $9E
                STY.zp     $22 
                LDY.#      $A0
                STY.zp     $23 
                LDY.#      $00
                STY.zp     $0B 

L_BRS_08A708B0:
                EOR.i,y    $22
                BNE        L_BRS_08B208A9
                INX 
                INY 

L_BRS_08AD08E9:
L_BRS_08AD0904:
                LDA,x      $0200
                BNE        L_BRS_08A708B0

L_BRS_08B208A9:
                CMP.#      $80
                BNE        L_BRS_08DC08B4
                INX 
                LDA,x      $0200 
                JSR        L_JSR_091D08BA

L_BRS_08BD08CA:
L_BRS_08BD08DA:
                BCS        L_BRS_085108BD
                LDA.zp     $0B 
                BMI        L_BRS_08DC08C1
                STY.zp     $08 
                LDY.#      $0B

L_BRS_08C708CD:
                CMP,y      $092E 
                BEQ        L_BRS_08BD08CA
                DEY 
                BPL        L_BRS_08C708CD
                LDY.zp     $08 
                CMP.#      $34
                BCC        L_BRS_08DC08D3
                LDA,x      $0200 
                CMP.#      $28
                BEQ        L_BRS_08BD08DA

L_BRS_08DC08B4:
L_BRS_08DC08C1:
L_BRS_08DC08D3:
                DEY 

L_BRS_08DD08E0:
                INY 
                LDA.i,y    $22 
                BPL        L_BRS_08DD08E0
                INC.zp     $0B 
                LDX.zp     $7A 
                INY 
                LDA.i,y    $22
                BNE        L_BRS_08AD08E9
                INY 
                BEQ        L_BRS_08F808EC
                LDY.zp     $71 
                LDA,x      $0200 
                BNE        L_BRS_090608F3

L_BRS_08F50895:
L_BRS_08F50913:
                JMP         $A5C9  

L_BRS_08F808EC:
                LDA.#      $3A
                STA.zp     $22 
                LDA.#      $09
                STA.zp     $23 
                LDA.#      $80
                STA.zp     $0B 
                BNE        L_BRS_08AD0904

L_BRS_090608F3:
L_BRS_09060918:
                INX 
                INY 

L_JSR_09090E73:
                STA,y      $01FB
                JSR        L_JSR_091D090B
                BCS        L_BRS_091A090E
                LDA,x      $0200
                BEQ        L_BRS_08F50913
                JSR        L_JSR_091D0915
                BCC        L_BRS_09060918

L_BRS_091A090E:
                JMP L_JMP_082B091A

L_JSR_091D08BA:
L_JSR_091D090B:
L_JSR_091D0915:
                CMP.#      $30
                BCC        L_BRS_092C091F + 1 ; BAD
                CMP.#      $3A
                BCC        L_BRS_092D0923
                CMP.#      $41
                BCC         L_BRS_092C0927 + 1 ; BAD
                CMP.#       $5B

L_BRS_092C091F:
L_BRS_092C0927:
                BIT.zp      $38 

L_BRS_092D0923:
                RTS

; Data Block
                DATA.b $04
                DATA.b $18
                DATA.b $23
                DATA.b $26
                DATA.b $31
                DATA.b $32
                DATA.b $33
                DATA.b $2E
                DATA.b $2D
                DATA.b $2C
                DATA.b $2B
                DATA.b $2A
                DATA.b $42
                DATA.b $59
                DATA.b $54
                DATA.b $C5
                DATA.b $57
                DATA.b $4F
                DATA.b $52
                DATA.b $C4
                DATA.b $4F
                DATA.b $52
                DATA.b $C7
                DATA.b $41
                DATA.b $55
                DATA.b $54
                DATA.b $CF
                DATA.b $4F
                DATA.b $4C
                DATA.b $C4
                DATA.b $49
                DATA.b $4E
                DATA.b $43
                DATA.b $4C
                DATA.b $55
                DATA.b $44
                DATA.b $C5
                DATA.b $53
                DATA.b $45
                DATA.b $4E
                DATA.b $C4
                DATA.b $55
                DATA.b $4E
                DATA.b $53
                DATA.b $45
                DATA.b $4E
                DATA.b $C4
                DATA.b $42
                DATA.b $43
                DATA.b $C3
                DATA.b $42
                DATA.b $43
                DATA.b $D3
                DATA.b $42
                DATA.b $45
                DATA.b $D1
                DATA.b $42
                DATA.b $4D
                DATA.b $C9
                DATA.b $42
                DATA.b $4E
                DATA.b $C5
                DATA.b $42
                DATA.b $50
                DATA.b $CC
                DATA.b $42
                DATA.b $56
                DATA.b $C3
                DATA.b $42
                DATA.b $56
                DATA.b $D3
                DATA.b $41
                DATA.b $44
                DATA.b $C3
                DATA.b $41
                DATA.b $4E
                DATA.b $C4
                DATA.b $43
                DATA.b $4D
                DATA.b $D0
                DATA.b $45
                DATA.b $4F
                DATA.b $D2
                DATA.b $4C
                DATA.b $44
                DATA.b $C1
                DATA.b $4F
                DATA.b $52
                DATA.b $C1
                DATA.b $53
                DATA.b $42
                DATA.b $C3
                DATA.b $53
                DATA.b $54
                DATA.b $C1
                DATA.b $41
                DATA.b $53
                DATA.b $CC
                DATA.b $44
                DATA.b $45
                DATA.b $C3
                DATA.b $49
                DATA.b $4E
                DATA.b $C3
                DATA.b $4C
                DATA.b $53
                DATA.b $D2
                DATA.b $52
                DATA.b $4F
                DATA.b $CC
                DATA.b $52
                DATA.b $4F
                DATA.b $D2
                DATA.b $53
                DATA.b $54
                DATA.b $D8
                DATA.b $43
                DATA.b $50
                DATA.b $D8
                DATA.b $43
                DATA.b $50
                DATA.b $D9
                DATA.b $4C
                DATA.b $44
                DATA.b $D8
                DATA.b $4C
                DATA.b $44
                DATA.b $D9
                DATA.b $53
                DATA.b $54
                DATA.b $D9
                DATA.b $4A
                DATA.b $53
                DATA.b $D2
                DATA.b $4A
                DATA.b $4D
                DATA.b $D0
                DATA.b $42
                DATA.b $49
                DATA.b $D4
                DATA.b $42
                DATA.b $52
                DATA.b $CB
                DATA.b $43
                DATA.b $4C
                DATA.b $C3
                DATA.b $43
                DATA.b $4C
                DATA.b $C4
                DATA.b $43
                DATA.b $4C
                DATA.b $C9
                DATA.b $43
                DATA.b $4C
                DATA.b $D6
                DATA.b $44
                DATA.b $45
                DATA.b $D8
                DATA.b $44
                DATA.b $45
                DATA.b $D9
                DATA.b $49
                DATA.b $4E
                DATA.b $D8
                DATA.b $49
                DATA.b $4E
                DATA.b $D9
                DATA.b $4E
                DATA.b $4F
                DATA.b $D0
                DATA.b $50
                DATA.b $48
                DATA.b $C1
                DATA.b $50
                DATA.b $48
                DATA.b $D0
                DATA.b $50
                DATA.b $4C
                DATA.b $C1
                DATA.b $50
                DATA.b $4C
                DATA.b $D0
                DATA.b $52
                DATA.b $54
                DATA.b $C9
                DATA.b $52
                DATA.b $54
                DATA.b $D3
                DATA.b $53
                DATA.b $45
                DATA.b $C3
                DATA.b $53
                DATA.b $45
                DATA.b $C4
                DATA.b $53
                DATA.b $45
                DATA.b $C9
                DATA.b $54
                DATA.b $41
                DATA.b $D8
                DATA.b $54
                DATA.b $41
                DATA.b $D9
                DATA.b $54
                DATA.b $53
                DATA.b $D8
                DATA.b $54
                DATA.b $58
                DATA.b $C1
                DATA.b $54
                DATA.b $58
                DATA.b $D3
                DATA.b $54
                DATA.b $59
                DATA.b $C1
                DATA.b $00


IQPLOP_PATCH:         ; $0a06
                PHA 

L_BRS_0A070A0C:
                LDA        $028D 
                CMP.#      $01
                BEQ        L_BRS_0A070A0C
                PLA 
                BPL        L_BRS_0A270A0F
                CMP.#      $FF
                BEQ        L_BRS_0A270A13
                BIT.zp     $0F 
                BMI        L_BRS_0A270A17
                BVC        L_BRS_0A2A0A19
                CMP.zp     $08 
                BNE        L_BRS_0A270A1D
                PHA 
                LDA.zp     $0F 
                EOR.#      $40
                STA.zp     $0F 
                PLA 

L_BRS_0A270A0F:
L_BRS_0A270A13:
L_BRS_0A270A17:
L_BRS_0A270A1D:
                JMP         $A6F3

L_BRS_0A2A0A19:
                CMP.#      $90
                BEQ        L_BRS_0A460A2C
                PHA 
                CMP.#      $83
                BEQ        L_BRS_0A380A31 + 1     ; Bad
                EOR.#      $8F
                BNE        L_BRS_0A420A35

L_BRS_0A380A31:
                BIT         $3AA9 
                STA.zp      $08 
                LDA.zp      $0F 
                EOR.#       $40
                STA.zp      $0F

L_BRS_0A420A35:
                PLA 

L_BRS_0A430A4E:
                JMP         $A724

L_BRS_0A460A2C:
                INY 
                LDA.i,y     $5F
                BMI         L_BRS_0A500A49
                DEY 
                LDA.#       $90
                BNE         L_BRS_0A430A4E

L_BRS_0A500A49:
                STY.zp      $49
                TAX 
                LDY.#       $FF

L_BRS_0A550A5E:
                DEX 
                BPL         L_BRS_0A600A56

L_BRS_0A580A5C:
                INY 
                LDA,Y       $093A
                BPL         L_BRS_0A580A5C
                BMI         L_BRS_0A550A5E

L_BRS_0A600A56:
L_BRS_0A600A6C:
                INY 
                LDA,y       $093A
                BPL         L_BRS_0A690A64
                JMP         $A6EF

L_BRS_0A690A64:
                JSR         $AB47
                BNE         L_BRS_0A600A6C

IEVAL_PATCH:          ; $0a66

                JSR         CHRGET          ; $0073
                LDX.#       $00
                STX.zp      $0D 
                CMP.#       $AC
                BEQ         L_BRS_0A8F0A77
                STX.zp      $62 
                STX.zp      $63 
                CMP.#       $24
                BEQ         L_BRS_0AC00A7F
                CMP.#       $25
                BEQ         L_BRS_0AAD0A83
                CMP.#       $27
                BEQ         L_BRS_0AA00A87
                JSR         $0079
                JMP         $AE8D

L_BRS_0A8F0A77:
                JSR         CHRGET          ; $0073

L_JSR_0A920F3D:
                LDA.zp      $FB 
                LDY.zp      $FC 
                STY.zp      $62 

L_BRS_0A980AA8:
                STA.zp      $63 

L_BRS_0A9A0AB0:
L_BRS_0A9A0AB4:
L_BRS_0A9A0AC7:
L_BRS_0A9A0ACB:
                LDX.#       $90
                SEC 
                JMP         $BC49

L_BRS_0AA00A87:
                JSR         L_JSR_0BAC0AA0
                PHA 
                JSR         CHRGET          ; $0073
                PLA 
                BNE         L_BRS_0A980AA8
                JMP         $AF08                         ; Output ?SYNTAX Error

L_BRS_0AAD0A83:
L_BRS_0AAD0ABB:
                JSR         CHRGET          ; $0073
                BCS         L_BRS_0A9A0AB0
                CMP.#       $32
                BCS         L_BRS_0A9A0AB4
                LSR.A 
                ROL.zp      $63 
                ROL.zp      $62 
                BCC         L_BRS_0AAD0ABB

L_BRS_0ABD0AD7:
                JMP         $B248                         ; ?ILLEGAL QUANTITY

L_BRS_0AC00A7F:
L_BRS_0AC00AE0:
                JSR         CHRGET          ; $0073
                BCC         L_BRS_0ACF0AC3
                CMP.#       $47
                BCS         L_BRS_0A9A0AC7
                CMP.#       $41
                BCC         L_BRS_0A9A0ACB
                SBC.#       $07

L_BRS_0ACF0AC3:
                AND.#       $0F
                LDX.#       $04

L_BRS_0AD30ADA:
                ASL.zp      $63 
                ROL.zp      $62 
                BCS         L_BRS_0ABD0AD7
                DEX 
                BNE         L_BRS_0AD30ADA
                ORA.zp      $63
                STA.zp      $63 
                BCC         L_BRS_0AC00AE0
                STA         $02A8 
                STA.zp      $45 
                JSR         L_JSR_0BB20AE7
                JSR         $B113                         ; Does A hold an alphabetic character?
                BCS         L_BRS_0AF20AED

L_BRS_0AEF0B2D:
                JMP         $AF08                         ; Output ?SYNTAX Error

L_BRS_0AF20AED:
                LDX.#       $00
                STX.zp      $0D 
                STX.zp      $0E 

L_BRS_0AF80B04:
L_BRS_0AF80B0A:
                JSR         L_JSR_0BAC0AF8
                BCC         L_BRS_0B020AFB
                JSR         $B113                         ; Does A hold an alphabetic character?
                BCC         L_BRS_0B0C0B00

L_BRS_0B020AFB:
                CPX.#       $07
                BCS         L_BRS_0AF80B04
                INX 

L_BRS_0B070B13:
                STA,x       $02A8 
                BNE         L_BRS_0AF80B0A

L_BRS_0B0C0B00:
                INX 
                CPX.#       $08
                BCS         L_BRS_0B150B0F
                LDA.#       $00
                BEQ         L_BRS_0B070B13

L_BRS_0B150B0F:
                LDA         $02A9 
                STA.zp $46 
                JSR L_JSR_0BB20B1A
                CMP.#  $24
                BNE L_BRS_0B270B1F
                LDA.#  $FF
                STA.zp $0D 
                BNE L_BRS_0B3A0B25

L_BRS_0B270B1F:
                CMP.#  $25
                BNE L_BRS_0B460B29
                LDA.zp $10 
                BNE L_BRS_0AEF0B2D
                LDA.#  $80
                STA.zp $0E 
                ORA.zp $45
                STA.zp $45 
                STA $02A8 

L_BRS_0B3A0B25:
                LDA.zp $46 
                ORA.#  $80
                STA.zp $46 
                STA $02A9 
                JSR L_JSR_0BAC0B43

L_BRS_0B460B29:
                ORA.zp $10
                EOR.#   $28
                BNE L_BRS_0B4F0B4A
                JMP $B1D1                         ; Get Array Parameters

L_BRS_0B4F0B4A:
                STY.zp $10 
                LDA.zp $2D 
                LDX.zp $2E 

L_BRS_0B550B79:
                STX.zp $60 

L_BRS_0B570B76:
                STA.zp $5F 
                CPX.zp $30 
                BCC L_BRS_0B610B5B
                CMP.zp $2F 
                BCS L_BRS_0B7B0B5F

L_BRS_0B610B5B:
                LDY.#  $00

L_BRS_0B630B6D:
                LDA,y $02A8
                EOR.i,y $5F 
                BNE L_BRS_0B720B68
                INY 
                CPY.#  $08
                BCC L_BRS_0B630B6D
                JMP $B185

L_BRS_0B720B68:
                LDA.zp $5F 
                ADC.#  $0D
                BCC L_BRS_0B570B76
                INX 
                BNE L_BRS_0B550B79

L_BRS_0B7B0B5F:
                PLA 
                PHA 
                CMP.#  $2A
                BNE L_BRS_0B840B7F
                JMP $B123

L_BRS_0B840B7F:
                LDA $02AA 
                BNE L_BRS_0B8C0B87
                JMP $B128                         ; Create Variable

L_BRS_0B8C0B87:
                LDA.zp $2F 
                LDY.zp $30 
                JSR $B147
                LDY.#  $07

L_BRS_0B950B9B:
                LDA,y $02A8 
                STA.i,y $5F 
                DEY 
                BPL L_BRS_0B950B9B
                LDY.#  $07
                JMP $B174
                BPL L_BRS_0BA90BA2
                LDY.#  $08
                JMP $B5C7

L_BRS_0BA90BA2:
                JMP $B5F6

L_JSR_0BAC0AA0:
L_JSR_0BAC0AF8:
L_JSR_0BAC0B43:
                INC.zp $7A 
                BNE L_BRS_0BB20BAE
                INC.zp $7B 

L_JSR_0BB20AE7:
L_JSR_0BB20B1A:
L_BRS_0BB20BAE:
                LDY.#  $00
                LDA.i,y $7A 
                CMP.#  $3A
                BCS L_BRS_0BBD0BB8
                JMP $0084

L_BRS_0BBD0BB8:
                RTS

; $0bb3
L_JSR_0BBE0D03:
L_JMP_0BBE0D2F:
L_JSR_0BBE0D44:
L_JSR_0BBE0D84:
L_JSR_0BBE0D92:
L_JMP_0BBE0D9A:
L_JSR_0BBE100C:
L_JMP_0BBE10B6:
L_JSR_0BBE110A:
                LDX.zp      $9D 
                BMI         L_BRS_0BEB0BC0
                CPX.#       $21
                BEQ         L_BRS_0BD10BC4
                CPX.#        $20
                BEQ         L_BRS_0BE40BC8
                LDA.#       $0E
                LDY.#       $0E
                JMP         L_JMP_11270BCE

L_BRS_0BD10BC4:
                LDX.zp      $FD 
                BEQ         L_BRS_0BE20BD3
                LDX.#       $08
                JSR         $E118                         ; Set Up For Output
                JSR         $E10C                         ; Output Character
                JSR         $FFCC                         ; Restore I/O Vector
                BEQ         L_BRS_0BE40BE0

L_BRS_0BE20BD3:
                STA.i,x     $FB

L_BRS_0BE40BC8:
L_BRS_0BE40BE0:
                INC.zp      $FB
                BNE L_BRS_0BEA0BE6
                INC.zp      $FC

L_BRS_0BEA0BE6:
                RTS

L_BRS_0BEB0BC0:
                JMP         $B3AB

; $0bee
L_JSR_0BEE0C3D:
L_JSR_0BEE0FE0:
                LDA.zp      $66 
                BMI         L_BRS_0C040BF0
                LDA.zp      $61 
                CMP.#       $91
                BCS         L_BRS_0C040BF6
                JSR         $BC9B                         ; Convert FAC#1 to Integer
                LDY.zp      $64 
                LDA.zp      $65 

L_BRS_0BFF0C0F:
                STA.zp      $14 
                STY.zp      $15 
                RTS 

L_BRS_0C040BF0:
L_BRS_0C040BF6:
                LDA.zp      $9D 
                LSR.A 
                BCC         L_BRS_0C0C0C07
                JMP         $B248                         ; ?ILLEGAL QUANTITY

L_BRS_0C0C0C07:
                LDA.#       $00
                TAY 
                BEQ         L_BRS_0BFF0C0F

L_JSR_0C110D50:
                JSR         CHRGET              ; $0073
                BEQ         L_BRS_0C1A0C14
                CMP.#       $3B
                BNE         L_BRS_0C210C18

L_BRS_0C1A0C14:
                LDA.#        $00
                STA.zp      $15
                STA.zp      $FE
                RTS


L_BRS_0C210C18:
                CMP.#       $23
                BNE         L_BRS_0C290C23
                LDX.#       $01
                BNE         L_BRS_0C310C27

L_BRS_0C290C23:
                LDX.#       $00
                CMP.#       $28
                BNE L_BRS_0C340C2D
                LDX.#       $80

L_BRS_0C310C27:
                JSR         CHRGET              ; $0073

L_BRS_0C340C2D:
                STX.zp      $FE 
                JSR         $AD9E                         ; Evaluate Expression in Text
                BIT.zp      $0D 
                BMI         L_BRS_0C470C3B
                JSR         L_JSR_0BEE0C3D
                LDA.zp      $FE 
                BMI         L_BRS_0C600C42
                BEQ         L_BRS_0C970C44
                RTS 

L_BRS_0C470C3B:
                LDA.zp $FE 
                CMP.# $01
                BEQ L_BRS_0C500C4B

L_BRS_0C4D0C90:
                JMP         $AF08                         ; Output ?SYNTAX Error

L_BRS_0C500C4B:
                JSR $B6A6
                LDY.# $00
                STY.zp $15 
                CMP.# $00
                BEQ L_BRS_0C5D0C59
                LDA.i,y $22 

L_BRS_0C5D0C59:
                STA.zp $14 
                RTS 

L_BRS_0C600C42:
                LDX.# $00
                STX.zp $0B 

L_BRS_0C640C8C:
L_BRS_0C640C9D:
                LDY.# $00

L_BRS_0C660C6F:
                LDA,x $0C9F 
                EOR.i,y $7A 
                BNE L_BRS_0C710C6B
                INX 
                INY 
                BNE L_BRS_0C660C6F

L_BRS_0C710C6B:
                ASL.A 
                BNE L_BRS_0C810C72
                LDX.zp $0B 
                LDA,x $0CAC 
                STA.zp $FE 
                JSR $A8FB
                JMP         CHRGET              ; $0073

L_BRS_0C810C72:
L_BRS_0C810C85:
                INX 
                LDA,x $0C9E 
                BPL L_BRS_0C810C85
                INC.zp $0B 
                LDA,x $0C9F 
                BNE L_BRS_0C640C8C
                LDA.zp $FE 
                BMI L_BRS_0C4D0C90
                LDA.# $02
                STA.zp $FE 
                RTS 

L_BRS_0C970C44:
                LDA.# $03
                STA.zp $0B 
                LDX.# $08
                BNE L_BRS_0C640C9D
                BIT $A958 
                AND.# $2C
                CMP,Y $00A9 
                BIT $2CD8 
                CMP,y $0500 
                ASL.zp $0F 
                DATA.b $03
                DATA.b $04  

IGONE_PATCH:          ; $0cb1

                JSR         CHRGET              ; $0073
                JSR L_JSR_0CC40CB4
                JSR $0079
                CMP.# $3B
                BNE L_BRS_0CC10CBC
                JSR $A93B                         ; Perform [rem]

L_BRS_0CC10CBC:
                JMP $A7AE                         ; BASIC Warm Start

L_JSR_0CC40CB4:
L_JSR_0CC4108E:
                BEQ L_BRS_0CCB0CC4
                CMP.# $3B
                BNE L_BRS_0CCF0CC8
                RTS 

L_BRS_0CCB0CC4:
L_BRS_0CCB0CD1:
                SEC 
                JMP $A7ED                         ; Perform BASIC Keyword

L_BRS_0CCF0CC8:
                CMP.# $AF
                BNE L_BRS_0CCB0CD1
                LDX.# $09
                TXA 
                BNE L_BRS_0D4A0CD6
                BNE L_BRS_0CDD0CD8
                JMP $A82F                         ; Perform [end]

L_BRS_0CDD0CD8:
                SBC.# $80
                BCS L_BRS_0CE40CDF

L_BRS_0CE10CE6:
L_BRS_0CE10D09:
L_BRS_0CE10D0D:
L_BRS_0CE10D3F:
                JMP $AF08                         ; Output ?SYNTAX Error

L_BRS_0CE40CDF:
                CMP.# $40
                BCS L_BRS_0CE10CE6
                CMP.# $08
                BCS L_BRS_0CF90CEA
                ASL.A 
                TAY 
                LDA,y $0DC7
                PHA 
                LDA,y $0DC6
                PHA 
                JMP         CHRGET              ; $0073

L_BRS_0CF90CEA:
                SBC.# $08
                TAX 
                CMP.# $08
                BCS L_BRS_0D390CFE
                LDA,x $0DD6
                JSR L_JSR_0BBE0D03
                JSR         CHRGET              ; $0073
                BEQ L_BRS_0CE10D09
                CMP.# $3B
                BEQ L_BRS_0CE10D0D
                JSR $AD8A                         ; Confirm Result
                LDA.zp $9D 
                LSR.A 
                BCC L_BRS_0D2F0D15
                JSR $B7F7                         ; Convert FAC#1 to Integer in LINNUM
                CLC 
                LDA.zp $14 
                SBC.zp $FB 
                TAX 
                PHP 
                LDA.zp $15 
                SBC.zp $FC 
                PLP 
                BPL L_BRS_0D2A0D26
                EOR.# $FF

L_BRS_0D2A0D26:
                CMP.# $00
                BNE L_BRS_0D320D2C
                TXA 

L_BRS_0D2F0D15:
                JMP L_JMP_0BBE0D2F

L_BRS_0D320D2C:
                LDA.# $26
                LDY.# $0E
                JMP L_JMP_11270D36

L_BRS_0D390CFE:
                CMP.# $1F
                BCC L_BRS_0D4A0D3B
                CMP.# $38
                BCS L_BRS_0CE10D3F
                LDA,x $0DD6 
                JSR L_JSR_0BBE0D44
                JMP         CHRGET              ; $0073

L_BRS_0D4A0CD6:
L_BRS_0D4A0D3B:
                PHA 
                LDA,x $0DD6 
                STA.zp $02 
                JSR L_JSR_0C110D50
                LDA.zp $15 
                JSR L_JSR_0D9D0D55
                BEQ L_BRS_0D660D58
                JSR L_JSR_0D9D0D5A
                BEQ L_BRS_0D660D5D
                LDA.# $46
                LDY.# $0E
                JMP L_JMP_11270D63

L_BRS_0D660D58:
L_BRS_0D660D5D:
L_BRS_0D670DD5:
                LDA.zp $02 
                AND.# $0F
                TAY 
                LDA,y $0E39 
                BPL L_BRS_0D760D6E
                LDA.zp $FE 
                ORA.# $10
                STA.zp $FE 

L_BRS_0D760D6E:
                PLA 
                SEC 
                SBC.# $08
                LDX.zp $FE 
                TAY 
                CLC 
                LDA,y $0E5D
                ADC,x $0E74 

L_BRS_0D850DD3:
                JSR L_JSR_0BBE0D84
                LDA.zp $FE 
                AND.# $0F

L_BRS_0D8B0DD1:
                BEQ L_BRS_0DC50D8B

L_JSR_0D8D0FF4:
                AND.# $08
                PHP 
                LDA.zp $14 
                JSR L_JSR_0BBE0D92
                PLP 
                BEQ L_BRS_0DC50D96
                LDA.zp $15 
                JMP L_JMP_0BBE0D9A

L_JSR_0D9D0D55:
L_JSR_0D9D0D5A:
                BEQ L_BRS_0DA50D9D
                LDA.zp $FE 
                ORA.# $08
                STA.zp $FE 

L_BRS_0DA50D9D:
                LDA.zp $FE 
                LSR.A 
                LSR.A 
                LSR.A 
                LSR.A 

L_BRS_0DAB0DD9:
                LDA.zp $02 
                BCS L_BRS_0DB30DAD
                AND.# $0F
                BCC L_BRS_0DB70DB1

L_BRS_0DB30DAD:
                LSR.A 
                LSR.A 
                LSR.A 
                LSR.A 

L_BRS_0DB70DB1:
                TAY 
                LDA.zp $FE 
                AND.# $07
                TAX 
                LDA,y $0E39
                EOR.# $FF
                AND,x $0E94

L_BRS_0DC50D8B:
L_BRS_0DC50D96:
                RTS 

                DATA.b $D4
                DATA.b $0F

L_BRS_0DC90DD7:
                CMP.i,y $0F
                DATA.b $A7
                ASL $0F42 
                ORA.i,y $10
                ROL.A 
                BPL L_BRS_0D8B0DD1
                BPL L_BRS_0D850DD3 + 1
                BPL L_BRS_0D670DD5 + 1
                BCS L_BRS_0DC90DD7 + 1
                BMI L_BRS_0DAB0DD9
                BPL L_BRS_0E2D0DDB + 1
                BVS L_BRS_0DE40DDD + 1
                ORA.zp $05
                ORA.zp $05

L_BRS_0DE40DDD:
                ORA.zp $05
                ASL.zp $17 
                ORA.i,Y $11
                DATA.b $17
                DATA.b $17
                DATA.b $17
                DATA.b $23
                PLP 
                PLP 
                AND,y $2B1A
                BIT $244C 
                DATA.b $00
                CLC 
                CLD 
                CLI 
                DATA.b $B8
                DEX 
                DEY 
                INX 
                INY 
                NOP 
                PHA 
                PHP 
                PLA 
                PLP 
                RTI 
                ;------------------------------
                RTS 
                ;------------------------------
                SEC 
                DATA.B $F8
                SEI 
                TAX 
                TAY 
                TSX 
                TXA 
                TXS 
                TYA 
                EOR.zp,x $4E 
                DATA.b $44
                EOR.zp $46 
                DATA.b $27
                DATA.b $44
                JSR $4F4C
                DATA.b $43
                EOR.i,x $54
                EOR.# $4F
                LSR $4320
                DATA.b $4F
                EOR.zp,x $4E
                DATA.b $54
                EOR.zp $D2
                DATA.b $42
                DATA.b $52
                EOR.i,x $4E
                DATA.b $43
                PHA 

L_BRS_0E2D0DDB:
                JSR $554F
                DATA.b $54
                JSR $464F
                JSR $4152
                LSR $C547 
                DATA.b $1C
                DATA.b $0C
                DATA.b $04
                DATA.b $14
                STY.zp $6E 
                JMP.i $860D 
                STX.zp,y $8E 
                STY $4980 
                JMP $454C
                DATA.b $47
                EOR.i,x $4C 
                JSR $4441
                DATA.b $44
                DATA.b $52
                EOR.zp $53 
                DATA.b $53
                EOR.# $4E
                DATA.b $47
                JSR $4F4D
                DATA.b $44
                CMP.zp $60 
                JSR $40C0
                LDY.# $00
                CPX.# $80
                ORA.i,x $C1
                SBC.i,x $41
                AND.i,x $61
                STA.i,x $E0
                CPY.# $A2
                LDY.# $80
                DATA.b $14
                RTI 

                JSR L_JSR_09090E73 + 1
                ORA.zp $15
                ORA.zp,x $01
                ORA.i,y $80
                ORA.# $80
                ORA $191D
                DATA.b $80
                DATA.b $80
                DATA.b $80
                DATA.b $80
                DATA.b $00
                DATA.b $04
                DATA.b $14
                DATA.b $14
                DATA.b $80
                DATA.b $80
                DATA.b $80
                DATA.b $80
                DATA.b $80
                DATA.b $0C
                DATA.b $1C
                DATA.b $1C
                DATA.b $80
                DATA.b $80
                BIT $0201 
                DATA.b $04
                PHP 
                BPL L_BRS_0EBA0E98
                RTI 

                DATA.b $80

L_JSR_0E9C0EBA:
L_JSR_0E9C0EC7:
L_JSR_0E9C0ED9:
L_JSR_0E9C0FF7:
                JSR $0079
                BEQ L_BRS_0EA50E9F
                CMP.# $3B
                BNE L_BRS_0EA70EA3

L_BRS_0EA50E9F:
                PLA 
                PLA 

L_BRS_0EA70EA3:
L_BRS_0EA70EEF:
L_BRS_0EA70EFB:
                RTS 

                LDA.# $00
                STA.zp $FB 
                STA.zp $FD 
                STA.zp $B7 
                LDA.# $C0
                STA.zp $FC 
                LDA.zp $9D 
                ORA.# $20
                STA.zp $9D 

L_BRS_0EBA0E98:
                JSR L_JSR_0E9C0EBA
                JSR $AD8A                         ; Confirm Result
                JSR $B7F7                         ; Convert FAC#1 to Integer in LINNUM
                STY.zp $FB 
                STA.zp $FC 
                JSR L_JSR_0E9C0EC7
                JSR $E200                         ; Get Next One Byte Parameter
                CPX.# $02
                BCC L_BRS_0ED40ECF
                JMP $B248                         ; ?ILLEGAL QUANTITY

L_BRS_0ED40ECF:
                TXA 
                ORA.zp $9D
                STA.zp $9D 
                JSR L_JSR_0E9C0ED9
                JSR $E200                         ; Get Next One Byte Parameter
                STX.zp $FD 
                JSR $E20E                         ; Check For Comma
                JSR $AD9E                         ; Evaluate Expression in Text
                JSR $B6A3                         ; Perform String Housekeeping
                JSR $FFBD                         ; Set Filename
                LDX.zp $FD 
                BEQ L_BRS_0EA70EEF
                LDA.# $08
                LDY.# $01
                JSR $FFBA                         ; Set Logical File Parameters
                LDA.zp $9D 
                LSR.A 
                BCC L_BRS_0EA70EFB
                LDA.zp $B7 
                BNE L_BRS_0F070EFF
                LDA.zp $FD 
                CMP.# $08
                BCS L_BRS_0F1C0F05

L_BRS_0F070EFF:
                JSR $E1C1
                LDX.# $08
                JSR $E118                         ; Set Up For Output
                LDA.zp $FB 
                JSR $E10C                         ; Output Character
                LDA.zp $FC 
                JSR $E10C                         ; Output Character
                JMP $FFCC                         ; Restore I/O Vector

L_BRS_0F1C0F05:
                JSR $F710                         ; Output I/O Error Messages: MISSING FILENAME
                JMP $A43B
                JSR $B08B                         ; Identify Variable
                STA.zp $49 
                STY.zp $4A 
                JSR $0079
                BEQ L_BRS_0F350F2C
                CMP.# $3B
                BEQ L_BRS_0F350F30
                JMP $A9AC

L_BRS_0F350F2C:
L_BRS_0F350F30:
                LDX.zp $3A 
                INX 
                BNE L_BRS_0F3D0F38
                JMP $AF08                         ; Output ?SYNTAX Error

L_BRS_0F3D0F38:
                JSR L_JSR_0A920F3D
                JMP $BBD0
                BEQ L_BRS_0F550F43 + 1
                JSR $A96B                         ; Fetch linnum From BASIC
                LDA.zp $14 
                STA $02B1 
                LDA.zp $15 
                STA $02B2 
                LDA.# $80

                L_BRS_0F550F43:
                BIT $00A9 
                STA $02B0 
                RTS 

L_BRS_0F5B0F80:
                LDA $02B0 
                AND.# $BF

L_BRS_0F610F99:
L_BRS_0F610FAC:
                BIT $00A9 
                STA $02B0                   

IMAIN_PATCH:    ; $0f66
                LDX.zp     $14 
                STX        $01FE 
                LDX.zp     $15 
                STX        $01FF 
                BIT        $02B0 
                BVS        L_BRS_0F990F73

L_BRS_0F750FD0:
                JSR        $A560                         ; Input Line Into Buffer
                STX.zp     $7A 
                STY.zp     $7B 
                JSR        CHRGET               ; $0073
                TAX 
                BEQ        L_BRS_0F5B0F80
                LDX.#      $FF
                STX.zp     $3A 
                BCC        L_BRS_0F8B0F86
                JMP        $A496

L_BRS_0F8B0F86:
                LDA        $02B0 
                ORA.#      $40
                STA        $02B0 
                JSR        $0079
                JMP        $A49C                         ; Get Line Number & Tokenise Text

L_BRS_0F990F73:
                BPL         L_BRS_0F610F99 + 1
                CLC 
                LDA         $01FE 
                ADC         $02B1 
                STA.zp      $63 
                LDA         $01FF 
                ADC         $02B2 
                STA.zp      $62 
                BCS         L_BRS_0F610FAC + 1
                LDX.#       $90
                SEC 
                JSR         $BC49
                JSR         $BDDF
                SEI 
                LDX.#       $00

L_BRS_0FBA0FC5:
                LDA,x       $0100
                CMP.#       $30
                BCC         L_BRS_0FC70FBF
                STA,x       $0277
                INX 
                BNE         L_BRS_0FBA0FC5

L_BRS_0FC70FBF:
                LDA.#      $20
                STA,x      $0277
                INX 
                STX.zp     $C6
                CLI 
                BNE        L_BRS_0F750FD0
                LDA.#      $08
                BIT        $00A9
                STA.zp     $02

L_BRS_0FD90FFD:
                JSR         $AD9E                         ; Evaluate Expression in Text
                BIT.zp      $0D 
                BMI         L_BRS_0FFF0FDE
                JSR         L_JSR_0BEE0FE0
                LDA.zp      $02 
                BNE         L_BRS_0FF40FE5
                LDX.zp      $15 
                BEQ         L_BRS_0FF40FE9
                LDX.zp      $9D 
                CPX.#       $20
                BEQ         L_BRS_0FF40FEF
                JMP         $B248                         ; ?ILLEGAL QUANTITY

L_BRS_0FF40FE5:
L_BRS_0FF40FE9:
L_BRS_0FF40FEF:
                JSR         L_JSR_0D8D0FF4

L_BRS_0FF71008:
                JSR         L_JSR_0E9C0FF7
                JSR         $E20E                         ; Check For Comma
                BNE         L_BRS_0FD90FFD

L_BRS_0FFF0FDE:
                JSR         $B6A6
                STA.zp      $64
                LDY.#       $00

L_BRS_10061010:
                CPY.zp      $64
                BEQ         L_BRS_0FF71008
                LDA.i,y     $22 
                JSR         L_JSR_0BBE100C
                INY 
                BNE         L_BRS_10061010
                LDY.#       $01
                LDA.#       $08
                STA.i,y     $2B
                JSR         $A533                         ; Rechain Lines
                LDA.zp      $22
                LDY.zp      $23
                ADC.zp      $2D
                STA.zp      $2D
                BCC         L_BRS_10261023
                INY

L_BRS_10261023:
                STY.zp      $2E
                JMP         $A65C
                JSR         $AD9E                         ; Evaluate Expression in Text
                JSR         $B6A3                         ; Perform String Housekeeping
                JSR         $FFBD                         ; Set Filename
                JSR         $E200                         ; Get Next One Byte Parameter
                LDA.#       $09
                LDY.#       $00
                JSR         $FFBA                         ; Set Logical File Parameters
                JSR         $E1C1
                LDX.#       $09
                JSR         $E11E                         ; Set Up For Input
                JSR         $E112                         ; Input Character
                LDA.zp      $90 
                AND.#       $02
                BEQ         L_BRS_1054104D
                LDA.#       $04
                JMP         $A43B

L_BRS_1054104D:
                JSR         $E112                         ; Input Character
                JSR         $FFCC                         ; Restore I/O Vector
                LDA.zp      $7A
                PHA 
                LDA.zp      $7B
                PHA 

L_BRS_10601095:
L_BRS_1060109D:
                LDX.#  $09
                JSR         $E11E                         ; Set Up For Input
                JSR         $E112                         ; Input Character
                JSR         $E112                         ; Input Character
                TAX 
                BEQ         L_BRS_10A2106C
                JSR         $E112                         ; Input Character
                JSR         $E112                         ; Input Character
                LDX.#       $FF

L_BRS_1076107E:
                INX 
                JSR         $E112                         ; Input Character
                STA,x       $0200 
                TAY 
                BNE         L_BRS_1076107E
                JSR         $FFCC                         ; Restore I/O Vector
                LDA.#       $FF
                STA.zp      $7A 
                LDA.#       $01
                STA.zp      $7B 

L_BRS_108B1099:
                JSR         CHRGET              ; $0073
                JSR         L_JSR_0CC4108E
                JSR         $0079
                TAX 
                BEQ         L_BRS_10601095
                CMP.#       $3A
                BEQ         L_BRS_108B1099
                CMP.#       $3B
                BEQ         L_BRS_1060109D
                JMP         $AF08                         ; Output ?SYNTAX Error

L_BRS_10A2106C:
                JSR         $FFCC                         ; Restore I/O Vector
                LDA.#       $09
                JSR         $FFC3                         ; Close Vector

L_BRS_10AA1112:
                PLA 
                STA.zp      $7B
                PLA 
                STA.zp      $7A
                RTS 

;$10B1  20 B4 10  JSR L_JSR_10B410B1
                JSR         L_JSR_10B410B1

L_JSR_10B410B1:
                LDA.#       $00
                JMP         L_JMP_0BBE10B6
                JSR         $AD9E                         ; Evaluate Expression in Text
                JSR         $B6A3                         ; Perform String Housekeeping
                TAY 
                LDA.#       $00
                CPY.#       $58
                BCC         L_BRS_10C910C4
                JMP         $A571

L_BRS_10C910C4:
L_BRS_10C910D1:
                STA,y       $0200
                DEY 
                BMI         L_BRS_10D310CD
                LDA.i,y     $22 
                BCC         L_BRS_10C910D1

L_BRS_10D310CD:
                LDA.zp      $7A 
                PHA 
                LDA.zp      $7B 
                PHA 
                LDA.#       $FF
                STA.zp      $7A 
                LDA.#       $01
                STA.zp      $7B 
                JSR         CHRGET              ; $0073
                BCC         L_BRS_10ED10E4
                LDA.#       $14
                LDY.#       $11
                JMP         L_JMP_112710EA

L_BRS_10ED10E4:
                JSR         $A96B                         ; Fetch linnum From BASIC
                JSR         $A57C
                LDA.zp      $14 
                STA         $01FE 
                LDA.zp      $15 
                STA         $01FF 
                STY         $01FC 
                STY         $01FD 
                STY.zp      $0B 
                LDY.#       $00

L_BRS_11071110:
                LDA,y       $01FC
                JSR         L_JSR_0BBE110A
                INY 
                CPY.zp      $0B
                BCC         L_BRS_11071110
                BCS         L_BRS_10AA1112
                EOR         $5349 
                DATA.b      $53
                EOR.#       $4E
                DATA.b      $47
                JSR         $494C
                LSR         $2045 
                LSR         $4D55 
                DATA.b      $42
                EOR.zp      $D2 
;------------------------------
L_JMP_11270BCE:
L_JMP_11270D36:
L_JMP_11270D63:
L_JMP_112710EA:
                STA.zp      $22 
                STY.zp      $23 
                JMP         $A447 

; ===========================================================================

                ; $112e
; VECTORTABLE:    DATA        $0f66           ; IMAIN
;                 DATA        $080E           ; ICRNCH
;                 DATA        $0a06           ; IQPLOP
;                 DATA        $0cb1           ; IGONE
;                 DATA        $0a6e           ; IEVAL

VECTORTABLE:    DATA        IMAIN_PATCH
                DATA        ICRNCH_PATCH
                DATA        IQPLOP_PATCH
                DATA        IGONE_PATCH
                DATA        IEVAL_PATCH


; THIS IS THE BLOCK TRANSFER ROUTINE.
; IT MAKES SPACE BY SHOVING EVERYTHING FORWARD.
;
; ON ENTRY:
; [Y,A]=[HIGHDS]    (FOR REASON).
; [HIGHDS]= DESTINATION OF [HIGH ADDRESS].
; [LOWTR]= LOWEST ADDR TO BE TRANSFERRED.
; [HIGHTR]= HIGHEST ADDR TO BE TRANSFERRED.

                ; $1138
STARTUP:        LDA.#       $37             ; Set Memory Banks
                STA.zp      R6510           ; $01

                LDA.#       $00
                STA.zp      HIGHDS          ; $58
                STA.zp      HIGHTR          ; $5A
                STA.zp      LOWTR           ; $5F
                LDA.#       $C0
                STA.zp      HIGHDS + 1      ; $59
                STA.zp      HIGHTR + 1      ; $5B
                LDA.#       $A0
                STA.zp      LOWTR + 1       ; $60
                JSR         BLTU            ; $A3BB           
                                            ; Copy $A000 to $C000 => $A000
                                            ; Copy Basic ROM to RAM Location

                LDX.#       $09             ; Copy Basic Vector Table
VECTORLOOP:     LDA,X       VECTORTABLE     ; $112E           ; VECTORTABLE
                STA,X       IMAIN           ; $0302
                DEX
                BPL         VECTORLOOP

                LDA.#       $4C
                STA         $B5C4 
                STA         $B092 
                STA         $B143 
                STA         $A9A5           ; Perform LET

                LDA.#       $0D
                STA         $B54E 
                STA         $B155 

                LDA.#       $08
                STA         $B60F 
                STA         $B189 

                LDA.#       $EA
                STA         $B610 

                LDA.#       $60
                STA         $B169 

                LDA.#       $8C
                LDY.#       $0B
                STA         $B144 
                STY         $B145 

                LDA.#       $E2
                LDY.#       $0A
                STA         $B093 
                STY         $B094 

                LDA.#       $A2
                LDY.#       $0B
                STA         $B5C5 
                STY         $B5C6 

                LDA.#       $D7
                LDY.#       $0C
                STA         $A02C 
                STY         $A02D 

                LDA.#       $22
                LDY.#       $0F
                STA         $A9A6 
                STY         $A9A7 

                LDA.#       $C4
                LDY.#       $0C
                STA         $A949 
                STY         $A94A  

                LDA.#       $FB
                LDY.#       $F0
                STA         VICII_BORDER_COLOR
                STY         VICII_BG_COL_0

                LDA.#       $1B
                LDY.#       $12                     ; Replace with End of App
                STA         $0281
                STY         $0282
                JSR         $E3BF                   ; Init BASIC Ram

                LDA.#       $E4                     ; Replace with TITLEMESSAGE
                LDY.#       $11
                JSR         $AB1E                   ; Output String
                JSR         $E430
                JMP         $E39D

TITLEMESSAGE:   DATA.B      $93
                DATA.B      $08
                DATA.B      $0E
                DATA.B      $9B
                DATA.B      $11
                DATA.B      $20
                DATA.B      $20
                DATA.B      $2A
                DATA.B      $20
                DATA.B      $C1
                DATA.B      $D3
                DATA.B      $D3
                DATA.B      $C5
                DATA.B      $CD
                DATA.B      $C2
                DATA.B      $CC
                DATA.B      $C5
                DATA.B      $D2
                DATA.B      $20
                DATA.B      $56
                DATA.B      $33
                DATA.B      $20
                DATA.B      $2A
                DATA.B      $20
                DATA.B      $20
                DATA.B      $20
                DATA.B      $42
                DATA.B      $59
                DATA.B      $20
                DATA.B      $D9
                DATA.B      $56
                DATA.B      $45
                DATA.B      $53
                DATA.B      $20
                DATA.B      $C8
                DATA.B      $41
                DATA.B      $4E
                DATA.B      $20
                DATA.B      $20
                DATA.B      $31
                DATA.B      $39
                DATA.B      $38
                DATA.B      $35
                DATA.B      $0D
                DATA.B      $0D
                DATA.B      $20
                DATA.B      $20
                DATA.B      $20
                DATA.B      $20
                DATA.B      $20
                DATA.B      $20
                DATA.B      $20
                DATA.B      $20
                DATA.B      $20
                DATA.B      $00
                DATA.B      $00
                DATA.B      $00
                DATA.B      $00
                DATA.B      $00
                DATA.B      $00
                DATA.B      $00
