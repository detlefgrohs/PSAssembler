# PSSuperMon64
Adapted from https://github.com/jblang/supermon64


## With Non-Relocated Basic Stub
pssm64bas.asm

```assembler

* = $0801

            DATA        $080B    ; Basic Stub
            DATA        $000A    ; 10 SYS2061
            DATA.B      $9E
            DATA.B      $32
            DATA.B      $30
            DATA.B      $36
            DATA.B      $31
            DATA.B      $00
            DATA        $0000

ORG:

            #INCLUDE pssupermon64.asm

* = $0801
```

![pssm64bas-emulated](https://github.com/detlefgrohs/PSAssembler/assets/5494000/f02cbd10-244e-4928-9ac0-268ebb816beb)
