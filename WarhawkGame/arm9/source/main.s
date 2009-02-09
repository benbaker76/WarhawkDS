@
@ Release V0.21
@
@ ps. you can kill trackers by swinging them off the bottom of the screen!

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
	.global initSystem
	.global main
	.global debugDigits

initSystem:
	bx lr

main:
	@ Setup the screens and the sprites	

	bl initVideo
	bl initSprites
	bl initData

	@ firstly, lets draw all the screen data ready for play
	@ and display the ship sprite
	
@	bl waitforVblank
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3
	bl drawMapScreenMain
	bl drawMapScreenSub
	bl drawSFMapScreenMain
	bl drawSFMapScreenSub
	bl drawSBMapScreenMain
	bl drawSBMapScreenSub
	bl drawScore
	bl drawSprite
	bl drawGetReadyText
	@bl playInGameMusic

	bl waitforFire
	mov r1,#1			@ just for checking (though this would NEVER be active at level start)
	ldr r0,=powerUp
	str r1,[r0]
	
	bl clearBG0
	bl drawAllEnergyBars

	mov r1,#0
	bl init_Alien
	mov r1,#1
	bl init_Alien
	mov r1,#2
	bl init_Alien
	mov r1,#3
	bl init_Alien
	mov r1,#4
	bl init_Alien
	mov r1,#5
	bl init_Alien
	mov r1,#6
	bl init_Alien
	mov r1,#7
	bl init_Alien
	mov r1,#8
	bl init_Alien
	mov r1,#9
	bl init_Alien
	mov r1,#10
	bl init_Alien
	mov r1,#11
	bl init_Alien
@	mov r1,#12
@	bl init_Alien



@@----------------------------@	
@ This is the MAIN game loop @
@----------------------------@
gameLoop:

	bl waitforVblank
	@--------------------------------------------
	@ this code is executed offscreen
	@--------------------------------------------
		
		bl moveShip
		
		bl scrollMain		@ Scroll Level Data
		bl scrollSub		@ Main + Sub
		bl levelDrift
		bl moveBullets		@ check and then moves bullets
		bl fireCheck


		bl move_Aliens

		bl addScore
		bl drawScore
@		bl drawDebugText
		
		bl scrollStars		@ Scroll Stars (BG2,BG3)


		bl checkEndOfLevel	@ Set Flag for end-of-level (use later to init BOSS)

		bl drawSprite
	bl waitforNoblank
	
	@---------------------------------------------
	@ this code is executed during refresh
	@ this should give us a bit more time in vblank
	@---------------------------------------------
			

	b gameLoop			@ our main loop
	
end:
	b end

