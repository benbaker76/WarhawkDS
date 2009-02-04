
//{{BLOCK(Level1)

//======================================================================
//
//	Level1, 512x4000@4, 
//	Transparent color : FF,00,FF
//	+ palette 256 entries, not compressed
//	+ 480 tiles (t|f|p reduced) not compressed
//	+ regular map (flat), not compressed, 64x500 
//	Total size: 512 + 15360 + 64000 = 79872
//
//	Time-stamp: 2009-02-04, 17:11:46
//	Exported by Cearn's GBA Image Transmogrifier, v0.8.3
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_LEVEL1_H
#define GRIT_LEVEL1_H

#define Level1TilesLen 15360
extern const unsigned int Level1Tiles[3840];

#define Level1MapLen 64000
extern const unsigned short Level1Map[32000];

#define Level1PalLen 512
extern const unsigned short Level1Pal[256];

#endif // GRIT_LEVEL1_H

//}}BLOCK(Level1)
