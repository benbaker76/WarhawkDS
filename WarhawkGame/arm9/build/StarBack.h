
//{{BLOCK(StarBack)

//======================================================================
//
//	StarBack, 256x3840@8, 
//	+ palette 256 entries, not compressed
//	+ 545 tiles (t|f reduced) not compressed
//	+ regular map (in SBBs), not compressed, 32x480 
//	Total size: 512 + 34880 + 30720 = 66112
//
//	Time-stamp: 2009-01-29, 15:48:33
//	Exported by Cearn's GBA Image Transmogrifier, v0.8.3
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_STARBACK_H
#define GRIT_STARBACK_H

#define StarBackTilesLen 34880
extern const unsigned int StarBackTiles[8720];

#define StarBackMapLen 30720
extern const unsigned short StarBackMap[15360];

#define StarBackPalLen 512
extern const unsigned short StarBackPal[256];

#endif // GRIT_STARBACK_H

//}}BLOCK(StarBack)