move_Aliens:	@ OUR CODE TO MOVE OUR ACTIVE ALIENS
	@ the data is only set to allow 32 aliens at any one time
	@ we will have to see how much time (raster) we have when detection is going
	@ to see if we can add more
	stmfd sp!, {r0-r10, lr}

	mov r7,#63
	moveAlienLoop:

		@ calculate r1 to be the alien sprite pointer to use
		ldr r1,=spriteActive+68		@ add 68 (17*4) for start of aliens
	
		ldr r0,[r1,r7, lsl #2]
		cmp r0,#0
		beq no_AlienMove
	
		add r1,r7, lsl #2
	@
	@	We will need to do checks here for special alien types
	@	2=mines, 3=hunter, 
	@	this will be stored in r0
	@
	
	@ if alien type is a 1, Carry on from here
	@ as it must be a linear or tracking alien
	@ r1 is now offset to start of alien data
	@ use r0 as offset to this (+512 per field)

		mov r0,#sptSpdYOffs		@ we use Initial Y speed as a variable to tell use what
		ldr r10,[r1,r0]		@ type of alien to move
		
		@mov r8, #23					@ y pos
		@mov r9, #4						@ digits
		@mov r11, #12					@ x pos
		@bl drawDigits
		
		cmp r10,#1024
			bne trackTest
				bl aliensLinear
				b alienPassed
			trackTest:
				bl aliensTracker
		alienPassed:
		
		mov r0,#sptYOffs
		ldr r10,[r1,r0]		
		cmp r10,#804			@ check if alien off screen - and kill it
			bmi alienOK
			mov r0,#0			@ uh oh - kill time!
			str r0,[r1]			@ store 0 in sprite active
		alienOK:
		no_AlienMove:
		subs r7,#1
	bpl moveAlienLoop
	
	ldmfd sp!, {r0-r10, pc}
	
@-------------- THIS CODE IS ONLY FOR LINEAR ALIENS
aliensLinear:
	@ do not touch r7
	mov r0,#sptTrackXOffs
	ldr r10,[r1,r0]		@ r10 is now our direction (0-7)
	mov r0,#sptTrackYOffs
	ldr r11,[r1,r0]		@ r11 = distance to travel	(1-x)
	mov r0,#sptSpdXOffs
	ldr r12,[r1,r0]		@ r12 = speed of travel
	@ first do our code to move in the direction
	@ then decrement r11 (distance) and if <0 load new tracking
	cmp r10,#1	@ up
		bne linPass1
			mov r0,#sptYOffs
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass1:
	cmp r10,#2	@ up/Right
		bne linPass2
			mov r0,#sptYOffs
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]		
			mov r0,#sptXOffs
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass2:	
	cmp r10,#3	@ Right
		bne linPass3
			mov r0,#sptXOffs
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass3:
	cmp r10,#4 @ Right/Down
		bne linPass4
			mov r0,#sptXOffs
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]	
			mov r0,#sptYOffs
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass4:
	cmp r10,#5 @ Down
		bne linPass5
			mov r0,#sptYOffs
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass5:
	cmp r10,#6 @ Down/Left
		bne linPass6
			mov r0,#sptXOffs
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]	
			mov r0,#sptYOffs
			ldr r4,[r1,r0]
			add r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass6:
	cmp r10,#7 @ Left
		bne linPass7
			mov r0,#sptXOffs
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]		
			b linPass8
		linPass7:
				@ Up/Left
			mov r0,#sptXOffs
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]	
			mov r0,#sptYOffs
			ldr r4,[r1,r0]
			sub r4,r12
			str r4,[r1,r0]		
	linPass8:
	mov r0,#sptTrackYOffs
	subs r11,r12		@ take speed off our distance to travel
	str r11,[r1,r0]	@ store it back
	cmp r11,#0
	bmi linearNew		@ if moves done, get another pair of instruction
 
	mov r15,r14	

	linearNew:
	
	
	ldr r2,=spriteInstruct	
	add r2, r7, lsl #7		@ add sprite number * 128
	add r2, #32				@ r2 = first instruction in spriteInstruct
	
	mov r0,#sptPhaseOffs	@ Now, increase our phase position
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
			str r4,[r0]
			b noMatchLin
		linNoKill:
	mov r0,#sptTrackXOffs
	str r4,[r1,r0]			@ store (r4) the new trackX
	add r3,#4				@ add 4 to the spriteInstruct position
	ldr r4,[r2,r3]			@ r4=next piece of tracking data (distance)
	mov r0,#sptTrackYOffs
	str r4,[r1,r0]			@ store (r4) the new distance
	noMatchLin:
	mov r15,r14

