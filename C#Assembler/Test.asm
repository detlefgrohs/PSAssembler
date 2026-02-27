* = $0801

#INCLUDE macros.asm

#MACRO Test()
                    LDA #$00
                    CLC
#ENDM

#MACRO TEST2(@A,@B,@C)
                    LDA @A
                    STA @B
                    AND @C
#ENDM

#macro HI(@value)
((@value & $FF00) >> 8)
#endM

                    ; Basic Stub
                    ; 10 SYS2061
                    .WORD       $080B   ; $0801 Pointer to Next Line
                    .WORD       $000A   ; $0803 Line Number '10'
                    .BYTE       $9E     ; $0805 BASIC Token for SYS
                    .BYTE       $32     ; $0806 '2'
                    .BYTE       $30     ; $0807 '0'
                    .BYTE       $36     ; $0808 '6'
                    .BYTE       $31     ; $0809 '1'  - 2061 is $080D
                    .BYTE       $00     ; $080A End of current line
                    .WORD       $0000   ; $080B Next Line (NULL no more lines)
                    ; $080D - 2061

START:              LDA         #$00
                    STA         VICII_BORDER_COLOR
                    RTS

                    @TEST2($100,START,%100)

                    LDA         #@HI(START)

                    .WORD       $0, $1, $2, $4
                    .BYTE       %0111, %1111, %1010, %1001

                    @Test()