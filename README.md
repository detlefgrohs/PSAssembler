# PSAssembler
A 65x Assembler built with PowerShell...

Why? Because I can...


## Features

- Include Files
Additional files can be including assembled but the #INCLUDE directive.
- Nested Macros
The #DEFINE Macro(Param1, Param2) ... #ENDM can be used to define macros and can even used to expand macros within other macros.
- Expressions
Full expressions and binary math support. << >> & | %1010 etc...
- Multi-Pass Assembly
1st pass of assembly only used to get all label locations. 2nd pass generates code with actual labels and offsets.
- Labels and Variables
Labels are just variables that are set to the current location in the assembly.

## Tests

###C64
tests\c64 has the tests that show C64 functionality...


## SuperMon64
I converted the https://github.com/jblang/supermon64 supermon64 assembly source to be a stress test of the assembler and my parsing.

## File Loading


## Macros and Macro Expansion
Macros are defined with the #MACRO directive and a block of code is contained between that and the #ENDM directive. Parameters are defined and replaced in the macro block with @ prefixes. Macro expansion will continue until there are no more macro expansions available. Anytime a @MacroName is not found, it will comment out the line, note the error and continue parsing the code. This is to ensure that all of the errors are collected and reported when possible.

```assembly
#MACRO LO(VALUE)
(@VALUE & $00FF)
#ENDM

#MACRO HI(VALUE)
((@VALUE & $FF00) >> 8)
#ENDM

#MACRO SET_WORD(ADDRESS,VALUE)
    LDA.#   @LO(@VALUE)
    STA     @ADDRESS
    LDA.#   @HI(@VALUE)
    STA     @ADDRESS+1
#ENDM

@SET_WORD($ABCD,$1234)
```
```assembly
0000 | A9 34    | LDA #$34    |     LDA.#   ($1234 & $00FF)
0002 | 8D CD AB | STA $ABCD   |     STA     $ABCD
0005 | A9 12    | LDA #$12    |     LDA.#   (($1234 & $FF00) >> 8)
0007 | 8D CE AB | STA $ABCE   |     STA     $ABCD+1
```
## Syntax
I am using a modified syntax that makes the expression parsing much easier because the modifiers that affect the addressing modes make it hard to have general expression parsing when parcheesis and modifiers such as ,X are part of the operand part of the syntax. Also the zero page addressing modes are hard to detect if the size of the operand cannot be determined yet (because we are in the 1st pass of the assembly).

By moving the modifiers to the Mnemonic part of the parsing the operand can then be treated like an expression as a whole.

The general format for lines in the assembly are:


|line|description|
|-|-|
`#DIRECTIVE parameters ; comment|Directive
left = right ; commment|Assignment
label: mnemonic operand ; comment |Syntax

### Regular Expressions
I use regular expressions to clean off the comments from the end of the line and then determine what type of line I am working with.

This is not an efficient way to parse but it is easy to code

```
ToFix : The table below is off...
```
|Format|OpCode|Addressing Mode|Mnemonic|
|---|---|---|---|
|LDA #[d8]|0xa9|Immediate|LDA.#|
|LDA [d8]|0xa5|ZeroPage|LDA.zp|
|"LDA [d8]|X"|0xb5|ZeroPageX|"LDA.zp|X"|
|"LDX [d8]|Y"|0xb6|ZeroPageY|"LDX.zp|Y"|
|LDA [a16]|0xad|Absolute|LDA|
|"LDA [a16]|X"|0xbd|AbsoluteX|"LDA|X"|
|"LDA [a16]|Y"|0xb9|AbsoluteY|"LDA|Y"|
|"LDA ([d8])|Y"|0xb1|IndexedIndirectY|"LDA.i|Y"|
|"LDA ([d8]|X)"|0xa1|IndexedIndirectX|"LDA.i|X"|
|TAX|0xaa|Implied|TAX|
|ASL A|0x0a|Accumulator|ASL.A|
|JMP ([a16])|0x6c|Indirect|JMP.i|
|BEQ [r8]|0xf0|Relative|BEQ|

