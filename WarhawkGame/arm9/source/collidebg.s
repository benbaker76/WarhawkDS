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
	.global detectBG
	
detectBG:						@ OUR CODE TO CHECK IF BULLET (OFFSET R0) IS IN COLLISION WITH A BASE
								@ AND LATER ALSO CHECK AGAINST ENEMIES
	stmfd sp!, {r0-r6, lr}

	
	ldr r1, =spriteX+4			@ DO X COORD CONVERSION
	ldr r1, [r1, r0, lsl #2]	@ r1=our x coord
	sub r1, #64					@ our sprite starts at 64 (very left of map) + 6 for left bullet
	add r1, #6					@ our left bullet is right a bit in the sprite
	lsr r1, #5					@ divide x by 32

	ldr r2, =spriteY+4			@ DO Y COORD CONVERSION
	ldr r2, [r2, r0, lsl #2]	@ r2=our y coord	
	sub r2, #384				@ take 384 (top pixel of top screen) off our bullets y pos
	

	ldr r3,=yposSub
	ldr r3,[r3]					@ load the yposSub
	sub r3,#160					@ take that bloody 160 off
	add r3,r2					@ add our scroll and bullet y together
	lsr r3,#5					@ divide by 32 (our blocks)

	lsl r3,#4					@ mul by 16	to convert to our colMap format	
	add r3,r1					@ add our X, piece of piss!!! :) and we struggled, pah!!!
	
@	bl debugStuff

@	bl debugStuff2
	
	@ r3 is now an offset to our collision data. Collision data is a long string containing a byte
	@ for every block on the screen (32x32). so, if r3 is 11, we know that (from the top of the map)
	@ this is the 3rd 32 block in on the second block down.
	@ each line is 0-9 10-19 20-29 etc.
	@ we must be able to use this to locate the map data that we have cached and alter tzhem tiles???
	@ we need to find the top left tile offset (8x8) and dump the data in a 32x32 bloczk..z

	ldr r4,=colMap
	ldrb r6,[r4,r3]			@ Check in collision map with r3 as byte offset
	cmp r6,#1					@ if we find a 1 = it is a hit!
	bne no_hit
	
	mov r6, #2
	strb r6, [r4, r3]
	
@-------------- the draw code	
		push {r0-r4}
		ldr r4, =spriteY+4			@ DO Y COORD CONVERSION
		ldr r4, [r4, r0, lsl #2]
		ldr r1,=575
		cmp r4,r1
		bpl bottomS
			ldr r1,=vofsSub
			ldr r1,[r1]
			sub r4,#384
			add r1,r4
			lsr r1,#5
			lsl r1,#2
			
			ldr r2, =spriteX+4			@ DO X COORD CONVERSION
			ldr r2, [r2, r0, lsl #2]
			sub r2,#58					@ 64 - 6 (bullet offset)
			lsr r2, #5
			lsl r2, #2
			mov r0,r2
			bl drawDamagedBlockSub
			b nonono

		bottomS:
		ldr r1,=vofsSub
		ldr r1,[r1]
		sub r4,#576
		add r1,r4
		lsr r1,#5
		lsl r1,#2
		ldr r2, =spriteX+4			@ DO Y COORD CONVERSION
		ldr r2, [r2, r0, lsl #2]
		sub r2,#58					@ 64 - 6 (bullet offset)
		lsr r2, #5
		lsl r2, #2
		mov r0,r2

		bl drawDamagedBlockMain
		nonono:
		pop {r0-r4}	
@--------------- end of draw code

		
@		kill:						@ use this to detect where the collision occurs
@		b kill
	
			
		ldr r1, =spriteActive+4		@ Kill the bullet
		mov r2,#0
		str r2, [r1, r0, lsl #2]
		ldr r0,=adder+7				@ add 321 to the score
		mov r1,#1
		strb r1,[r0]
		sub r0,#1
		mov r1,#2
		strb r1,[r0]
		sub r0,#1
		mov r1,#3
		strb r1,[r0]

	
	no_hit:

	ldmfd sp!, {r0-r6, pc}
	
debugStuff:
	@ moved this here to make it easier to follow the code!!!
	stmfd sp!, {r0-r6, lr}
			push { r0-r3 }
			ldr r0, =blockXText			@ Load out text pointer
			ldr r1, =0					@ x pos
			ldr r2, =8					@ y pos
			ldr r3, =1					@ Draw on Sub screen
			bl drawText
			pop { r0-r3 }
	
			mov r10, r1					@ display our X as a 32x32 horizontal block number (WORKS)
			mov r8, #8					@ y pos
			mov r9, #3					@ digits
			mov r11, #9					@ x pos
			bl drawDigits
			
			push { r0-r3 }
			ldr r0, =blockYText			@ Load out text pointer
			ldr r1, =0					@ x pos
			ldr r2, =10					@ y pos
			ldr r3, =1					@ Draw on Sub screen
			bl drawText
			pop { r0-r3 }

			mov r10,r2					@ display our y as a 32x32 horizontal block number (WORKS)
			mov r8, #10					@ y pos
			mov r9, #3					@ digits
			mov r11, #9					@ x pos
			bl drawDigits
	ldmfd sp!, {r0-r6, pc}
	
debugStuff2:
	stmfd sp!, {r0-r6, lr}
			push { r0-r3 }
			ldr r0, =tileNumText		@ Load out text pointer
			ldr r1, =0					@ x pos
			ldr r2, =12					@ y pos
			ldr r3, =1					@ Draw on Sub screen
			bl drawText
			pop { r0-r3 }				
								
			mov r10,r3
			mov r8, #12					@ y pos
			mov r9, #6					@ digits
			bl drawDigits
	ldmfd sp!, {r0-r6, pc}