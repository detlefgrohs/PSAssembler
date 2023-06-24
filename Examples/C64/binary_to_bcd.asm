
; ===========================================================================
BINARY_TO_BCD_8:
                LDA.#   0		    ; Clear the Result
		        STA     .RESULT
		        STA     .RESULT + 1
		        SED		            ; Set decimal mode
		        LDX.#   8		    ; The number of source bits

.LOOP:		    ASL     .NUMBER		; Shift out one bit
		        LDA     .RESULT     ; And add into result
		        ADC     .RESULT
		        STA     .RESULT
		        LDA     .RESULT + 1
    	        ADC     .RESULT + 1
		        STA     .RESULT + 1
		        DEX		            ; And repeat for next bit
		        BNE     .LOOP

                CLD		            ; Clear decimal mode
                RTS
.NUMBER:		DATA.b  $FF
.RESULT:		PAD     2

; ===========================================================================
BINARY_TO_BCD_16:       
		        LDA.#   0		; Clear the Result
		        STA     .RESULT
		        STA     .RESULT + 1
                STA     .RESULT + 2
                SED		            ; Set decimal mode
		        LDX.#   16		; The number of source bits

.LOOP:		    ASL     .NUMBER		; Shift out one bit
                ROL     .NUMBER + 1
		        LDA     .RESULT        ; And add into result
		        ADC     .RESULT
		        STA     .RESULT
		        LDA     .RESULT + 1
		        ADC     .RESULT + 1
		        STA     .RESULT + 1
                LDA     .RESULT + 2
		        ADC     .RESULT + 2
		        STA     .RESULT + 2
		        DEX		            ; And repeat for next bit
		        BNE     .LOOP

                CLD		            ; Clear decimal mode
                RTS
.NUMBER:		DATA    $FFFF
.RESULT:		PAD     3

; ===========================================================================
BINARY_TO_BCD_24:
                LDA.#   0		; Clear the Result
		        STA     .RESULT
		        STA     .RESULT + 1
                STA     .RESULT + 2
                STA     .RESULT + 3
                SED		            ; Set decimal mode
		        LDX.#   24		; The number of source bits

.LOOP:		    ASL     .NUMBER		; Shift out one bit
                ROL     .NUMBER + 1
                ROL     .NUMBER + 2
		        LDA     .RESULT	; And add into result
		        ADC     .RESULT
		        STA     .RESULT
		        LDA     .RESULT + 1	; propagating any carry
		        ADC     .RESULT + 1
		        STA     .RESULT + 1
                LDA     .RESULT + 2	; propagating any carry
		        ADC     .RESULT + 2
		        STA     .RESULT + 2
                LDA     .RESULT + 3	; propagating any carry
		        ADC     .RESULT + 3
		        STA     .RESULT + 3
		        DEX		; And repeat for next bit
		        BNE     .LOOP

                CLD		            ; Clear decimal mode
                RTS
.NUMBER:		DATA    $FFFF
                DATA.b  $FF
.RESULT:	    PAD     4

; ===========================================================================
BINARY_TO_BCD_32:
                LDA.#   0		; Ensure the result is clear
		        STA     .RESULT
		        STA     .RESULT + 1
                STA     .RESULT + 2
                STA     .RESULT + 3
                STA     .RESULT + 4
                SED		            ; Set decimal mode
		        LDX.#   32		; The number of source bits

.LOOP:		    ASL     .NUMBER		; Shift out one bit
                ROL     .NUMBER + 1
                ROL     .NUMBER + 2
                ROL     .NUMBER + 3
		        LDA     .RESULT	; And add into result
		        ADC     .RESULT
		        STA     .RESULT
		        LDA     .RESULT + 1	; propagating any carry
		        ADC     .RESULT + 1
		        STA     .RESULT + 1
                LDA     .RESULT + 2	; propagating any carry
		        ADC     .RESULT + 2
		        STA     .RESULT + 2
                LDA     .RESULT + 3	; propagating any carry
		        ADC     .RESULT + 3
		        STA     .RESULT + 3
                LDA     .RESULT + 4	; propagating any carry
		        ADC     .RESULT + 4
		        STA     .RESULT + 4
		        DEX		; And repeat for next bit
		        BNE     .LOOP
		
                CLD		            ; Clear decimal mode
                RTS
.NUMBER:		DATA    $FFFF
                DATA    $FFFF
.RESULT:		PAD     5