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
	.global moveShip

moveShip:
	stmfd sp!, {r0-r8, lr}
	ldr r5,=spriteObj			@ simple bit of animation code for the ship
	ldr r6,[r5]
	add r6,#1
	cmp r6,#3
	moveq r6,#0
	str r6,[r5]
	
	ldr r5,=spriteY
	ldr r6,=spriteX
	ldr r1,=REG_KEYINPUT		@ Read the keys!
	ldrb r7,=powerUp				@ check if we are "Powered up"
	cmp r7, #1					@ a 1 signals a power up
	moveq r7,#4					@ if so, move 4 pixels per refresh
	movne r7,#2					@ if not, move our standard 2
	
								@ r7 now holds our ship speed
	ldr r2,[r1]					@ R2 is the input (except X and Y handled by ARM7)
	tst r2,#BUTTON_UP			@ UP (and with value to isolate direction)
	bne dircheck1
	@ Up code
		ldr r8,[r5]
		subs r8,#2
		cmp r8,#576
		movmi r8,#576
		str r8,[r5]
		b dircheck2
	dircheck1:
	ldr r2,[r1]					@ R2 is the input (except X and Y handled by ARM7)
	tst r2,#BUTTON_DOWN			@ DOWN (and with value to isolate direction)
	bne dircheck2
	@ Down code
		ldr r8,[r5]
		adds r8,#2
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
			sub r8,r7, lsr #1
			ldr r4,=horizDrift
			strb r8,[r4]
			ldr r8,[r6]
			subs r8,r7, lsr #1
			cmp r8,#64
			movmi r8,#64
			b dircheck2pass
		leftmove:
		ldr r8,[r6]
		subs r8,r7
		cmp r8,#64
		movmi r8,#64
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
			ldr r4,=horizDrift
			strb r8,[r4]
			ldr r8,[r6]
			mov r4,#256
			add r4,#32
			adds r8,r7,lsr #1
			cmp r8,r4
			movpl r8,r4
			b dircheck3pass
		rightmove:
		ldr r8,[r6]
		mov r4,#256
		add r4,#32		
		adds r8,r7
		cmp r8,r4			@ 256-sprite width
		movpl r8,r4
		dircheck3pass:
		str r8,[r6]
	dircheck4:
	
	ldmfd sp!, {r0-r8, pc} 
