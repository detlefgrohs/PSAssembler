* = $0801

#INCLUDE ..\includes\includes.h

; Before 'Optimizations'
; Assembly Report:
;    Assembly Start  : 5/23/2023 6:01:53 PM
;    Assembly End    : 5/23/2023 6:02:06 PM
;    Elapsed Seconds : 12.99
;    Loaded Lines    : 912
;    Assembled Lines : 1,063
;    Assembled Bytes : 1,290
;    Labels/Variables: 191
;    Macros          : 23
;    Optimized Out   : 0

VICII_CHAR_DOLLARSIGN       = $24

VICII_CHAR_LETTER_X         = $18

#MACRO TEXT_SETXY(X,Y)
                LDX.#       @X
                LDY.#       @Y
                JSR         TEXT.SETXY
#ENDM
#MACRO TEXT_FGCOLOR(COLOR)
                LDA.#       @COLOR
                STA         TEXT.FGCOLOR
#ENDM
#MACRO TEXT_PRINTCHAR(CHAR) 
                LDA.#       @CHAR
                JSR         TEXT.PRINTCHAR
#ENDM

@BASICSTUB()

START:
                JSR         TEXT.CLEARSCREEN

	; Text::ForegroundColor := WHITE;
                ; LDA.#       VICII_COLOR_WHITE
                ; STA         TEXT.FGCOLOR
                @TEXT_FGCOLOR(VICII_COLOR_WHITE)

	; Text::SetColumnAndRow(0, 2);
                @TEXT_SETXY(0, 2);
                ; LDX.#       0
                ; LDY.#       2
                ; JSR         TEXT.SETXY

	; Text::WriteLine("     $$$$$$$$$$$$$$$$");
                LDA.#       5
                STA         TEXT.START_X
                LDA.#       2
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.WIDTH
                LDA.#       VICII_CHAR_DOLLARSIGN
                JSR         TEXT.HORIZONTALLINE
                ;@SET_ZP_WORD(ZP_PTR_A,TOP_TEXT)
                ;JSR         TEXT.PRINT

                JSR         TEXT.CRLF
	; Text::WriteLine("     XXXXXXXXXXXXXXXX");
                LDA.#       5
                STA         TEXT.START_X
                LDA.#       3
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.WIDTH
                LDA.#       VICII_CHAR_LETTER_X
                JSR         TEXT.HORIZONTALLINE
                ; @SET_ZP_WORD(ZP_PTR_A,TOP2_TEXT)
                ; JSR         TEXT.PRINT
                
; Text::SetColumnAndRow(5, 4);
; FOR l := 0 TO 16 DO BEGIN
;     Text::WriteDigit(l);
; END;
                ; LDX.#       5
                ; LDY.#       4
                ; JSR         TEXT.SETXY
                @TEXT_SETXY(5, 4);

                LDY.#       0
.1:             TYA         0
                JSR         TEXT.PRINTHEXDIGIT

                INY
                CPY.#       $10
                BNE         .1

; FOR h := 0 TO 16 DO BEGIN
;     Text::SetColumnAndRow(1, h + 6);
.2:             @TEXT_FGCOLOR(VICII_COLOR_WHITE)
                ; LDA.#       VICII_COLOR_WHITE
                ; STA         TEXT.FGCOLOR

                LDX.#       1
                LDA         Y_INDEX
                CLC
                ADC.#       6
                TAY
                JSR         TEXT.SETXY
;     Text::Write("$");
                ;@SET_ZP_WORD(ZP_PTR_A,DOLLAR_SIGN)
                ; LDA.#       VICII_CHAR_DOLLARSIGN
                ; JSR         TEXT.PRINTCHAR
                @TEXT_PRINTCHAR(VICII_CHAR_DOLLARSIGN) 
;     Text::WriteDigit(h);
                LDA         Y_INDEX
                JSR         TEXT.PRINTHEXDIGIT
;     Text::Write("X");
                ; @SET_ZP_WORD(ZP_PTR_A,LETTER_X)
                ; LDA.#       VICII_CHAR_LETTER_X
                ; JSR         TEXT.PRINTCHAR
                @TEXT_PRINTCHAR(VICII_CHAR_LETTER_X) 