@-------------- THIS CODE IS ONLY FOR TRACKING ALIENS
aliensTracker:
	mov r0,#sptXOffs
	ldr r10,[r1,r0]				@ x coord
	mov r0,#sptTrackXOffs
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
	mov r5,#sptSpdXOffs				@ r5= index to speed x (USED LATER)
	ldr r3,[r1,r5]					@ r3= speed x (USED LATER)
	
	mov r0,#sptSpdDelayXOffs		@ Update the speed delay
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
			mov r0,#sptMaxSpdOffs	
			ldr r4,[r1,r0]			@ load max speed
		cmp r3,r4					@ compare with current speed
		movgt r3,r4					@ if greater - max maximum
		str r3,[r1,r5]				@ store r3 to speed x
		b xDone

	xLeft:
		subs r3,#1					@ sub 1 from the speed			
			mov r0,#sptMaxSpdOffs	
			ldr r4,[r1,r0]			@ load max speed
			rsb r4,r4,#0			@ make this a negative value
		cmp r3,r4					@ compre with current speed
		movlt r3,r4					@ if it is less than, reset to maximum negative!
		str r3,[r1,r5]				@ store r3 to speed x

	xDone:
	mov r0,#sptXOffs			
	ldr r4,[r1,r0]					@ load our x pos
	adds r4,r3						@ add/sub our speed
	str r4,[r1,r0]					@ store it back
	
	@ Do Y Calculations

	mov r0,#sptYOffs			@ these offset values WILL be defined in global.s later!
	ldr r10,[r1,r0]			@ y coord
	mov r0,#sptTrackYOffs
	ldr r8,[r1,r0] 			@ track y
		cmp r8,#1024			@ if 1024, track your ship
		moveq r11,#9			@ if 1024, wider turn curve
		movne r11,#5			@ else, normal
		bne notYouY
			ldr r0,=spriteY
			ldr r8,[r0]			@ make tracking point your Y coord
		notYouY:			
	mov r5,#sptSpdYOffs			@ r5= index to speed (USED LATER)
	ldr r3,[r1,r5]				@ r3= speed y (USED LATER)

	mov r0,#sptSpdDelayYOffs	@ Update the speed delay
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
			mov r0,#sptMaxSpdOffs	
			ldr r4,[r1,r0]			@ load max speed
		cmp r3,r4					@ compare with current speed
		movgt r3,r4					@ if greater - max maximum
		str r3,[r1,r5]				@ store r3 to speed y
		b yDone

	yUp:
		subs r3,#1					@ sub 1 from the speed			
			mov r0,#sptMaxSpdOffs	
			ldr r4,[r1,r0]			@ load max speed
			rsb r4,r4,#0			@ make this a negative value
		cmp r3,r4					@ compre with current speed
		movlt r3,r4					@ if it is less than, reset to maximum negative!
		str r3,[r1,r5]				@ store r3 to speed y

	yDone:
	mov r0,#sptYOffs			
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

	mov r0,#sptXOffs
	ldr r2,[r1,r0]					@ r2=current x COORD
	mov r0,#sptTrackXOffs
	ldr r4,[r1,r0]					@ r4=track x COORD
	add r2,#32						@ a 32 pixel area is too big??
	cmp r2,r4
	bmi noMatch
	sub r2,#32
	add r4,#32
	cmp r2,r4
	bpl noMatch
	
	mov r0,#sptYOffs
	ldr r2,[r1,r0]					@ r2=current y COORD
	mov r0,#sptTrackYOffs
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
	
	mov r0,#sptPhaseOffs	@ Now, increase our phase position
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
	mov r0,#sptTrackXOffs
	str r4,[r1,r0]			@ store (r4) the new trackX
	add r3,#4				@ add 4 to the spriteInstruct position
	ldr r4,[r2,r3]			@ r4=next piece of tracking data (the trackY)
	mov r0,#sptTrackYOffs
	str r4,[r1,r0]			@ store (r4) the new trackY
	
	noMatch:
	mov r15,r14

