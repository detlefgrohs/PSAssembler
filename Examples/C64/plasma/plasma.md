

Original code from 
    https://codebase64.org/doku.php?id=base:8x8-plasma-looped

```asm
//--------------------------------------------------------------------------------------------------
// 8x8 Plasma Crap w/o Speedcode
// For Codebase64
// By Cruzer/CML 2009
// Asm: KickAss 3.1
//--------------------------------------------------------------------------------------------------
// memory...
.var plasmaCnt =	$02
.var add =		$04
.var yPos =		$05
.var screen =		$0400
.var basic =		$0801
.var sine64 =		$1000
.var sine128 =		$1200
.var colorTable =	$1400
.var bitmap =		$2000
.var code =		$4000
//--------------------------------------------------------------------------------------------------
.pc = sine64 "sine64"
.for (var i=0; i<$200; i++)
	.by 32 + 32 * sin(i/[$100/2/PI])
.pc = sine128 "sine128"
.for (var i=0; i<$200; i++)
	.by 64 + 64 * sin(i/[$100/2/PI])
//--------------------------------------------------------------------------------------------------
.pc = $0801 "basic"
:BasicUpstart(code)
//--------------------------------------------------------------------------------------------------
.pc = code "code"
	jmp start
//--------------------------------------------------------------------------------------------------
// plasma params...
.var width = 20
.var height = 20
.var sineSpreadX = 	$03
.var sineSpreadY =	$01
.var colorSpreadX = 	$01
.var colorSpreadY = 	$02
.var realtimeSpread0 =	$04
.var realtimeSpread1 =	$07
sineSpeeds:	.byte $03,$fe
addSpeed:	.byte $ff
colors:		.byte $a7,$aa,$8a,$2a,$b8,$95,$b5,$c5,$55,$5f,$cd,$5d,$37,$dd,$d1,$11
//--------------------------------------------------------------------------------------------------
start:
	sei
//clear screen...
	ldx #$00
	txa
!:	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $0700,x
	inx
	bne !-
	
// fill bitmap...
	ldx #0
	ldy #$1f
	lda #%01010101
!:	sta bitmap,x
	eor #%11111111
	inx
	bne !-
	inc !- +2
	dey
	bpl !-

// generate color table...

	ldx #0
!loop:
	txa
	asl
	asl
	asl
	bcc !+
	eor #$ff
!:	lsr
	lsr
	lsr
	lsr
	tay
	lda colors,y
	sta colorTable,x
	sta colorTable+$100,x
	inx
	bne !loop-

// init vic...
	lda #$3b
	sta $d011
	lda #$18
	sta $d018

//--------------------------------------------------------------------------------------------------
mainLoop:
	lda #$00
	sta $d020
	lda #$44
!:	cmp $d012
	bne !-
	sta $d020
	
	lda plasmaCnt+0
	clc
	adc sineSpeeds+0
	sta plasmaCnt+0
	lda plasmaCnt+1
	clc
	adc sineSpeeds+1

	sta plasmaCnt+1
	lda add
	clc
	adc addSpeed
	anc #$3f
	sta add

	lda #<screen
	sta store+1
	lda #>screen
	sta store+2
	
	lda #0
	sta sine0+1
	sta sine1+1
	sta rtSine+1
	sta color+1

	lda #height-1
	sta yPos
yLoop:
	ldx plasmaCnt + 0
	ldy plasmaCnt + 1
	clc
sine0:	lda sine128,x
sine1:	adc sine64,y
	sta lineOffset
	
	lda sine0+1
	clc
	adc #realtimeSpread0
	sta sine0+1

	lda sine1+1
	clc
	adc #realtimeSpread1
	sta sine1+1

	ldx #width-1
xLoop:
	lda sineOffsets,x
	clc
	adc lineOffset
	tay
	lda colorOffsets,x
	clc
rtSine:	adc sine64,y
	adc add
	tay
color:	lda colorTable,y
store:	sta screen,x
	dex
	bpl xLoop

	lda rtSine+1
	clc
	adc #sineSpreadY
	sta rtSine+1

	lda color+1
	clc
	adc #colorSpreadY
	sta color+1

	lda store+1
	clc
	adc #40
	sta store+1
	bcc !+
	inc store+2
!:	
	dec yPos	
	bpl yLoop

	jmp mainLoop

sineOffsets:
	.fill 40, i*sineSpreadX
colorOffsets:
	.fill 40, i*colorSpreadX
lineOffset:
	.by 0
```