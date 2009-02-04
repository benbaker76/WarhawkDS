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
	.global waitforFire
	.global fireCheck
	.global moveBullets

waitforFire:
	@ Messy bit just to wait for button to start
	@ This is a delay that can be skipped by FIRE
	@ Not great, but serves its purpose for now
	@ this will need to update music at later stage also
	
	stmfd sp!, {r0-r6, lr}
	
	mov r4,#200
	
	buttpause:
	
		bl waitforVblank
		bl scrollStars
		bl waitforNoblank
	
		ldr r1,=REG_KEYINPUT
		ldr r2,[r1]
		tst r2,#BUTTON_A
		beq butta
		subs r4,#1
		bne buttpause
		
	butta:	
	
	ldmfd sp!, {r0-r6, pc}

fireCheck:			@ OUR CODE TO CHECK FOR FIRE (A) AND RELEASE A BULLET
	stmfd sp!, {r0-r6, lr}
	
	ldr r1,=REG_KEYINPUT
	ldr r2,[r1]
	tst r2,#BUTTON_A
	beq fireDown
		ldr r0,=firePress
		mov r1,#0
		str r1,[r0]					@ set the flag to say fire has been released
		ldmfd sp!, {r0-r6, pc}
	fireDown:
		ldr r0,=powerUp				@ check if autofire is on
		ldrb r0, [r0]
		cmp r0,#1
		beq initpowerUp				@ if so, lets use it
	
		ldr r0,=firePress			@ load our pressed button check
		ldr r0, [r0]
		cmp r0,#0					@ check if fire is released
		beq initFire				@ if it was, then lets see if we have a bullet spare?
		ldmfd sp!, {r0-r6, pc}
	initpowerUp:
		@ this is a little bit of code for auto fire
		@ add a little delay check in here to see if we are ready for another bullet
		@ if so, just continue the code!
		ldr r4,=powerUpDelay
		ldr r3,[r4]					@ r3=our delay
		add r3,#1					@ increment out counter
		cmp r3,#6					@ wait 8 refreshes before another bullet
		moveq r3,#0					@ if it is 8, zero the delay
		str r3,[r4]					@ put the result back
		beq initFire				@ ok, lets "fire one off"
		ldmfd sp!, {r0-r6, pc}		@ but, if not - we are done!
	initFire:
		ldr r0,=firePress
		mov r1,#1
		str r1,[r0]
		@ Ok, now we need to see about initialising a bullet!!
		@ These are stored in our sprite table from position 1-4 (4 bullets)
		@ First thing is to see if we can fire a bullet.
		ldr r0,=powerUp
		ldr r0, [r0]
		cmp r0,#1
		moveq r0,#15				@ if powered up, we can allow 16 bullets
		movne r0,#3					@ if not, just the 4
		ldr r1, =spriteActive
		add r1, #4					@ add 4 bytes as stored in words
		isbulletPossible:
			ldr r2,[r1,r0, lsl #2]	@ Multiplied by 4 as in words
			cmp r2,#0
			beq bulletPossible
			subs r0,#1
		bpl isbulletPossible
		ldmfd sp!, {r0-r6, pc}
	bulletPossible:
		@ ok, all we need to do now is set spriteActive for the bullet r0
		@ and set the image and coords for the bullet to start
		@ the bullet code will take care of the rest
		ldr r1,=spriteActive
		add r1,#4
		mov r2,#1
		str r2,[r1,r0, lsl #2]		@ sprite is now active

		ldr r1, =spriteSpeedY
		add r1, #4
		mov r2,#4					@ set the bullets speed!
		str r2,[r1,r0, lsl #2]

		ldr r3,=spriteX
		ldr r2,[r3]					@ our ships x coord
		ldr r4,=horizDrift			@ we need to add our horizontal-
		ldr r4,[r4]					@ drift to the bullets X coord
		add r2,r4
		ldr r1,=spriteX				@ store it in bullets x
		add r1, #4
		str r2,[r1,r0, lsl #2]		@ done!
		
		ldr r3,=spriteY
		ldr r2,[r3]					@ our ships y coord
		ldr r1,=spriteY				@ store the result in bullets y
		add r1,#4
		str r2,[r1,r0, lsl #2]		@ done

		mov r2,#3					@ set r2 to our bullet image
		ldr r1, =spriteObj
		add r1, #4
		str r2,[r1,r0, lsl #2]		@ done
		
		bl playBlasterSound
		
		@ bullet should now be ready to go!!!
		@ We can add the bullet movement code here, OR do it seperate
		@ along with the colision checks??? Hmmmm
	ldmfd sp!, {r0-r6, pc}
	
moveBullets:			@ OUR CODE TO MOVE THE ACTIVE BULLETS UP THE SCREEN
	stmfd sp!, {r0-r6, lr}
	mov r0,#15
	ldr r1, =spriteActive
	add r1, #4
	activeBloop:
		ldr r2,[r1,r0, lsl #2]			@ Multiplied by 4 as in words
		cmp r2,#0						@ check if bullet is active (1=yes)
		beq bulletDead
			@ Ok, this bullet is ACTIVE,
			@ so, lets move it, all we need to do is sub
			@ bullets speed from Ypos and check for off screen
			ldr r3,=spriteY
			add r3,#4
			ldr r4,[r3,r0, lsl #2]
			
			ldr r5, =spriteSpeedY		@ Let us load r6 with the bullets speed
			add r5, #4
			ldr r6,[r5,r0, lsl #2]		@ this can be used for a power shot
				
			subs r4,r6					@ using r6 as a speed
			cmp r4,#360					@ this is our exit, so it can slide off the top
			bgt activeBstill
				mov r5,#0				@ clear the flag, and -
				str r5,[r1,r0, lsl #2]	@ Kill the bullet
				b bulletDead
			activeBstill:
			str r4,[r3, r0, lsl #2]	@ store the new Y pos back
			
			@ Now we need to do some detection code!!!
			@ we will keep it seperate at the moment for ease
			cmp r4,#384
			blgt detectBG				@ if greater than 384, check for collision
			@ r0=our bullet numberz
		
			@ TEST--------

		bulletDead:
		subs r0,#1
		bpl activeBloop	
	
	ldmfd sp!, {r0-r6, pc}
