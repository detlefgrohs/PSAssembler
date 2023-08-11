

LDA #[d8]       A9 d8       2
LDA [d8]        A5 d8       3
LDA [d8],X      B5 d8       4
LDA [a16]       AD al ah    4
LDA [a16],X	    BD al ah    4/5
LDA [a16],Y	    B9 al ah    4/5
LDA ([d8]),Y    B1 d8       6
LDA ([d8],X)    A1 d8       5/6





ADC #[d8]     69 d8      2
ADC ([d8]),Y  71 d8      6
ADC ([d8],X)  61 d8      5\6
ADC [a16]     6D al ah   4
ADC [a16],X   7D al ah   4\5
ADC [a16],Y   79 al ah   4\5
ADC [d8]      65 d8      3
ADC [d8],X    75 d8      4

SBC #[d8]     E9 d8      2
SBC ([d8]),Y  F1 d8      6
SBC ([d8],X)  E1 d8      5\6
SBC [a16]     ED al ah   4
SBC [a16],X   FD al ah   4\5
SBC [a16],Y   F9 al ah   4\5
SBC [d8]      E5 d8      3
SBC [d8],X    F5 d8      4


ASL [a16]     0E al ah   4
ASL [a16],X   1E al ah   4\5
ASL [d8]      06 d8      3
ASL [d8],X    16 d8      4
ASL A         0A         2

LSR [a16]     4E al ah   4
LSR [a16],X   5E al ah   4\5
LSR [d8]      46 d8      3
LSR [d8],X    56 d8      4
LSR A         4A         2


ROL [a16]     2E al ah   4
ROL [a16],X   3E al ah   4\5
ROL [d8]      26 d8      3
ROL [d8],X    36 d8      4
ROL A         2A         2

ROR [a16]     6E al ah   4
ROR [a16],X   7E al ah   4\5
ROR [d8]      66 d8      3
ROR [d8],X    76 d8      4
ROR A         6A         2

INC [a16]     EE al ah   4
INC [a16],X   FE al ah   4\5
INC [d8]      E6 d8      3
INC [d8],X    F6 d8      4

INX           E8         2
INY           C8         2

DEC [a16]     CE al ah   4
DEC [a16],X   DE al ah   4\5
DEC [d8]      C6 d8      3
DEC [d8],X    D6 d8      4

DEX           CA         2
DEY           88         2




AND #[d8]     29 d8      2
AND ([d8]),Y  31 d8      6
AND ([d8],X)  21 d8      5\6
AND [a16]     2D al ah   4
AND [a16],X   3D al ah   4\5
AND [a16],Y   39 al ah   4\5
AND [d8]      25 d8      3
AND [d8],X    35 d8      4

EOR #[d8]     49 d8      2
EOR ([d8]),Y  51 d8      6
EOR ([d8],X)  41 d8      5\6
EOR [a16]     4D al ah   4
EOR [a16],X   5D al ah   4\5
EOR [a16],Y   59 al ah   4\5
EOR [d8]      45 d8      3
EOR [d8],X    55 d8      4

ORA #[d8]     09 d8      2
ORA ([d8]),Y  11 d8      6
ORA ([d8],X)  01 d8      5\6
ORA [a16]     0D al ah   4
ORA [a16],X   1D al ah   4\5
ORA [a16],Y   19 al ah   4\5
ORA [d8]      05 d8      3
ORA [d8],X    15 d8      4



BCC [r8]      90 d8      2\4
BCS [r8]      B0 d8      2\4
BEQ [r8]      F0 d8      2\4

BMI [r8]      30 d8      2\4
BNE [r8]      D0 d8      2\4
BPL [r8]      10 d8      2\4

BVC [r8]      50 d8      2\4
BVS [r8]      70 d8      2\4

CLC           18         2
CLD           D8         2
CLI           58         2
CLV           B8         2


BIT [a16]     2C al ah   4
BIT [d8]      24 d8      3

CMP #[d8]     C9 d8      2
CMP ([d8]),Y  D1 d8      6
CMP ([d8],X)  C1 d8      5\6
CMP [a16]     CD al ah   4
CMP [a16],X   DD al ah   4\5
CMP [a16],Y   D9 al ah   4\5
CMP [d8]      C5 d8      3
CMP [d8],X    D5 d8      4

CPX #[d8]     E0 d8      2
CPX [a16]     EC al ah   4
CPX [d8]      E4 d8      3

CPY #[d8]     C0 d8      2
CPY [a16]     CC al ah   4
CPY [d8]      C4 d8      3


JMP ([a16])   6C al ah   5
JMP [a16]     4C al ah   4
JSR [a16]     20 al ah   4

LDA #[d8]     A9 d8      2
LDA ([d8]),Y  B1 d8      6
LDA ([d8],X)  A1 d8      5\6
LDA [a16]     AD al ah   4
LDA [a16],X   BD al ah   4\5
LDA [a16],Y   B9 al ah   4\5
LDA [d8]      A5 d8      3
LDA [d8],X    B5 d8      4

LDX #[d8]     A2 d8      2
LDX [a16]     AE al ah   4
LDX [a16],Y   BE al ah   4\5
LDX [d8]      A6 d8      3
LDX [d8],Y    B6 d8      4

LDY #[d8]     A0 d8      2
LDY [a16]     AC al ah   4
LDY [a16],X   BC al ah   4\5
LDY [d8]      A4 d8      3
LDY [d8],X    B4 d8      4



NOP           EA         2
BRK           00         2

PHA           48         2
PHP           08         2
PLA           68         2
PLP           28         2



RTI           40         2
RTS           60         2


SEC           38         2
SED           F8         2
SEI           78         2


STA ([d8]),Y  91 d8      6
STA ([d8],X)  81 d8      5\6
STA [a16]     8D al ah   4
STA [a16],X   9D al ah   4\5
STA [a16],Y   99 al ah   4\5
STA [d8]      85 d8      3
STA [d8],X    95 d8      4


STX [a16]     8E al ah   4
STX [d8]      86 d8      3
STX [d8],Y    96 d8      4
STY [a16]     8C al ah   4
STY [d8]      84 d8      3
STY [d8],X    94 d8      4


TAX           AA         2
TAY           A8         2
TSX           BA         2
TXA           8A         2
TXS           9A         2
TYA           98         2
