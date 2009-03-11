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
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	.arm
	.align
	.text
	.global checkWave
	.global moveAliens
	.global initHunterMine
	.global animateAliens

checkWave:		@ CHECK AND INITIALISE ANY ALIEN WAVES AS NEEDED
	stmfd sp!, {r0-r4, lr}
	@ Check our ypossub against the current alienLevel data
	@ if there is a match, init the alien wave
	@ waveNumber is the digit we need to use to pull the data
	ldr r1,=waveNumber
	ldr r3,[r1]						@ r3=current wave number to look for
	ldr r2,=alienLevel

	ldr r4,=levelNum				@ we need to modify alienLevel based on game level
	ldr r4,[r4]						@ r4=current level
	sub r4,#1
	add r2,r4, lsl #9				@ add to alienLevel, LEVEL*512 (128 words)
	
	ldr r5,[r2, r3, lsl #3]			@ r5=current alien level scroll used to generate
	cmp r5,#0						@ if the wave is 0, then All done!
	beq initWaveAliensDone
	ldr r4,=yposSub				
	ldr r4,[r4]						@ r4= our scroll position
	cmp r5,r4						@ is this the same as r5?
	beq initWave					@ if so, we are ready to go :)
	ldmfd sp!, {r0-r4, pc}			@ if not, lets just go to main loop
	
	initWave:
		add r2,#4					@ ok, add 4 (1 word) to r2
		ldr r4,[r2, r3, lsl #3] 	@ r4 is now the attack wave number to init	
		add r3,#1					@ add 1 to wave number
		str r3,[r1]					@ and store it back
		@ we need to strip the ident from r4
		
		ldr r5,=0xffff
		and r7,r4,r5				@ r7= alien type (lower 16 bits)
		sub r4,r7
		lsr r4,#16					@ r4= ident
		mov r6,r4					@ move to r6 for later

	cmp r7,#SPRITE_TYPE_MINE		@ Check for a "MINE FIELD" request
	bne noMines
				ldr r4,=mineCount
				mov r6,#75									@ set number of mines to init (Base this on LEVEL)
				str r6,[r4]
				ldr r4,=mineDelay
				mov r6,#0
				str r6,[r4]									@ set delay to 0 (the mine code handles the rest)
				b initWaveAliensDone
	noMines:
	cmp r7,#SPRITE_TYPE_HUNTER								@ Check for a "HUNTER" request
	bne noHunter
				ldr r4,=hunterCount
				mov r6,#25									@ set number of hunters to init (Base this on LEVEL)
				str r6,[r4]
				ldr r4,=hunterDelay
				mov r6,#0
				str r6,[r4]									@ set delay to 0 (the hunter code handles the rest)
				b initWaveAliensDone	
	noHunter:
		@ from here on in, we know that it is a normal attack

		@ now we need to make r2 the index to the start of attack wave r1
		ldr r2,=alienWave
		add r2, r7, lsl #7				@ add r2=r1*128 (each wave is 32 words)
		mov r3,#0						@ counter to get the data an init them
		initWaveAliens:					@ we need to pass r1 to initAliens to start them
			ldr r1,[r2,r3, lsl #2]		@ r1+alien number*4 (one word each)
			cmp r1,#0
				beq initWaveAliensDone	@ if the alien descript is 0, that is it!
				bl initAlien
			add r3,#1
			cmp r3,#32
		bne initWaveAliens
	initWaveAliensDone:
	ldmfd sp!, {r0-r4, pc}	
	
initAlien:	@ ----------------This code will find a blank alien sprite and assign it
	stmfd sp!, {r0-r10, lr}

								@ set r1 to the alien movement number you wish to activate
	ldr r4,=alienDescript		@ r4=LOCATION OF ALIEN DESCRIPTION
	add r4,r1, lsl #7			@ add it to aliendescrip so we know where to grab from
								@ now er need to find a blank alien
	ldr r3,=spriteActive+68

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

initReversed:	
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
	
		ldmfd sp!, {r0-r10, pc}@ No space for the alien, so lets exit!	
		
	foundSpace:

	mov r5,r0					@ store the sprite number for later retrieval
	
	add r3,r0, lsl #2
	mov r2,#1
	str r2,[r3]					@ activate Sprite

	mov r0,#SPRITE_IDENT_OFFS
	str r6,[r3,r0]				@ store the sprite ident (r6 set earlier)

	mov r1,#0					@ r1=REF to alienDescript data (just add to this)
								@ Now we will dump the data in our sprite table
	ldr r0,=SPRITE_X_OFFS
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store X coord
	
	add r1,#4
	ldr r0,=SPRITE_Y_OFFS
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store y coord
	
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
	str r2,[r3,r0]				@ store sprites maximum speed

	add r1,#4
	mov r0,#SPRITE_OBJ_OFFS
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store sprites Object (Image)
	
	add r1,#4
	ldr r6,=0xffff			
	ldr r2,[r4,r1]				@ this value if split as 2 16bit words
	and r7,r2,r6
	mov r0,#SPRITE_HIT_OFFS
	str r7,[r3,r0]				@ store sprites hits to kill (lower 16)
	sub r2,r7
	lsr r2,#16
	mov r0,#SPRITE_FIRE_SPEED_OFFS
	str r2,[r3,r0]				@ store sprites shot speed (upper 16)

	add r1,#4					@ Move our pointer to the shot setting
	ldr r2,[r4,r1]
	and r7,r2,#0xFF				@ r7= shot type (lower 8 bits)
	mov r0,#SPRITE_FIRE_TYPE_OFFS
	str r7,[r3,r0]				@ store the byte value of the Fire Type
	sub r2,r7
	lsr r2,#8					@ r2= shot delay
	mov r0,#SPRITE_FIRE_MAX_OFFS
	str r2,[r3,r0]				@ store the fire delay maximum value for use later
	mov r0,#SPRITE_FIRE_DELAY_OFFS
	str r2,[r3,r0]				@ set our counter to max also, this is our countdown

	mov r2,#0
	mov r0,#SPRITE_ANGLE_OFFS
	str r2,[r3,r0]				@ store sprite angle (0 init) (WILL WE USE THIS?)
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

	mov r7,#63						@ 64 aliens! (63-0)
	moveAlienLoop:

		@ calculate r1 to be the alien sprite pointer to use
		ldr r1,=spriteActive+68		@ add 68 (17*4) for start of aliens
	
		ldr r0,[r1,r7, lsl #2]
		cmp r0,#0					@ r0 = spriteActive Value
		beq noAlienMove
	
		add r1,r7, lsl #2
	@
	@	We will need to do checks here for special alien types
	@	2=mines, 3=hunter, 
	@	this will be stored in r0
	@
	cmp r0,#0
	beq noAlienMove
	@ if alien type is a 1, Carry on from here
	@ as it must be a linear or tracking alien
	@ r1 is now offset to start of alien data
	@ use r0 as offset to this (+512 per field)
	
	cmp r0,#2					@ check if this is a mine?
		bne mineNot				@ if not, carry on
		bl moveMine				@ move the mine based on y speed
		b haveWeCrashed			@ and we are done
		
	mineNot:
	cmp r0,#3					@ check if this is a tracker?
		bne hunterNot
		bl moveHunter
		b haveWeCrashed
	
	hunterNot:
	cmp r0,#10					@ is it a powerup!!?
	bne powerupNot
		b haveWeCrashed
	
	powerupNot:
	
	
	cmp r0,#1
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
		
		
		mov r0,#SPRITE_Y_OFFS
		ldr r10,[r1,r0]		
		cmp r10,#800					@ check if alien off screen - and kill it
			bmi alienOK
				mov r0,#0			@ uh oh - kill time!
				str r0,[r1]			@ store 0 in sprite active
				b doDetect
			alienOK:
		@
		@	This is where we need to check for alien fire and init if needed
		@	sptFireTypeOffs = fire type (0=none) this is our first check

			mov r0,#SPRITE_FIRE_TYPE_OFFS
			ldr r3,[r1,r0]				@ load fire type (keep r3 as we use it later)
			cmp r3,#0					@ is it a firing alien?
			beq doDetect				@ if not, that is it!
		@	
		@	Now, we need to update the fire delay to see if it is time to fire
		@
			mov r0,#SPRITE_FIRE_DELAY_OFFS
			ldr r9,[r1,r0]				@ get fire delay
			subs r9,#1					@ take 1 off the count
			str r9,[r1,r0]				@ put it back


			bpl doDetect				@ if not 0, no fire mate!
				mov r2,#SPRITE_FIRE_MAX_OFFS
				ldr r9,[r1,r2]			@ load the delay max
				str r9,[r1,r0]			@ and reset the counter
				cmp r10,#384-48			@ Make sure alien is at least NEARLY on screen before firing
				bmi doDetect			@ if no, just forget it
				bl alienFireInit		@ time to fire, r3=fire type, r1=offset to alien
			
			haveWeCrashed:
			doDetect:
				@ ok, now we need to check if an alien has hit YOU!!
				@ r1 is alien base offset!
			
				bl alienCollideCheck		

		noAlienMove:
		subs r7,#1
	bpl moveAlienLoop
	
	ldmfd sp!, {r0-r10, pc}
	
@-------------- THIS CODE IS ONLY FOR LINEAR ALIENS
aliensLinear:
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
	linPass8:
	mov r0,#SPRITE_TRACK_Y_OFFS
	subs r11,r12		@ take speed off our distance to travel
	str r11,[r1,r0]	@ store it back
	cmp r11,#0
	bmi linearNew		@ if moves done, get another pair of instruction
 
	mov r15,r14	

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
		moveq r3,#0			@ if direction if 0 = loop pattern
		beq linInstruct
		cmp r4,#2048
		bne linNoKill
			mov r4,#0
			str r4,[r1]
			b noMatchLin
		linNoKill:
	mov r0,#SPRITE_TRACK_X_OFFS
	str r4,[r1,r0]			@ store (r4) the new trackX
	add r3,#4				@ add 4 to the spriteInstruct position
	ldr r4,[r2,r3]			@ r4=next piece of tracking data (distance)
	mov r0,#SPRITE_TRACK_Y_OFFS
	str r4,[r1,r0]			@ store (r4) the new distance
	noMatchLin:
	mov r15,r14

@-------------- THIS CODE IS ONLY FOR TRACKING ALIENS
aliensTracker:
	mov r0,#SPRITE_X_OFFS
	ldr r10,[r1,r0]				@ x coord
	mov r0,#SPRITE_TRACK_X_OFFS
	ldr r8,[r1,r0]				 	@ track x coord
		cmp r8,#1024				@ if the track is a simple 1024, then track player
		moveq r11,#9				@ if tracking player, increase turning curve
		movne r11,#5				@ else, leave as standard
		bne notYouX
			ldr r0,=spriteX			@ load your X
			ldr r8,[r0]				@ r8= your X
			ldr r5,=horizDrift
			ldr r5,[r5]				@ account for horizontal scroll
			add r8,r5				@ at this to the tracking point
		notYouX:
	mov r5,#SPRITE_SPEED_X_OFFS		@ r5= index to speed x (USED LATER)
	ldr r3,[r1,r5]					@ r3= speed x (USED LATER)
	
	mov r0,#SPRITE_SPEED_DELAY_X_OFFS		@ Update the speed delay
	ldr r6,[r1,r0]					@ r6 = speed delay x
	subs r6,#1						@ take 1 off
	str r6,[r1,r0]					@ put it back
	cmp r6,#0						@ if <> 0
	bne xDone						@ carry on
	mov r6,r11						@ else reset counter
	str r6,[r1,r0]					@ store it and allow update of speed

	cmp r10,r8						@ is sprite l/r of track x?
	beq xNone						@ it is the same
	bpl xLeft						@ if right, go left - else, go right
	bmi xRight						@ if left, go right
	
	xNone:							@ we need to make speed drop to 0
		cmp r3,#0 @ r3 is speed
		beq xDone
		bpl xSlow
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
	mov r0,#SPRITE_TRACK_Y_OFFS
	ldr r8,[r1,r0] 			@ track y
		cmp r8,#1024			@ if 1024, track your ship
		moveq r11,#9			@ if 1024, wider turn curve
		movne r11,#5			@ else, normal
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
	mov r6,r11					@ else reset counter
	str r6,[r1,r0]				@ store it and allow update of speed

	cmp r10,r8					@ is sprite below track y?
	beq yNone					@ if the same, slow speed down
	bpl yUp						@ if so, go up
	bmi yDown					@ if not, go down
	
	yNone:						@ we need to make speed drop to 0
		cmp r3,#0 @ r3 is speed
		beq yDone
		bpl ySlow
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
	add r2,#32						@ a 32 pixel area is too big??
	cmp r2,r4
	bmi noMatch
	sub r2,#32
	add r4,#32
	cmp r2,r4
	bpl noMatch
	
	mov r0,#SPRITE_Y_OFFS
	ldr r2,[r1,r0]					@ r2=current y COORD
	mov r0,#SPRITE_TRACK_Y_OFFS
	ldr r4,[r1,r0]					@ r4=track Y COORD
	add r2,#32
	cmp r2,r4
	bmi noMatch
	sub r2,#32
	add r4,#32
	cmp r2,r4
	bpl noMatch
	
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
		bne trackNoKill
			mov r4,#0
			str r4,[r0]
			b noMatch
		trackNoKill:
	mov r0,#SPRITE_TRACK_X_OFFS
	str r4,[r1,r0]			@ store (r4) the new trackX
	add r3,#4				@ add 4 to the spriteInstruct position
	ldr r4,[r2,r3]			@ r4=next piece of tracking data (the trackY)
	mov r0,#SPRITE_TRACK_Y_OFFS
	str r4,[r1,r0]			@ store (r4) the new trackY
	
	noMatch:
	mov r15,r14
	
	
initHunterMine:
@-------------- THIS CODE IS ONLY FOR INITIALISING HUNTERS AND MINES
@ first, lets check if mines are active?
@ we can use mineCount for this, if 0 = then sadly no mines
	stmfd sp!, {lr}
	ldr r0,=mineCount
	ldr r1,[r0]
	cmp r1,#0				@ is is active??
	bne checkMineTimer		@ yes!!
		b initHunter		@ no :( so let us check for a hunter
	checkMineTimer:
	ldr r0,=mineDelay
	ldr r1,[r0]
	sub r1,#1				@ count down the timer
	str r1,[r0]
	cmp r1,#0
	bpl initHunter			@ not time yet
		mov r1,#8			@ reset the timer	(Change based on LEVEL)
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
					mov r0,#SPRITE_Y_OFFS
					mov r1,#SCREEN_SUB_TOP-32			@ set y coord
					str r1,[r3,r0]
					mov r0,#SPRITE_SPEED_Y_OFFS
					mov r1,#3				@ set y speed (change based on LEVEL) (3 is good for early levels)
					str r1,[r3,r0]
					mov r0,#SPRITE_OBJ_OFFS
					mov r1,#36
					str r1,[r3,r0]			@ set sprite to display
					mov r0,#SPRITE_HIT_OFFS
					mov r1,#4096			@ set number of hits HIGH
					str r1,[r3,r0]
					mov r0,#SPRITE_FIRE_TYPE_OFFS
					mov r1,#0				@ set it to never fire
					str r1,[r3,r0]
					mov r0,#SPRITE_IDENT_OFFS
					str r1,[r3,r0]

					ldr r0,=mineCount		@ decrement the mine counter
					ldr r1,[r0]
					subs r1,#1
					movmi r1,#0
					str r1,[r0]				@ store it back

	initHunter:								@-------- DO THE "HUNTER" INIT

	ldr r0,=hunterCount
	ldr r1,[r0]
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
		mov r1,#50																	@ reset the timer	(Change based on LEVEL)
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
					mov r1,#2				@ set y speed (change based on LEVEL) (2 is good for early levels)
					str r1,[r3,r0]
					mov r0,#SPRITE_OBJ_OFFS
					mov r1,#30
					str r1,[r3,r0]			@ set sprite to display
					mov r0,#SPRITE_HIT_OFFS
					mov r1,#0				@ set number of hits a single shot (for now)
					str r1,[r3,r0]
					mov r0,#SPRITE_FIRE_TYPE_OFFS
					mov r1,#0				@ set it to never fire (for now)
					str r1,[r3,r0]
					mov r0,#SPRITE_IDENT_OFFS
					str r1,[r3,r0]

					ldr r0,=hunterCount		@ decrement the hunter counter
					ldr r1,[r0]
					subs r1,#1
					movmi r1,#0
					str r1,[r0]				@ store it back
	initNothing:
	initHunterMineFail:
	ldmfd sp!, {pc}
	
	
	
moveMine:
	@ this is just a little bit of code to move our "MINES", that is all we have to do
	@ all our other code will take care of the rest!
	@ r1 is an offset pointer to our mine sprites
	@ do not use r0,r1 or r7 here to write to!
	mov r2,#SPRITE_SPEED_Y_OFFS
	ldr r5,[r1,r2]							@ r5 = the mines speed
	mov r2,#SPRITE_Y_OFFS
	ldr r6,[r1,r2]							@ r6 = the mines Y coord
	
	add r6,r5
	str r6,[r1,r2]	
	mov r15,r14
	
moveHunter:
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
		mov r15,r14
	hunterKill:
		mov r2,#0
		str r2,[r1]									@ kill that nasty hunter!! :)
	mov r15,r14
	
animateAliens:
stmfd sp!, {r0, lr}
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
		
	animateAliensDelay:
ldmfd sp!, {r0, pc}
	
	

	.data
	.align
	
seedpointer: 
        .long    seed  
seed: 
        .long    0x55555555 
        .long    0x55555555
	
	.pool
	.end