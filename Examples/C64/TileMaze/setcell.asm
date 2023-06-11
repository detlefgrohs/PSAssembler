
; ===========================================================================
SET_CELL:       ; screenLocation := $4400 + offset;
                @SET_WORD(.SL_ST + 1, $4400)
                CLC
                LDA     .SL_ST + 1
                ADC     .OFFSET
                STA     .SL_ST + 1
                LDA     .SL_ST + 2
                ADC     .OFFSET + 1
                STA     .SL_ST + 2
                ; colorLocation := $D800 + offset;
                @SET_WORD(.CL_ST + 1, $D800)
                CLC
                LDA     .CL_ST + 1
                ADC     .OFFSET
                STA     .CL_ST + 1
                LDA     .CL_ST + 2
                ADC     .OFFSET + 1
                STA     .CL_ST + 2

                ; bitmapLocation := $6000 + (offset * 8);
                LDA     .OFFSET
                STA     .BMP_ST + 1
                LDA     .OFFSET + 1
                STA     .BMP_ST + 2
                @ROL_WORD(.BMP_ST + 1)
                @ROL_WORD(.BMP_ST + 1)
                @ROL_WORD(.BMP_ST + 1)
                CLC
                LDA     .BMP_ST + 1
                ADC.#   @LO($6000)
                STA     .BMP_ST + 1
                LDA     .BMP_ST + 2
                ADC.#   @HI($6000)
                STA     .BMP_ST + 2

                ; tileLocation := tilesetLocation + (tileNumber << 3);
                LDA     .TILE_NUMBER
                STA     .TL_LD + 1
                LDA.#   0
                STA     .TL_LD + 2
                @ROL_WORD(.TL_LD + 1)
                @ROL_WORD(.TL_LD + 1)
                @ROL_WORD(.TL_LD + 1)
                CLC
                LDA     .TL_LD + 1
                ADC.#   @LO(CHARDATA)
                STA     .TL_LD + 1
                LDA     .TL_LD + 2
                ADC.#   @HI(CHARDATA)
                STA     .TL_LD + 2

                LDX.#   7
.LOOP:          ; FOR bitmapIndex := 0 TO 8 DO
                ; 	bitmapLocation[bitmapIndex] := tileLocation[bitmapIndex];
.TL_LD:         LDA,X   $0000
.BMP_ST:        STA,X   $0000
                DEX
                BPL     .LOOP

                ; colorLocation[0] := c1;
                LDA     .COLOR_1
.CL_ST:         STA     $0000
                ; screenLocation[0] := (c2 << 4) | c3;
                LDA     .COLOR_2
                ASL.A
                ASL.A
                ASL.A
                ASL.A
                ORA     .COLOR_3
.SL_ST:         STA     $0000

                RTS

.OFFSET:        DATA    $0000
.TILE_NUMBER:   DATA    $0000
.COLOR_1:       DATA.b  $00
.COLOR_2:       DATA.b  $00
.COLOR_3:       DATA.b  $00

; ===========================================================================
SET_CELL_NO_COLOR:       ; bitmapLocation := $6000 + (offset * 8);
                LDA     .OFFSET
                STA     .BMP_ST + 1
                LDA     .OFFSET + 1
                STA     .BMP_ST + 2
                @ROL_WORD(.BMP_ST + 1)
                @ROL_WORD(.BMP_ST + 1)
                @ROL_WORD(.BMP_ST + 1)
                CLC
                LDA     .BMP_ST + 1
                ADC.#   @LO($6000)
                STA     .BMP_ST + 1
                LDA     .BMP_ST + 2
                ADC.#   @HI($6000)
                STA     .BMP_ST + 2

                ; tileLocation := tilesetLocation + (tileNumber << 3);
                LDA     .TILE_NUMBER
                STA     .TL_LD + 1
                LDA.#   0
                STA     .TL_LD + 2
                @ROL_WORD(.TL_LD + 1)
                @ROL_WORD(.TL_LD + 1)
                @ROL_WORD(.TL_LD + 1)
                CLC
                LDA     .TL_LD + 1
                ADC.#   @LO(CHARDATA)
                STA     .TL_LD + 1
                LDA     .TL_LD + 2
                ADC.#   @HI(CHARDATA)
                STA     .TL_LD + 2

                LDX     .LOOP_COUNT

.LOOP:          ; FOR bitmapIndex := 0 TO 8 DO
                ; 	bitmapLocation[bitmapIndex] := tileLocation[bitmapIndex];
.TL_LD:         LDA,X   $0000
.BMP_ST:        STA,X   $0000
                DEX
                BPL     .LOOP

                RTS

.OFFSET:        DATA    $0000
.TILE_NUMBER:   DATA    $0000
.LOOP_COUNT:    DATA.b  7
