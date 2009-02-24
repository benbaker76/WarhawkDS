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
	.global findAlienFire
	
	@ Fire types
	@ 1-4	=	Directional 1=up, 2=right, 3=down, 4=left (speed 2)
	@ 5-6	=	Directional with Vertical move 5=right, 6=left (move down with scroller) (Speed 2)
	@ 7-10	=	Directional 7=up, 8=right, 9=down, 10=left (speed 4)
	@ 11-12	=	Directional with Vertical move 5=right, 6=left (move down with scroller) (Speed 4)
	@ 13	=	Standard "Warhawk" tracker shot
	.arm
	.align

@
@----------------- INITIALISE A SHOT 
@

alienFireInit:
	stmfd sp!, {r0-r10, lr}
	@ This initialises and aliens bullet
	@ REMEMBER, 	R1 = our aliens offset (we can use this to get coords) (must use sptXXXOffs)
	@ 				R3 = our fire type to initialise (passed from moveAliens)
	@
	ldr r4,=spriteX
	ldr r4,[r4]
	ldr r5,=spriteY
	ldr r5,[r5]
	@---------- All our inits follow from here - SEQUENTIALLY ---------@
	
	cmp r3,#19					@ check and init standard linear shots types 1-12
		blmi initStandardShot
	cmp r3,#19
		bleq initTrackerShot
	cmp r3,#20
		bleq initAccelShot
	cmp r3,#21
		bleq initRippleShot
	cmp r3,#22
		bleq initRippleTripleShot
	cmp r3,#23
		bleq initMineShot
	cmp r3,#24
		bleq initTripleShot
	cmp r3,#25
		bleq initRippleShotPhase1
	cmp r3,#26
		bleq initRippleShotPhase2
	cmp r3,#27
		bleq initRippleShotPhase1F
	cmp r3,#28
		bleq initRippleShotPhase2F
	@ etc!

	alienFireInitDone:
	ldmfd sp!, {r0-r10, pc}

@	
@----------------- MOVE ALIEN BULLETS AND CHECK COLLISIONS
@

alienFireMove:
	stmfd sp!, {r0-r10, lr}
	@ here. we need to step through all alien bullets and check type
	@ and from that we will bl to code to act on it :)
	@ and then return to the main loop!
		ldr r0,=spriteX
		ldr r0,[r0]							@ set r0 to player x
		ldr r1,=horizDrift
		ldr r1,[r1]
		add r0,r1							@ and add the horizontal drift value
		ldr r1,=spriteY
		ldr r1,[r1]							@ set r1 to player y
	
		ldr r5,=spriteActive				@ R5 is pointer to bullet base
		mov r4, #81							@ alien bullet are 81-112 (32)
		findAlienBullet:
			ldr r3,[r5,r4, lsl #2]			@ Multiplied by 4 as in words
			cmp r3,#0						@ if 0 = no active bullet
			beq testSkip
				mov r2,r5					@ mov r5 into r2 as bullet base
				add r2,r4, lsl #2			@ Set r2 to bullets offset
				mov r3,#sptFireTypeOffs
				ldr r3,[r2,r3]				@ r3= fire type to update
	
				cmp r3,#19					@ check for standard shot 1-12
					blmi moveStandardShot
				cmp r3,#19
					bleq moveTrackerShot
				cmp r3,#20
					bleq moveAccelShot
				cmp r3,#21
					bleq moveRippleShot
				cmp r3,#23
					bleq moveMineShot
					
					
					
				cmp r3,#25
					bleq moveRippleShotPhase1
				@ ETC
	
				@ and from here we need to check if the bullet is on our ship
				@ and if so, deplete energy, mainloop will act on a 0 and kill us!
				mov r6,#sptXOffs
				ldr r6,[r2,r6]
				mov r7,#sptYOffs
				ldr r7,[r2,r7]
				@ r0,r1 = player x/y
				@ r6,r7 = bullet x/y
	
				add r6,#16
				cmp r6,r0						@ r6=Bullet x / r0= your X
				bmi testSkip
				sub r6,#16+12
				cmp r6,r0	
				bgt testSkip

				add r7,#16
				cmp r7,r1						@ r7=bullet y / r1= your y
				bmi testSkip
				sub r7,#16+12
				cmp r7,r1
				bgt testSkip	

					@ Bullet HAS HIT US!!
					@ kill bullet unless it is tracker/mine type!!
				
					ldr r6,=spriteBloom
					mov r7,#16
					str r7,[r6]						@ make ship flash
				
					@bl ShipHitSound				@ activate sound for ship being hit!
				
					ldr r6,=energy					@ Take 1 off your energy
					ldr r7,[r6]
					subs r7,#1
					movmi r7,#0
					str r7,[r6]
						
					mov r6,#sptObjOffs
					ldr r6,[r2,r6]
					cmp r6,#26						@ 26 is the sprite we use for mine/tracker
					bne killAlienBullet
						mov r6,#sptBloomOffs		@ if it is obj 26
						mov r7,#16					@ flash it, and do not destroy
						str r7,[r2,r6]
				
					@ THIS BIT SHOULD JUST KILL THE BULLET???
				
					b testSkip
					killAlienBullet:
					mov r7,#0
					str r7,[r2]					@ kill bullet
					
					mov r6,#sptYOffs		@ put bullet X off screen, only works if kill bullet
					mov r7,#788				@ above is disabled? MADNESS!!
					str r7,[r2,r6]
					mov r6,#sptXOffs		@ put bullet X off screen, only works if kill bullet
					mov r7,#512				@ above is disabled? MADNESS!!
					str r7,[r2,r6]

					
			testSkip:
			add r4,#1
			cmp r4,#113
		bne findAlienBullet				
	
	ldmfd sp!, {r0-r10, pc}
	
@----------------- FIND A SPARE SLOT FOR A BULLET
	@ be warned - this modifies r2,r5
	@ this returns r2=	sprite offset to use
	@					or 255, if none available
findAlienFire:
	stmfd sp!, {r0,r1,r3,r4,r5,lr}
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
		ldmfd sp!, {r0,r1,r3,r4,r5,pc}
		findAlienFireDone:
		add r2, r4, lsl #2			@ return r2 as pointer to bullet
	ldmfd sp!, {r0,r1,r3,r4,r5,pc}
.end
