@
@ Release V0.18
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
	bl drawMapMain
	bl drawMapSub
	bl drawSFMapMain
	bl drawSFMapSub
	bl drawSBMapMain
	bl drawSBMapSub
	bl clearBG0
	bl drawScore
	bl drawSprite
	bl drawGetReadyText
	@bl playInGameMusic

	bl waitforFire
	mov r1,#1			@ just for checking (though this would NEVER be active at level start)
	ldr r0,=powerUp
	str r1,[r0]
	
	bl clearBG0

@	mov r1,#0
@	bl init_Alien
@	mov r1,#1
@	bl init_Alien
@	mov r1,#2
@	bl init_Alien
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
@----------------------------@	
@ This is the MAIN game loop @
@----------------------------@
gameLoop:

	bl waitforVblank
	@--------------------------------------------
	@ this code is executed offscreen
	@--------------------------------------------
		bl scrollStars		@ Scroll Stars (BG2,BG3)
		bl levelDrift
		
		bl checkEndOfLevel	@ Set Flag for end-of-level (use later to init BOSS)
		
		bl scrollMain		@ Scroll Level Data
		bl scrollSub		@ Main + Sub
	
		bl drawSprite		@ Move our craft (d-pad and A, perhaps check for pause and shut DS)
		bl fireCheck
		bl moveBullets

		bl moveShip
		bl move_Aliens

		bl addScore
		bl drawScore
		bl drawDebugText

@	bl waitforNoblank
	@---------------------------------------------
	@ this code is executed during refresh
	@ this should give us a bit more time in vblank
	@---------------------------------------------
			
			

		ldr r0, =scrollPixelText		@ Load our text pointer
		ldr r1, =0						@ x pos
		ldr r2, =22						@ y pos
		ldr r3, =1						@ Draw on main screen
		bl drawText	
		ldr r0,=scrollPixel
		ldr r10,[r0]			
		mov r8, #22						@ y pos
		mov r9, #4						@ digits
		mov r11, #12					@ x pos
		bl drawDigits

@		ldr r0, =scrollBlockText		@ Load our text pointer
@		ldr r1, =0						@ x pos
@		ldr r2, =20						@ y pos
@		ldr r3, =1						@ Draw on main screen
@		bl drawText	
@		ldr r0,=scrollBlock
@		ldr r10,[r0]			
@		mov r8, #20						@ y pos
@		mov r9, #2						@ digits
@		mov r11, #12					@ x pos
@		bl drawDigits

	b gameLoop			@ our main loop
	
end:
	b end

