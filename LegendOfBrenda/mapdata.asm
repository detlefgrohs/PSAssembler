       ; Screen[0,0]
       DATA.b $00 ; MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  .   L   L   L   L   L   
       DATA.b $00 ; MC  MC  MC  MC  MC  .   MT  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  .   MT  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  .   MT  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  .   MT  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  .   MT  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  .   MT  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  .   MT  MC  MC  MC  MC  
       DATA.b $00 ; MC  MC  MC  MC  MC  .   MT  MC  MC  MC  MC  
       ; cellTypes 4
       ; rowTypes 3

; .    : $01 : Ground                         => 9
; L    : $02 : Ladder                         => 5
; MC   : $06 : Moutain Center                 => 154
; MT   : $07 : Mountain Top                   => 8
; MC  MC  MC  MC  MC  MC  MC  MC  MC  MC  MC   : 7
      #DATA.b $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
; MC  MC  MC  MC  MC  .   L   L   L   L   L    : 1
      #DATA.b $06, $06, $06, $06, $06, $01, $02, $02, $02, $02, $02
; MC  MC  MC  MC  MC  .   MT  MC  MC  MC  MC   : 8
      #DATA.b $06, $06, $06, $06, $06, $01, $07, $06, $06, $06, $06
