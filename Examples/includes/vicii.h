
VICII_COLOR_BLACK           = $00
VICII_COLOR_WHITE           = $01
VICII_COLOR_RED             = $02
VICII_COLOR_CYAN            = $03
VICII_COLOR_PURPLE          = $04
VICII_COLOR_GREEN           = $05
VICII_COLOR_BLUE            = $06
VICII_COLOR_YELLOW          = $07
VICII_COLOR_ORANGE          = $08
VICII_COLOR_BROWN           = $09
VICII_COLOR_PINK            = $0A
VICII_COLOR_DARK_GREY       = $0B
VICII_COLOR_GREY            = $0C
VICII_COLOR_LIGHT_GREEN     = $0D
VICII_COLOR_LIGHT_BLUE      = $0E
VICII_COLOR_LIGHT_GREY      = $0F

VICII                      = $D000
VICII_SPRITE_0_X           = VICII + $00
VICII_SPRITE_0_Y           = VICII + $01
VICII_SPRITE_1_X           = VICII + $02
VICII_SPRITE_1_Y           = VICII + $03
VICII_SPRITE_2_X           = VICII + $04
VICII_SPRITE_2_Y           = VICII + $05
VICII_SPRITE_3_X           = VICII + $06
VICII_SPRITE_3_Y           = VICII + $07
VICII_SPRITE_4_X           = VICII + $08
VICII_SPRITE_4_Y           = VICII + $09
VICII_SPRITE_5_X           = VICII + $0A
VICII_SPRITE_5_Y           = VICII + $0B
VICII_SPRITE_6_X           = VICII + $0C
VICII_SPRITE_6_Y           = VICII + $0D
VICII_SPRITE_7_X           = VICII + $0E
VICII_SPRITE_7_Y           = VICII + $0F
VICII_SPRITE_MSB_X         = VICII + $10
VICII_CONTROL_1            = VICII + $11
VICII_RASTER               = VICII + $12
VICII_LIGHTPEN_X           = VICII + $13
VICII_LIGHTPEN_Y           = VICII + $14
VICII_SPRITE_ENABLE        = VICII + $15
VICII_CONTROL_2            = VICII + $16
VICII_SPRITE_EXPAND_Y      = VICII + $17
VICII_MEMORY_CONTROL       = VICII + $18
VICII_IRR                  = VICII + $19
VICII_IMR                  = VICII + $1A
VICII_SPRITE_PRIORITY      = VICII + $1B
VICII_SPRITE_COL_MODE      = VICII + $1C
VICII_SPRITE_EXPAND_X      = VICII + $1D
VICII_SPRITE_2S_COLLISION  = VICII + $1E
VICII_SPRITE_2B_COLLISION  = VICII + $1F
VICII_BORDER_COLOR         = VICII + $20
VICII_BG_COL_0             = VICII + $21
VICII_BG_COL_1             = VICII + $22
VICII_BG_COL_2             = VICII + $23
VICII_BG_COL_3             = VICII + $24
VICII_SPRITE_COL_0         = VICII + $25
VICII_SPRITE_COL_1         = VICII + $26
VICII_SPRITE_0_COLOR       = VICII + $27
VICII_SPRITE_1_COLOR       = VICII + $28
VICII_SPRITE_2_COLOR       = VICII + $29
VICII_SPRITE_3_COLOR       = VICII + $2A
VICII_SPRITE_4_COLOR       = VICII + $2B
VICII_SPRITE_5_COLOR       = VICII + $2C
VICII_SPRITE_6_COLOR       = VICII + $2D
VICII_SPRITE_7_COLOR       = VICII + $2E

VICII_SCREEN_RAM            = $0400
VICII_COLOR_RAM             = $D800

VICII_SCREEN_TEXT_WIDTH     = 40
VICII_SCREEN_TEXT_HEIGHT    = 25

VICII_SCREEN_BITMAP_WIDTH   = 320
VICII_SCREEN_BITMAP_HEIGHT  = 200

VICII_TOP_SCREEN_RASTER_POS = 50
VICII_SCREEN_RASTER_LINES   = 200

VICII_RASTER_MAX_PAL        = 312
VICII_RASTER_MAX_NTSC       = 263

#MACRO VICII_SCREEN_TEXT_LINE(LineNumber)
VICII_SCREEN_RAM + ( VICII_SCREEN_TEXT_WIDTH * @LineNumber )
#ENDM

#MACRO VICII_SCREEN_COLOR_LINE(LineNumber)
VICII_COLOR_RAM + ( VICII_SCREEN_TEXT_WIDTH * @LineNumber )
#ENDM

VICII_CHAR_DOLLARSIGN       = $24
VICII_CHAR_LETTER_X         = $18
