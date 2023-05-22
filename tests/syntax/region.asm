* = $0801

#REGION RegionA
LABELA:
            LDA     $F000
            STA     $E000
.1:         JMP     .1

#ENDR

#REGION RegionB
LABELB:
            LDA     $B000
            STA     $C000
.2:         BCC     .2
#ENDR


START:      LDA     $0801
            STA     $0801

            JSR     LABELA

            RTS