;     FOR l := 0 TO 16 DO BEGIN
;         Text::SetCharacter(l + 5, h + 6, (h << 4) + l, LIGHT_BLUE);
;     END;
                LDA.#       $00
                STA         X_INDEX

                @TEXT_FGCOLOR(VICII_COLOR_LIGHT_BLUE)
                ; LDA.#       VICII_COLOR_LIGHT_BLUE
                ; STA         TEXT.FGCOLOR

.3:             LDA         X_INDEX
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
                BNE         .3

                INC         Y_INDEX
                LDA         Y_INDEX
                CMP.#       $10
                BNE         .2
; END;

                @TEXT_FGCOLOR(VICII_COLOR_BLACK)
                ; LDA.#       VICII_COLOR_BLACK
                ; STA         TEXT.FGCOLOR

; Text::HorizontalLineASM2(5, 5, 16, $43, BLACK);
                LDA.#       5
                STA         TEXT.START_X
                LDA.#       5
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.WIDTH
                LDA.#       $43
                JSR         TEXT.HORIZONTALLINE
; Text::HorizontalLineASM2(5, 22, 16, $43, BLACK);
                LDA.#       5
                STA         TEXT.START_X
                LDA.#       22
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.WIDTH
                LDA.#       $43
                JSR         TEXT.HORIZONTALLINE

; Text::VerticalLine(4, 6, 16, $5D, BLACK);
                LDA.#       4
                STA         TEXT.START_X
                LDA.#       6
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.HEIGHT
                LDA.#       $5D
                JSR         TEXT.VERTICALLINE
; Text::VerticalLine(21, 6, 16, $5D, BLACK);
                LDA.#       21
                STA         TEXT.START_X
                LDA.#       6
                STA         TEXT.START_Y
                LDA.#       16
                STA         TEXT.HEIGHT
                LDA.#       $5D
                JSR         TEXT.VERTICALLINE

; Text::SetCharacter(4, 5, $55, BLACK);
                @TEXT_SETXY(4, 5);
                ; LDX.#       4
                ; LDY.#       5
                ; JSR         TEXT.SETXY
                @TEXT_PRINTCHAR($55)
                ; LDA.#       $55
                ; JSR         TEXT.PRINTCHAR
; Text::SetCharacter(4, 22, $4A, BLACK);
                @TEXT_SETXY(4, 22);
                ; LDX.#       4
                ; LDY.#       22
                ; JSR         TEXT.SETXY
                @TEXT_PRINTCHAR($4A)
                ; LDA.#       $4A
                ; JSR         TEXT.PRINTCHAR
; Text::SetCharacter(21, 5, $49, BLACK);
                @TEXT_SETXY(21, 5);
                ; LDX.#       21
                ; LDY.#       5
                ; JSR         TEXT.SETXY
                @TEXT_PRINTCHAR($49)
                ; LDA.#       $49
                ; JSR         TEXT.PRINTCHAR
; Text::SetCharacter(21, 22, $4B, BLACK);
                @TEXT_SETXY(21, 22);
                ; LDX.#       21
                ; LDY.#       22
                ; JSR         TEXT.SETXY
                @TEXT_PRINTCHAR($4B)
                ; LDA.#       $4B
                ; JSR         TEXT.PRINTCHAR

                @SET_ZP_WORD(ZP_PTR_A,COLOR_STRINGS)

                LDA.#       0
                STA         Y_INDEX
; FOR l := 0 TO 16 DO BEGIN
;     Text::ForegroundColor := YELLOW;
.4:             @TEXT_FGCOLOR(VICII_COLOR_YELLOW)
                ; LDA.#       VICII_COLOR_YELLOW
                ; STA         TEXT.FGCOLOR
;     Text::SetColumnAndRow(23, 6 + l);
                LDX.#       23
                LDA         Y_INDEX
                CLC
                ADC.#       6
                TAY
                JSR         TEXT.SETXY
;     Text::Write(colorStrings[l]);
                JSR         TEXT.PRINT
                @ADD_ZP_WORD(ZP_PTR_A,12)
;     Text::HorizontalLineASM2(35, 6 + l, 4, $E0, l);
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
                JSR         TEXT.HORIZONTALLINE

                INC         Y_INDEX
                LDA         Y_INDEX
                CMP.#       $10
                BNE         .4
; END;

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