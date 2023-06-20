
; // memory...
plasmaCnt =	$02
add =		$04
yPos =		$05
screen =		$0400

; Changing to dynamic regions rather than hardcoded...
; basic =		$0801       ; not needed

; sine64 =		$1000           ; Done: Move to plasma-data.asm
; sine128 =		$1200
; colorTable =	$1400
; bitmap =		$2000

; code =		$4000   ; not needed

; // plasma params...
width = 20
height = 20
sineSpreadX = 	$03
sineSpreadY =	$01
colorSpreadX = 	$01
colorSpreadY = 	$02
realtimeSpread0 =	$04
realtimeSpread1 =	$07
