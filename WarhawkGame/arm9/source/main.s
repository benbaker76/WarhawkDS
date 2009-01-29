@
@ Release V0.16
@

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
@	str r1,[r0]
	
	bl clearBG0
	mov r1,#0
	bl init_Alien
	mov r1,#1
	bl init_Alien
	mov r1,#2
	bl init_Alien
	mov r1,#3
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

		ldr r0, =scrollBlockText		@ Load our text pointer
		ldr r1, =0						@ x pos
		ldr r2, =20						@ y pos
		ldr r3, =1						@ Draw on main screen
		bl drawText	
		ldr r0,=scrollBlock
		ldr r10,[r0]			
		mov r8, #20						@ y pos
		mov r9, #2						@ digits
		mov r11, #12					@ x pos
		bl drawDigits

	b gameLoop			@ our main loop
	
end:
	b end
	
	
move_Aliens:	@ OUR CODE TO MOVE OUR ACTIVE ALIENS
	@ the data is only set to allow 32 aliens at any one time
	@ we will have to see how much time (raster) we have when detection is going
	@ to see if we can add more
	stmfd sp!, {r0-r10, lr}

	mov r7,#31
	move_Loop:

	@ calculate r1 to be the alien sprite pointer to use
	ldr r1,=spriteActive+68		@ add 68 (17*4) for start of aliens
	
	ldr r0,[r1,r7, lsl #2]
	cmp r0,#0
	beq no_AlienMove
	
	add r1,r7, lsl #2
	
	
	@ r1 is now offset to start of alien data
	@ use r0 as offset to this (+512 per field)

	@ Do Y Calculations

	mov r0,#1024		@ these offset values WILL be defined in global.s later!
	ldr r10,[r1,r0]	@ y coord
	mov r0,#5120
	ldr r8,[r1,r0] 	@ track y
				
	mov r5,#2048		@ r5= index to speed (USED LATER)
	ldr r3,[r1,r5]		@ r3= speed y (USED LATER)

	mov r0,#3072		@ Update the speed delay
	ldr r6,[r1,r0]		@ r6 = speed delay y
	subs r6,#1			@ take 1 off
	str r6,[r1,r0]		@ put it back
	cmp r6,#0			@ if <>0
	bne y_Done			@ carry on
	mov r6,#5			@ else reset counter
	str r6,[r1,r0]		@ store it and allow update of speed

	cmp r10,r8			@ is sprite below track y?
	beq y_None
	bpl y_Up			@ if so, go up - else, go down
	bmi y_Down
	
	y_None:
	@ we need to make speed drop to 0
		cmp r3,#0 @ r3 is speed
		beq y_Done
		bpl y_Slow
			adds r3,#1
			str r3,[r1,r5]
			b y_Done
		y_Slow:
			subs r3,#1
			str r3,[r1,r5]
		b y_None

	y_Down:	
		add r3,#1			@ add 1 to the speed
			mov r0,#3584	
			ldr r4,[r1,r0]	@ load max speed
		cmp r3,r4			@ compare with current speed
		movgt r3,r4			@ if greater - max maximum
		str r3,[r1,r5]		@ store r3 to speed y
		b y_Done

	y_Up:
		subs r3,#1			@ sub 1 from the speed			
			mov r0,#3584	
			ldr r4,[r1,r0]	@ load max speed
			rsb r4,r4,#0	@ make this a negative value
		cmp r3,r4			@ compre with current speed
		movlt r3,r4			@ if it is less than, reset to maximum negative!
		str r3,[r1,r5]		@ store r3 to speed y

	y_Done:
	mov r0,#1024			
	ldr r4,[r1,r0]			@ load our y pos
	adds r4,r3				@ add/sub our speed
	str r4,[r1,r0]			@ store it back

	@ Do X Calculations

	mov r0,#512
	ldr r10,[r1,r0]	@ x coord
	mov r0,#4608
	ldr r8,[r1,r0] 	@ track x coord
				
	mov r5,#1536		@ r5= index to speed x (USED LATER)
	ldr r3,[r1,r5]		@ r3= speed x (USED LATER)

	mov r0,#2560		@ Update the speed delay
	ldr r6,[r1,r0]		@ r6 = speed delay x
	subs r6,#1			@ take 1 off
	str r6,[r1,r0]		@ put it back
	cmp r6,#0			@ if <> 0
	bne x_Done			@ carry on
	mov r6,#5			@ else reset counter
	str r6,[r1,r0]		@ store it and allow update of speed

	cmp r10,r8			@ is sprite l/r of track x?
	beq x_None			@ it is the same
	bpl x_Left			@ if right, go left - else, go right
	bmi x_Right			@ if left, go right
	
	x_None:
	@ we need to make speed drop to 0
		cmp r3,#0 @ r3 is speed
		beq x_Done
		bpl x_Slow
			adds r3,#1
			str r3,[r1,r5]
			b x_Done
		x_Slow:
			subs r3,#1
			str r3,[r1,r5]
		b x_Done

	x_Right:		
		add r3,#1			@ add 1 to the speed
			mov r0,#3584	
			ldr r4,[r1,r0]	@ load max speed
		cmp r3,r4			@ compare with current speed
		movgt r3,r4			@ if greater - max maximum
		str r3,[r1,r5]		@ store r3 to speed x
		b x_Done

	x_Left:
		subs r3,#1			@ sub 1 from the speed			
			mov r0,#3584	
			ldr r4,[r1,r0]	@ load max speed
			rsb r4,r4,#0	@ make this a negative value
		cmp r3,r4			@ compre with current speed
		movlt r3,r4			@ if it is less than, reset to maximum negative!
		str r3,[r1,r5]		@ store r3 to speed x

	x_Done:
	mov r0,#512			
	ldr r4,[r1,r0]			@ load our x pos
	adds r4,r3				@ add/sub our speed
	str r4,[r1,r0]			@ store it back

	@ Now we need to check if we are close enough to our track point?
	@ so, we need a colision check against the trackX/y
	@ if this is within a range? (will take testing to judge the area of collision)
	@ move the spritePhase one along and load the next track X/Y from spriteInstruct
	@ and store that into the spriteTrackX/y location.

	mov r0,#512
	ldr r2,[r1,r0]			@ r2=current x
	mov r0,#4608
	ldr r4,[r1,r0]			@ r4=track x
	add r2,#32
	cmp r2,r4
	bmi no_Match
	sub r2,#32
	add r4,#32
	cmp r2,r4
	bpl no_Match
	
	mov r0,#1024
	ldr r2,[r1,r0]			@ r2=current y
	mov r0,#5120
	ldr r4,[r1,r0]			@ r4=track y
	add r2,#32
	cmp r2,r4
	bmi no_Match
	sub r2,#32
	add r4,#32
	cmp r2,r4
	bpl no_Match
	
	@ To get here we must be within our 16 pixel boundry of a track point.
	@ Time to get another from ((spriteInstruct)+sprite number*128)+32
	@ r7=sprite number
	@ Now we need to dump the data in the correct position in spriteInstruct for later use
	@ calculate = start + ((sprite number *32) * 4)
	
		ldr r2,=spriteInstruct	
		add r2, r7, lsl #7		@ add sprite number * 128
		add r2, #32				@ r2 = first instruction in spriteInstruct
	
	mov r0,#4096
	ldr r3,[r1,r0]			@ r3 = phase number
	add r3,#1
	cmp r3,#24				@ if end of sequence, loop it?
	moveq r3,#0
	loop_Instruct:
	str r3,[r1,r0]
	lsl r3,#3				@ multiply by 8 to find offset
	
	ldr r4,[r2,r3]
	cmp r4,#0
		moveq r3,#0			@ if track x if 0 = loop pattern
		beq loop_Instruct
	mov r0,#4608
	str r4,[r1,r0]
	add r3,#4
	ldr r4,[r2,r3]
	mov r0,#5120
	str r4,[r1,r0]
	

	no_Match:


	
	cmp r10,#840			@ check if alien off screen - and kill it
	bmi alien_OK
		mov r0,#0			@ uh oh - kill time!
		str r0,[r1]			@ store 0 in sprite active
	alien_OK:
	no_AlienMove:
	subs r7,#1
	cmp r7,#0
	bpl move_Loop
	
	ldmfd sp!, {r0-r10, pc}


init_Alien:				@ This code will find a blank alien sprite and assign it
	stmfd sp!, {r0-r10, lr}
								@ set r1 to the alien movement number you wish to activate
	ldr r4,=alienDescript		@ r4=LOCATION OF ALIEN DESCRIPTION
	add r4,r1, lsl #7			@ add it to aliendescrip so we know where to grab from
								@ now er need to find a blank alien

	ldr r3,=spriteActive+68
	mov r0,#0	@ SPRITE R0 points to the sprite that will be used for the alien
				@ we need to use a loop here to FIND a spare sprite
				@ and this will be used to init the alien!!
	find_Space_Loop:
		ldr r2,[r3,r0, lsl #2]
		cmp r2,#0
		beq found_Space
			adds r0,#1
			cmp r0,#32
	bne find_Space_Loop
	
	
		ldmfd sp!, {r0-r10, pc}
	
	found_Space:
	mov r2,#1
	str r2,[r3,r0, lsl #2]			@ activate Sprite


	mov r5,r0						@ store the sprite number for later retrieval
	lsl r0, #2
	mov r1,#0						@ r1=REF to alienDescript data (just add to this)

	add r0,#512
	ldr r2,[r4,r1]
	str r2,[r3,r0]			@ store X
	
	add r1,#4
	add r0,#512
	ldr r2,[r4,r1]
	str r2,[r3,r0]			@ store y
	
	add r1,#4
	add r0,#512
	ldr r2,[r4,r1]
	str r2,[r3,r0]			@ store initial X speed
	
	add r1,#4
	add r0,#512
	ldr r2,[r4,r1]
	str r2,[r3,r0]			@ store initial Y speed

	mov r2,#12
	add r0,#512
	str r2,[r3,r0]			@ store speed delay x (start at 4) (use for inc/dec on x speed)
							
	mov r2,#12
	add r0,#512
	str r2,[r3,r0]			@ store speed delay Y (start at 4) (use for inc/dec on y speed)

	add r1,#4
	add r0,#512
	ldr r2,[r4,r1]
	str r2,[r3,r0]			@ store sprites maximum speed

	mov r2,#0
	add r0,#512
	str r2,[r3,r0]			@ store sprite data phase (always start at 0)	

	mov r6,r0				@ store position in data till later

	add r0,#1024
		
	add r1,#4
	add r0,#512
	ldr r2,[r4,r1]
	str r2,[r3,r0]			@ store sprites Object (Image)
	
	add r1,#4
	add r0,#512
	ldr r2,[r4,r1]
	cmp r2,#0				@ check hits to kill is never 0
	moveq r2,#1				@ in case we forget to set this
	str r2,[r3,r0]			@ store sprites hits to kill

	mov r2,#0
	add r0,#512
	str r2,[r3,r0]			@ store sprite angle (0 init)

	mov r0,r6				@ r2 now points to our first tracking
	add r0,#512				@ coord (X) - need to grab this from alienDescript
	mov r1,#32
	ldr r2,[r4,r1]			@ load alien descript +32 = init track x
	str r2,[r3,r0]			@ store first track X
	add r0,#512
	mov r1,#36
	ldr r2,[r4,r1]			@ load alien descript +36 = init track y
	str r2,[r3,r0]			@ store first track y

	ldr r2,=spriteInstruct	
	add r2,r5, lsl #7
	mov r1,#127
	init_Loop:
		ldrb r3,[r4,r1]
		strb r3,[r2,r1]
	subs r1,#1
	bpl init_Loop
	
	ldmfd sp!, {r0-r10, pc}
	
	
	
	
	
	
alienDescript:	@ These are stored in blocks of 32 words --- for however many we use?
	.word 90	@ init X
	.word 340	@ init y
	.word 0 @ init speed X
	.word 0	@ init speed y		@ (set to 999 to signal liner mode?)
	.word 4 @ init maxSpeed
	.word 7 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 1	@ init 'fire type' 0=none
	.word 130,440	@ track x,y 1
	.word 90,500	@ track x,y 2
	.word 130,580		@ track x,y 3
	.word 260,500		@ etc.....
	.word 130,440		@ make any (trackX 999 to attack your ship)
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
	.word 0	@ init speed y		@ (set to 999 to signal liner mode?)
	.word 4 @ init maxSpeed
	.word 7 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 1	@ init 'fire type' 0=none
	.word 160,440	@ track x,y 1
	.word 120,500	@ track x,y 2
	.word 160,580		@ track x,y 3
	.word 290,500		@ etc.....
	.word 160,440		@ make any (trackX 999 to attack your ship)
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
	.word 0	@ init speed y		@ (set to 999 to signal liner mode?)
	.word 3 @ init maxSpeed
	.word 8 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 300,400	@ track x,y 1
	.word 260,500	@ track x,y 2
	.word 300,400		@ track x,y 3
	.word 260,500		@ etc.....
	.word 300,600		@ make any (trackX 999 to attack your ship)
	.word 260,400		@ (in linear mode these are direction, distance, speed y is speed)
	.word 280,500
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed	
	@ Full 32 words per Alien Description (128 bytes)

	.word 200	@ init X
	.word 300	@ init y
	.word 0 @ init speed X
	.word 0	@ init speed y		@ (set to 999 to signal liner mode?)
	.word 6 @ init maxSpeed
	.word 9 @ init spriteObj
	.word 1	@ init hits to kill (1=1 hit)
	.word 0	@ init 'fire type' 0=none
	.word 200,650	@ track x,y 1
	.word 200,450	@ track x,y 2
	.word 0,0		@ track x,y 3
	.word 0,0		@ etc.....
	.word 0,0		@ make any (trackX 999 to attack your ship)
	.word 0,0		@ (in linear mode these are direction, distance, speed y is speed)
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0
	.word 0,0		@ The last Y coord must be off screen base so alien is destroyed	
	@ Full 32 words per Alien Description (128 bytes)


.end

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