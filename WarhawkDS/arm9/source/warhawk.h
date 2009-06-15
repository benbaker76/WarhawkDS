@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"), to deal in the Software without restriction, including
@ without limitation the rights to use, copy, modify, merge, publish,
@ distribute, sublicense, and/or sell copies of the Software, and to
@ permit persons to whom the Software is furnished to do so, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software.
@ 
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
@ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
@ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
@ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
@ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
@ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
@ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "../build/Font.h"
#include "../build/Score.h"
#include "../build/Energy.h"
#include "../build/EnergyLow.h"
#include "../build/LoadingTop.h"
#include "../build/LoadingBottom.h"
#include "../build/Proteus.h"
#include "../build/Headsoft.h"
#include "../build/Infectuous.h"
#include "../build/PPOT.h"
#include "../build/Retrobytes.h"
#include "../build/Web.h"
#include "../build/TitleTop.h"
#include "../build/TitleBottom.h"
#include "../build/Congratulations.h"
#include "../build/LargeShip.h"
#include "../build/WarShip.h"
#include "../build/Moonscape.h"
#include "../build/Moonscape2.h"
#include "../build/AntonLaVey1.h"
#include "../build/AntonLaVey2.h"
#include "../build/AntonLaVey3.h"
#include "../build/Orbscape.h"
#include "../build/Credits01.h"
#include "../build/Credits02.h"
#include "../build/Credits03.h"
#include "../build/Credits04.h"
#include "../build/Credits05.h"
#include "../build/Credits06.h"
#include "../build/Credits07.h"
#include "../build/Credits08.h"
#include "../build/Credits09.h"
#include "../build/Credits10.h"
#include "../build/LogoSprites.h"
#include "../build/CheatSprites.h"
#include "../build/StartSprites.h"
#include "../build/FireSprites.h"
#include "../build/CursorSprite.h"
#include "../build/ArrowSprite.h"
#include "../build/StarFront.h"
#include "../build/StarBack.h"
#include "../build/Sprites.h"
#include "../build/Level1.h"
#include "../build/Level2.h"
#include "../build/Level3.h"
#include "../build/Level4.h"
#include "../build/Level5.h"
#include "../build/Level6.h"
#include "../build/Level7.h"
#include "../build/Level8.h"
#include "../build/Level9.h"
#include "../build/Level10.h"
#include "../build/Level11.h"
#include "../build/Level12.h"
#include "../build/Level13.h"
#include "../build/Level14.h"
#include "../build/Level15.h"
#include "../build/Level16.h"
#include "../build/SpritesLev1.h"
#include "../build/SpritesLev2.h"
#include "../build/SpritesLev3.h"
#include "../build/SpritesLev4.h"
#include "../build/SpritesLev5.h"
#include "../build/SpritesLev6.h"
#include "../build/SpritesLev7.h"
#include "../build/SpritesLev8.h"
#include "../build/SpritesLev9.h"
#include "../build/SpritesLev10.h"
#include "../build/SpritesLev11.h"
#include "../build/SpritesLev12.h"
#include "../build/SpritesLev13.h"
#include "../build/SpritesLev14.h"
#include "../build/SpritesLev15.h"
#include "../build/SpritesLev16.h"
#include "../build/Spritesboss1.h"
#include "../build/Spritesboss2.h"
#include "../build/ExplodeOriginal.h"
#include "../build/ExplodeSkull.h"
#include "../build/ExplodeRing.h"
#include "../build/BossBullets.h"
#include "../build/BossExplode.h"
#include "../build/BBEnergy.h"
#include "../build/Hunters.h"
@ View the VRAM layout at http://dev-scene.com/NDS/Tutorials_Day_4#Background_Memory_Layout_and_VRAM_Management

@ BG0 - Text / Score / Energy
@ BG1 - Level Map
@ BG2 - StarFront
@ BG3 - StarBack

#define BG0_MAP_BASE				27
#define BG0_MAP_BASE_SUB			27

#define BG1_MAP_BASE				30
#define BG1_MAP_BASE_SUB			30

#define BG2_MAP_BASE				29
#define BG2_MAP_BASE_SUB			29

#define BG3_MAP_BASE				28
#define BG3_MAP_BASE_SUB			28

#define BG0_TILE_BASE				3
#define BG0_TILE_BASE_SUB			3

