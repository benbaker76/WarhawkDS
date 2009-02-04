
//{{BLOCK(Meter)

//======================================================================
//
//	Meter, 48x24@8, 
//	Transparent color : FF,00,FF
//	+ palette 256 entries, not compressed
//	+ 3 tiles (t|f|p reduced) not compressed
//	+ regular map (flat), not compressed, 6x3 
//	Total size: 512 + 192 + 36 = 740
//
//	Time-stamp: 2009-02-04, 17:11:47
//	Exported by Cearn's GBA Image Transmogrifier, v0.8.3
//	( http://www.coranac.com/projects/#grit )
//
//======================================================================

#ifndef GRIT_METER_H
#define GRIT_METER_H

#define MeterTilesLen 192
extern const unsigned int MeterTiles[48];

#define MeterMapLen 36
extern const unsigned short MeterMap[18];

#define MeterPalLen 512
extern const unsigned short MeterPal[256];

#endif // GRIT_METER_H

//}}BLOCK(Meter)