move_Aliens:	@ OUR CODE TO MOVE OUR ACTIVE ALIENS
	@ the data is only set to allow 32 aliens at any one time
	@ we will have to see how much time (raster) we have when detection is going
	@ to see if we can add more
	stmfd sp!, {r0-r10, lr}

	mov r7,#31
	moveAlienLoop:

	@ calculate r1 to be the alien sprite pointer to use
	ldr r1,=spriteActive+68		@ add 68 (17*4) for start of aliens
	
	ldr r0,[r1,r7, lsl #2]
	cmp r0,#0
	beq no_AlienMove
	
	add r1,r7, lsl #2
	@
	@	We will need to do checks here for special alien types
	@	2=mines, 3=hunter
	@	this will be stored in r0
	@
	
	
	@ r1 is now offset to start of alien data
	@ use r0 as offset to this (+512 per field)

	@ Do X Calculations
	mov r0,#sptSpdYOffs		@ we use Initial Y speed as a variable to tell use what
	ldr r10,[r1,r0]		@ type of alien to move
	cmp r10,#1024
	blne aliensTracker		@ if not 1024 then Tracker
	bleq aliensLinear		@ if is 1024 then Linear
	
	cmp r10,#820			@ check if alien off screen - and kill it
	bmi alienOK
		mov r0,#0			@ uh oh - kill time!
		str r0,[r1]			@ store 0 in sprite active
	alienOK:
	no_AlienMove:
	subs r7,#1
@	cmp r7,#0
	bpl moveAlienLoop
	
	ldmfd sp!, {r0-r10, pc}
	
@-------------- THIS CODE IS ONLY FOR LINEAR ALIENS
aliensLinear:

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
	mov r0,#31	@ SPRITE R0 points to the sprite that will be used for the alien
				@ we need to use a loop here to FIND a spare sprite
				@ and this will be used to init the alien!!
	find_Space_Loop:
		ldr r2,[r3,r0, lsl #2]
		cmp r2,#0
		beq found_Space
			subs r0,#1
@			cmp r0,#32
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
	
	
	
	
	
	
alienDescript:	@ These are stored in blocks of 32 words --- for however many we use?

	.word 90	@ init X
	.word 340	@ init y
	.word 0 @ init speed X
	.word 0	@ init speed y		@ (set to 1024 to signal liner mode?)
	.word 4 @ init maxSpeed
	.word 17 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 1	@ init 'fire type' 0=none
	.word 130,440	@ track x,y 1
	.word 90,500	@ track x,y 2
	.word 130,580		@ track x,y 3
	.word 260,500		@ etc.....
	.word 130,440		@ make any (trackX 1024 to attack your ship)
	.word 90,380		@ (in linear mode these are direction, distance, speed y is speed)
	.word 195,500
	.word 195,550
	.word 260,600
	.word 90,700
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed	
	@ Full 32 words per Alien Description (128 bytes)
	
	.word 120	@ init X
	.word 340	@ init y
	.word 0 @ init speed X
	.word 0	@ init speed y		@ (set to 1024 to signal liner mode?)
	.word 4 @ init maxSpeed
	.word 17 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 1	@ init 'fire type' 0=none
	.word 160,440	@ track x,y 1
	.word 120,500	@ track x,y 2
	.word 160,580		@ track x,y 3
	.word 290,500		@ etc.....
	.word 160,440		@ make any (trackX 1024 to attack your ship)
	.word 120,380		@ (in linear mode these are direction, distance, speed y is speed)
	.word 225,500
	.word 225,550
	.word 290,600
	.word 120,700
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed	
	@ Full 32 words per Alien Description (128 bytes)
	
	.word 280	@ init X
	.word 300	@ init y
	.word 0 @ init speed X
	.word 0	@ init speed y		@ (set to 1024 to signal liner mode?)
	.word 3 @ init maxSpeed
	.word 17 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 300,400	@ track x,y 1
	.word 260,500	@ track x,y 2
	.word 300,400		@ track x,y 3
	.word 260,500		@ etc.....
	.word 300,600		@ make any (trackX 1024 to attack your ship)
	.word 260,400		@ (in linear mode these are direction, distance, speed y is speed)
	.word 280,500
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed	
	@ Full 32 words per Alien Description (128 bytes)
@ pattern 3
	.word 100	@ init X
	.word 300	@ init y
	.word 0 @ init speed X
	.word 0	@ init speed y		@ (set to 1024 to signal liner mode?)
	.word 3 @ init maxSpeed
	.word 37 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 100,700	@ track x,y 1
	.word 100,420	@ track x,y 2
	.word 1024,1024		@ track x,y 3
	.word 0,0		@ etc.....
	.word 0,0		@ make any (trackX 1024 to attack your ship)
	.word 0,0		@ (in linear mode these are direction, distance, speed y is speed)
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed	
	@ Full 32 words per Alien Description (128 bytes)

@ THESE FROM HERE ARE CORRECTLY COMMENTED

	.word 140	@ init X
	.word 200	@ init y
	.word 0 @ init speed X		@ (this is overal speed in linear mode)
	.word 0	@ init speed y		@ (set to 1024 to signal linear mode)
	.word 3 @ init maxSpeed		@ (on ones that attack you - 5 is the fastest)
	.word 37 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 140,700	@ track x,y 1
	.word 140,420		@ track x,y 2
	.word 1024,1024		@ track x,y 3
	.word 0,0		@ etc.....
	.word 0,0		@ make any track 1024 to attack your ship on that vertices
	.word 0,0		@ (in linear mode these are direction, distance, speed x is speed)
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed
	.word 0,0		@ if not, the pattern will loop forever	

	.word 180	@ init X
	.word 100	@ init y
	.word 0 @ init speed X		@ (this is overal speed in linear mode)
	.word 0	@ init speed y		@ (set to 1024 to signal linear mode)
	.word 3 @ init maxSpeed		@ (on ones that attack you - 5 is the fastest)
	.word 37 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 180,700	@ track x,y 1
	.word 180,420		@ track x,y 2
	.word 1024,1024		@ track x,y 3
	.word 0,0		@ etc.....
	.word 0,0		@ make any track 1024 to attack your ship on that vertices
	.word 0,0		@ (in linear mode these are direction, distance, speed x is speed)
	.word 0,0		@ you can make them trackers at any time on any axis.. :)
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed
	.word 0,0		@ if not, the pattern will loop forever	

@ pattern 6
	.word 314	@ init X
	.word 300	@ init y
	.word 0 @ init speed X
	.word 0	@ init speed y		@ (set to 1024 to signal liner mode?)
	.word 3 @ init maxSpeed
	.word 37 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 314,700	@ track x,y 1
	.word 314,420	@ track x,y 2
	.word 1024,1024		@ track x,y 3
	.word 0,0		@ etc.....
	.word 0,0		@ make any (trackX 1024 to attack your ship)
	.word 0,0		@ (in linear mode these are direction, distance, speed y is speed)
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed	
	@ Full 32 words per Alien Description (128 bytes)

@ THESE FROM HERE ARE CORRECTLY COMMENTED

	.word 274	@ init X
	.word 200	@ init y
	.word 0 @ init speed X		@ (this is overal speed in linear mode)
	.word 0	@ init speed y		@ (set to 1024 to signal linear mode)
	.word 3 @ init maxSpeed		@ (on ones that attack you - 5 is the fastest)
	.word 37 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 274,700	@ track x,y 1
	.word 274,420		@ track x,y 2
	.word 1024,1024		@ track x,y 3
	.word 0,0		@ etc.....
	.word 0,0		@ make any track 1024 to attack your ship on that vertices
	.word 0,0		@ (in linear mode these are direction, distance, speed x is speed)
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed
	.word 0,0		@ if not, the pattern will loop forever	

	.word 234	@ init X
	.word 100	@ init y
	.word 0 @ init speed X		@ (this is overal speed in linear mode)
	.word 0	@ init speed y		@ (set to 1024 to signal linear mode)
	.word 3 @ init maxSpeed		@ (on ones that attack you - 5 is the fastest)
	.word 37 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 234,700	@ track x,y 1
	.word 234,420		@ track x,y 2
	.word 1024,1024		@ track x,y 3
	.word 0,0		@ etc.....
	.word 0,0		@ make any track 1024 to attack your ship on that vertices
	.word 0,0		@ (in linear mode these are direction, distance, speed x is speed)
	.word 0,0		@ you can make them trackers at any time on any axis.. :)
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed
	.word 0,0		@ if not, the pattern will loop forever	
	
	.word 0	@ init X
	.word 500	@ init y
	.word 0 @ init speed X		@ (this is overal speed in linear mode)
	.word 0	@ init speed y		@ (set to 1024 to signal linear mode)
	.word 2 @ init maxSpeed		@ (on ones that attack you - 5 is the fastest)
	.word 37 @ init spriteObj
	.word 2	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 200,500	@ track x,y 1
	.word 200,580		@ track x,y 2
	.word 100,580		@ track x,y 3
	.word 100,660		@ etc.....
	.word 200,660		@ make any track 1024 to attack your ship on that vertices
	.word 185,384		@ (in linear mode these are direction, distance, speed x is speed)
	.word 1024,1024		@ you can make them trackers at any time on any axis.. :)
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed
	.word 0,0		@ if not, the pattern will loop forever	
	
	.word 415	@ init X
	.word 500	@ init y
	.word 0 @ init speed X		@ (this is overal speed in linear mode)
	.word 0	@ init speed y		@ (set to 1024 to signal linear mode)
	.word 2 @ init maxSpeed		@ (on ones that attack you - 5 is the fastest)
	.word 37 @ init spriteObj
	.word 2	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 215,500	@ track x,y 1
	.word 215,580		@ track x,y 2
	.word 315,580		@ track x,y 3
	.word 315,660		@ etc.....
	.word 215,660		@ make any track 1024 to attack your ship on that vertices
	.word 230,384		@ (in linear mode these are direction, distance, speed x is speed)
	.word 1024,1024		@ you can make them trackers at any time on any axis.. :)
	.word 0,0
	.word 0,0
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