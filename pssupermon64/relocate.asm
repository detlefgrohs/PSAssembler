; DG 20230510 From relocate.asm

; ----------------------------------------------------------------------------
; variables

SOURCE  = $22               ; first temp variable
TOPMEM  = $24               ; highest address available to BASIC
LASTBYT = $26               ; previous byte encountered
VARTAB  = $2D               ; pointer to start of BASIC variable storage area
FRETOP  = $33               ; pointer to bottom of string text storage area
TARGET  = $37               ; end of basic memory/start of machine code (aka MEMSIZ)

; ----------------------------------------------------------------------------
; basic header

        * = $0801

        ; 100 PRINT "{DOWN}SUPERMON+64    JIM BUTTERFIELD"
        ; 110 SYS(PEEK(43)+256*PEEK(44)+71)

        ;.BYTE $29,$08,$64,$00,$99,$20,$22,$11
        DATA.b $29
        DATA.b $08
        DATA.b $64
        DATA.b $00
        DATA.b $99
        DATA.b $20
        DATA.b $22
        DATA.b $11

        ; .TEXT "SUPERMON+64    JIM BUTTERFIELD"
        DATA.b 'S'
        DATA.b 'U'
        DATA.b 'P'
        DATA.b 'E'
        DATA.b 'R'
        DATA.b 'M'
        DATA.b 'O'
        DATA.b 'N'
        DATA.b '+'
        DATA.b '6'
        DATA.b '4'
        DATA.b ' '
        DATA.b ' '
        DATA.b ' '
        DATA.b ' '
        DATA.b 'J'
        DATA.b 'I'
        DATA.b 'M'
        DATA.b ' '
        DATA.b 'B'
        DATA.b 'U'
        DATA.b 'T'
        DATA.b 'T'
        DATA.b 'E'
        DATA.b 'R'
        DATA.b 'F'
        DATA.b 'I'
        DATA.b 'E'
        DATA.b 'L'
        DATA.b 'D'
 
        ; .BYTE $22,$00,$43,$08,$6E,$00,$9E,$28
        DATA.b $22
        DATA.b $00
        DATA.b $43
        DATA.b $08
        DATA.b $6E
        DATA.b $00
        DATA.b $9E
        DATA.b $28

        ; .BYTE $C2,$28,$34,$33,$29,$AA,$32,$35
        DATA.b $C2
        DATA.b $28
        DATA.b $34
        DATA.b $33
        DATA.b $29
        DATA.b $AA
        DATA.b $32
        DATA.b $35

        ; .BYTE $36,$AC,$C2,$28,$34,$34,$29,$AA
        DATA.b $36
        DATA.b $AC
        DATA.b $C2
        DATA.b $28
        DATA.b $34
        DATA.b $34
        DATA.b $29
        DATA.b $AA

        ; .BYTE $37,$31,$29,$00,$00,$00,$00,$00
        DATA.b $37
        DATA.b $31
        DATA.b $29
        DATA.b $00
        DATA.b $00
        DATA.b $00
        DATA.b $00
        DATA.b $00

        ; .BYTE $00
        DATA.b $00

; ----------------------------------------------------------------------------
; relocator stub

        LDA.zp VARTAB          ; start copying from the start of basic variables
        STA.zp SOURCE
        LDA.zp VARTAB+1
        STA.zp SOURCE+1
        LDA.zp TARGET          ; start copying to the end of BASIC memory
        STA.zp TOPMEM
        LDA.zp TARGET+1
        STA.zp TOPMEM+1
LOOP:   LDY.# $00            ; no offset from pointers
        LDA.zp SOURCE          ; decrement two-byte source address
        BNE NB1
        DEC.zp SOURCE+1
NB1:    DEC.zp SOURCE
        LDA.i,Y SOURCE      ; get byte currently pointed to by SOURCE
        CMP.# $36            ; check for address marker ($36)
        BNE NOADJ           ; skip address adjustment unless found
        LDA.zp SOURCE          ; decrement two-byte source address
        BNE NB2
        DEC.zp SOURCE+1
NB2:    DEC.zp SOURCE
        LDA.i,Y SOURCE      ; get byte currently pointed to by SOURCE
        CMP.# $36            ; check for second consecutive marker ($36)
        BEQ DONE            ; if found, we're done with relocation
        STA.zp LASTBYT         ; if not, save byte for later
        LDA.zp SOURCE          ; decrement two-byte source address
        BNE NB3
        DEC.zp SOURCE+1
NB3:    DEC.zp SOURCE
        LDA.i,Y SOURCE      ; current byte is low byte of relative address
        CLC 
        ADC.zp TOPMEM          ; calc absolute low byte by adding top of memory
        TAX                 ; save absolute low byte in X
        LDA.zp LASTBYT         ; previous byte is high byte of relative address
        ADC.zp TOPMEM+1        ; calc absolute high byte by adding top of memory
        PHA                 ; save absolute high byte on stack
        LDA.zp TARGET          ; decrement two-byte target address
        BNE NB4
        DEC.zp TARGET+1
NB4:    DEC.zp TARGET
        PLA                 ; retrieve absolute high byte from stack
        STA.i,Y TARGET      ; save it to the target address
        TXA                 ; retrieve absolute low byte from stack
NOADJ:  PHA                 ; save current byte on stack
        LDA.zp TARGET          ; decrement two-byte target address
        BNE NB5
        DEC.zp TARGET+1
NB5:    DEC.zp TARGET
        PLA                 ; retrieve current byte from stack
        STA.i,Y TARGET      ; save it in the target address
        CLC                 ; clear carry for unconditional loop
        BCC LOOP            ; rinse, repeat
DONE:   LDA.zp TARGET          ; fix pointer to string storage
        STA.zp FRETOP
        LDA.zp TARGET+1
        STA.zp FRETOP+1
        JMP.i TARGET        ; jump to the beginning of the relocated code

; DG 20230510 0539 - Completed Relocate.asm - Used BeyondCompare to confirm
;                    generated prg (178 bytes of 3,171)
