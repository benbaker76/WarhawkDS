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
	.global waitforFire
	.global fireCheck
	.global moveBullets

fireCheck:			@ OUR CODE TO CHECK FOR FIRE (A) AND RELEASE A BULLET
	stmfd sp!, {r0-r8, lr}
	
	ldr r1,=deathMode		@ if player is dying - firing is not allowed
	ldr r1,[r1]				@ should it be allowed??
	cmp r1,#DEATHMODE_STILL_ACTIVE
	beq fireAllowed
		ldmfd sp!, {r0-r8, pc}
	fireAllowed:
	
	ldr r1,=REG_KEYINPUT
	ldr r2,[r1]
	tst r2,#BUTTON_A
	beq fireDown
	@ FIRE RELEASED
		@ ** we need to read "firePress" and see if it >0
		@ ** if so, fire bullet, else if >31 fire power shot
		ldr r0,=firePress
		ldr r8,[r0]			@ r8= fire pressed duration
		mov r2,#0
		str r2,[r0]			@ RESET "firepress" to 0
		ldr r0,=fireTrap
		str r2,[r0]
		cmp r8,#1
		bpl initFire		@ Fire
		notTimeToFire:
		ldmfd sp!, {r0-r8, pc}
	fireDown:
	@ FIRE PRESSED
		ldr r0,=fireTrap
		ldr r0,[r0]
		cmp r0,#0
		bne notTimeToFire
		ldr r0,=powerUp				@ check if autofire is on and fire pressed
		ldr r0, [r0]
		cmp r0,#1
		moveq r8,#0
		beq initpowerUp				@ if so, lets use it
			ldr r0,=firePress		@ if not, we need to incrememnt "firepress"
			ldr r8,[r0]
			add r8,#1
			cmp r8,#255
			moveq r8,#255			@ but not to go too high
			str r8,[r0]
			cmp r8,#1				@ this bit enables a fire on press and release
			beq initFire			@ of the fire button, better?? or TOO MUCH?
			
		@ and exit!
		ldmfd sp!, {r0-r8, pc}

	initpowerUp:
		@ this is a little bit of code for auto fire
		@ add a little delay check in here to see if we are ready for another bullet
		@ if so, just continue the code!
		ldr r4,=powerUpDelay
		ldr r3,[r4]					@ r3=our delay
		add r3,#1					@ increment our counter
		cmp r3,#4					@ wait 4 refreshes before another bullet
		moveq r3,#0					@ if it is 8, zero the delay
		str r3,[r4]					@ put the result back
		beq initFire				@ ok, lets "fire one off"
		ldmfd sp!, {r0-r8, pc}		@ but, if not - we are done!

	initFire:
		@ Ok, now we need to see about initialising a bullet!!
		@ These are stored in our sprite table from position 1-15 (16 bullets)
		@ First thing is to see if we can fire a bullet.
		ldr r0,=powerUp
		ldr r0, [r0]
		cmp r0,#1
		moveq r0,#15				@ if powered up, we can allow 16 bullets
		movne r0,#7					@ if not, just the 8
		ldr r1, =spriteActive+4
		isbulletPossible:
			ldr r2,[r1,r0, lsl #2]	@ Multiplied by 4 as in words
			cmp r2,#0
			beq bulletPossible
			subs r0,#1
		bpl isbulletPossible
		ldmfd sp!, {r0-r8, pc}
	bulletPossible:
		@ GENERATE BULLET
		@ ok, all we need to do now is set spriteActive for the bullet r0
		@ and set the image and coords for the bullet to start
		@ the bullet code will take care of the rest
		@ r8 tells us if normal or POWER (1)
		
		ldr r1,=haveIShot
		mov r2,#1
		str r2,[r1]
	
		ldr r1,=spriteActive+4
		mov r2,#1
		str r2,[r1,r0, lsl #2]		@ sprite is now active
		
		ldr r3,=spriteX
		ldr r2,[r3]					@ our ships x coord
		ldr r4,=horizDrift			@ we need to add our horizontal-
		ldr r4,[r4]					@ drift to the bullets X coord
		add r2,r4
		ldr r1,=spriteX+4			@ store it in bullets x
		str r2,[r1,r0, lsl #2]		@ done!		

		cmp r8,#31					@ This is the "HOLD" period needed for the shot!
		ble fireNormal				@ "POWERSHOT"

			bl playPowershotSound
			
			ldr r3,=spriteY
			ldr r2,[r3]					@ our ships y coord
			add r2,#6					@ Move it down a little
			ldr r1,=spriteY+4			@ store the result in bullets y
			str r2,[r1,r0, lsl #2]		@ done
			ldr r1, =spriteSpeedY+4
			mov r2,#8					@ set the bullets speed!
			str r2,[r1,r0, lsl #2]	
			mov r2,#4					@ set r2 to our bullet image
			ldr r1, =spriteObj+4
			str r2,[r1,r0, lsl #2]		@ done
			
			ldmfd sp!, {r0-r8, pc}

		fireNormal:					@ "NORMALSHOT"
		
			bl playBlasterSound
		
			ldr r3,=spriteY
			ldr r2,[r3]					@ our ships y coord
			add r2,#6					@ Move it down a little
			ldr r1,=spriteY+4			@ store the result in bullets y
			str r2,[r1,r0, lsl #2]
			ldr r1, =spriteSpeedY+4
			ldr r4,=powerUp
			ldr r4,[r4]
			cmp r4,#1
			moveq r2,#8					@ power up speed
			movne r2,#6					@ normal speed
			str r2,[r1,r0, lsl #2]
			mov r2,#3					@ set r2 to our bullet image
			ldr r1, =spriteObj+4
			str r2,[r1,r0, lsl #2]		@ done
		
	ldmfd sp!, {r0-r8, pc}
	
moveBullets:			@ OUR CODE TO MOVE THE ACTIVE BULLETS UP THE SCREEN
	stmfd sp!, {r0-r8, lr}
	mov r0,#15
	ldr r1, =spriteActive+4
	activeBloop:
		ldr r2,[r1,r0, lsl #2]			@ Multiplied by 4 as in words
		cmp r2,#0						@ check if bullet is active (1=yes)
		beq bulletDead
			@ Ok, this bullet is ACTIVE,
			@ so, lets move it, all we need to do is sub
			@ bullets speed from Ypos and check for off screen

			ldr r3,=spriteY+4
			ldr r4,[r3,r0, lsl #2]

			ldr r5, =spriteSpeedY+4		@ Let us load r6 with the bullets speed
			ldr r6,[r5,r0, lsl #2]		@ this can be used for a power shot
				
			subs r4,r6					@ using r6 as a speed
			mov r5,#SCREEN_SUB_TOP-32
			cmp r4,r5					@ this is our exit, so it can slide off the top
			bgt activeBstill
				mov r5,#0				@ clear the flag, and -
				str r5,[r1,r0, lsl #2]	@ Kill the bullet
				ldr r3,=spriteY+4
				mov r5,#SPRITE_KILL
				str r5,[r3,r0, lsl #2]
				b bulletDead
			activeBstill:
			str r4,[r3, r0, lsl #2]	@ store the new Y pos back

			cmp r4,#384
			bmi bulletDead

			bl detectALN				@ detect agains aliens
			bl detectBGL				@ check if we have hit a base!!! 	(Left Gun)
			bl detectBGR 				@									(Right Gun)
			
		bulletDead:
		subs r0,#1
		bpl activeBloop	
	
	ldmfd sp!, {r0-r8, pc}
	
	.pool
	.end