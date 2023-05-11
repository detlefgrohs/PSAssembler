* = $0801

#INCLUDE ..\includes.h

@BASICSTUB()

SCR_PTR             = $FB
LINE_NUM            = $FD
PAT_OFFSET          = $FE
OV_PAT_OFFS         = $FF

SCREEN_LOC  = $0400

NUM_SCR_LINES = 19
NUM_SCR_COLS = 40

                    
            LDA.#       NUM_CHARS            ; OverallPatternOffset($FF) = NUMBER_OF_ELEMENTS
            STA.zp      OV_PAT_OFFS                   ; 4 Bytes (5 Cycles)
        
START:       LDY.#       0
            LDA.#       $80
S0:         CPY         $D012
            BNE         S0
            AND         $D011
            BNE         S0
            
            LDA.#       $00
            STA         $D020

            LDA.#       NUM_SCR_LINES                   ; LineNum($FE) = 25
            STA.zp      LINE_NUM        
            LDA.zp      OV_PAT_OFFS                   ; PatternOffset($FD) = OverallPatternOffset($FF)
            STA.zp      PAT_OFFSET
            LDA.#       SCREEN_LOC & $00FF    ; <SCREEN_LOC                  ; Pointer($FB) = $0400
            STA.zp      SCR_PTR
            LDA.#       (SCREEN_LOC & $FF00) >> 8    ; >SCREEN_LOC
            STA.zp      SCR_PTR+1             ; 16 Bytes (21 Cycles)
      
LINE_LOOP:  LDX.zp      PAT_OFFSET                   ; X = PatternOffset($FD) & Y = 39  
            LDY.#       NUM_SCR_COLS-1                   ; 4 Bytes (5 Cycles)
            
CHAR_LOOP:  LDA,X       CHARS-1             ; Load Pattern (+1 because [0] when X = 1)
            STA.i,Y     SCR_PTR               ; Store at Pointer + Y
            DEX                       ; X-- OffsetCtr
            BNE         CL1
            LDX.#       NUM_CHARS            ; Reset X
CL1:        DEY                       ; Y-- CharacterCtr
            BPL         CHAR_LOOP             ; 13 Bytes (18 or so Cycles)

            CLC                       ; Add 40 to $FB Pointer($FB)
            LDA.zp      SCR_PTR
            ADC.#       NUM_SCR_COLS
            STA.zp      SCR_PTR
            BCC         CL2
            INC.zp      SCR_PTR+1                   ; 11 Bytes (14 to 17 Cycles)

CL2:        DEC.zp      PAT_OFFSET                  ; PatternOffset($FD)--
            BNE         CL3
            LDA.#       NUM_CHARS            ; Reset PatternOffset($FD)
            STA.zp      PAT_OFFSET                  ; 8 Bytes (9 to 12 Cycles)
        
CL3:        DEC.zp      LINE_NUM                   ; LineNum($FE)--
            BNE         LINE_LOOP             ; 4 Bytes (7 to 9 Cycles)
        
            DEC.zp      OV_PAT_OFFS                   ; OverallPatternOffset($FF)--
            BNE         CL4
            LDA.#       NUM_CHARS            ; Reset OverallPatternOffset($FF)
            STA.zp      OV_PAT_OFFS                   ; 8 Bytes (9 to 12 Cycles)
CL4:           
            LDA.#       $01
            STA         $D020
 
            JMP         START                 ; Do this forever  3 Bytes (3 Cycles)

CHARS:      DATA.b      $6F
            DATA.b      $52
            DATA.b      $46
            DATA.b      $43
            DATA.b      $44
            DATA.b      $45
            DATA.b      $77
            DATA.b      $45
            DATA.b      $44
            DATA.b      $43
            DATA.b      $46
            DATA.b      $52
NUM_CHARS   = 12

; 1M Cycles / 50 => 20k Cycles per Jiffy
; 40 x 18 Cycles => 720 Cycles per Line
; 25 x 720 Cycles => 18k Cycles per Screen
;
; 1M / 18K => 55.5 FPS

;SCR_PTR     = $FB
