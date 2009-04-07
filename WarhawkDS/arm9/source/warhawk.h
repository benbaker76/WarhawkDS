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
#include "../build/LogoSprites.h"
#include "../build/StartSprites.h"
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

#include "../build/ExplodeOriginal.h"
#include "../build/ExplodeSkull.h"

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
#define GAMEMODE_CONTINUEGAME		6
#define GAMEMODE_GETREADY			7
#define GAMEMODE_BOSSDIE			8
#define GAMEMODE_ENDOFLEVEL			9
#define GAMEMODE_GAMEOVER			10
#define GAMEMODE_HISCORE_ENTRY		11

@ Level count

#define LEVEL_COUNT					16

#define AUDIO_PLAY_SOUND			0
#define AUDIO_PLAY_MUSIC			1
#define AUDIO_STOP_MUSIC			2

@ FX defines. These are bits so we can have multiple fx at once

#define FX_NONE						0
#define FX_SINE_WOBBLE				BIT(0)
#define FX_FADE_BLACK_IN			BIT(1)
#define FX_FADE_BLACK_OUT			BIT(2)
#define FX_FADE_WHITE_IN			BIT(3)
#define FX_FADE_WHITE_OUT			BIT(4)
#define FX_MOSAIC_IN				BIT(5)
#define FX_MOSAIC_OUT				BIT(6)
#define FX_SPOTLIGHT_IN				BIT(7)
#define FX_SPOTLIGHT_OUT			BIT(8)
#define FX_SCANLINE					BIT(9)
#define FX_WIPE_IN_LEFT				BIT(10)
#define FX_WIPE_IN_RIGHT			BIT(11)
#define FX_WIPE_OUT_UP				BIT(12)
#define FX_WIPE_OUT_DOWN			BIT(13)
#define FX_CROSSWIPE				BIT(14)
#define FX_COLOR_CYCLE				BIT(15)
#define FX_COPPER_TEXT				BIT(16)
#define FX_COLOR_CYCLE_TEXT			BIT(17)
#define FX_TEXT_SCROLLER			BIT(18)
#define FX_STARFIELD				BIT(19)
#define FX_PALETTE_FADE_TO_RED		BIT(20)

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

#define SCREEN_LEFT					64
#define SCREEN_RIGHT				319
#define SCREEN_SUB_WHITESPACE		383
#define SCREEN_SUB_TOP				384
#define SCREEN_SUB_BOTTOM			575
#define SCREEN_MAIN_TOP				576
#define SCREEN_MAIN_BOTTOM			767
#define SCREEN_MAIN_WHITESPACE		768
#define SPRITE_KILL					788+32
