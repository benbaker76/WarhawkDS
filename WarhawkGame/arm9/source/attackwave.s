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

	.arm
	.align
	.data
	
	.global alienDescript
	.global alienWave
	.global alienLevel
	
alienLevel:
	@ These blocks define what alienWave appears and when on each level
	@ 128 words per level
	@ these are pairs, first is "ypossub" and second is "alienWave"
	@ "ypossub" starts at 3744 and ends at 160
	@ the "scroll pos" MUST work backwards, ie. start at level base
	@ to init a mine
	@ set "scroll Pos" as usual, then set the wave to #8192
	@ to init a hunter
	@ set "scroll Pos" as usual, then set the wave to #16384
	@ the upper 16 bits of a wave demote its ident
	@ 0		= no ident				(non tied)
	@ 1-4	= low priority ident 	(1 non tied)
	@ 5+	= low ident				(5 non tied)
@lev1
	.word 3650,16384,3450,1,3060,393219,3060-16,393218,3060-32,393218,3060-48,393218,3060-64,393218,3060-80,393218,3060-96,393218,3060-112,393220,2600,8192,2550,5,2500,5,2450,5,2400,5,2350,5
	.word 2150,6,2000,7,1950,7,1900,7,1850,7,1600,1,1500,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
@lev2	
	.word 3650,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
@Lev3
	.word 3650,393225,3600,458762,3550,524299,3500,589834,3450,655369,3400,458762,3365,8192,3350,524299,3300,589834,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
@lev4		
	.word 3650,12,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
@lev5
	.word 3650,16384,3300,16384,3100,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
@6
.space 512
@7
.space 512
@8
.space 512
@9
.space 512
@10
.space 512
@11
	.word 3650,393225,3600,458762,3550,524299,3500,589834,3450,655369,3400,458762,3365,8192,3350,524299,3300,589834,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
@12
.space 512
@13
.space 512
@14
	.word 3650,16384,3450,1,3060,393219,3060-16,393218,3060-32,393218,3060-48,393218,3060-64,393218,3060-80,393218,3060-96,393218,3060-112,393220,2600,8192,2550,5,2500,5,2450,5,2400,5,2350,5
	.word 2150,6,2000,7,1950,7,1900,7,1850,7,1600,1,1500,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
@15
.space 512
@16
.space 512
	
alienWave:
	@ These blocks define what alienDescripts create a attack wave
	@ these are just indexes to the alienDescripts to use. A maximum of
	@ 32 aliens per wave!
	@ The first line must remain 0, this is so alienLevel can use 0 as NOTHING - for ease
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	@ wave 1
	.word 1,2,3,4,5,6,7,8,9,10,11,12,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 2
	.word 13,14,15,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 3
	.word 17,18,19,20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 4
	.word 21,22,23,24,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 5
	.word 25,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 6
	.word 26,27,28,29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 7
	.word 30,25,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 8	-	Bullet test wave
	.word 32,31,33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 9
	.word 34,35,36,37,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 10
	.word 38,39,40,41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 11
	.word 42,43,44,45,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 12	-	Bullet test wave 2
	.word 46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave ETC...
	
alienDescript:
	@ The first descript is blank so we can use 0 in alienWave for "no descript"

	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	@ These are stored in blocks of 32 words --- for however many we use?
@1
	.word 90,120,1,1024,0,47,0,0					@ inits	01100100 00010011	= type 19, delay 100
	.word 5,280,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@2	
	.word 90,140,1,1024,0,47,0,0					@ inits
	.word 5,260,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@3	
	.word 90,160,1,1024,0,47,0,0					@ inits
	.word 5,240,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@4	
	.word 90,180,1,1024,0,47,0,0					@ inits
	.word 5,220,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@5	
	.word 90,200,1,1024,0,47,0,0					@ inits
	.word 5,200,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@6	
	.word 90,220,1,1024,0,47,0,0					@ inits
	.word 5,180,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@7	
	.word 90,240,1,1024,0,47,0,0					@ inits
	.word 5,160,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@8	
	.word 90,260,1,1024,0,47,0,0					@ inits
	.word 5,140,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@9	
	.word 90,280,1,1024,0,47,0,0					@ inits
	.word 5,120,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@10	
	.word 90,300,1,1024,0,47,0,0					@ inits
	.word 5,100,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@11	
	.word 90,320,1,1024,0,47,0,0					@ inits
	.word 5,80,4,50,3,50,4,50,5,50,6,50				@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@12	
	.word 90,340,1,1024,0,47,0,0					@ inits
	.word 5,60,4,50,3,50,4,50,5,50,6,50				@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
