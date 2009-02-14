#include "warhawk.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	.global alienFireInit
	.global alienFireMove


	.arm
	.align

@----------------- INITIALISE A SHOT 
alienFireInit:
	stmfd sp!, {r0-r10, lr}
	@ This initialises and aliens bullet
	@ REMEMBER, 	R1 = our aliens offset (we can use this to get coords) (must use sptXXXOffs)
	@ 				R3 = our fire type to initialise ok?
	@	For examples we will use the types 1-4
	@	these are up, down, left, right
	@   REMEMBER = the bullet delay has already been RESET	
	bl findAlienFire
	cmp r2,#255
	beq testno
		@ r1= offset for alien
		@ r2= offset for bullet
		mov r0,#sptXOffs
		ldr r6,[r1,r0]			@ r6=aliens x
		str r6,[r2,r0]
		mov r0,#sptYOffs
		ldr r6,[r1,r0]
		str r6,[r2,r0]
		mov r0,#sptObjOffs
		mov r6,#27
		str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
		mov r6,#1
		str r6,[r2]				@ set ACTIVE
	
	testno:
	
	
	
	ldmfd sp!, {r0-r10, pc}
@----------------- FIND A SPARE SLOT FOR A BULLET
	@ be warned - this modifies r2,r5
	@ this returns r4=	sprite offset to use
	@					or 255, if none available
findAlienFire:
		stmfd sp!, {lr}
		mov r4, #81					@ alien bullet are 81-112 (32)
		ldr r2, =spriteActive
		isAlienFirePossible:
			ldr r5,[r2,r4, lsl #2]	@ Multiplied by 4 as in words
			cmp r5,#0
			beq findAlienFireDone
			add r4,#1
			cmp r4,#113
		bne isAlienFirePossible
		mov r2,#255					@ set to 255 to signal "NO SPACE FOR FIRE"
		ldmfd sp!, {pc}
		findAlienFireDone:
		mov r4,r4, lsl #2
		add r2, r4					@ return r2 as pointer to bullet
		ldmfd sp!, {pc}
	
@----------------- MOVE ALIEN BULLETS AND CHECK COLLISIONS
alienFireMove:
	stmfd sp!, {r0-r10, lr}
	@ here. we need to step through all alien bullets and check type
	@ and from that we will bl to code to act on it :)
	@ and then return to the main loop!
	
	
	@ do stuff here
	
		mov r4, #81					@ alien bullet are 81-112 (32)
		findAlienBullet:

			ldr r2, =spriteActive
			ldr r5,[r2,r4, lsl #2]	@ Multiplied by 4 as in words
			cmp r5,#0
			beq testSkip
			
				@ this is TEST code (well all of it)
				add r2, r4, lsl #2
				mov r7,#sptYOffs
				ldr r1,[r2,r7]
				add r1,#2
				str r1,[r2,r7]
				cmp r1,#768
				bmi testpass
					mov r1,#0
					str r1,[r2]
				testpass:
				mov r7,#
			
			
			testSkip:
			add r4,#1
			cmp r4,#113
		bne findAlienBullet		
	
	@ and from here we need to check if the bullet is on our ship
	@ and if so, deplete energy, mainloop will act on a 0 and kill us!
	
	ldmfd sp!, {r0-r10, pc}
	
@----------------- BULLET TYPE CODE FROM HERE
.end
