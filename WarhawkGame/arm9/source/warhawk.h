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

@ FX defines. These are bits so we can have multiple fx at once

#define FX_STOP						0
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

@ We should be #includeing the generated headers for these values
@ But it will error out because there is some "C" code
@ We should ask the author of grit to add an option to output pure asm headers
@ So we can eg. #include "..\build\StarBack.h" instead of copying out these values

#define StarBackPalLen				512
#define Level1TilesLen				49152
#define CraterTilesLen				544
#define StarFrontTilesLen 			576
#define StarBackTilesLen			15008
#define ScoreTilesLen				1344
#define FontTilesLen				3392
#define EnergyTilesLen				512

#define SpritesTilesLen				37888
#define SpritesPalLen				512

#define InGameMusicLen				851393
#define BlasterLen					5170
#define ExplosionLen				6488
#define AlienExplodeLen				6709
#define AlienExplodeScreamLen		8080
#define ElecShotLen					7916
#define LaserShotLen				4401
#define ShipArmourHit1Len			2452
#define ShipArmourHit2Len			1074
#define ClassicLen					999
#define CrashBuzLen					9115
#define DinkDinkLen					14752
#define HitWallLen					4133
#define LowLen						3840
#define SteelLen					1893

#define typeMine					8192
#define typeHunter					16384

#define sptActiveOffs				0
#define sptXOffs					512
#define sptYOffs					1024
#define sptSpdXOffs					1536
#define sptSpdYOffs					2048
#define sptSpdDelayXOffs			2560
#define sptSpdDelayYOffs			3072
#define sptMaxSpdOffs				3584
#define sptPhaseOffs				4096
#define sptTrackXOffs				4608
#define sptTrackYOffs				5120
#define sptObjOffs					5632
#define sptHitsOffs					6144
#define sptAngleOffs				6656
#define sptExpDelayOffs				7168
#define sptFireTypeOffs				7680
#define sptFireDlyOffs				8192
#define sptFireMaxOffs				8704
#define sptBloomOffs				9216
#define sptIdentOffs				9728
#define sptFireSpdOffs				10240