@13 @	
	.word 180,300,2,1024,0,48,0x3FFFF,0x2806			@ fire is 50 delay and fire left (fire type 6)
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@14	
	.word 212,300,2,1024,0,49,2048,0					@ inits
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@15	
	.word 244,300,2,1024,0,50,2048,0					@ inits
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@16	@
	.word 276,300,2,1024,0,51,0x3FFFF,0x2805				@ fire is 50 delay and fire right (fire type 5) 00110010 00000101
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@17	
	.word 180,300,2,1024,0,52,2048,0					@ inits
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@18	
	.word 212,300,2,1024,0,53,0x4FFFF,0x2803 		@ fie is 40 delay and fire down (fire type 7) 00101000 00000111
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@19	
	.word 244,300,2,1024,0,54,0x4FFFF,0x2803		@ inits
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@20	
	.word 276,300,2,1024,0,55,200,0					@ inits
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@21	
	.word 180,300,2,1024,0,56,2048,0					@ inits
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@22	
	.word 212,300,2,1024,0,57,200,0 				@ inits
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@23	
	.word 244,300,2,1024,0,58,200,0 				@ inits
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@24	
	.word 276,300,2,1024,0,59,200,0 				@ inits
	.word 5,800,0,0,0,0,0,0,0,0,0,0					@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@25
	.word 320,360,0,0,3,46,0x30004,0x2803			@ inits
	.word 280,400,200,420,200,460,1024,1024,0,0,0,0	@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@26	
	.word 32,576,1,1024,0,42,0,0					@ inits
	.word 3,383,2048,2048,0,0,0,0,0,0,0,0			@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@27	
	.word 32,576+22,2,1024,0,42,0,0					@ inits
	.word 3,383,2048,2048,0,0,0,0,0,0,0,0			@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@28	
	.word 383,576+44,2,1024,0,42,0,0				@ inits
	.word 7,383,2048,2048,0,0,0,0,0,0,0,0			@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@29	
	.word 383,576+66,1,1024,0,42,0,0							@ inits
	.word 7,383,2048,2048,0,0,0,0,0,0,0,0						@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@30
	.word 63+32,360,0,0,3,46,0x30004,25623								@ inits
	.word 103+32,400,183+32,420,183+32,460,1024,1024,0,0,0,0	@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0	
@31	-	Accellerator bullet tester
	.word 150,450,1,1024,0,43,20,0x280A							@ inits
	.word 7,50,3,50,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0	
@32	-	TRiple shot bullet tester
	.word 250,451,0,1024,0,44,0x40014,0x4812					@ inits	- bullet 10100 00010101
	.word 3,50,7,50,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0	
