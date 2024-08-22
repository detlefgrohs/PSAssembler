


* = $0801

#INCLUDE ..\..\Examples\includes\includes.h
; #INCLUDE macros.h

                @BASICSTUB()

START:
            LDA.#       $01
            STA         VICII_SCREEN_RAM

            ; Y = 3
            ; X = 5
            ; So (Y*16) + X => 53
            

            RTS

LOADSCREEN: ; Registers X & Y will hold the screen x,y
            STX         LOADSCREEN_X
            STY         LOADSCREEN_Y

            ; Calculate Screen #
            ; (Y * 16) + X => SCREENNUM
            TYA         ; Y register still holds y
            ROL.A
            ROL.A
            ROL.A
            ROL.A
            ADC         LOADSCREEN_X
            STA         LOADSCREEN_SCREENNUMBER

            ; SETUP PTRS
            ; SETUP THE SCREENDATA_PTR => (SCREENNUMBER * 4) + SCREENDATA
            ; LOADSCREEN_SCREENDATA_PTR = LOADSCREEN_SCREENNUMBER
            
            LDA         LOADSCREEN_SCREENNUMBER     ; Remove/Optimize out...
            STA         LOADSCREEN_SCREENDATA_PTR
            STA         LOADSCREEN_SCREENMAPDATA_PTR
            LDA.#       $00
            STA         LOADSCREEN_SCREENDATA_PTR + 1
            STA         LOADSCREEN_SCREENMAPDATA_PTR + 1

            ; LOADSCREEN_SCREENDATA_PTR * 4
            @ROL_WORD(LOADSCREEN_SCREENDATA_PTR)
            @ROL_WORD(LOADSCREEN_SCREENDATA_PTR)
            ; LOADSCREEN_SCREENDATA_PTR += SCREENDATA
            ; @ADD_WORD(LOADSCREEN_SCREENDATA_PTR,SCREENDATA)
            CLC
            LDA         LOADSCREEN_SCREENDATA_PTR
            ADC.#       @LO(SCREENDATA)
            STA         LOADSCREEN_SCREENDATA_PTR
            LDA         LOADSCREEN_SCREENDATA_PTR + 1
            ADC.#       @HI(SCREENDATA)
            STA         LOADSCREEN_SCREENDATA_PTR + 1
            
            ; SETUP THE SCREENMAPDATA_PTR => (SCREENNUMBER * 16) + SCREENMAPDATA
            ; LOADSCREEN_SCREENDMAPATA_PTR * 16
            @ROL_WORD(LOADSCREEN_SCREENMAPDATA_PTR)
            @ROL_WORD(LOADSCREEN_SCREENMAPDATA_PTR)
            @ROL_WORD(LOADSCREEN_SCREENMAPDATA_PTR)
            @ROL_WORD(LOADSCREEN_SCREENMAPDATA_PTR)
            ; LOADSCREEN_SCREENDATA_PTR += SCREENDATA
            ;@ADD_WORD(LOADSCREEN_SCREENMAPDATA_PTR,SCREENMAPDATA)
            CLC
            LDA         LOADSCREEN_SCREENMAPDATA_PTR
            ADC.#       @LO(SCREENMAPDATA)
            STA         LOADSCREEN_SCREENMAPDATA_PTR
            LDA         LOADSCREEN_SCREENMAPDATA_PTR + 1
            ADC.#       @HI(SCREENMAPDATA)
            STA         LOADSCREEN_SCREENMAPDATA_PTR + 1

            ; Set the SCREEN_PTR
            LDA.#       @LO(VICII_SCREEN_RAM)
            STA         LOADSCREEN_SCREEN_PTR
            LDA.#       @HI(VICII_SCREEN_RAM)
            STA         LOADSCREEN_SCREEN_PTR + 1

            ; Reset COLUMN_INDEX
            LDA.#       $00
            STA         LOADSCREEN_COLUMN_INDEX

            ; Get the current
