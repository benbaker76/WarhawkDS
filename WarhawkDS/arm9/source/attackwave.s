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
.space 512
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
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	@ wave 1
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@ wave 2
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


	@ wave ETC...
	
alienDescript:
	@ The first descript is blank so we can use 0 in alienWave for "no descript"

	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	@ These are stored in blocks of 32 words --- for however many we use?
@1
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
@2	
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
@3	
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0



@Demo
	@ Alien define structure

	.word 180		@ init X				@ initial X coord (LOW 16)
					@ fire burst amount		@ Amount of bullets to fire in burst (0=none) (HIGH 16)
					@ set random			@ or - set to 32768 for random fire!
	.word 450		@ init y				@ initial Y coord (LOW 16)
					@ fire burst delay		@ delay between burst shots (HIGH 16)
					@ random freq			@ or - set to random level (0-8191 = higher is less)
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