@33	-	Mine shot bullet tester
	.word 200,400,1,1024,0,37,20,0x320D							@ inits	- bullet 10100 00010101
	.word 3,60,7,120,3,60,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@34	-	 4 sprite alien with double ripple shot
	.word 100,200,2,1024,0,42,200,0							@ inits	- bullet 10100 00010101
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@35	-	
	.word 132,200,2,1024,0,43,200,0							@ inits	- bullet 10100 00010101
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@36	-	
	.word 100,232,2,1024,0,44,0x4FFFF,0x320F							@ inits	- bullet 10100 00010101
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@37	-	
	.word 132,232,2,1024,0,45,0x4FFFF,0x3210							@ inits	- bullet 10100 00010101
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@38	-	 4 sprite alien with double ripple shot
	.word 200,200,2,1024,0,42,200,0							@ inits	- bullet 10100 00010101
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@39	-	
	.word 232,200,2,1024,0,43,200,0							@ inits	- bullet 10100 00010101
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@40	-	
	.word 200,232,2,1024,0,44,0x4FFFF,0x320F							@ inits	- bullet 10100 00010101
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@41	-	
	.word 232,232,2,1024,0,45,0x4FFFF,0x3210							@ inits	- bullet 10100 00010101
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@42	-	 4 sprite alien with double ripple shot
	.word 300,200,2,1024,0,50,200,0								@ inits
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@43	-	
	.word 332,200,2,1024,0,51,200,0								@ inits
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@44	-	
	.word 300,232,2,1024,0,52,0x4FFFF,0x320F					@ inits
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@44	-	
	.word 332,232,2,1024,0,53,0x4FFFF,0x3210					@ inits
	.word 5,600,0,0,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0
@46	-	DIRECT bullet tester
	.word 150,451,0,1024,0,1,0x40014,0x0F11					@ inits	- bullet 10100 00010101
	.word 3,50,7,50,0,0,0,0,0,0,0,0								@ Track points
	.word 0,0,0,0,0,0,0,0,0,0,0,0	

@34
	@ Alien define structure

	.word 180		@ init X				@ initial X coord
	.word 450		@ init y				@ initial Y coord
	.word 0 		@ init speed X			@ (this is overal speed in linear mode)
	.word 1024		@ init speed y			@ (set to 1024 to signal linear mode)
	.word 3 		@ init maxSpeed			@ (on ones that attack you - 5 is the fastest)
	.word 35		@ init spriteObj		@ Sprite to use for image
	.word 20		@ init hits to kill		@ lower 16 = Hits (0=one shot)
											@ upper 16 = shot speed
	.word 19220		@ init 'fire type' 		@ Lower 8 bits = type, 0=none
											@ the rest is delay (shifted 8 left)
	.word 0,0		@ track x,y 1			@ tracking coordinate (as in coords.png)
	.word 0,0		@ track x,y 2
	.word 0,0		@ track x,y 3
	.word 0,0		@ etc.....
	.word 215,660	@ make any track 1024 to attack your ship on that vertices
	.word 230,384	@ (in linear mode these are direction, distance, "speed x" is speed)
	.word 1024,1024	@ you can make them trackers at any time on any axis.. :)
	.word 0,0		@ make them 0 and the wave will loop to the begining
	.word 0,0		@ make them 2048 to kill the alien (spriteActive=0)
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed
	.word 0,0		@ if not, the pattern will loop forever

	.pool
	.end

Auto KIll

Perhaps adding a track value of 2048 will instantly kill the alien. This could be handy for taking
an alien off the side of the screen for both trackers and linear?


one thing we do need to think about is the other attack types in Warhawk
we could have seperate code for each, I really do not know how to fit them in at the moment

Each level will have a wavePattern desctription

This will be 2 words per wave

- Scroll_pos, attackWave

So, at a certain point, wave X will be initialised.

Each wave is constructed of 32 words, each word is a pointer to the number of a alienDescript with
0 signalling "no Alien" (we need to sub 1 to get correct wave)
So, each wave can have 32 aliens in it. too many???? Please let me know!

So, back to the Warhawk special waves

1 = mines. These randomly fall from the top of the screen at a random X coord
2 = Trackers	These have 3 phases
			1 = random X, fall down screen and lock onto your Y coord and change direction
			2 = as above, except, when their x matches yours, and y is less than they move up
			3 = as 2, except they move up or down on a x match
3 = Powerup(s)
			This is dropped from a shot (special) ship from level 3 onwards.
			shoot ship to release power up, shooting power up kills it!!
			
We could use attackWave with an unreachable value to signal these? Ie. 10000000,10000001,10000002, etc

We may also need to add a spriteType to global.s to enable collision detection to know what power up
is collected, or that an alien is now a SAFE explosion, and to tell drawsprite.s to animate it!

Oh, well - that is my rambling from a fool all done with (for now! ha ha ha ha ha! <manically>)