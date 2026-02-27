* = $0801

#INCLUDE ..\..\includes\includes.h

#INCLUDE plasma.h

; //--------------------------------------------------------------------------------------------------
; // 8x8 Plasma Crap w/o Speedcode
; // For Codebase64
; // By Cruzer/CML 2009
; // Asm: KickAss 3.1
; //--------------------------------------------------------------------------------------------------

; //--------------------------------------------------------------------------------------------------
; .pc = $0801 "basic"
; :BasicUpstart(code)
; //--------------------------------------------------------------------------------------------------
; .pc = code "code"
; 	jmp start
; //--------------------------------------------------------------------------------------------------
                @BASICSTUB()

; //--------------------------------------------------------------------------------------------------
; start:
START:
; 	sei
; //clear screen...
; 	ldx #$00
; 	txa
; !:	sta $0400,x
; 	sta $0500,x
; 	sta $0600,x
; 	sta $0700,x
; 	inx
; 	bne !-
                    SEI
                    LDX.#   $00
                    TXA
.CSLOOP:            STA,X   $0400
                    STA,X   $0500
                    STA,X   $0600
                    STA,X   $0700
                    INX
                    BNE     .CSLOOP

; // fill bitmap...
; 	ldx #0
; 	ldy #$1f
; 	lda #%01010101
; !:	sta bitmap,x
; 	eor #%11111111
; 	inx
; 	bne !-
; 	inc !- +2
; 	dey
; 	bpl !-
                    LDX.#   $00
                    LDY.#   $1f
                    LDA.#   %01010101
.FBLOOP:            STA,X   bitmap
                    EOR.#   %11111111
                    INX
                    BNE     .FBLOOP
                    INC     .FBLOOP + 2
                    DEY
                    BPL     .FBLOOP

; // generate color table...
; 	ldx #0
; !loop:
; 	txa
; 	asl
; 	asl
; 	asl
; 	bcc !+
; 	eor #$ff
; !:	lsr
; 	lsr
; 	lsr
; 	lsr
; 	tay
; 	lda colors,y
; 	sta colorTable,x
; 	sta colorTable+$100,x
; 	inx
; 	bne !loop-


; // init vic...
; 	lda #$3b
; 	sta $d011
; 	lda #$18
; 	sta $d018
                    LDA.#   $3b
                    STA     $D011
                    LDA.#   $18
                    STA     $D018

; //--------------------------------------------------------------------------------------------------
; mainLoop:
.MAINLOOP:
; 	lda #$00
; 	sta $d020
; 	lda #$44
; !:	cmp $d012
; 	bne !-
; 	sta $d020
                    LDA.#   $00
                    STA     $D020
                    LDA.#   $44
.1:                 CMP     $D012
                    BNE     .1
                    STA     $D020

; 	lda plasmaCnt+0
; 	clc
; 	adc sineSpeeds+0
; 	sta plasmaCnt+0
; 	lda plasmaCnt+1
; 	clc
; 	adc sineSpeeds+1

; 	sta plasmaCnt+1
; 	lda add
; 	clc
; 	adc addSpeed
; 	anc #$3f
; 	sta add

; 	lda #<screen
; 	sta store+1
; 	lda #>screen
; 	sta store+2
	
; 	lda #0
; 	sta sine0+1
; 	sta sine1+1
; 	sta rtSine+1
; 	sta color+1

; 	lda #height-1
; 	sta yPos
; yLoop:
; 	ldx plasmaCnt + 0
; 	ldy plasmaCnt + 1
; 	clc
; sine0:	lda sine128,x
; sine1:	adc sine64,y
; 	sta lineOffset
	
; 	lda sine0+1
; 	clc
; 	adc #realtimeSpread0
; 	sta sine0+1

; 	lda sine1+1
; 	clc
; 	adc #realtimeSpread1
; 	sta sine1+1

; 	ldx #width-1
; xLoop:
; 	lda sineOffsets,x
; 	clc
; 	adc lineOffset
; 	tay
; 	lda colorOffsets,x
; 	clc
; rtSine:	adc sine64,y
; 	adc add
; 	tay
; color:	lda colorTable,y
; store:	sta screen,x
; 	dex
; 	bpl xLoop

; 	lda rtSine+1
; 	clc
; 	adc #sineSpreadY
; 	sta rtSine+1

; 	lda color+1
; 	clc
; 	adc #colorSpreadY
; 	sta color+1

; 	lda store+1
; 	clc
; 	adc #40
; 	sta store+1
; 	bcc !+
; 	inc store+2
; !:	
; 	dec yPos	
; 	bpl yLoop

; 	jmp mainLoop
                    JMP     .MAINLOOP

#INCLUDE plasma-data.asm