#define BG1_TILE_BASE				0
#define BG1_TILE_BASE_SUB			0

#define BG2_TILE_BASE				5
#define BG2_TILE_BASE_SUB			5

#define BG3_TILE_BASE				5
#define BG3_TILE_BASE_SUB			5

@ star screens
@ BG2 - Starfield
@ BG3 - StarBack

#define STAR_BG2_TILE_BASE			4
#define STAR_BG2_TILE_BASE_SUB		4

#define STAR_BG3_TILE_BASE			1
#define STAR_BG3_TILE_BASE_SUB		1

@ Our background priorities

#define BG0_PRIORITY				0
#define BG1_PRIORITY				1
#define BG2_PRIORITY				2
#define BG3_PRIORITY				3

@ Sprite priority is 1 so it appears below BG0

#define SPRITE_PRIORITY				1

@ Game modes

#define GAMEMODE_STOPPED			0
#define GAMEMODE_RUNNING			1
#define GAMEMODE_PAUSED				2
#define GAMEMODE_LOADING			3
#define GAMEMODE_INTRO				4
#define GAMEMODE_TITLESCREEN		5
#define GAMEMODE_GAMECONTINUE		6
#define GAMEMODE_GETREADY			7
#define GAMEMODE_BOSSDIE			8
#define GAMEMODE_ENDOFLEVEL			9
#define GAMEMODE_GAMEOVER			10
#define GAMEMODE_HISCORE_ENTRY		11
#define GAMEMODE_ENDOFGAME			12
#define GAMEMODE_BIGBOSS_LAVEY		13
#define GAMEMODE_BIGBOSS			14
#define GAMEMODE_CREDITS			15

#define BOSSMODE_CHECK_SCROLL		0
#define BOSSMODE_GET_READY			1
#define BOSSMODE_ATTACK				2
#define BOSSMODE_EXPLODE			3
#define BOSSMODE_EXPLODE_DONE		4

#define BIGBOSSMODE_NONE			0
#define BIGBOSSMODE_SCROLL_ON		1
#define BIGBOSSMODE_MOVE			2
#define BIGBOSSMODE_EXPLODE_INIT	3
#define BIGBOSSMODE_NO_DEATH		4
#define BIGBOSSMODE_MAIN_EXPLODE	5
#define BIGBOSSMODE_ALL_DONE		6
#define BIGBOSSMODE_NO_MORE			7
#define BIGBOSSMODE_FADE_OUT		8

#define LEVELENDMODE_NONE			0
#define LEVELENDMODE_BOSSATTACK		1
#define LEVELENDMODE_BOSSDIE		2
#define LEVELENDMODE_BOSSEXPLODE	3
#define LEVELENDMODE_FADE_OUT		4

#define DEATHMODE_STILL_ACTIVE		0
#define DEATHMODE_DEATH_INIT		1
#define DEATHMODE_MID_EXPLODE		2
#define DEATHMODE_MAIN_EXPLODE		3
#define DEATHMODE_DELAY				4
#define DEATHMODE_ALL_DONE			5
#define DEATHMODE_FADE_OUT			6

@ FX defines. These are bits so we can have multiple fx at once

#define FX_NONE						0
#define FX_SINE_WOBBLE				BIT(0)
#define FX_FADE_IN					BIT(1)
#define FX_FADE_OUT					BIT(2)
#define FX_MOSAIC_IN				BIT(3)
#define FX_MOSAIC_OUT				BIT(4)
#define FX_SPOTLIGHT_IN				BIT(5)
#define FX_SPOTLIGHT_OUT			BIT(6)
#define FX_SCANLINE					BIT(7)
#define FX_WIPE_IN_LEFT				BIT(8)
#define FX_WIPE_IN_RIGHT			BIT(9)
#define FX_WIPE_OUT_UP				BIT(10)
#define FX_WIPE_OUT_DOWN			BIT(11)
#define FX_CROSSWIPE				BIT(12)
#define FX_COLOR_CYCLE				BIT(13)
#define FX_COLOR_PULSE				BIT(14)
#define FX_COPPER_TEXT				BIT(15)
#define FX_COLOR_CYCLE_TEXT			BIT(16)
#define FX_TEXT_SCROLLER			BIT(17)
#define FX_VERTTEXT_SCROLLER		BIT(18)
#define FX_STARFIELD				BIT(19)
#define FX_PALETTE_FADE_TO_RED		BIT(20)
#define FX_STARFIELD_DOWN			BIT(21)
#define FX_STARFIELD_MULTI			BIT(22)
#define FX_FIREWORKS				BIT(23)
#define FX_STARBURST				BIT(24)

