
Assembly Phases

    Loading
        Loading the main file
            Handle #INCLUDE and recursively load files...
            Handle #STOP and #CONTINUE commands to ignore lines...

        Macro Expansion
            Expand Macros in the Line array until there are no more expansions
            #MACRO and #ENDM processed

        Assembly Phases
            Collection
                This will process the Line array and define the variables and labels and regions they are a part of

                    Labels will have a Region added and CalledFromRegion = @();
                    New Region = @{};
                        Region; StartAddress; EndAddress; ReferenceCount = 0;

            Pre-Optimization
                Will process the Line array and note which regions make calls to other regions.

            Optimization
                Will remove regions that are not being reference from the <root> region or by any other regions.

            Assembly
                Will final assemble the remaining lines into an array of bytes




## Next Steps
Organize Libraries
    Text
        Text.ScrollUp
            Calls Text.ClearLine

        Text.ClearScreen
            Calls Text.ClearLine
        
        Text.ClearLine

        Text.Print
            Calls Text.PrintChar
        Text.PrintByte
            Calls Text.PrintChar
        Text.PrintHexDigit
            Calls Text.PrintChar
        Text.PrintWord
            Calls Text.PrintChar

        Text.PrintChar
            Calls Text.CRLF

        Text.CRLF

        Text.SET_PTRS


    Math
        Math.Random
        Math.

    Heap
        Heap.?
            Get from TSRE


Graphics Demos
    All from TSRE



Pester Support


Syntax thoughts
    ASL.A could just be ASL...


When do I run this? During or before expand macros? When are variables assigned?

#CODE
    Anything like @word will be replaced with the value of the variable...
#ENDC





<#

    [x] Assembly Stats

    [ ] MultiByte DATA.b

    [ ] Examples
        [x] ScrollUp with Color
            [ ] Optimize
        [x] NewMaze
            [ ] Optimize
            [ ] Smooth scrolling
        [ ] Text Routine
            [ ] Struct for x,y etc...
            [ ] ScrollUp copied
            [ ] byte, word, fp to string...

        [ ] Math Routines - In Assembly


    [x] Assertions
        [ ] formatting

    [ ] New Directives
        [ ] #PRINT
        [ ] 

    [ ] Keywords
        [ ] 2 Types Reserved for PS Syntax
        [ ] Reserved Variables

    [ ] Reassigning labels or variables?

    [ ] Tests
        With Assertions

    [ ] Load Binary
        Charsets/Sprites

#>



## 

ML
Assembly
Macros
Higher Level Constructs



for(indexY = 0; indexY < 16 ; indexY++ ) {
            LDA.#           0
            STA             .indexY

.loop
            {}

            CLC
.indexY_    LDA.#           $00
            ADC.#           1
            STA             .indexY

            CMP.#           16
            BNE             .loop
.indexY = .indexY_ + 1
}

@LOOP_START(IndexA, 0)

@LOOP_INCREMENT(IndexA)
@LOOP_ADD(IndexA, 2)
@LOOP_NEXT(IndexA, 16)

Need in MacroExpression to create labels:

    @Index = IndexA

    .@Index => .IndexA
    .@Index_ => .IndexA_
    .@Index_Loop => .IndexA_Loop



#MACRO LOOP_START(IndexName, StartValue)
            LDA.#           @StartValue
            STA             '.'@StartValue  ; New macro functionality
.@IndexName_Loop:
#ENDM

#MACRO LOOP_INCREMENT(IndexName)
            INC             '.'@IndexName
#ENDM

#MACRO LOOP_NEXT(IndexName, Limit)
            LDA             '.'@IndexName
            CMP.#           @Limit
            BNE             .@IndexName_Loop
#ENDM





3 Fizz

5 Buzz





; Translate A into hexadecimal digits in A (bit 7-4) and X (bit 3-0)
hex_digits
        pha
        and #$0f
        cmp #$0a
        bcs +
        adc #$3a
+       sbc #$09
        tax
        pla
        lsr
        lsr
        lsr
        lsr
        cmp #$0a
        bcs +
        adc #$3a
+       sbc #$09
        rts


http://unusedino.de/ec64/technical/aay/c64/basromma.htm

LDX #LOW BYTE
LDA #HIGH BYTE
JSR $BDCD
RTS 

https://www.chibiakumas.com/6502/c64.php



<#
    ToDo:

        Documentation
            Command line

            # commands
                Macros
                STATS
                INCLUDE
                STOP/Continue
                CodeSegment

            How the assembler works
                Loading file(s)
                Executing CODESEGMENTS
                Expanding MACROS
                Assembly Pass
                    Collection
                    Allocation
                    Optmization
                    Relocation
                    Assembly
                Outputting

            Syntax
                General parsing mode
                    Remove Comments
                    Parse Line
                        Check if label: #COMMAND works...

                Why I did what I did...
                    ZP is a pain also modifiers are hard sometimes
                        so addressing mode is part of mnemonic and everything
                        after is the value, which is either a direct value, expression
                        or variable

                How the Opcodes.x.json file works
                6502 commands
                    Addressing Modes
                
                    LD/ST

                    CMP/BR

                    JSR/RTS

                    Math

                    Other

            Optimization
                ZP via code modification

                Parameters
                A,X,Y

            Assembly Routines Documentation
                BIN to BCD

                JSR Parameters

                @BASICSTUB()

            Testing
                ASSERTIONS
                RASTERLINE stuff


        Enhancements:
            DATA & DATA.b multi byte/word values



            WORD    $0000
            DWORD   $00000000
            QWORD   $0000000000000000 ; Is this needed



            STRUCT

            #STRUCT Name
                .START:     WORD    $0000
                .END:       WORD    $0000
                .LENGTH:    BYTE    $00
            #ENDS

            HEAD:   @Name

            @MACRO with no parameters


            Error Handling
                Still a couple of areas where duplicate errors are generated

            Dump Assembly ps1

            Disassemble.ps1

        To Complete/Documentate
            MACROS
                Stack Stuff

                SET Memory

                INC/DEC

                ADD/SBC

                Rotate

                Loops

                IF/THEN



            C64 Specific Stuff
                VICII
                BASIC
                KERNAL

            Libraries
                TEXT
                MATH
                GRAPHICS


        [ ] Book generation PowerShell scripts
            That could actually be a small book in itself
            'Write a book in Visual Code and PowerShell'

            What does it take to generate a ebook for Amazon...

#>