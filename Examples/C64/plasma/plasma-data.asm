
sineSpeeds:	        DATA.b  $03
                    DATA.b  $fe
addSpeed:	        DATA.b  $ff
colors:		        DATA.b  $a7
                    DATA.b  $aa
                    DATA.b  $8a
                    DATA.b  $2a
                    DATA.b  $b8
                    DATA.b  $95
                    DATA.b  $b5
                    DATA.b  $c5
                    DATA.b  $55
                    DATA.b  $5f
                    DATA.b  $cd
                    DATA.b  $5d
                    DATA.b  $37
                    DATA.b  $dd
                    DATA.b  $d1
                    DATA.b  $11

; //--------------------------------------------------------------------------------------------------
; sineOffsets:
; 	.fill 40, i*sineSpreadX
sineOffsets:        PAD     40
; ToDo: Fill with the data properly

; colorOffsets:
; 	.fill 40, i*colorSpreadX
colorOffsets:       PAD     40
; ToDo: Fill with the data properly

; lineOffset:
; 	.by 0
LineOffset:         DATA.b  $00

                    PAD     $1000 - CURADDR
; //--------------------------------------------------------------------------------------------------

;sine64 =		$1000           ; Done: Move to plasma-data.asm
; .pc = sine64 "sine64"
; .for (var i=0; i<$200; i++)
; 	.by 32 + 32 * sin(i/[$100/2/PI])
sine64:             PAD     $0200
; ToDo: Fill with the data properly

;sine128 =		$1200
; .pc = sine128 "sine128"
; .for (var i=0; i<$200; i++)
; 	.by 64 + 64 * sin(i/[$100/2/PI])
sine128:            PAD     $0200
; ToDo: Fill with the data properly

; colorTable =	$1400
colorTable:         PAD     $2000 - $1400    ; ToDo Find actual size

;bitmap =		$2000
bitmap:             PAD     $1000 ; ToDo Find actual size
