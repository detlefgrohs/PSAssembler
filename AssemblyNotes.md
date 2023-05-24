
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
