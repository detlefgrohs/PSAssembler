#MACRO BASICSTUB()
            ; Basic Stub
            ; 10 SYS2061
            DATA        $080B   ; $0801 Pointer to Next Line
            DATA        $000A   ; $0803 Line Number '10'
            DATA.B      $9E     ; $0805 BASIC Token for SYS
            DATA.B      $32     ; $0806 '2'
            DATA.B      $30     ; $0807 '0'
            DATA.B      $36     ; $0808 '6'
            DATA.B      $31     ; $0809 '1'  - 2061 is $080D
            DATA.B      $00     ; $080A End of current line
            DATA        $0000   ; $080B Next Line (NULL no more lines)
                                ; $080D - 2061
#ENDM

#MACRO BASICSTUB128()
; From https://devdef.blogspot.com/2018/03/commodore-128-assembly-part-1-all-code.html
;.macro BasicUpstart128(address) {
;    .pc = $1c01 "C128 Basic"
;    .word upstartEnd  // link address
;    .word 10   // line num
;    .byte $9e  // sys
;    .text toIntString(address)
;    .byte 0
;upstartEnd:
;    .word 0  // empty link signals the end of the program
;    .pc = $1c0e "Basic End"
;}
            ; 128 Basic Stub
            ; 10 SYS????
            ; $1C01
            DATA        $1C0B       ; $1C01 Pointer to Next Line
            DATA        $000A       ; $1C03 Line Number '10'
            DATA.B      $9E         ; $1C05 BASIC Token for SYS
            DATA.B      $37         ; $1C06 '7'
            DATA.B      $31         ; $1C07 '1'
            DATA.B      $38         ; $1C08 '8'
            DATA.B      $31         ; $1C09 '1'
            DATA.B      $00         ; $1C0A End of current line
            DATA        $0000       ; $1C0B
                                    ; $1C0D - 7181
#ENDM