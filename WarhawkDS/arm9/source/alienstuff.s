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

#include "warhawk.h"
#include "video.h"
#include "sprite.h"


	.arm
	.align
	.text
	.global checkWave
	.global moveAliens
	.global initHunterMine
	.global animateAliens
	.global initAlien
	.global explodeIdentAlien

checkWave:		@ CHECK AND INITIALISE ANY ALIEN WAVES AS NEEDED
	stmfd sp!, {r0-r10, lr}
	@ Check our ypossub against the current alienLevel data
	@ if there is a match, init the alien wave
	@ waveNumber is the digit we need to use to pull the data
	ldr r1,=waveNumber
	ldr r3,[r1]						@ r3=current wave number to look for

	cmp r3,#127
	ble waveInitPossible
	ldmfd sp!, {r0-r10, pc}

	waveInitPossible:

	ldr r2,=alienLevel
	ldr r4,=levelNum				@ we need to modify alienLevel based on game level
	ldr r4,[r4]						@ r4=current level
	sub r4,#1

	add r2,r4, lsl #10				@ add to alienLevel, LEVEL*1024 (256 words)
	
	ldr r5,[r2, r3, lsl #3]		@ r5=current alien level scroll used to generate
	cmp r5,#0						@ if the scroll is 0, then All done!
	bne readyToInit

	ldmfd sp!, {r0-r10, pc}

	readyToInit:

	ldr r4,=yposSub				
	ldr r4,[r4]						@ r4= our scroll position
	cmp r5,r4						@ is this the same as r5?
	beq initWave					@ if so, we are ready to go :)
	ldmfd sp!, {r0-r10, pc}			@ if not, lets just go to main loop
	
	initWave:
		add r2,#4					@ ok, add 4 (1 word) to r2
		ldr r4,[r2, r3, lsl #3] 	@ r4 is now the attack wave number to init	
		add r3,#1					@ add 1 to wave number
		str r3,[r1]					@ and store it back

		cmp r4,#0					@ if the wave is 0, then there is no need to init one!
		beq initWaveAliensDone
	
		@ we need to strip the ident from r4
		
		ldr r5,=0xffff
		and r7,r4,r5				@ r7= alien type (lower 16 bits)
		sub r4,r7
		lsr r4,#16					@ r4= ident
		mov r6,r4					@ move to r6 for later

	cmp r7,#SPRITE_TYPE_MINE		@ Check for a "MINE FIELD" request
	bne noMines
				ldr r4,=mineTimerCounter
				mov r6,#600									@ set duration of mines to init (Base this on LEVEL)
				str r6,[r4]
				ldr r4,=mineDelay
				mov r6,#0
				str r6,[r4]									@ set delay to 0 (the mine code handles the rest)
				b initWaveAliensDone
	noMines:
	cmp r7,#SPRITE_TYPE_HUNTER								@ Check for a "HUNTER" request
	bne noHunter
				ldr r4,=hunterTimerCounter
				mov r6,#600									@ set duration of hunters to init (Base this on LEVEL)
				str r6,[r4]
				ldr r4,=hunterDelay
				mov r6,#0
				str r6,[r4]									@ set delay to 0 (the hunter code handles the rest)
				b initWaveAliensDone	
	noHunter:
		@ from here on in, we know that it is a normal attack
		@ now we need to make r2 the index to the start of attack wave r7
		@ r4 = ident, 0 is none!!
		ldr r2,=alienWave
		add r2, r7, lsl #7				@ add r2=r7*128 (each wave is 32 words)
		mov r3,#0						@ counter to get the data an init them
		initWaveAliens:					@ we need to pass r1 to initAliens to start them
			ldr r1,[r2,r3, lsl #2]		@ r1+alien number*4 (one word each)
			cmp r1,#0
			beq initWaveAliensDone		@ if the alien descript is 0, that is it!
				bl initAlien
				add r3,#1
				cmp r3,#32
			bne initWaveAliens
	initWaveAliensDone:
	ldmfd sp!, {r0-r10, pc}	
	
initAlien:	@ ----------------This code will find a blank alien sprite and assign it
	stmfd sp!, {r0-r10, lr}

								@ set r1 to the alien movement number you wish to activate
	@ the high 16 of r1 is used as an X offset.... so, we need to strip it...
	mov r9,r1, lsr #16			@ r9 is now an offset for the x plane....
	ldr r8,=0xFFFF
	and r1,r8
	
	ldr r4,=alienDescript		@ r4=LOCATION OF ALIEN DESCRIPTION
	add r4,r1, lsl #7			@ add it to aliendescrip so we know where to grab from
								@ now er need to find a blank alien
	ldr r3,=spriteActive+68		@ IS +68 CORRECT, SOMEHOW AN ALIEN IS BECOMING A BULLET??
								@ IT IS, SO WHAT IS IT????
cmp r6,#5
bpl initReversed

	mov r0,#63					@ SPRITE R0 points to the sprite that will be used for the alien
								@ we need to use a loop here to FIND a spare sprite
								@ and this will be used to init the alien!!
	findSpaceLoop:
		ldr r2,[r3,r0, lsl #2]
		cmp r2,#0
		beq foundSpace
		subs r0,#1
	bpl findSpaceLoop
	
		ldmfd sp!, {r0-r10, pc}@ No space for the alien, so lets exit!

initReversed:					@	We scan from start to finish here to find spare slots
	mov r0,#0					@ SPRITE R0 points to the sprite that will be used for the alien
								@ we need to use a loop here to FIND a spare sprite
								@ and this will be used to init the alien!!
	findSpaceLoopRev:
		ldr r2,[r3,r0, lsl #2]
		cmp r2,#0
		beq foundSpace
		add r0,#1
		cmp r0,#64
	bne findSpaceLoopRev
	@ ok, we found nothing :( But is the Ship an IDENT that needs space?
	cmp r6, #6
	blt notAnIdent

@ there may be a problem here that causes normal aliens to colide and kill other aliens?
@ it is a blead somewhere in the init? hmmmmm....

	mov r0,#0
	findSpaceExplodeLoop:
		ldr r2,[r3,r0, lsl #2]
		cmp r2,#11					@ player explosion
		beq spaceIsExplosion
		cmp r2,#12					@ player explosion (slow)
		beq spaceIsExplosion
		cmp r2,#4					@ alien Explosion
		beq spaceIsExplosion
		b findSpaceExplodeLoopCount
			spaceIsExplosion:
			ldr r2,=spriteObj+68
			ldr r2,[r2,r0, lsl #2]
			cmp r2,#8				@ r2 = explosion frame (7-14)
			bgt foundSpace
			cmp r2,#0
			beq foundSpace
		findSpaceExplodeLoopCount:
		add r0,#1
		cmp r0,#64
	bne findSpaceExplodeLoop
	notAnIdent:
	
		ldmfd sp!, {r0-r10, pc}	@ No space for the alien, so lets exit!	
		
	foundSpace:

	mov r5,r0					@ store the sprite number for later retrieval
	
	add r3,r0, lsl #2
	mov r2,#1
	str r2,[r3]					@ activate Sprite

	mov r0,#SPRITE_IDENT_OFFS
	str r6,[r3,r0]				@ store the sprite ident (r6 set earlier)
	ldr r6,=0xffff				@ use for anding
	mov r1,#0					@ r1=REF to alienDescript data (just add to this)
								@ Now we will dump the data in our sprite table
	ldr r0,=SPRITE_X_OFFS
	ldr r2,[r4,r1]
	and r2,r6
	add r2,r9					@ add the wave X offset
	str r2,[r3,r0]				@ store X coord
	ldr r2,[r4,r1]
	lsr r2,#16
	ldr r0,=SPRITE_BURST_NUM_OFFS
	str r2,[r3,r0]
	ldr r0,=SPRITE_BURST_NUM_COUNT_OFFS
	str r2,[r3,r0]				@ store burst fire number and backup

	
	add r1,#4
	ldr r0,=SPRITE_Y_OFFS
	ldr r2,[r4,r1]
	and r2,r6
	str r2,[r3,r0]				@ store y coord
	ldr r2,[r4,r1]
	lsr r2,#16
	ldr r0,=SPRITE_BURST_DELAY_OFFS
	str r2,[r3,r0]
	ldr r0,=SPRITE_BURST_DELAY_COUNT_OFFS
	str r2,[r3,r0]				@ store burst fire delay and backup	
	
	add r1,#4
	ldr r0,=SPRITE_SPEED_X_OFFS
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store initial X speed
	
	add r1,#4
	ldr r0,=SPRITE_SPEED_Y_OFFS
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store initial Y speed

	mov r2,#12
	ldr r0,=SPRITE_SPEED_DELAY_X_OFFS
	str r2,[r3,r0]				@ store speed delay x (start at 12) (use for inc/dec on x speed)
	ldr r0,=SPRITE_SPEED_DELAY_Y_OFFS
	str r2,[r3,r0]				@ store speed delay Y (start at 12) (use for inc/dec on y speed)

	add r1,#4
	ldr r0,=SPRITE_SPEED_MAX_OFFS
	ldr r2,[r4,r1]
	and r2,r6
	str r2,[r3,r0]				@ store sprites maximum speed (low 16)
	ldr r2,[r4,r1]
	lsr r2,#16
	cmp r2,#0
	moveq r2,#5
	ldr r0,=SPRITE_SPEED_DELAY_OFFS
	str r2,[r3,r0]

	add r1,#4
	mov r0,#SPRITE_OBJ_OFFS
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store sprites Object (Image)
	
	add r1,#4
	ldr r2,[r4,r1]				@ this value is split as 2 16bit words
	and r2,r6
	mov r0,#SPRITE_HIT_OFFS
	str r2,[r3,r0]				@ store sprites hits to kill (lower 16)
	ldr r2,[r4,r1]
	lsr r2,#16
	mov r0,#SPRITE_FIRE_SPEED_OFFS
	str r2,[r3,r0]				@ store sprites shot speed (upper 16)

	add r1,#4					@ Move our pointer to the shot setting
	ldr r2,[r4,r1]
	and r2,r6					@ r7= shot type (lower 16)
	mov r0,#SPRITE_FIRE_TYPE_OFFS
	str r2,[r3,r0]				@ store the byte value of the Fire Type
	ldr r2,[r4,r1]
	lsr r2,#16					@ r2= shot delay (upper 16)
	mov r0,#SPRITE_FIRE_MAX_OFFS
	str r2,[r3,r0]				@ store the fire delay maximum value for use later
	mov r2,#0
	mov r0,#SPRITE_FIRE_DELAY_OFFS
	str r2,[r3,r0]				@ set our counter to 0, this is our countdown

	mov r0,#SPRITE_ANGLE_OFFS
	str r2,[r3,r0]				@ store sprite angle (0 init) (WILL WE USE THIS? er - i have, for flags)
	mov r0,#SPRITE_BLOOM_OFFS
	str r2,[r3,r0]				@ make sure the "bloom" is set to 0 (palette number)
	ldr r0,=SPRITE_PHASE_OFFS
	str r2,[r3,r0]				@ store sprite data phase (always start at 0)

	mov r0,#SPRITE_TRACK_X_OFFS	@ coord (X) - need to grab this from alienDescript
	mov r1,#32
	ldr r2,[r4,r1]				@ load alien descript +32 = init track x
	str r2,[r3,r0]				@ store first track X
	mov r0,#SPRITE_TRACK_Y_OFFS
	mov r1,#36
	ldr r2,[r4,r1]				@ load alien descript +36 = init track y
	str r2,[r3,r0]				@ store first track 

	ldr r2,=spriteInstruct	
	add r2,r5, lsl #7			@ the sprite number was stored in R5 earlier
	mov r1,#127					@ 128 bytes or 32 words for alien track data
	initLoop:
		ldrb r3,[r4,r1]		@ load from alienDescript
		strb r3,[r2,r1]		@ store in spriteInstruct
	subs r1,#1				
	bpl initLoop				@ repeat
	
	ldmfd sp!, {r0-r10, pc}
	
@---------------------------------------------------------------------------------	
	
moveAliens:	@ OUR CODE TO MOVE OUR ACTIVE ALIENS
	@ the data is only set to allow 32 aliens at any one time
	@ we will have to see how much time (raster) we have when detection is going
	@ to see if we can add more
	stmfd sp!, {r0-r10, lr}
		
	ldr r0,=deathMode
	ldr r0,[r0]
	cmp r0,#DEATHMODE_ALL_DONE
	blt moveAlienActive
		ldmfd sp!, {r0-r10, pc}
	moveAlienActive:

	mov r7,#63						@ 64 aliens! (63-0)
	moveAlienLoop:

		@ calculate r1 to be the alien sprite pointer to use
		ldr r1,=spriteActive+68		@ add 68 (17*4) for start of aliens
	
		ldr r0,[r1,r7, lsl #2]
		cmp r0,#0					@ r0 = spriteActive Value
		beq noAlienMove

		add r1,r7, lsl #2

		cmp r0,#256
		bge bossFireCheckThing

	@
	@	We will need to do checks here for special alien types
	@	2=mines, 3=hunter, 
	@	this will be stored in r0
	@
	@ if alien type is a 1, Carry on from here
	@ as it must be a linear or tracking alien
	@ r1 is now offset to start of alien data
	@ use r0 as offset to this (+512 per field)
	
	cmp r0,#2					@ check if this is a mine?
		bne mineNot				@ if not, carry on
		bl moveMine				@ move the mine based on y speed
		b doDetect				@ and we are done
		
	mineNot:
	cmp r0,#3					@ check if this is a tracker?
		bne hunterNot
		bl moveHunter			@ move the tracker
		b doDetect
	
	hunterNot:
	cmp r0,#10					@ is it a powerup!!?
	beq doDetect				@ if so, we dont need to do anything here (except detection)
	
	cmp r0,#9					@ is it a dropship?
	beq alienPassed				@ if so, do nothing (we will detect this seperate to allow crash-collecting)
	
	cmp r0,#1					@ if it is not a 1, it is not an alien
	bne noAlienMove

		mov r0,#SPRITE_SPEED_Y_OFFS		@ we use Initial Y speed as a variable to tell use what
		ldr r10,[r1,r0]				@ type of alien to move (Linear or curved/tracker)
		
		cmp r10,#1024
			bne trackTest
				bl aliensLinear
				b alienPassed
			trackTest:
				bl aliensTracker
		alienPassed:
		
bossFireCheckThing:		
		
		mov r0,#SPRITE_Y_OFFS
		ldr r10,[r1,r0]		
		cmp r10,#SPRITE_KILL				@ check if alien off screen - and avoid any more code
		bpl noAlienMove
		@
		@	This is where we need to check for alien fire and init if needed
		@	sptFireTypeOffs = fire type (0=none) this is our first check


			mov r0,#SPRITE_FIRE_TYPE_OFFS
			ldr r3,[r1,r0]				@ load fire type (keep r3 as we use it later)
			cmp r3,#0					@ is it a firing alien?
			beq doDetect				@ if not, that is it!

		@	
		@	Now, we need to update the fire delay to see if it is time to fire
		@	but also account for burst fire and random fire!
		@
		
			mov r0,#SPRITE_FIRE_DELAY_OFFS
			ldr r9,[r1,r0]				@ get fire delay
			subs r9,#1					@ take 1 off the count
			str r9,[r1,r0]				@ put it back
			bpl doDetect				@ if this is not 0, do nothing

				mov r9,#0
				str r9,[r1,r0]			@ set to 0
			
				mov r0,#SPRITE_BURST_NUM_COUNT_OFFS
				ldr r9,[r1,r0]							@ load "backup" burst number
				cmp r9,#0								@ if this is "0", no need for burst!
				beq fireAsNormal						@ so it is a standart timed shot
				cmp r9,#RANDOM_FIRE						@ check if random fire?
				bne notRandomFire
					@ ok, we need to grab "burst delay" and get a random number
					@ if this is >= "burst delay" then FIRE!!!
					mov r0,#SPRITE_BURST_DELAY_COUNT_OFFS
					ldr r9,[r1,r0]
					bl getRandom
					lsr r8,#16			@ r8 = halfword
					cmp r8,r9			@ if the random number is > than your number = FIRE
					blt doDetect
					b fireAsNormal

				notRandomFire:
					
					mov r0,#SPRITE_BURST_DELAY_OFFS		@ load the burst delay
					ldr r9,[r1,r0]
					subs r9,#1							@ decrement the counter
					str r9,[r1,r0]						@ store it back
					bpl doDetect						@ if not time, dont fire
					
					mov r2,#SPRITE_BURST_DELAY_COUNT_OFFS
					ldr r9,[r1,r2]
					str r9,[r1,r0]						@ reset the delay
					
					mov r0,#SPRITE_BURST_NUM_OFFS		@ load the shots to fire
					ldr r9,[r1,r0]
					cmp r9,#0							@ have we any shots left?
					bne fireBurstShot
						@ burst of shots has finished, so reset counters
						mov r2,#SPRITE_BURST_NUM_COUNT_OFFS
						ldr r9,[r1,r2]
						str r9,[r1,r0]					@ reset the number of burst shots
						mov r0,#SPRITE_FIRE_DELAY_OFFS
						mov r2,#SPRITE_FIRE_MAX_OFFS
						ldr r9,[r1,r2]			@ load the delay max
						str r9,[r1,r0]			@ and reset the counter
						b doDetect
					fireBurstShot:
					subs r9,#1
					str r9,[r1,r0]
					mov r2,#SPRITE_BURST_DELAY_COUNT_OFFS
					ldr r9,[r1,r2]						@ load reset value
					mov r0,#SPRITE_BURST_DELAY_OFFS		@ load the burst delay
					str r9,[r1,r0]						@ reset the delay						
					b fireAlienShotNow
						
				fireAsNormal:
				mov r0,#SPRITE_FIRE_DELAY_OFFS
				mov r2,#SPRITE_FIRE_MAX_OFFS
				ldr r9,[r1,r2]			@ load the delay max
				str r9,[r1,r0]			@ and reset the counter
				fireAlienShotNow:
										@ r10= y coord of alien (we grabbed this earlier)
				cmp r10,#384-48			@ Make sure alien is at least NEARLY on screen before firing
				bmi doDetect			@ if no, just forget it
				bl alienFireInit		@ time to fire, r3=fire type, r1=offset to alien
				
				
				
			doDetect:
				@ ok, now we need to check if this alien has hit YOU!!
				@ r1 is alien base offset!
			
				bl alienCollideCheck		

		noAlienMove:
		subs r7,#1
	bpl moveAlienLoop
	
	ldmfd sp!, {r0-r10, pc}
	
@-------------- THIS CODE IS ONLY FOR LINEAR ALIENS
aliensLinear:
	stmfd sp!, {r0-r10, lr}
	@ do not touch r7 or r1
	mov r0,#SPRITE_TRACK_X_OFFS
	ldr r10,[r1,r0]		@ r10 is now our direction (0-7)
	mov r0,#SPRITE_TRACK_Y_OFFS
	ldr r11,[r1,r0]		@ r11 = distance to travel	(1-x)
	mov r0,#SPRITE_SPEED_X_OFFS
	ldr r12,[r1,r0]		@ r12 = speed of travel
	@ first do our code to move in the direction
	@ then decrement r11 (distance) and if <0 load new tracking
	cmp r10,#1	@ up
		bne linPass1
			mov r0,#SPRITE_Y_OFFS
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass1:
	cmp r10,#2	@ up/Right
		bne linPass2
			mov r0,#SPRITE_Y_OFFS
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]		
			mov r0,#SPRITE_X_OFFS
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass2:	
	cmp r10,#3	@ Right
		bne linPass3
			mov r0,#SPRITE_X_OFFS
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass3:
	cmp r10,#4 @ Right/Down
		bne linPass4
			mov r0,#SPRITE_X_OFFS
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]	
			mov r0,#SPRITE_Y_OFFS
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass4:
	cmp r10,#5 @ Down
		bne linPass5
			mov r0,#SPRITE_Y_OFFS
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass5:
	cmp r10,#6 @ Down/Left
		bne linPass6
			mov r0,#SPRITE_X_OFFS
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]	
			mov r0,#SPRITE_Y_OFFS
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass6:
	cmp r10,#7 @ Left
		bne linPass7
			mov r0,#SPRITE_X_OFFS
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass7:
				@ Up/Left
			mov r0,#SPRITE_X_OFFS
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]	
			mov r0,#SPRITE_Y_OFFS
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]
	cmp r10,#2048
		beq killTracker
	linPass8:
	mov r0,#SPRITE_TRACK_Y_OFFS
	cmp r12,#0
	subeq r11,#1
	subs r11,r12		@ take speed off our distance to travel
	str r11,[r1,r0]	@ store it back
	cmp r11,#0
	bmi linearNew		@ if moves done, get another pair of instruction
 
	ldmfd sp!, {r0-r10, pc}	

	linearNew:
	
	ldr r2,=spriteInstruct	
	add r2, r7, lsl #7		@ add sprite number * 128
	add r2, #32				@ r2 = first instruction in spriteInstruct
	
	mov r0,#SPRITE_PHASE_OFFS	@ Now, increase our phase position
	ldr r3,[r1,r0]			@ r3 = phase number
	add r3,#1				@ add one to the phase position
	cmp r3,#24				@ if end of sequence, loop it?
	moveq r3,#0				@		by setting to 0

	linInstruct:
	str r3,[r1,r0]			@ store it back
	lsl r3,#3				@ multiply by 8 to find offset
	
	ldr r4,[r2,r3]			@ r4=next piece of tracking data (the direction)
	cmp r4,#0
	bne linearNoLoop
		mov r3,#0
		str r3,[r1,r0]
		lsl r3,#3
		ldr r4,[r2,r3]
	linearNoLoop:
		moveq r3,#0			@ if direction if 0 = loop pattern
		beq linInstruct
		cmp r4,#2048
		beq killTracker
		
	@ code for speed change??? (ulp!)
	ldr r0,=0xFFFF
	and r4,r0				@ trackX is lower 16 bits	
	mov r0,#SPRITE_TRACK_X_OFFS
	str r4,[r1,r0]			@ store (r4) the new trackX
	ldr r4,[r2,r3]			@ load speed (highest 16 bits)
	lsr r4,#16				@ shift it down
	cmp r4,#0				@ if 0, no change
	beq noLinearSpeedChange
		sub r4,#1						@ get new speed (was 1+, but we need 0 for stopping)
		mov r0,#SPRITE_SPEED_X_OFFS		
		str r4,[r1,r0]					@ write new speed
	noLinearSpeedChange:
	add r3,#4				@ add 4 to the spriteInstruct position (for the distance/time)
	ldr r4,[r2,r3]			@ r4=next piece of tracking data (distance)
	mov r0,#SPRITE_TRACK_Y_OFFS
	str r4,[r1,r0]			@ store (r4) the new distance

	ldmfd sp!, {r0-r10, pc}

@-------------- THIS CODE IS ONLY FOR TRACKING ALIENS
aliensTracker:
	stmfd sp!, {r0-r10, lr}
	mov r0,#SPRITE_X_OFFS
	ldr r10,[r1,r0]				@ x coord
	mov r0,#SPRITE_SPEED_DELAY_OFFS	@ the "friction" reset
	ldr r9,[r1,r0]
	mov r0,#SPRITE_TRACK_X_OFFS
	ldr r8,[r1,r0]				 	@ track x coord
		cmp r8,#1024				@ if the track is a simple 1024, then track player
		bne notYouX
			ldr r0,=spriteX			@ load your X
			ldr r8,[r0]				@ r8= your X
			ldr r5,=horizDrift
			ldr r5,[r5]				@ account for horizontal scroll
			add r8,r5				@ at this to the tracking point
		notYouX:
		cmp r8,#2048
		beq killTracker
	mov r5,#SPRITE_SPEED_X_OFFS		@ r5= index to speed x (USED LATER)
	ldr r3,[r1,r5]					@ r3= speed x (USED LATER)
	
	mov r0,#SPRITE_SPEED_DELAY_X_OFFS		@ Update the speed delay
	ldr r6,[r1,r0]					@ r6 = speed delay x
	subs r6,#1						@ take 1 off
	str r6,[r1,r0]					@ put it back
	cmp r6,#0						@ if <> 0
	bne xDone						@ carry on
	mov r6,r9						@ else reset counter
	str r6,[r1,r0]					@ store it and allow update of speed

	cmp r10,r8						@ is sprite l/r of track x?
	beq xNone						@ it is the same
	bpl xLeft						@ if right, go left - else, go right
	bmi xRight						@ if left, go right
	
	xNone:							@ we need to make speed drop to 0
		cmp r3,#0 @ r3 is speed
		beq xDone
		bgt xSlow
			adds r3,#1
			str r3,[r1,r5]
			b xDone
		xSlow:
			subs r3,#1
			str r3,[r1,r5]
		b xDone

	xRight:		
		add r3,#1					@ add 1 to the speed
			mov r0,#SPRITE_SPEED_MAX_OFFS	
			ldr r4,[r1,r0]			@ load max speed
		cmp r3,r4					@ compare with current speed
		movgt r3,r4					@ if greater - max maximum
		str r3,[r1,r5]				@ store r3 to speed x
		b xDone

	xLeft:
		subs r3,#1					@ sub 1 from the speed			
			mov r0,#SPRITE_SPEED_MAX_OFFS	
			ldr r4,[r1,r0]			@ load max speed
			rsb r4,r4,#0			@ make this a negative value
		cmp r3,r4					@ compre with current speed
		movlt r3,r4					@ if it is less than, reset to maximum negative!
		str r3,[r1,r5]				@ store r3 to speed x

	xDone:
	mov r0,#SPRITE_X_OFFS			
	ldr r4,[r1,r0]					@ load our x pos
	adds r4,r3						@ add/sub our speed
	str r4,[r1,r0]					@ store it back
	
	@ Do Y Calculations

	mov r0,#SPRITE_Y_OFFS			@ these offset values WILL be defined in global.s later!
	ldr r10,[r1,r0]			@ y coord
	mov r0,#SPRITE_SPEED_DELAY_OFFS	@ the "friction" reset
	ldr r9,[r1,r0]
	mov r0,#SPRITE_TRACK_Y_OFFS
	ldr r8,[r1,r0] 			@ track y
		cmp r8,#1024			@ if 1024, track your ship
		bne notYouY
			ldr r0,=spriteY
			ldr r8,[r0]			@ make tracking point your Y coord
		notYouY:			
	mov r5,#SPRITE_SPEED_Y_OFFS			@ r5= index to speed (USED LATER)
	ldr r3,[r1,r5]				@ r3= speed y (USED LATER)

	mov r0,#SPRITE_SPEED_DELAY_Y_OFFS	@ Update the speed delay
	ldr r6,[r1,r0]				@ r6 = speed delay y
	subs r6,#1					@ take 1 off
	str r6,[r1,r0]				@ put it back
	cmp r6,#0					@ if <>0
	bne yDone					@ carry on
	mov r6,r9					@ else reset counter
	str r6,[r1,r0]				@ store it and allow update of speed

	cmp r10,r8					@ is sprite below track y?
	beq yNone					@ if the same, slow speed down
	bpl yUp						@ if so, go up
	bmi yDown					@ if not, go down
	
	yNone:						@ we need to make speed drop to 0
		cmp r3,#0 @ r3 is speed
		beq yDone
		bgt ySlow
			adds r3,#1
			str r3,[r1,r5]
			b yDone
		ySlow:
			subs r3,#1
			str r3,[r1,r5]
		b yNone

	yDown:	
		add r3,#1					@ add 1 to the speed
			mov r0,#SPRITE_SPEED_MAX_OFFS	
			ldr r4,[r1,r0]			@ load max speed
		cmp r3,r4					@ compare with current speed
		movgt r3,r4					@ if greater - max maximum
		str r3,[r1,r5]				@ store r3 to speed y
		b yDone

	yUp:
		subs r3,#1					@ sub 1 from the speed			
			mov r0,#SPRITE_SPEED_MAX_OFFS	
			ldr r4,[r1,r0]			@ load max speed
			rsb r4,r4,#0			@ make this a negative value
		cmp r3,r4					@ compre with current speed
		movlt r3,r4					@ if it is less than, reset to maximum negative!
		str r3,[r1,r5]				@ store r3 to speed y

	yDone:
	mov r0,#SPRITE_Y_OFFS			
	ldr r4,[r1,r0]					@ load our y pos
	adds r4,r3						@ add/sub our speed
	str r4,[r1,r0]					@ store it back


	@ Now we need to check if we are close enough to our track point?
	@ so, we need a colision check against the trackX/y
	@ if this is within a range? (will take testing to judge the area of collision)
	@ move the spritePhase one along and load the next track X/Y from spriteInstruct
	@ and store that into the spriteTrackX/y location.
	
	cmp r11,#9						@ check if ye are tracking you
	beq noMatch						@ if so, no need to update track points

	@ This bit of code really needs rewriting!!! The checks are too loose!

	mov r0,#SPRITE_X_OFFS
	ldr r2,[r1,r0]					@ r2=current x COORD
	mov r0,#SPRITE_TRACK_X_OFFS
	ldr r4,[r1,r0]					@ r4=track x COORD


	add r2,#32
	cmp r2,r4
	blt noMatch
	sub r2,#32
	add r4,#32
	cmp r4,r2
	blt noMatch
	
	mov r0,#SPRITE_Y_OFFS
	ldr r2,[r1,r0]					@ r2=current y COORD
	mov r0,#SPRITE_TRACK_Y_OFFS
	ldr r4,[r1,r0]					@ r4=track Y COORD
	
	add r2,#32
	cmp r2,r4
	blt noMatch
	sub r2,#32
	add r4,#32
	cmp r4,r2
	blt noMatch	

	@ To get here we must be within our 16 pixel boundry of a track point.
	@ Time to get another from ((spriteInstruct)+sprite number*128)+32
	@ r7=sprite number
	@ Now we need to dump the data in the correct position in spriteInstruct for later use
	@ calculate = start + ((sprite number *32) * 4)
	
	ldr r2,=spriteInstruct	
	add r2, r7, lsl #7		@ add sprite number * 128
	add r2, #32				@ r2 = first instruction in spriteInstruct
	
	mov r0,#SPRITE_PHASE_OFFS	@ Now, increase our phase position
	ldr r3,[r1,r0]			@ r3 = phase number
	add r3,#1				@ add one to the phase position
	cmp r3,#24				@ if end of sequence, loop it?
	moveq r3,#0				@		by setting to 0
	loopInstruct:
	str r3,[r1,r0]			@ store it back
	lsl r3,#3				@ multiply by 8 to find offset
	
	ldr r4,[r2,r3]			@ r4=next piece of tracking data (the trackX)
	cmp r4,#0
		moveq r3,#0			@ if track x if 0 = loop pattern
		beq loopInstruct
	cmp r4,#2048
		beq killTracker
		
		
	@ code for speed change??? (ulp!)
	ldr r0,=0xFFFF
	and r4,r0				@ trackX is lower 16 bits	
	mov r0,#SPRITE_TRACK_X_OFFS
	str r4,[r1,r0]			@ store (r4) the new trackX
	ldr r4,[r2,r3]
	lsr r4,#16
	cmp r4,#0
	beq noTrackerSpeedChange
		sub r4,#1						@ get new speed
		mov r0,#SPRITE_SPEED_MAX_OFFS		
		str r4,[r1,r0]					@ write new speed
	noTrackerSpeedChange:				

	add r3,#4				@ add 4 to the spriteInstruct position
	ldr r4,[r2,r3]			@ r4=next piece of tracking data (the trackY)
	mov r0,#SPRITE_TRACK_Y_OFFS
	str r4,[r1,r0]			@ store (r4) the new trackY
	
	noMatch:
	ldmfd sp!, {r0-r10, pc}
	
	killTracker:
	
		mov r0,#SPRITE_Y_OFFS
		mov r10,#SPRITE_KILL
		str r10,[r1,r0]

	ldmfd sp!, {r0-r10, pc}
	
initHunterMine:
@-------------- THIS CODE IS ONLY FOR INITIALISING HUNTERS AND MINES
@ first, lets check if mines are active?
@ we can use mineTimerCounter for this, if 0 = then sadly no mines
	stmfd sp!, {lr}
	ldr r0,=mineTimerCounter
	ldr r1,[r0]
	subs r1,#1
	cmp r1,#0
	movmi r1,#0
	str r1,[r0]
	cmp r1,#0				@ is is active??
	bne checkMineTimer		@ yes!!
		b initHunter		@ no :( so let us check for a meteor/mine/thing
	checkMineTimer:
	ldr r0,=mineDelay
	ldr r1,[r0]
	sub r1,#1				@ count down the timer
	str r1,[r0]
	cmp r1,#0
	bpl initHunter			@ not time yet
		ldr r7,=levelNum	@ set the timer between meteors based on level
		ldr r7,[r7]
		cmp r7,#3
		movle r1,#16
		cmp r7,#4
		movge r1,#12
		cmp r7,#8
		movge r1,#8
		cmp r7,#10
		movge r1,#6
		str r1,[r0]
			ldr r3,=spriteActive+68		@ ok, time to init a mine... We need to find a free space for it?
			mov r0,#0					@ R0 points to the sprite that will be used for the mine
				findMineLoop:
				ldr r2,[r3,r0, lsl #2]
				cmp r2,#0
				beq foundMine
					add r0,#1
					cmp r0,#64
				bne findMineLoop
				b initHunterMineFail
					foundMine:
					add r3,r0, lsl #2		@ r3 is now offset to mine sprite
					mov r1,#2
					str r1,[r3]				@ activate as activeSprite 2
					mov r0,#SPRITE_X_OFFS
						@ GENERATE A RANDOM NUMBER (32bit word)
						bl getRandom
						ldr r2,=0x1ff
						and r8,r2
						mov r2,#9
						mul r8,r2
						lsr r8,#4
						add r8,#64
						@ this should make it 64-351 ( from 0-288)
					str r8,[r3,r0]			@ set x coord (RANDOM)
					ldr r7,=levelNum
					ldr r7,[r7]
					mov r0,#SPRITE_Y_OFFS
					mov r1,#SCREEN_SUB_TOP-32			@ set y coord
					str r1,[r3,r0]
					
					mov r0,#SPRITE_SPEED_Y_OFFS
					mov r1,#0x3				@ set Y speed based on level (r7)
					cmp r7,#5
					movge r1,#0x7
					cmp r7,#10
					movge r1,#0x7
					bl getRandom
					and r8,r1
					cmp r8,#2
					addle r8,#2
					cmp r7,#10
					addge r8,#1
					str r8,[r3,r0]
					
					mov r0,#SPRITE_OBJ_OFFS
					mov r1,#36
					str r1,[r3,r0]			@ set sprite to display
					mov r0,#SPRITE_HIT_OFFS
					mov r1,#19				@ set number of hits (shooting does nothing with a meteor)
					str r1,[r3,r0]
					mov r0,#SPRITE_FIRE_TYPE_OFFS
					mov r1,#0				@ set it to never fire
					str r1,[r3,r0]
					mov r0,#SPRITE_IDENT_OFFS
					str r1,[r3,r0]

	initHunter:								@-------- DO THE "HUNTER" INIT

	ldr r0,=hunterTimerCounter
	ldr r1,[r0]
	subs r1,#1
	cmp r1,#0
	movmi r1,#0
	str r1,[r0]
	cmp r1,#0				@ is is active??
	bne checkHunterTimer		@ yes!!
		b initNothing		@ no :( so let us check for a hunter
	checkHunterTimer:
	ldr r0,=hunterDelay
	ldr r1,[r0]
	sub r1,#1				@ count down the timer
	str r1,[r0]
	cmp r1,#0
	bpl initNothing			@ not time yet
		ldr r7,=levelNum
		ldr r7,[r7]
		mov r1,#40			@ set the duration for the next hunter based on level
		cmp r7,#3
		movge r1,#27
		cmp r7,#7
		movge r1,#22
		cmp r7,#10
		movge r1,#18
		str r1,[r0]
			ldr r3,=spriteActive+68		@ ok, time to init a mine... We need to find a free space for it?
			mov r0,#0					@ R0 points to the sprite that will be used for the mine
				findHunterLoop:
				ldr r2,[r3,r0, lsl #2]
				cmp r2,#0
				beq foundHunter
					adds r0,#1
					cmp r0,#64
				bne findHunterLoop
				b initHunterMineFail
					foundHunter:
					add r3,r0, lsl #2		@ r3 is now offset to mine sprite
					mov r1,#3
					str r1,[r3]				@ activate as activeSprite 3
					mov r0,#SPRITE_X_OFFS
						@ GENERATE A RANDOM NUMBER (32bit word)
						bl getRandom
						ldr r2,=0x1ff
						and r8,r2
						mov r2,#9
						mul r8,r2
						lsr r8,#4
						add r8,#64
						@ this should make it 64-351 ( from 0-288)
					str r8,[r3,r0]			@ set x coord (RANDOM)
					mov r0,#SPRITE_Y_OFFS
					mov r1,#SCREEN_SUB_TOP-32			@ set y coord
					str r1,[r3,r0]
					mov r0,#SPRITE_SPEED_Y_OFFS
					@ r7=level
					mov r1,#2		@ set hunter speed based on level
					cmp r7,#6
					movge r1,#3
					cmp r7,#10
					movge r1,#4
					str r1,[r3,r0]
					
					mov r0,#SPRITE_OBJ_OFFS
					mov r1,#30
					str r1,[r3,r0]			@ set sprite to display
					mov r0,#SPRITE_HIT_OFFS
					mov r1,#0				@ set number of hits a single shot (for now)
					str r1,[r3,r0]
					mov r0,#SPRITE_IDENT_OFFS
					str r1,[r3,r0]					
					

					mov r0,#SPRITE_FIRE_TYPE_OFFS
					mov r1,#0				@ set it to never fire (for now)
					str r1,[r3,r0]

	initNothing:
	initHunterMineFail:
	ldmfd sp!, {pc}
	
moveMine:
	@ this is just a little bit of code to move our "MINES", that is all we have to do
	@ all our other code will take care of the rest!
	@ r1 is an offset pointer to our mine sprites
	@ do not use r0,r1 or r7 here to write to!
	stmfd sp!, {r0-r10, lr}
	mov r2,#SPRITE_SPEED_Y_OFFS
	ldr r5,[r1,r2]							@ r5 = the mines speed
	mov r2,#SPRITE_Y_OFFS
	ldr r6,[r1,r2]							@ r6 = the mines Y coord
	add r6,r5
	str r6,[r1,r2]	
	ldmfd sp!, {r0-r10, pc}	
moveHunter:
	stmfd sp!, {r0-r10, lr}
	@ do not use r0,r1 or r7 here to write to!
	@ in a hunter, we use sptObjOffs to tell use which way it is moving
	@ 30=down 31=up 32=left 33=rght
	ldr r2,=levelNum
	ldr r8,[r2]										@ r8 = current level
	mov r2,#SPRITE_OBJ_OFFS
	ldr r4,[r1,r2]									@ r4 = current direction
	ldr r3,=spriteY
	ldr r3,[r3]										@ r3 = your Y pos
	ldr r9,=spriteX
	ldr r9,[r9]										@ r9 = your X pos	
	ldr r5,=horizDrift
	ldr r5,[r5]
	add r9,r5
		cmp r4,#30
		bne hunt1									@ GOING DOWN
			mov r2,#SPRITE_SPEED_Y_OFFS
			ldr r5,[r1,r2]							@ r5 = the hunters speed
			mov r2,#SPRITE_Y_OFFS
			ldr r6,[r1,r2]							@ r6 = the mines Y coord
			add r6,r5
			str r6,[r1,r2]
			cmp r6,#SCREEN_MAIN_WHITESPACE
			bpl hunterKill
			cmp r6,r3								@ is the Hunter level with your Y?
			bmi	hunterDone							@ if not, we are done
				mov r2,#SPRITE_X_OFFS
				ldr r5,[r1,r2]						@ r5 = Hunters X
				cmp r5,r9
				bpl hunterLeft
					mov r2,#SPRITE_OBJ_OFFS			@ Turn Hunter Right
					mov r5,#33
					str r5,[r1,r2]
					b hunterDone
				hunterLeft:
					mov r2,#SPRITE_OBJ_OFFS			@ Turn Hunter Left
					mov r5,#32
					str r5,[r1,r2]
					b hunterDone			
		hunt1:
		cmp r4,#32									@ GOING LEFT
		bne hunt2									@ we need to move and check for X IF level is >3
			mov r2,#SPRITE_SPEED_Y_OFFS
			ldr r5,[r1,r2]							@ r5 = the hunters speed (we will use Y speed globally)
			mov r2,#SPRITE_X_OFFS
			ldr r6,[r1,r2]							@ r6 = the hunters X coord
			subs r6,r5
			str r6,[r1,r2]
			cmp r6,#0
			bmi hunterKill
			cmp r8,#4								@ if we are on level 1-3, no need to do more
			bmi hunterDone
			cmp r6,r9 								@ is the Hunter (r6) near you (r9)								
			bpl hunterDone	
					mov r2,#SPRITE_Y_OFFS
					ldr r5,[r1,r2]					@ r5 = Hunter Y
					cmp r5,r3						@ if you are below it, dont bother going up!
					bmi hunterDone
					mov r2,#SPRITE_OBJ_OFFS			@ Turn Hunter Up
					mov r5,#31
					str r5,[r1,r2]
					b hunterDone
		
		hunt2:
		cmp r4,#33									@ GOING RIGHT
		bne hunt3
			mov r2,#SPRITE_SPEED_Y_OFFS
			ldr r5,[r1,r2]							@ r5 = the hunters speed (we will use Y speed globally)
			mov r2,#SPRITE_X_OFFS
			ldr r6,[r1,r2]							@ r6 = the hunters X coord
			add r6,r5
			str r6,[r1,r2]
			cmp r6,#SCREEN_SUB_TOP
			bpl hunterKill	
			cmp r8,#4								@ if we are on level 1-3, no need to do more
			bmi hunterDone
			@add r6,#48
			cmp r6,r9								@ is the Hunter (r6) near you (r9)								
			bmi hunterDone							@ if not, dont do anything
					mov r2,#SPRITE_Y_OFFS
					ldr r5,[r1,r2]					@ r5 = Hunter Y
					cmp r5,r3						@ if you are below it, dont bother going up!
					bmi hunterDone
					mov r2,#SPRITE_OBJ_OFFS			@ Turn Hunter Up
					mov r5,#31
					str r5,[r1,r2]
					b hunterDone		
		
		hunt3:									
		cmp r4,#31									@ GOING UP
		bne hunterDone
			mov r2,#SPRITE_SPEED_Y_OFFS
			ldr r5,[r1,r2]							@ r5 = the hunters speed (we will use Y speed globally)
			mov r2,#SPRITE_Y_OFFS
			ldr r6,[r1,r2]							@ r6 = the hunters X coord
			sub r6,r5
			str r6,[r1,r2]	
			cmp r6,#SCREEN_SUB_TOP-32
			bmi hunterKill
			
		hunterDone:
		
	ldmfd sp!, {r0-r10, pc}
	hunterKill:
		mov r2,#0
		str r2,[r1]									@ kill that nasty hunter!! :)
	ldmfd sp!, {r0-r10, pc}	

animateAliens:
stmfd sp!, {r0-r10, lr}
	ldr r0,=gameMode
	ldr r0,[r0]
	cmp r0,#GAMEMODE_BIGBOSS
	beq animateAliensDelay
	
	ldr r0,=animDelay
	ldr r1,[r0]
	add r1,#1
	cmp r1,#4
	moveq r1,#0
	str r1,[r0]
	bne animateAliensDelay
		ldr r0,=animFrame
		ldr r1,[r0]
		add r1,#1
		cmp r1,#8
		moveq r1,#0
		str r1,[r0]

		ldr r0, =SpritesAnimTiles
		mov r2,#5*512
		mul r2,r1				
		add r0,r2									@ r0 = source of data			
		ldr r1,=SPRITE_GFX
		add r1,#512*37								@ r1 = destination
		mov r2,#512*5								@ r2 = length
		bl dmaCopy
		ldr r1,=SPRITE_GFX_SUB
		add r1,#512*37
		mov r2,#512*5
		bl dmaCopy
		
		@ Meteors
		
		ldr r0,=meteorFrame
		ldr r1,[r0]
		add r1,#1
		cmp r1,#16
		moveq r1,#0
		str r1,[r0]

		ldr r0, =SpritesMeteorTiles
		add r0,r1, lsl #9							@ r0 = source of data			
		ldr r1,=SPRITE_GFX
		add r1,#512*36								@ r1 = destination
		mov r2,#512									@ r2 = length
		bl dmaCopy
		ldr r1,=SPRITE_GFX_SUB
		add r1,#512*36
		mov r2,#512
		bl dmaCopy		
			
	animateAliensDelay:
ldmfd sp!, {r0-r10, pc}

explodeIdentAlien:
	stmfd sp!, {r0-r10, lr}
	@ r8=IDENT
	mov r7,#111
	ldr r6,=spriteIdent+68
	fireIdentExplodeLoop:
	ldr r3,[r6,r7,lsl #2]
	cmp r3,r8
		bne fireIdentExplodeMissed
		@ ok, we have found a matching ident
		@ so, set this to EXPLODE
			push {r8}
			ldr r2,=spriteActive+68
			mov r3,#11					@ set to an explosion
			str r3,[r2,r7,lsl #2]		@
			mov r3,#6					@ set first explosion frame
			ldr r2,=spriteObj+68
			str r3,[r2,r7,lsl #2]
			bl getRandom
			and r8,#0xf
			add r3,r8,#4					@ set the delay on explosion
			ldr r2,=spriteExplodeDelay+68
			str r3,[r2,r7,lsl #2]
			@ from here we add a little shift to x/y to muddle the explosions slighlty
			ldr r2,=spriteX+68
			ldr r3,[r2,r7,lsl #2]
			bl getRandom
			and r8,#0x7
			subs r8,#3
			adds r3,r8
			str r3,[r2,r7,lsl #2]
			ldr r2,=spriteY+68
			ldr r3,[r2,r7,lsl #2]
			bl getRandom
			and r8,#0x7
			subs r8,#3
			adds r3,r8
			str r3,[r2,r7,lsl #2]
			ldr r2,=spriteBloom+68
			bl getRandom
			and r8,#0x2f
			str r8,[r2,r7,lsl #2]	
		
			@ ok, now add another random explosion to it
				mov r9,#63
				ldr r2,=spriteActive+68
				findFreeSpriteX:
					ldr r3,[r2, r9, lsl #2]
					cmp r3,#0
					beq foundFreeSpriteX
					subs r9,#1
				bpl findFreeSpriteX
				b fireIdentExplodeNot
				
				foundFreeSpriteX:

			mov r3,#11					@ set to an explosion
			str r3,[r2,r9,lsl #2]		@
			mov r3,#6					@ set first explosion frame
			ldr r2,=spriteObj+68
			str r3,[r2,r9,lsl #2]
			bl getRandom
			and r8,#0xF
			add r3,r8,#12					@ set the delay on explosion
			ldr r2,=spriteExplodeDelay+68
			str r3,[r2,r9,lsl #2]
			@ from here we add a little shift to x/y to muddle the explosions slighlty
			ldr r2,=spriteX+68
			ldr r3,[r2,r7,lsl #2]
			bl getRandom
			and r8,#0x20
			subs r8,#15
			adds r3,r8
			str r3,[r2,r9,lsl #2]
			ldr r2,=spriteY+68
			ldr r3,[r2,r7,lsl #2]
			bl getRandom
			and r8,#0x20
			subs r8,#15
			adds r3,r8
			str r3,[r2,r9,lsl #2]
			ldr r2,=spriteBloom+68
			bl getRandom
			and r8,#0x2f
			str r8,[r2,r9,lsl #2]	
			
		fireIdentExplodeNot:
		pop {r8}
		fireIdentExplodeMissed:
		subs r7,#1
	bpl fireIdentExplodeLoop	

	ldmfd sp!, {r0-r10, pc}
	
	.pool
	.end