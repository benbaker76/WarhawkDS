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

	.arm
	.align
	.text
	
	.global bossAttackLR
	.global bossHunterMovement
	
@------------ MOVE BOSS ATTACK "0=STANDARD" (LEFT/RIGHT INERTIA)
bossAttackLR:
	stmfd sp!, {r0-r8, lr}
	
	ldr r8,=bossLeftMin
	ldr r8,[r8]
	ldr r9,=bossRightMax
	ldr r9,[r9]
	ldr r4,=bossXDir
	ldr r0,[r4]					@ r0/r4 0=left / 1=right
	ldr r6,=bossX
	ldr r3,[r6]					@ r3/r6 boss X
	ldr r1,=bossXSpeed
	ldr r2,[r1]	
	ldr r1,=bossTurn
	ldr r5,[r1]
	ldr r1,=bossXDelay
	ldr r7,[r1]
	add r7,#1
	cmp r7,r5
	moveq r7,#0
	str r7,[r1]
	beq bossMoveLR
	b noBossUpdate
	@------ BOSS LEFT/RIGHT UPDATE
	bossMoveLR:
	cmp r0,#0
	bne bossRight
		@ move left
		ldr r5,=bossMaxX
		ldr r5,[r5]
		rsb r5,r5,#0
		ldr r1,=bossXSpeed
		ldr r2,[r1]				@ r2 = current X speed
		subs r2,#1
		cmp r2,r5
		movmi r2,r5
		str r2,[r1]
		cmp r3,r8			@ the compare should be (180-32)-maxBossXspeed*2 (ish)
		movmi r0,#1
		b noBossUpdate
	bossRight:
		@ move right
		ldr r5,=bossMaxX
		ldr r5,[r5]
		ldr r1,=bossXSpeed
		ldr r2,[r1]				@ r2 = current X speed
		adds r2,#1
		cmp r2,r5
		movpl r2,r5
		str r2,[r1]
		cmp r3,r9		
		movpl r0,#0
	@-------- END OF BOSS MOVE
	noBossUpdate:	
	str r0,[r4]

	adds r3,r2
	str r3,[r6]
	ldmfd sp!, {r0-r8, PC}
	

@------------ MOVE BOSS ATTACK "1=HUNTER" (TRACK ONTO PLAYER)
bossHunterMovement:
	stmfd sp!, {r0-r8, lr}
	@ first let us work on X coords
	@ r0=Players X coord / r1=Boss X coord
	ldr r0,=spriteX
	ldr r0,[r0]
	ldr r1,=horizDrift
	ldr r1,[r1]
	add r0,r1
	ldr r8,=bossX
	ldr r1,[r8]				@ we will use this later (r8)
	add r1,#32
	
	ldr r2,=bossXDelay
	ldr r3,[r2]
	subs r3,#1				@ decrement the X delay
	str r3,[r2]
	ldr r3,=bossXSpeed
	ldr r3,[r3]
	bpl bossHunterXDone
	ldr r4,=bossTurn
	ldr r4,[r4]
	str r4,[r2]				@ reset the delay
		
	cmp r0,r1
	bgt bossHunterRight
		@ move hunter left!
		ldr r2,=bossXSpeed
		ldrsb r3,[r2]
		subs r3,#1
		ldr r4,=bossMaxX
		ldr r4,[r4]
		rsb r4,r4,#0
		cmp r3,r4
		movmi r3,r4
		str r3,[r2]			@ store new speed back
		b bossHunterXDone
	bossHunterRight:
		@ move hunter left!
		ldr r2,=bossXSpeed
		ldrsb r3,[r2]
		add r3,#1
		ldr r4,=bossMaxX
		ldr r4,[r4]
		cmp r3,r4
		movpl r3,r4
		str r3,[r2]			@ store new speed back	
		
	bossHunterXDone:
	ldr r1,[r8]
	adds r1,r3
	str r1,[r8]

	@ next let us work on Y coords
	@ r0=Players Y coord / r1=Boss Y coord
	ldr r0,=spriteY
	ldr r0,[r0]
	ldr r8,=bossY
	ldr r1,[r8]				@ we will use this later (r8)
	add r1,#32
	
	ldr r2,=bossYDelay
	ldr r3,[r2]
	subs r3,#1				@ decrement the X delay
	str r3,[r2]
	ldr r3,=bossYSpeed
	ldr r3,[r3]
	bpl bossHunterYDone
	ldr r4,=bossTurn
	ldr r4,[r4]
	str r4,[r2]				@ reset the delay
		
	cmp r0,r1
	bgt bossHunterDown
		@ move hunter left!
		ldr r2,=bossYSpeed
		ldrsb r3,[r2]
		subs r3,#1
		ldr r4,=bossMaxY
		ldr r4,[r4]
		rsb r4,r4,#0
		cmp r3,r4
		movmi r3,r4
		str r3,[r2]			@ store new speed back
		b bossHunterYDone
	bossHunterDown:
		@ move hunter left!
		ldr r2,=bossYSpeed
		ldrsb r3,[r2]
		add r3,#1
		ldr r4,=bossMaxY
		ldr r4,[r4]
		cmp r3,r4
		movpl r3,r4
		str r3,[r2]			@ store new speed back	
		
	bossHunterYDone:
	ldr r1,[r8]
	adds r1,r3
	str r1,[r8]	
	
	ldmfd sp!, {r0-r8, PC}
	
