


## TileMaze-Chars.bin

Coloring
Bg 00 - 
Fg 11 - 
M1 01 - 
M2 10 -

    0 1 2
    3 8 4
    5 6 7

.CURRENT:       DATA.b  $00
.NEIGHBORS:     DATA.b  $00
.TILE_VALUE:    FILL    10
.TILE_POS:

Position 0 Mask 0b00010000
    00  0 ???0????
    10  0 ???1????
    
    0A  1 ???0????
    06  1 ???1????

; 2 Value Mask Checker (When C/8 is 0)
        LDA     .NEIGHBORDS
        AND.#   0b00010000
        BNE     .NS
        LDA.#   $00
        JMP     .CONT
.NS:    LDA.#   $10
.CONT:  STA.X   .TILE_VALUE
        INX


Position 1 Mask 0b10010000
    01  0 0??0????
    12  0 0??1????
    11  0 1??0????
    11  0 1??1????

    0B  1 0??0????
    09  1 0??1????
    07  1 1??0????
    07  1 1??1????

; 4 Value Mask Checker (When C/8 is 0)
        LDA     .NEIGHBORS
        AND.#   0b10010000
        CMP.#   0b10010000
        BNE     .1
        LDA.#   $11
        JMP     .CONT
.1:     CMP.#   0b10000000
        BNE     .2
        LDA.#   $11
        JMP     .CONT
.2:     CMP.#   0b00010000
        BNE     .3
        LDA.#   $12
        JMP     .CONT
.3      LDA.#   $01
.CONT:  STA.X   .TILE_VALUE
        INX

