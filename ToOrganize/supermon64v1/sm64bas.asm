
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

            #INCLUDE Supermon64v1.asm

* = $0801