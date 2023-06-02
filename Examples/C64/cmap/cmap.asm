* = $0801

#INCLUDE ..\..\includes\includes.h

                @BASICSTUB()

#STATS.PUSH
START:          LDA.#       UNPACK_MEMORY.MODE_BYTE
                STA         UNPACK_MEMORY.MODE
                
                @SET_WORD(UNPACK_MEMORY.SOURCE, CMAP1);
                @SET_WORD(UNPACK_MEMORY.SOURCE_END, CMAP1_END);
                @SET_WORD(UNPACK_MEMORY.TARGET, VICII_SCREEN_RAM);
                JSR         UNPACK_MEMORY

                @SET_WORD(UNPACK_MEMORY.SOURCE, CMAP2);
                @SET_WORD(UNPACK_MEMORY.SOURCE_END, CMAP2_END);
                JSR         UNPACK_MEMORY

                @SET_WORD(UNPACK_MEMORY.SOURCE, TEST);
                @SET_WORD(UNPACK_MEMORY.SOURCE_END, TEST_END);
                JSR         UNPACK_MEMORY

                @SET_WORD(UNPACK_MEMORY.SOURCE, TESTC);
                @SET_WORD(UNPACK_MEMORY.SOURCE_END, TESTC_END);
                @SET_WORD(UNPACK_MEMORY.TARGET, VICII_COLOR_RAM);
                LDA.#       UNPACK_MEMORY.MODE_NIBBLE
                STA         UNPACK_MEMORY.MODE
                JSR         UNPACK_MEMORY

                INC         VICII_BORDER_COLOR

                JMP         START

                RTS

CMAP1:          #LOADBINARY     cmap1.binc
CMAP1_END:      

CMAP2:          #LOADBINARY     cmap2.binc
CMAP2_END:

TEST:          #LOADBINARY     test.binc
TEST_END:

TESTC:         #LOADBINARY     testc.binc
TESTC_END:

#INCLUDE ..\..\library\unpack.asm