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
	.global bossLurcherMovement
	.global bossCraneMovement
	.global bossSine1Movement
	.global bossSine2Movement
	
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
	sub r0,#48
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
		@ move hunter up!
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
		@ move hunter down!
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
	
@------------ MOVE BOSS ATTACK "2=LURCHER" (LUNGE AT PLAYER)
bossLurcherMovement:
	stmfd sp!, {r0-r8, lr}
	bl bossAttackLR			@ we are still moving left/right, so use that code!
	
	ldr r0,=spriteX
	ldr r0,[r0]
	ldr r1,=horizDrift
	ldr r1,[r1]
	add r0,r1				@ r0=Players X coord
	
	@ read bossYDir (0=on line, 1=Down, 2=Up)
	
	ldr r1,=bossYDir
	ldr r2,[r1]
	cmp r2,#0
	bne bossLurching
		@ we are on the top line, so lets check for X coord match
		@ if bossX+96>r0 and bossx<r0+32
		ldr r3,=bossX
		ldr r4,[r3]					@ r4=bossX
		add r4,#96-8
		cmp r4,r0
		bmi bossLurcherDone
		sub r4,#96-8
		add r0,#32
		cmp r4,r0
		bpl bossLurcherDone
		@ ok, we are now within range, lets make a LURCH :)
		mov r2,#1
		str r2,[r1]					@ set bossYDir to 1 (down)
		mov r2,#0
		ldr r1,=bossYSpeed
		str r2,[r1]					@ set Y speed to 0
		ldr r1,=bossTurn
		ldr r3,[r1]
		ldr r1,=bossYDelay
		str r3,[r1]					@ reset the speed change countdown
		b bossLurcherDone
	
	bossLurching:
		@ first check and update the friction delay
		ldr r3,=bossYDelay
		ldr r4,[r3]
		subs r4,#1
		str r4,[r3]
		ldr r4,=bossYSpeed
		ldr r4,[r4]
		bpl bossLurcherAdds
		ldr r5,=bossTurn
		ldr r4,[r5]
		str r4,[r3]					@ resest the friction/delay to bossTurn
	
		cmp r2,#1
		bne bossLurchUp
			@ ok, boss is coming down, so we need to update the Y speed +
			@ and check if we are below a set point, and if so, go back up!!
			
			ldr r3,=bossY
			ldr r3,[r3]
			ldr r5,=591
			
			ldr r7,=bossRightMax	@ replacement CODE SECTION???
			ldr r7,[r7]
			ldr r8,=bossMaxY
			ldr r8,[r8]
			sub r7, r8, lsl #4
			sub r7,r8
			sub r7,#64+48
			add r5,r7
				
	@		ldr r6,=bossMaxY
	@		ldr r6,[r6]
	@		sub r5,r6
	@		lsl r6,#1
	@		sub r5,r6
			cmp r3,r5
			bmi bossLurcherDownUpdate
				mov r3,#2
				str r3,[r1]			@ set movement to UP
				b bossLurcherDone
			bossLurcherDownUpdate:
			ldr r3,=bossYSpeed
			ldr r4,[r3]
			ldr r5,=bossMaxY
			ldr r5,[r5]
			adds r4,#1
			cmp r4,r5
			movgt r4,r5
			str r4,[r3]
			b bossLurcherAdds
	
		bossLurchUp:
			ldr r5,=bossY
			ldr r3,[r5]
			ldr r6,=438
			ldr r7,=bossMaxY		@ max Y speed
			ldr r7,[r7]
			add r6,r7
			lsl r7,#4
			add r6,r7
			cmp r3,r6
			bgt bossLurcherReturnUpdateFaster
				Ldr r7,=bossYSpeed
				ldrsb r4,[r7]
				cmp r4,#-1
				bge bossLurcherNoSlow
					add r4,#1
					str r4,[r7]
					b bossLurcherAdds
				bossLurcherNoSlow:
				ldr r6,=438
				add r6,r4
				cmp r3,r6
				bge bossLurcherAdds
				ldr r6,=438
				str r6,[r5]			@ reset Y coord
				mov r3,#0
				str r3,[r1]			@ set movement "Done"
				b bossLurcherDone
			bossLurcherReturnUpdateFaster:
			ldr r3,=bossYSpeed
			ldr r4,[r3]
			ldr r5,=bossMaxY
			ldr r5,[r5]
			rsb r5,r5,#0
			subs r4,#1
			cmp r4,r5
			movmi r4,r5
			str r4,[r3]
			b bossLurcherAdds
	
	bossLurcherAdds:
			ldr r5,=bossY
			ldr r6,[r5]
			adds r6,r4
			str r6,[r5]
	
	bossLurcherDone:
	
	
	ldmfd sp!, {r0-r8, pc}

@------------ MOVE BOSS ATTACK "3=CRANE" (Track Y and follow sine)
bossCraneMovement:
	stmfd sp!, {r0-r8, lr}
	bl bossAttackLR			@ we are still moving left/right, so use that code!
	@ r0=Players Y coord / r1=Boss Y coord
	ldr r0,=spriteY
	ldr r0,[r0]
	sub r0,#48
	ldr r8,=bossY
	ldr r1,[r8]				@ we will use this later (r8)
	add r1,#32
	
	ldr r2,=bossYDelay
	ldr r3,[r2]
	subs r3,#1				@ decrement the X delay
	str r3,[r2]
	ldr r3,=bossYSpeed
	ldr r3,[r3]
	bpl bossCraneDone
	ldr r4,=bossTurn
	ldr r4,[r4]
	str r4,[r2]				@ reset the delay
		
	cmp r0,r1
	bgt bossCraneDown
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
		b bossCraneDone
	bossCraneDown:
		@ move hunter left!
		ldr r2,=bossYSpeed
		ldrsb r3,[r2]
		add r3,#1
		ldr r4,=bossMaxY
		ldr r4,[r4]
		cmp r3,r4
		movpl r3,r4
		str r3,[r2]			@ store new speed back	
		
	bossCraneDone:
	ldr r1,[r8]
	adds r1,r3
	str r1,[r8]		
	
	ldmfd sp!, {r0-r8, pc}
	
@------------ MOVE BOSS ATTACK "4=Sine1" (Sine Y move)
bossSine1Movement:
	stmfd sp!, {r0-r8, lr}
	bl bossAttackLR			@ we are still moving left/right, so use that code!
	
	ldr r0,=bossYSpeed
	ldr r1,[r0]
	ldr r2,=bossSine1
	ldrb r2,[r2,r1]			@ r2=Y poss in sine
	ldr r3,=438
	add r2,r3
	ldr r4,=bossY
	str r2,[r4]
	
	add r1,#1
	cmp r1,#320
	moveq r1,#0
	str r1,[r0]
	
	ldmfd sp!, {r0-r8, pc}
	
@------------ MOVE BOSS ATTACK "5=Sine2" (Sine Y move)
bossSine2Movement:
	stmfd sp!, {r0-r8, lr}
	bl bossAttackLR			@ we are still moving left/right, so use that code!
	
	ldr r0,=bossYSpeed
	ldr r1,[r0]
	ldr r2,=bossSine2
	ldrb r2,[r2,r1]			@ r2=Y poss in sine
	ldr r3,=438
	add r2,r3
	ldr r4,=bossY
	str r2,[r4]
	
	add r1,#1
	cmp r1,#440
	moveq r1,#0
	str r1,[r0]
	
	ldmfd sp!, {r0-r8, pc}