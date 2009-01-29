
//{{BLOCK(Level1)

//======================================================================
//
//	Level1, 512x4096@4, 
//	Transparent color : FF,00,FF
//	+ palette 256 entries, not compressed
//	+ 288 tiles (t|f|p reduced) not compressed
//	+ regular map (in SBBs), not compressed, 64x512 
//	Total size: 512 + 9216 + 65536 = 75264
//
//	Time-stamp: 2009-01-29, 15:48:32
//	Exported by Cearn's GBA Image Transmogrifier, v0.8.3
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_LEVEL1_H
#define GRIT_LEVEL1_H

#define Level1TilesLen 9216
extern const unsigned int Level1Tiles[2304];

#define Level1MapLen 65536
extern const unsigned short Level1Map[32768];

#define Level1PalLen 512
extern const unsigned short Level1Pal[256];

#endif // GRIT_LEVEL1_H

//}}BLOCK(Level1)
