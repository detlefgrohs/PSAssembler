
byte variableB = value;
word variableW;

byte peek(word address) {
    return mem[address];
}
; Constant Address
                    LDA     @ADDRESS

; Passed in Address Variable
                    LDA     @ADDRESS
                    STA     .LD + 1
                    LDA     @ADDRESS + 1    ; Does this make sense
                    STA     .LD + 2
.LD:                LDA     $0000

void poke(word address, byte value) {
    memory[address] = value;
}

void main() {

}





for (byte index = 0 ; index < 100; index + 1) {
    NOP
}

; Setup
.var_index      DATA.b  0

; Initialize
                LDA.#   0
                STA     .var_index
.loop:

; Operation
                NOP

; Advance
                LDA     .var_index
                ADC.#   1
                STA     .var_index

; Check
                CMP.#   100
                BNE     .loop



