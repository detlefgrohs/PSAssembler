# PSAssembler
A 65x Assembler built with PowerShell...

Why? Because I can...

## C64 Example Loop
Simple example that shows a lot of the capabilities of this assembler.
- Include Files
- Macros
- Variables and Expressions

```assembly
* = $0801

#INCLUDE include.asm

@BASICSTUB()

QuarterPage = 1000 / 4

START:      LDX.#       QuarterPage

LOOP:       TXA
            
            STA,X       SCREEN + (QuarterPage * 0)
            STA,X       COLOR + (QuarterPage * 0)

            STA,X       SCREEN + (QuarterPage * 1)
            STA,X       COLOR + (QuarterPage * 1)
            
            STA,X       SCREEN + (QuarterPage * 2)
            STA,X       COLOR + (QuarterPage * 2)

            STA,X       SCREEN + (QuarterPage * 3)
            STA,X       COLOR + (QuarterPage * 3)

            DEX
            BNE         LOOP

            RTS
```
```
0801 |          |             | * = $0801
0801 |          |             | 
0801 |          |             | #INCLUDE include.asm
0801 |          |             | ; Start Including 'include.asm'
0801 |          |             | ; include.asm file...
0801 |          |             | SCREEN = $0400
0801 |          |             | COLOR = $D800
0801 |          |             | 
0801 |          |             | HIGHNIBBLE = %11110000
0801 |          |             | LOWNIBBLE = %00001111
0801 |          |             | 
0801 |          |             | 
0801 |          |             | ; Ending Including 'include.asm'
0801 |          |             | 
0801 |          |             | 
0801 | 0B 08    |             |             DATA        $080B    ; Basic Stub
0803 | 0A 00    |             |             DATA        $000A    ; 10 SYS2061
0805 | 9E       |             |             DATA.B      $9E
0806 | 32       |             |             DATA.B      $32
0807 | 30       |             |             DATA.B      $30
0808 | 36       |             |             DATA.B      $36
0809 | 31       |             |             DATA.B      $31
080A | 00       |             |             DATA.B      $00
080B | 00 00    |             |             DATA        $0000
080D |          |             | 
080D |          |             | 
080D |          |             | QuarterPage = 1000 / 4
080D |          |             | 
080D | A2 FA    | LDX #$FA    | START:      LDX.#       QuarterPage
080F |          |             | 
080F | 8A       | TXA         | LOOP:       TXA
0810 |          |             |             
0810 | 9D 00 04 | STA $0400,X |             STA,X       SCREEN + (QuarterPage * 0)
0813 | 9D 00 D8 | STA $D800,X |             STA,X       COLOR + (QuarterPage * 0)
0816 |          |             | 
0816 | 9D FA 04 | STA $04FA,X |             STA,X       SCREEN + (QuarterPage * 1)
0819 | 9D FA D8 | STA $D8FA,X |             STA,X       COLOR + (QuarterPage * 1)
081C |          |             |             
081C | 9D F4 05 | STA $05F4,X |             STA,X       SCREEN + (QuarterPage * 2)
081F | 9D F4 D9 | STA $D9F4,X |             STA,X       COLOR + (QuarterPage * 2)
0822 |          |             | 
0822 | 9D EE 06 | STA $06EE,X |             STA,X       SCREEN + (QuarterPage * 3)
0825 | 9D EE DA | STA $DAEE,X |             STA,X       COLOR + (QuarterPage * 3)
0828 |          |             | 
0828 | CA       | DEX         |             DEX
0829 | D0 E4    | BNE $E4     |             BNE         LOOP
082B |          |             | 
082B | 60       | RTS         |             RTS
```
![loop-emulated](https://github.com/detlefgrohs/PSAssembler/assets/5494000/936caac8-f745-4b9b-89d5-541178ec1414)








