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
	.global moveShip

moveShip:
	stmfd sp!, {r0-r8, lr}
	ldr r5,=deathMode
	ldr r5,[r5]					@ if in final death throws, player cannot move
	cmp r5,#DEATHMODE_MAIN_EXPLODE
	bpl dircheck4
	
	ldr r5,=spriteObj			@ simple bit of animation code for the ship
	ldr r6,[r5]					@ r6 is the frame

	ldr r7,=shipAnimDelay
	ldr r8,[r7]
	add r8,#1
	str r8,[r7]
	cmp r8,#4					@ change this for the delay!(4 works ok on hardware for me?)
	bne noShipAnim
		mov r8,#0
		str r8,[r7]
		add r6,#1
		cmp r6,#3
		moveq r6,#0
		str r6,[r5]	
	noShipAnim:
	
	ldr r5,=spriteY
	ldr r6,=spriteX
	ldr r1,=REG_KEYINPUT		@ Read the keys!
	ldr r7,=powerUp				@ check if we are "Powered up"
	ldr r7,[r7]
	cmp r7, #1					@ a 1 signals a power up
	moveq r7,#5					@ if so, move 5 pixels per refresh
	movne r7,#3					@ if not, move our standard 3

								@ r7 now holds our ship speed
	ldr r2,[r1]					@ R2 is the input (except X and Y handled by ARM7)
	tst r2,#BUTTON_UP			@ UP (and with value to isolate direction)
	bne dircheck1
	@ Up code
		ldr r8,[r5]
		subs r8,r7
		cmp r8,#384+8
		movmi r8,#384+8
		str r8,[r5]
		b dircheck2
	dircheck1:
	ldr r2,[r1]					@ R2 is the input (except X and Y handled by ARM7)
	tst r2,#BUTTON_DOWN			@ DOWN (and with value to isolate direction)
	bne dircheck2
	@ Down code
		ldr r8,[r5]
		add r8,r7
		cmp r8,#736
		movpl r8,#736
		str r8,[r5]
	dircheck2:
	ldr r2,[r1]					@ R2 is the input (except X and Y handled by ARM7)
	tst r2,#BUTTON_LEFT			@ LEFT (and with value to isolate direction)
	bne dircheck3
	@ Left code
		ldr r8,=horizDrift
		ldr r8, [r8]
		cmp r8,#0
		beq leftmove
			subs r8,r7, lsr #1
			cmp r8,#0
			movmi r8,#0
			ldr r4,=horizDrift
			strb r8,[r4]
			ldr r8,[r6]
			subs r8,r7, lsr #1
			cmp r8,#64
			movle r8,#64
			b dircheck2pass
		leftmove:
		ldr r8,[r6]
		subs r8,r7
		cmp r8,#64
		movle r8,#64
		dircheck2pass:
		str r8,[r6]
		b dircheck4
	dircheck3:
	ldr r2,[r1]					@ R2 is the input (except X and Y handled by ARM7)
	tst r2,#BUTTON_RIGHT		@ RIGHT (and with value to isolate direction)
	bne dircheck4
	@ Right code
		ldr r8,=horizDrift
		ldr r8, [r8]
		cmp r8,#64
		beq rightmove
			add r8,r7, lsr #1
			cmp r8,#64
			movpl r8,#64
			ldr r4,=horizDrift
			strb r8,[r4]
			
			ldr r8,[r6]
			mov r4,#256
			add r4,#32
			adds r8,r7,lsr #1
			cmp r8,r4
			movge r8,r4
			b dircheck3pass
		rightmove:
		ldr r8,[r6]
		mov r4,#256
		add r4,#32		
		adds r8,r7
		cmp r8,r4			@ 256-sprite width
		movge r8,r4
		dircheck3pass:
		str r8,[r6]
	dircheck4:
	
	ldmfd sp!, {r0-r8, pc}
	
	.pool
	.end