@ Sprite types

#define SPRITE_TYPE_MINE			8192
#define SPRITE_TYPE_HUNTER			16384
#define SPRITE_TYPE_ALIENWAVE		32768
#define RANDOM_FIRE					32768

#define SPRITE_ACTIVE_OFFS				0
#define SPRITE_X_OFFS					512
#define SPRITE_Y_OFFS					1024
#define SPRITE_SPEED_X_OFFS				1536
#define SPRITE_SPEED_Y_OFFS				2048
#define SPRITE_SPEED_DELAY_X_OFFS		2560
#define SPRITE_SPEED_DELAY_Y_OFFS		3072
#define SPRITE_SPEED_MAX_OFFS			3584
#define SPRITE_PHASE_OFFS				4096
#define SPRITE_TRACK_X_OFFS				4608
#define SPRITE_TRACK_Y_OFFS				5120
#define SPRITE_OBJ_OFFS					5632
#define SPRITE_HIT_OFFS					6144
#define SPRITE_ANGLE_OFFS				6656
#define SPRITE_EXP_DELAY_OFFS			7168
#define SPRITE_FIRE_TYPE_OFFS			7680
#define SPRITE_FIRE_SPEED_OFFS			10240
#define SPRITE_FIRE_DELAY_OFFS			8192
#define SPRITE_FIRE_MAX_OFFS			8704
#define SPRITE_BLOOM_OFFS				9216
#define SPRITE_IDENT_OFFS				9728
#define SPRITE_BURST_NUM_OFFS			10752
#define SPRITE_BURST_NUM_COUNT_OFFS		11264
#define SPRITE_BURST_DELAY_OFFS			11776
#define SPRITE_BURST_DELAY_COUNT_OFFS	12288
#define SPRITE_SPEED_DELAY_OFFS			12800
#define SPRITE_HORIZ_FLIP_OFFS			13312
#define SPRITE_VERT_FLIP_OFFS			13824
#define SPRITE_EXPLODE_TYPE_OFFS		14336
#define SPRITE_MISC_TYPE_OFFS			14848

@ Screen positions

#define SCREEN_LEFT					64
#define SCREEN_RIGHT				319
#define SCREEN_SUB_WHITESPACE		383
#define SCREEN_SUB_TOP				384
#define SCREEN_SUB_BOTTOM			575
#define SCREEN_MAIN_TOP				576
#define SCREEN_MAIN_BOTTOM			767
#define SCREEN_MAIN_WHITESPACE		768
#define SPRITE_KILL					788+32

@ Colors

#define COLOR_BLACK					0x0000
#define COLOR_WHITE					0x7FFF
#define COLOR_RED					0x001F
#define COLOR_YELLOW				0x03FF
#define COLOR_ORANGE				0x029F
#define COLOR_LIME					0x03E0
#define COLOR_GREEN					0x0200
#define COLOR_CYAN					0x7FE0
#define COLOR_BLUE					0x7C00
#define COLOR_PURPLE				0x4010
#define COLOR_VIOLET				0x761D
#define COLOR_MAGENTA				0x7C1F
#define COLOR_BROWN					0x14B4

@ Levels

#define LEVEL_1						1
#define LEVEL_2						2
#define LEVEL_3						3
#define LEVEL_4						4
#define LEVEL_5						5
#define LEVEL_6						6
#define LEVEL_7						7
#define LEVEL_8						8
#define LEVEL_9						9
#define LEVEL_10					10
#define LEVEL_11					11
#define LEVEL_12					12
#define LEVEL_13					13
#define LEVEL_14					14
#define LEVEL_15					15
#define LEVEL_16					16

#define LEVEL_COUNT					16

@ Option values

#define OPTION_GAMEMODECURRENT_NORMAL		0
#define OPTION_GAMEMODECURRENT_MENTAL		1

#define OPTION_GAMEMODECOMPLETE_NORMAL		BIT(0)
#define OPTION_GAMEMODECOMPLETE_MENTAL		BIT(1)

@ Fade values

#define FADE_NOT_BUSY				0
#define FADE_BUSY					1
