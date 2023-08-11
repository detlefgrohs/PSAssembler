; ===========================================================================
INITIALIZE:
	            ; jiffyTime := $A0;
		
	            ; SetBitMapMode();
                LDA.#   $3B
                STA     $D011

                ; SetMultiColorMode();
                LDA.#   16
                ORA     $D016
                STA     $D016

                ; SetBank(VIC_BANK1);
                LDA.#   $2
                STA     $DD00

                ; Poke(^$D018, 0, Peek(^$D018, 0) | $08);
                ; What is this?
                LDA     $D018
                ORA.#   $8
                STA     $D018

                ; Screen_BG_Col := Cyan;
                ; Screen_FG_Col := Cyan;
                LDA.#   VICII_COLOR_CYAN
                STA     $D020
                STA     $D021

                ; SetMemoryConfig(1, 1, 0);	// IO, Kernal, BASIC
                LDA.ZP  $01
                AND.#   %11111000
                ORA.#   %110
                STA.ZP  $01

                ; idleFrame := 0;
                ; walkingFrame := 0;

                RTS
