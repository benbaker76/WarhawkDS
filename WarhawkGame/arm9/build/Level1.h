
//{{BLOCK(Level1)

//======================================================================
//
//	Level1, 512x4000@4, 
//	Transparent color : FF,00,FF
//	+ palette 256 entries, not compressed
//	+ 275 tiles (t|f|p reduced) not compressed
//	+ regular map (flat), not compressed, 64x500 
//	Total size: 512 + 8800 + 64000 = 73312
//
//	Time-stamp: 2009-02-04, 04:24:31
//	Exported by Cearn's GBA Image Transmogrifier, v0.8.3
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_LEVEL1_H
#define GRIT_LEVEL1_H

#define Level1TilesLen 8800
extern const unsigned int Level1Tiles[2200];

#define Level1MapLen 64000
extern const unsigned short Level1Map[32000];

#define Level1PalLen 512
extern const unsigned short Level1Pal[256];

#endif // GRIT_LEVEL1_H

//}}BLOCK(Level1)
