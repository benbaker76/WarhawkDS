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

	.global checkPowerUp
	.global dropShipShot
	.global powerupCollect
	.global movePowerUp
	
	.arm
	.align
	.text
	
checkPowerUp:
	stmfd sp!, {r0-r6, lr}
	ldr r0,=levelNum
	ldr r0,[r0]
	cmp r0,#3
	bpl powerAvailable
		ldmfd sp!, {r0-r6, pc}
	powerAvailable:
	ldr r0,=powerUp
	ldr r1,[r0]
	cmp r1,#1
	bne checkPowerDelay
		ldr r0,=powerupLives
		ldr r1,[r0]
		subs r1,#1
		str r1,[r0]
		cmp r1,#0
		movmi r1,#0
		bpl checkPowerDelay
			mov r1,#0
			ldr r0,=powerUp
			str r1,[r0]
			
			@playpowerupLostSound		@ this is for when powerup RUNS out!!
	
	checkPowerDelay:
	
	ldr r0,=delayPowerUp				@ this is our counter
	ldr r1,[r0]
	add r1,#1							@ add to it
	cmp r1,#368							@ we will use this for a test value
	str r1,[r0]							@ store it back
	bpl powerInit
		ldmfd sp!, {r0-r6, pc}	
	powerInit:
	@ ok, now we need to generate a Drop ship!!!
	@ shall we use a base explosion for this?

	mov r6,#63						@ 64 aliens! (63-0)
	findDropLoop:

		@ calculate r1 to be the alien sprite pointer to use
		ldr r4,=spriteActive+68		@ add 68 (17*4) for start of aliens
	
		ldr r5,[r4,r6, lsl #2]
		cmp r5,#0					@ r0 = spriteActive Value
		beq startDropShip

		subs r6,#1
		bne findDropLoop

	ldmfd sp!, {r0-r6, pc}
		
	startDropShip:
		mov r1,#0
		str r1,[r0]						@ reset the counter!
	
		mov r5,#9						@ an id of 9 = drop ship!
		str r5,[r4,r6, lsl #2]			@ set sprite to "base explosion"

		ldr r4,=spriteObj+68
		mov r5,#35						@ This is the Dropship Sprite
		str r5,[r4,r6, lsl #2]			@ 

		bl getRandom
		and r8,#255
		add r8,#80
		

		ldr r4,=spriteX+68
		str r8,[r4,r6, lsl #2]			@ store r1 as X, calculated above

		ldr r4,=spriteY+68
		mov r1,#352						@ set the Y coord into Whitespace!
		str r1,[r4,r6, lsl #2]			@ store r2 as Y, calculated above
	
		ldr r4,=spriteHits+68
		mov r1,#0						@ set the hits to 0
		str r1,[r4,r6, lsl #2]			@ store r2 as Y, calculated above	

	ldmfd sp!, {r0-r6, pc}
	
dropShipShot:						@------------ We have shot a drop ship!!
	stmfd sp!, {r0-r6, lr}
	@ r4 = the offset to the sprite!
	@ we need to generate a powerup at the same coords! (active=10)
	mov r0,#SPRITE_X_OFFS
	ldr r1,[r4,r0]						@ r1=X
	mov r0,#SPRITE_Y_OFFS
	ldr r2,[r4,r0]						@ r2=y
	@ ok, now we need a space for it?
	ldr r3,=spriteActive+68
	mov r0,#63					@ SPRITE R0 points to the sprite that will be used for the alien
								@ we need to use a loop here to FIND a spare sprite
								@ and this will be used to init the alien!!
	findPowerLoop:
		ldr r5,[r3,r0, lsl #2]
		cmp r5,#0
		beq foundPower
		subs r0,#1
	bpl findPowerLoop
	@ WHAT will i do if there is no space???????????????? (ie, during mine storm)
	ldmfd sp!, {r0-r6, pc}	@ No space for the alien, so lets exit!	
	
	foundPower:
	add r3,r0, lsl #2			@ r3 = pointer to new powerup
	
	mov r0,#SPRITE_X_OFFS
	str r1,[r3,r0]
	mov r0,#SPRITE_Y_OFFS
	str r2,[r3,r0]
	mov r1,#10
	str r1,[r3]					@ set active to 10 (this is a powerup)
	mov r1,#29
	mov r0,#SPRITE_OBJ_OFFS
	str r1,[r3,r0]
	mov r1,#8					@ powerup takes 4 shots to destroy
	mov r0,#SPRITE_HIT_OFFS		@ set its hit points to 2
	str r1,[r3,r0]	
	
	mov r1,#0
	mov r0,#SPRITE_SPEED_X_OFFS
	str r1,[r3,r0]
	mov r1,#4
	mov r0,#SPRITE_SPEED_DELAY_X_OFFS
	str r1,[r3,r0]
	
	ldmfd sp!, {r0-r6, pc}
	
powerupCollect:
	stmfd sp!, {r0-r6, lr}
	@ r1 is the ref to the powerup - we need to remove it!
	mov r0,#SPRITE_KILL
	mov r2,#SPRITE_Y_OFFS
	str r0,[r1,r2]
	
	@bl playPowerupCollect
	
	mov r0,#1
	ldr r1,=powerUp
	str r0,[r1]
	
	mov r0,#652					@ set duration of powerup
	ldr r1,=powerupLives
	str r0,[r1]
	
	ldmfd sp!, {r0-r6, pc}
	
movePowerUp:
	stmfd sp!, {r0-r6, lr}
	ldr r0,=spriteY
	ldr r1,[r0,r8,lsl #2]
	add r1,#2							@ move it down screen
	str r1,[r0,r8,lsl #2]
	@ now it needs to have a fairly fast TRACK
	ldr r0,=spriteX
	ldr r0,[r0]
	ldr r1,=horizDrift
	ldr r1,[r1]
	add r0,r1				@ r0=Players X coord

	ldr r6,=spriteX
	ldr r4,[r6,r8,lsl #2]	@ R4=powerup X (use r6 later)
	
	ldr r1,=spriteSpeedDelayX
	ldr r2,[r1,r8,lsl #2]
	subs r2,#1
	str r2,[r1,r8,lsl #2]
	cmp r2,#0
	bne powerupXDone
	mov r2,#10
	str r2,[r1,r8,lsl #2]
	
	cmp r0,r4
	bgt powerupRight
		ldr r2,=spriteSpeedX
		add r2, r8, lsl #2
		ldrsb r3,[r2]
		subs r3,#1
		cmp r3,#-4
		movmi r3,#-4
		str r3,[r2]				@ store new speed back
		b powerupXDone
	powerupRight:
		ldr r2,=spriteSpeedX
		add r2, r8, lsl #2
		ldrsb r3,[r2]
		add r3,#1
		cmp r3,#4
		movpl r3,#4
		str r3,[r2]				@ store new speed back
	
	powerupXDone:
	
	ldr r0,=spriteSpeedX
	ldr r3,[r0, r8, lsl #2]	
	adds r4,r3
	str r4,[r6,r8, lsl #2]		@ using r6 again! :)
		
	ldmfd sp!, {r0-r6, pc}