COLUMN_LOOP:
            ; Get the current COLUMNDATA_INDEX from the SCREENMAPDATA
            LDX         LOADSCREEN_COLUMN_INDEX
            CPX.#       $10
            BEQ         CONTINUE

            ; Get the current index into the COLUMNDATA
            LDA,X     LOADSCREEN_SCREENMAPDATA_PTR

            STA         LOADSCREEN_TEMP
            LDA.#       $00
            STA         LOADSCREEN_TEMP + 1
            ; (COLUMNDATA_IMDEX * 2) + (COLUMNDATA_INDEX * 4)
            @ROL_WORD(LOADSCREEN_TEMP)

            LDA         LOADSCREEN_TEMP
            STA         LOADSCREEN_COLUMNDATA_PTR
            LDA         LOADSCREEN_TEMP + 1
            STA         LOADSCREEN_COLUMNDATA_PTR + 1
            @ROL_WORD(LOADSCREEN_TEMP)
            
            CLC
            LDA         LOADSCREEN_COLUMNDATA_PTR
            ADC         LOADSCREEN_TEMP
            STA         LOADSCREEN_COLUMNDATA_PTR
            LDA         LOADSCREEN_COLUMNDATA_PTR + 1
            ADC         LOADSCREEN_TEMP + 1
            STA         LOADSCREEN_COLUMNDATA_PTR + 1

            ; 
            

            INC         LOADSCREEN_COLUMN_INDEX
            JMP         COLUMN_LOOP
CONTINUE:

            RTS

LOADSCREEN_X:
            DATA.b      $00
LOADSCREEN_Y:
            DATA.b      $00
LOADSCREEN_SCREENNUMBER:
            DATA.b      $00
LOADSCREEN_COLUMN_INDEX:
            DATA.b      $00

LOADSCREEN_SCREENDATA_PTR:
            DATA        $0000
LOADSCREEN_SCREENMAPDATA_PTR:
            DATA        $0000

LOADSCREEN_COLUMNDATA_PTR:
            DATA        $0000

LOADSCREEN_SCREEN_PTR:
            DATA        $0000

LOADSCREEN_TEMP:
            DATA        $0000

SCREENDATA:             ; Pallette, secret info, monster info, other
            ; Screen[0,0]
            #DATA.b     $00, $00, $00, $00


SCREENMAPDATA:          ; Each screen has 16 bytes of column data
            ; Screen[0,0]
            #DATA.b     $00, $01, $00, $01, $00, $01, $00, $01
            #DATA.b     $00, $01, $00, $01, $00, $01, $00, $01

COLUMNDATA:             ; Each column has 6 bytes
                        ; 1st nibble => TILESET Index
                        ; 2nd nibble => cell data
                        ; Each byte after that is 2 nibbles of cell data
                        ; for a total of 11 cells
            ; ColumnData[0]
            #DATA.b     $00, $12, $30, $12, $30, $12
            ; ColumnData[1]
            #DATA.b     $13, $21, $03, $21, $03, $21


TILESETS:               ; Each TileSet has a mapping of indexes to actual
                        ; TileData, 16 mappings because each nibble in
                        ; COLUMNDATA represents a byte in here which
                        ; represents a cell
            ; TileSet[0]
            #DATA.b     $00, $01, $02, $03, $00, $00, $00, $00
            #DATA.b     $00, $00, $00, $00, $00, $00, $00, $00
            ; TileSet[1]
            #DATA.b     $03, $02, $01, $00, $00, $00, $00, $00
            #DATA.b     $00, $00, $00, $00, $00, $00, $00, $00

CELLDATA:
            ; CellData[0]
            #DATA.b     $01, $01, $01, $01      ; AAAA
            ; CellData[1]
            #DATA.b     $02, $02, $02, $02      ; BBBB
            ; CellData[2]
            #DATA.b     $03, $03, $03, $03      ; CCCC
            ; CellData[3]
            #DATA.b     $04, $04, $04, $04      ; DDDD

