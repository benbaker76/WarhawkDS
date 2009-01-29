
//{{BLOCK(StarFront)

//======================================================================
//
//	StarFront, 256x3840@4, 
//	Transparent color : FF,00,FF
//	+ palette 256 entries, not compressed
//	+ 18 tiles (t|f|p reduced) not compressed
//	+ regular map (in SBBs), not compressed, 32x480 
//	Total size: 512 + 576 + 30720 = 31808
//
//	Time-stamp: 2009-01-29, 15:48:33
//	Exported by Cearn's GBA Image Transmogrifier, v0.8.3
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_STARFRONT_H
#define GRIT_STARFRONT_H

#define StarFrontTilesLen 576
extern const unsigned int StarFrontTiles[144];

#define StarFrontMapLen 30720
extern const unsigned short StarFrontMap[15360];

#define StarFrontPalLen 512
extern const unsigned short StarFrontPal[256];

#endif // GRIT_STARFRONT_H

//}}BLOCK(StarFront)
