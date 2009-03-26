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


.word 3700,1,3670,1,3640,1,3610,1
.word 3580,1,3550,1,3520,1,3490,1
.word 3400,2,3300,16384,2900,0x00060003,2750,4
.word 2720,4,2690,4,2660,4,2630,4
.word 2600,4,2200,8192,1400,2,1350,0x00060005
.word 1250,0x00070006,1150,0x00080007,1050,0x00090006,950,0x000A0005
.word 850,0x000B0006,750,0x000C0007,650,0x000D0006,0,0
.word 0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0

@lev2	
.space 512
@Lev3
.space 512
@lev4		
.space 512
@lev5
.space 512
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
.space 512
@12
.space 512
@13
.space 512
@14
.space 512
@15
.space 512
@16
.space 512
	
alienWave:
	@ These blocks define what alienDescripts create a attack wave
	@ these are just indexes to the alienDescripts to use. A maximum of
	@ 32 aliens per wave!
	@ The first line must remain 0, this is so alienLevel can use 0 as NOTHING - for ease
	@ set the high 16 of the attack wave to shift it in the X plane.....
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	@ wave 1	@ bouncing (aliens right to left) random track shot
	.word 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 2	@ 4 ships swwep - no shot
	.word 2,3,4,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 3	@ a big ship for level 1
	.word 6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 4	@ some tracking aliens
	.word 26,27,28,29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 5	@ medum ship (using the same aliens here but offsetting them)
	.word 0x0060001E,0x0060001F,0x00600020,0x00600021,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 6
	.word 0x00c0001E,0x00c0001F,0x00c00020,0x00c00021,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 7
	.word 0x0120001E,0x0120001F,0x01200020,0x01200021,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	@ wave ETC...
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	
alienDescript:
	@ The first descript is blank so we can use 0 in alienWave for "no descript"
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@------------------------------------

	@ These are stored in blocks of 32 words --- for however many we use?
@1	- bounce from top right
	.word 0x800001AD,0xFFA00190,-3,0,0x00050003,38,0x00030000,0x00000009
	.word 120,400,90,440,300,520
	.word 90,580,110,620,416,620
	.word 2048,2048,0,0,0,0,0,0,0,0,0,0
@2	
	.word 96,340,4,1024,0,45,0,0
	.word 5,225,4,50,3,116,2,50
	.word 1,250,2048,2048,0,0,0,0
	.word 0,0,0,0,0,0,0,0
@3	
	.word 320,340,4,1024,0,45,0,0
	.word 5,225,6,50,7,116,8,50
	.word 1,250,2048,2048,0,0,0,0
	.word 0,0,0,0,0,0,0,0
@4
	.word 121,290,3,1024,0,45,0,0
	.word 5,275,4,50,3,66,2,50
	.word 1,325,2048,2048,0,0,0,0
	.word 0,0,0,0,0,0,0,0
@5
	.word 295,290,3,1024,0,45,0,0
	.word 5,275,6,50,7,66,8,50
	.word 1,325,2048,2048,0,0,0,0
	.word 0,0,0,0,0,0,0,0
@6-25		big ship
	.word 128,200,2,1024,0,56,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 160,200,2,1024,0,57,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 192,200,2,1024,0,58,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 224,200,2,1024,0,59,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0

	.word 128,232,2,1024,0,48,0x0002000C,0x00160005
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 160,232,2,1024,0,49,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 192,232,2,1024,0,50,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 224,232,2,1024,0,51,0x0002000C,0x00160006
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0

	.word 128,264,2,1024,0,48,0x0004000C,0x00160005
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 160,264,2,1024,0,49,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 192,264,2,1024,0,50,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 224,264,2,1024,0,51,0x0004000C,0x00160006
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0

	.word 128,296,2,1024,0,48,0x0002000C,0x00160005
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 160,296,2,1024,0,49,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 192,296,2,1024,0,50,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 224,296,2,1024,0,51,0x0002000C,0x00160006
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0

	
	.word 128,328,2,1024,0,52,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0x000500A0,0x00030148,2,1024,0,53,0x0003000C,0x0030000F
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0x000500C0,0x00030148,2,1024,0,54,0x0003000C,0x00300010
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 224,328,2,1024,0,55,12,0
	.word 5,250,4,999,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
@26
	.word 128,360,0,0,0x00090003,44,0,0
	.word 1024,1024,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
@27
	.word 288,360,0,0,0x00090003,44,0,0
	.word 1024,1024,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
@28
	.word 178,330,0,0,0x00090003,44,0,0
	.word 1024,1024,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
@29
	.word 238,330,0,0,0x00090003,44,0,0
	.word 1024,1024,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
@30
	.word 0,200,3,1024,0,60,4,0
	.word 5,280,0x00030005,40,0x00020005,200,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0

	.word 32,200,3,1024,0,61,4,0
	.word 5,280,0x00030005,40,0x00020005,200,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0

	.word 0,232,3,1024,0,62,0x00040004,0x00300003
	.word 5,280,0x00030005,40,0x00020005,200,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	
	.word 32,232,3,1024,0,63,0x00040004,0x00300003
	.word 5,280,0x00030005,40,0x00020005,200,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0
@Demo
	@ Alien define structure

	.word 180		@ init X				@ initial X coord (LOW 16)
					@ fire burst amount		@ Amount of bullets to fire in burst (0=none) (HIGH 16)
					@ set random			@ or - set to 32768 for random fire!
	.word 450		@ init y				@ initial Y coord (LOW 16)
					@ fire burst delay		@ delay between burst shots (HIGH 16)
					@ random freq			@ or - set to random level (0000-FFFF = higher is less frequent)
	.word 0 		@ init speed X			@ (this is overal speed in linear mode)
	.word 1024		@ init speed y			@ (set to 1024 to signal linear mode)
	.word 3 		@ init maxSpeed			@ (on ones that attack you - 5 is the fastest) (LOW 16)
											@ (high 16) friction for a curve alien
	.word 35		@ init spriteObj		@ Sprite to use for image
	.word 20		@ init hits to kill		@ lower 16 = Hits (0=one shot)
											@ upper 16 = shot speed (shot)
	.word 19220		@ init 'fire type' 		@ Fire type 0=none (LOW 16)
											@ the rest is delay (UPPER 16)
											@ set delay to 0 for "random fire"
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