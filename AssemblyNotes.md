
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

