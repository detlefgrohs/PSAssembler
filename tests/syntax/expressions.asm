BYTE = $AB
WORD = $CDEF

LDA.#       %11001100               ; LDA #$CC
LDA.#       $FF                     ; LDA #$FF
LDA.#       BYTE                    ; LDA #$AB
LDA.#       WORD & $00FF            ; LDA #$EF

LDA.#       ($10 + 2 + BYTE)        ; LDA #$BD

LDA         WORD                    ; LDA $CDEF
LDA         WORD+1
LDA         WORD + 1
LDA         WORD+%10
LDA         WORD + %10

LDA.#       $FF & %11110000         ; LDA #$F0
LDA.#       %11000000 | %00001100   ; LDA #$CC

LDA.#       $80 >> 4                ; LDA #$08
LDA.#       $01 << 3                ; LDA #$08

LDA.#       256 / 64                ; LDA #$04

LDA.#       'A'                     ; LDA #$41
LDA.#       'A' | %10000000         ; LDA #$C1

LDA.#       if ( BYTE -gt $80 ) { $10 } else { $20 }
LDA.#       if ( BYTE -lt $80 ) { $10 } else { $20 }

LDA.#       if ( -not BYTE -lt $80 ) { $10 } else { $20 }

LDA.#       if ( BYTE -gt $80 -and WORD -eq WORD ) { $10 } else { $20 }
LDA.#       if ( BYTE -lt $80 -or WORD -ne WORD ) { $10 } else { $20 }


LDA.#       BYTE -eq $AB
LDA.#       BYTE -gt $80
LDA.#       BYTE -lt $80


#STOP
            TEXT "ABCDEFG"


; Want conditional macros or blocks
; Way complicated because when do the variables and labels get defined and also the sections could
; control what the variables and labels could be...
#IF

#ELSEIF

#ELSE

#ENDIF