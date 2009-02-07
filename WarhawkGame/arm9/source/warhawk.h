@ View the VRAM layout at http://dev-scene.com/NDS/Tutorials_Day_4#Background_Memory_Layout_and_VRAM_Management

@ BG0 - Text / Score / Energy
@ BG1 - Level Map
@ BG2 - StarFront
@ BG3 - StarBack

#define BG0_MAP_BASE				15
#define BG0_MAP_BASE_SUB			17

#define BG1_MAP_BASE				19
#define BG1_MAP_BASE_SUB			21

#define BG2_MAP_BASE				23
#define BG2_MAP_BASE_SUB			25

#define BG3_MAP_BASE				27
#define BG3_MAP_BASE_SUB			29

#define BG0_TILE_BASE				1
#define BG0_TILE_BASE_SUB			1

#define BG1_TILE_BASE				0
#define BG1_TILE_BASE_SUB			0

#define BG2_TILE_BASE				2
#define BG2_TILE_BASE_SUB			2

#define BG3_TILE_BASE				5
#define BG3_TILE_BASE_SUB			5

@ Our background priorities

#define BG0_PRIORITY				0
#define BG1_PRIORITY				1
#define BG2_PRIORITY				2
#define BG3_PRIORITY				3

@ Sprite priority is 1 so it appears below BG0

#define SPRITE_PRIORITY				1

@ We should be #include'ing the generated headers for these values
@ But it will error out because there is some "C" code
@ We should ask the author of grit to add an option to output pure asm headers
@ So we can eg. #include "..\build\StarBack.h" instead of copying out these values

#define StarBackPalLen				512
#define Level1TilesLen				32768
#define CraterTilesLen				544
#define StarFrontTilesLen 			576
#define StarBackTilesLen			34880
#define ScoreTilesLen				1344
#define FontTilesLen				3392
#define EnergyTilesLen				512

#define SpritesTilesLen				33280
#define SpritesPalLen				512

#define InGameMusicLen				851393
#define BlasterSoundLen				5170
#define ExplosionSoundLen			6488

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
