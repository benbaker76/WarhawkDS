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
	.global alienFireInit
	.global alienFireMove
	.global findAlienFire
	
	@ Fire types
	@ 1-4	=	Directional 1=up, 2=right, 3=down, 4=left (speed 2)
	@ 5-6	=	Directional with Vertical move 5=right, 6=left (move down with scroller) (Speed 2)
	@ 7-10	=	Directional 7=up, 8=right, 9=down, 10=left (speed 4)
	@ 11-12	=	Directional with Vertical move 5=right, 6=left (move down with scroller) (Speed 4)
	@ 13	=	Standard "Warhawk" tracker shot

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

	cmp r3,#9					@ check and init standard linear shots types 1-12
		blmi initStandardShot
		cmp r2,#255
		blne playLaserShotSound
		mov r2,#255
	cmp r3,#9
		bleq initTrackerShot
		cmp r2,#255
		blne playLaserShotSound
		mov r2,#255
	cmp r3,#10
		bleq initAccelShot
		cmp r2,#255
		blne playCrashBuzSound
		mov r2,#255
	cmp r3,#11
		bleq initRippleShot
		cmp r2,#255
		blne playLaserShotSound
		mov r2,#255
	cmp r3,#12
		bleq initRippleTripleShot
		cmp r2,#255
		blne playLaserShotSound
		mov r2,#255
	cmp r3,#13
		bleq initMineShot
		cmp r2,#255
		blne playLowSound
		mov r2,#255
	cmp r3,#14
		bleq initTripleShot
		cmp r2,#255
		blne playLaserShotSound
		mov r2,#255
	cmp r3,#15
		bleq initRippleShotPhase1
		cmp r2,#255
		blne playLaserShotSound
		mov r2,#255
	cmp r3,#16
		bleq initRippleShotPhase2
		cmp r2,#255
		blne playLaserShotSound
		mov r2,#255
	cmp r3,#17
		bleq initDirectShot
		cmp r2,#255
		blne playLaserShotSound
		mov r2,#255
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
	
				cmp r3,#9					@ check for standard shot 1-12
					blmi moveStandardShot
				cmp r3,#9
					bleq moveTrackerShot
				cmp r3,#10
					bleq moveAccelShot
				cmp r3,#11					@ 12 is triple ripple
					bleq moveRippleShot
				cmp r3,#13
					bleq moveMineShot
				@cmp r3,#14	
					@bleq moveTripleShot
					
				cmp r3,#15 					@ 16 is phase 2
					bleq moveRippleShotSingle
				cmp r3,#17
					bleq moveDirectShot

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
				
					bl playSteelSound				@ activate sound for ship being hit!
				
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
@					mov r7,#0
@					str r7,[r2]					@ kill bullet
					
					mov r6,#sptYOffs		@ put bullet X off screen, only works if kill bullet
					mov r7,#788				@ above is disabled? MADNESS!!
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

	.pool
	.end