init_Alien:				@ This code will find a blank alien sprite and assign it
	stmfd sp!, {r0-r10, lr}
								@ set r1 to the alien movement number you wish to activate
	ldr r4,=alienDescript		@ r4=LOCATION OF ALIEN DESCRIPTION
	add r4,r1, lsl #7			@ add it to aliendescrip so we know where to grab from
								@ now er need to find a blank alien

	ldr r3,=spriteActive+68
	mov r0,#63	@ SPRITE R0 points to the sprite that will be used for the alien
				@ we need to use a loop here to FIND a spare sprite
				@ and this will be used to init the alien!!
	find_Space_Loop:
		ldr r2,[r3,r0, lsl #2]
		cmp r2,#0
		beq found_Space
			subs r0,#1
	bpl find_Space_Loop
	
	ldmfd sp!, {r0-r10, pc}	@ No space for the alien, so lets exit!
	
	found_Space:
	mov r5,r0					@ store the sprite number for later retrieval
	
	add r3,r0, lsl #2
	mov r2,#1
	str r2,[r3]					@ activate Sprite
	
	mov r1,#0					@ r1=REF to alienDescript data (just add to this)
								@ Now we will dump the data in our sprite table
	ldr r0,=sptXOffs
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store X coord
	
	add r1,#4
	ldr r0,=sptYOffs
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store y coord
	
	add r1,#4
	ldr r0,=sptSpdXOffs
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store initial X speed
	
	add r1,#4
	ldr r0,=sptSpdYOffs
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store initial Y speed

	mov r2,#12
	ldr r0,=sptSpdDelayXOffs
	str r2,[r3,r0]				@ store speed delay x (start at 12) (use for inc/dec on x speed)

	mov r2,#12
	ldr r0,=sptSpdDelayYOffs
	str r2,[r3,r0]				@ store speed delay Y (start at 12) (use for inc/dec on y speed)

	add r1,#4
	ldr r0,=sptMaxSpdOffs
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store sprites maximum speed

	mov r2,#0
	ldr r0,=sptPhaseOffs
	str r2,[r3,r0]				@ store sprite data phase (always start at 0)	

	add r1,#4
	mov r0,#sptObjOffs
	ldr r2,[r4,r1]
	str r2,[r3,r0]				@ store sprites Object (Image)
	
	add r1,#4
	add r0,#sptHitsOffs
	ldr r2,[r4,r1]
	cmp r2,#0					@ check hits to kill is never 0
	moveq r2,#1					@ in case we forget to set this
	str r2,[r3,r0]				@ store sprites hits to kill

	mov r2,#0
	mov r0,#sptAngleOffs
	str r2,[r3,r0]				@ store sprite angle (0 init)

	mov r0,r6					@ r2 now points to our first tracking
	mov r0,#sptTrackXOffs		@ coord (X) - need to grab this from alienDescript
	mov r1,#32
	ldr r2,[r4,r1]				@ load alien descript +32 = init track x
	str r2,[r3,r0]				@ store first track X
	mov r0,#sptTrackYOffs
	mov r1,#36
	ldr r2,[r4,r1]				@ load alien descript +36 = init track y
	str r2,[r3,r0]				@ store first track y

	ldr r2,=spriteInstruct	
	add r2,r5, lsl #7			@ the sprite number was stored in R5 earlier
	mov r1,#127					@ 128 bytes or 32 words for alien track data
	init_Loop:
		ldrb r3,[r4,r1]		@ load from alienDescript
		strb r3,[r2,r1]		@ store in spriteInstruct
	subs r1,#1				
	bpl init_Loop				@ repeat
	
	ldmfd sp!, {r0-r10, pc}
	
moveBaseExplosion:

	ldr r1,=spriteActive
	mov r0,#113
		checkBase:
@		ldr r2,[r1,r0, lsl#2]
@		cmp r2,#5
@		bne noBaseHere
				ldr r2,=spriteY
				ldr r3,[r2,r0, lsl #2]
				add r3,r3,#1
				str r3,[r2,r0, lsl #2]
		
		
		noBaseHere:
		add r0,#1
		cmp r0,#128
		bne checkBase
	
mov r15,r14
	
	
alienDescript:	@ These are stored in blocks of 32 words --- for however many we use?

	.word 90,120,1,1024,0,37,1,1					@ inits
	.word 5,280,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,140,1,1024,0,37,1,1					@ inits
	.word 5,260,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,160,1,1024,0,37,1,1					@ inits
	.word 5,240,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,180,1,1024,0,37,1,1					@ inits
	.word 5,220,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,200,1,1024,0,37,1,1					@ inits
	.word 5,200,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,220,1,1024,0,37,1,1					@ inits
	.word 5,180,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,240,1,1024,0,37,1,1					@ inits
	.word 5,160,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,260,1,1024,0,37,1,1					@ inits
	.word 5,140,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,280,1,1024,0,37,1,1					@ inits
	.word 5,120,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,300,1,1024,0,37,1,1					@ inits
	.word 5,100,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,320,1,1024,0,37,1,1					@ inits
	.word 5,80,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500
	
	.word 90,340,1,1024,0,37,1,1					@ inits
	.word 5,60,4,50,3,50,4,50,5,50,6,50			@ Track points
	.word 7,10,8,10,1,5,2,5,3,80,5,500

	@ Alien define structure

	.word 164		@ init X				@ initial X coord
	.word 450		@ init y				@ initial Y coord
	.word 0 		@ init speed X			@ (this is overal speed in linear mode)
	.word 1024		@ init speed y			@ (set to 1024 to signal linear mode)
	.word 1 		@ init maxSpeed			@ (on ones that attack you - 5 is the fastest)
	.word 56 		@ init spriteObj		@ Sprite to use for image
	.word 2			@ init hits to kill		@ make massive for indestructable
	.word 0			@ init 'fire type' 		@ 0=none
	.word 3,120		@ track x,y 1			@ tracking coordinate (as in coords.png)
	.word 7,120		@ track x,y 2
	.word 0,0		@ track x,y 3
	.word 315,660	@ etc.....
	.word 215,660	@ make any track 1024 to attack your ship on that vertices
	.word 230,384	@ (in linear mode these are direction, distance, "speed x" is speed)
	.word 1024,1024	@ you can make them trackers at any time on any axis.. :)
	.word 0,0		@ make them 0 and the wave will loop to the begining
	.word 0,0		@ make them 2048 to kill the alien (spriteActive=0)
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed
	.word 0,0		@ if not, the pattern will loop forever	
			
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