* = $0801

#INCLUDE ..\includes\includes.h

@BASICSTUB()

START:          JSR         TEXT.CLEARSCREEN

                @TEXT_FGCOLOR(VICII_COLOR_WHITE)        ; Text::ForegroundColor := WHITE;

                LDA.#       5                           ; Text::WriteLine("     $$$$$$$$$$$$$$$$");
                STA         TEXT.START_X
                LDA.#       2
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.WIDTH
                LDA.#       VICII_CHAR_DOLLARSIGN
                JSR         TEXT.HORIZONTALLINE
	
                LDA.#       5                           ; Text::WriteLine("     XXXXXXXXXXXXXXXX");
                STA         TEXT.START_X
                LDA.#       3
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.WIDTH
                LDA.#       VICII_CHAR_LETTER_X
                JSR         TEXT.HORIZONTALLINE

                @TEXT_SETXY(5, 4);
                LDY.#       0                           ; FOR l := 0 TO 16 DO BEGIN
.1:             TYA         0
                JSR         TEXT.PRINTHEXDIGIT          ;     Text::WriteDigit(l);
                INY
                CPY.#       $10
                BNE         .1                          ; END;

.2:             @TEXT_FGCOLOR(VICII_COLOR_WHITE)        ; FOR h := 0 TO 16 DO BEGIN
                LDX.#       1                           ;     Text::SetColumnAndRow(1, h + 6);
                LDA         Y_INDEX
                CLC
                ADC.#       6
                TAY
                JSR         TEXT.SETXY
                @TEXT_PRINTCHAR(VICII_CHAR_DOLLARSIGN)  ;     Text::Write("$");
                LDA         Y_INDEX
                JSR         TEXT.PRINTHEXDIGIT          ;     Text::WriteDigit(h);

                @TEXT_PRINTCHAR(VICII_CHAR_LETTER_X)    ;     Text::Write("X");

                LDA.#       $00                         ;     FOR l := 0 TO 16 DO BEGIN
                STA         X_INDEX

                @TEXT_FGCOLOR(VICII_COLOR_LIGHT_BLUE)
.3:             LDA         X_INDEX                     ; Text::SetCharacter(l + 5, h + 6, (h << 4) + l, LIGHT_BLUE);
                CLC
                ADC.#       5
                TAX
                LDA         Y_INDEX
                CLC
                ADC.#       6
                TAY
                JSR         TEXT.SETXY

                LDA         Y_INDEX
                ROL.A
                ROL.A
                ROL.A
                ROL.A
                CLC
                ADC         X_INDEX
                JSR         TEXT.PRINTCHAR

                INC         X_INDEX
                LDA         X_INDEX
                CMP.#       $10
                BNE         .3                          ;     END;

                INC         Y_INDEX
                LDA         Y_INDEX
                CMP.#       $10
                BNE         .2                          ; END;

                @TEXT_FGCOLOR(VICII_COLOR_BLACK)

                LDA.#       5
                STA         TEXT.START_X
                LDA.#       5
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.WIDTH
                LDA.#       $43
                JSR         TEXT.HORIZONTALLINE         ; Text::HorizontalLineASM2(5, 5, 16, $43, BLACK);

                LDA.#       5
                STA         TEXT.START_X
                LDA.#       22
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.WIDTH
                LDA.#       $43
                JSR         TEXT.HORIZONTALLINE         ; Text::HorizontalLineASM2(5, 22, 16, $43, BLACK);

                LDA.#       4
                STA         TEXT.START_X
                LDA.#       6
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.HEIGHT
                LDA.#       $5D
                JSR         TEXT.VERTICALLINE           ; Text::VerticalLine(4, 6, 16, $5D, BLACK);

                LDA.#       21
                STA         TEXT.START_X
                LDA.#       6
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.HEIGHT
                LDA.#       $5D
                JSR         TEXT.VERTICALLINE           ; Text::VerticalLine(21, 6, 16, $5D, BLACK);

                @TEXT_SETXY(4, 5);
                @TEXT_PRINTCHAR($55)                    ; Text::SetCharacter(4, 5, $55, BLACK);

                @TEXT_SETXY(4, 22);
                @TEXT_PRINTCHAR($4A)                    ; Text::SetCharacter(4, 22, $4A, BLACK);

                @TEXT_SETXY(21, 5);
                @TEXT_PRINTCHAR($49)                    ; Text::SetCharacter(21, 5, $49, BLACK);

                @TEXT_SETXY(21, 22);
                @TEXT_PRINTCHAR($4B)                    ; Text::SetCharacter(21, 22, $4B, BLACK);

                @SET_ZP_WORD(ZP_PTR_A,COLOR_STRINGS)

                LDA.#       0
                STA         Y_INDEX                     ; FOR l := 0 TO 16 DO BEGIN

.4:             @TEXT_FGCOLOR(VICII_COLOR_YELLOW)       ;     Text::ForegroundColor := YELLOW;
                LDX.#       23
                LDA         Y_INDEX
                CLC
                ADC.#       6
                TAY
                JSR         TEXT.SETXY                  ;     Text::SetColumnAndRow(23, 6 + l);

                JSR         TEXT.PRINT                  ;     Text::Write(colorStrings[l]);
                @ADD_ZP_WORD(ZP_PTR_A,12)
                LDA         Y_INDEX
                STA         TEXT.FGCOLOR

                LDA.#       35
                STA         TEXT.START_X
                LDA         Y_INDEX
                CLC
                ADC.#       6
                STA         TEXT.START_Y
                LDA.#       4
                STA         TEXT.WIDTH
                LDA.#       $E0
                JSR         TEXT.HORIZONTALLINE         ;     Text::HorizontalLineASM2(35, 6 + l, 4, $E0, l);

                INC         Y_INDEX
                LDA         Y_INDEX
                CMP.#       $10
                BNE         .4                          ; END;

                JMP         CURADDR

X_INDEX:        DATA.b      $00
Y_INDEX:        DATA.b      $00
                ;            123456789AB
COLOR_STRINGS:  #TEXTZ      "   BLACK $0"
                #TEXTZ      "   WHITE $1"
                #TEXTZ      "     RED $2"
                #TEXTZ      "    CYAN $3"
                #TEXTZ      "  PURPLE $4"
                #TEXTZ      "   GREEN $5"
                #TEXTZ      "    BLUE $6"
                #TEXTZ      "  YELLOW $7"
                #TEXTZ      "  ORANGE $8"
                #TEXTZ      "   BROWN $9"
                #TEXTZ      "  LT RED $A"
                #TEXTZ      " DK GREY $B"
                #TEXTZ      "    GREY $C"
                #TEXTZ      "LT GREEN $D"
                #TEXTZ      " LT BLUE $E"
                #TEXTZ      " LT GREY $F"

#INCLUDE ..\library\text.asm