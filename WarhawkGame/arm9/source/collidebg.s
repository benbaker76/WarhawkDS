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
	.global detectBGL
	.global detectBGR
	
@-------------- DETECT Left BULLET
detectBGL:						@ OUR CODE TO CHECK IF BULLET (OFFSET R0) IS IN COLLISION WITH A BASE
								@ AND LATER ALSO CHECK AGAINST ENEMIES
	stmfd sp!, {r0-r6, lr}
	
	ldr r1, =spriteX+4			@ DO X COORD CONVERSION
	ldr r1, [r1, r0, lsl #2]	@ r1=our x coord
	sub r1, #64					@ our sprite starts at 64 (very left of map) + 6 for left bullet
	add r1, #6					@ our left bullet is right a bit in the sprite
	lsr r1, #5					@ divide x by 32
	ldr r2, =spriteY+4			@ DO Y COORD CONVERSION
	ldr r2, [r2, r0, lsl #2]	@ r2=our BULLETS y coord	
	sub r2, #384				@ take 384 off our coord, as this is the top of the screen
	lsr r2,#5					@ convert to a 32 block
	lsl r2,#5					
	ldr r3,=yposSub
	ldr r3,[r3]					@ load the yposSub
	sub r3,#160					@ take that bloody 160 off
	add r3,r2					@ add our scroll and bullet y together
	lsr r3,#5					@ divide by 32 (our blocks)
	lsl r3,#4					@ mul by 16	to convert to our colMap format	
	add r3,r1					@ add our X, r3 is now an offset to our collision data

	ldr r4,=colMap
	ldrb r6,[r4,r3]			@ Check in collision map with r3 as byte offset
	cmp r6,#0					@ if we find a 0 = no hit!
	beq no_hit
	cmp r6,#3					@ 1 and 2 = Hit!
	bpl no_hit
	bl playExplosionSound

	lsl r6,#2 					@ times by 4
	ldr r9,=craterFrame			@ get our frame for use as a crater
	ldr r8,[r9]
	add r8,#1					@ add one to it
	cmp r8,#4					@ are we at crater 5 (0-4)
	moveq r8,#0					@ if so, reset back to the first crater
	str r8,[r9]					@ store it back
	add r6,r8					@ and add it to our collmap ref!
	strb r6, [r4, r3]			@ store CRATER in collmap (as 4 or 8) + frame (0-3)
	mov r9,r6					@ save r6 in r9 for the crater draw

@-------------- the CRATER draw code	
		push {r0-r4}				@ We need a check for if crater at top on main, draw also base of sub
		ldr r4, =spriteY+4			@ DO Y COORD CONVERSION
		ldr r4, [r4, r0, lsl #2]
		lsr r4,#5					@ convert to a 32 block
		lsl r4,#5

		ldr r1,=575
		cmp r4,r1
		bpl bottomS
			ldr r1,=vofsSub		@---- Draw Crater on Top Screen
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
			bl drawCraterBlockSub	
			b nonono
			
		bottomS:
			ldr r1,=vofsSub		@---- Draw crater on Bottom Screen
			ldr r1,[r1]
			sub r4,#576
			add r1,r4
			lsr r1,#5
			lsl r1,#2	
			ldr r2, =spriteX+4				@ DO Y COORD CONVERSION
			ldr r2, [r2, r0, lsl #2]
			sub r2,#58						@ 64 - 6 (bullet offset)
			lsr r2, #5
			lsl r2, #2
			mov r0,r2
			push {r0}
			bl drawCraterBlockMain
			pop {r0}

			cmp r10,#0
			bne nonono
				ldr r1,=vofsSub				@ Draw Crater on Top Screen
				ldr r1,[r1]
				add r1,#192
				lsr r1,#5
				lsl r1,#2	
				bl drawCraterBlockSub

		nonono:
		pop {r0-r4}	
@--------------- end of CRATER draw code
	
		mov r10,#6
		bl initBaseExplode			@ Draw the EXPLOSION
									@ pass r5 with the offset for the bullet (ie 6)
		
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

@-------------- DETECT Right BULLET	
detectBGR:						@ OUR CODE TO CHECK IF BULLET (OFFSET R0) IS IN COLLISION WITH A BASE
								@ AND LATER ALSO CHECK AGAINST ENEMIES
	stmfd sp!, {r0-r6, lr}
	
	ldr r1, =spriteX+4			@ DO X COORD CONVERSION
	ldr r1, [r1, r0, lsl #2]	@ r1=our x coord
	sub r1, #64					@ our sprite starts at 64 (very left of map) + 6 for left bullet
	add r1, #24					@ our left bullet is right a bit in the sprite
	lsr r1, #5					@ divide x by 32
	ldr r2, =spriteY+4			@ DO Y COORD CONVERSION
	ldr r2, [r2, r0, lsl #2]	@ r2=our BULLETS y coord	
	sub r2, #384				@ take 384 off our coord, as this is the top of the screen
	lsr r2,#5					@ convert to a 32 block
	lsl r2,#5					
	ldr r3,=yposSub
	ldr r3,[r3]					@ load the yposSub
	sub r3,#160					@ take that bloody 160 off
	add r3,r2					@ add our scroll and bullet y together
	lsr r3,#5					@ divide by 32 (our blocks)
	lsl r3,#4					@ mul by 16	to convert to our colMap format	
	add r3,r1					@ add our X, r3 is now an offset to our collision data

	ldr r4,=colMap
	ldrb r6,[r4,r3]			@ Check in collision map with r3 as byte offset
	cmp r6,#0					@ if we find a 0 = no hit!
	beq no_hitR
	cmp r6,#3					@ 1 and 2 = Hit!
	bpl no_hitR
	bl playExplosionSound

	lsl r6,#2 					@ times by 4
	ldr r9,=craterFrame			@ get our frame for use as a crater
	ldr r8,[r9]
	add r8,#1					@ add one to it
	cmp r8,#4					@ are we at crater 5 (0-4)
	moveq r8,#0					@ if so, reset back to the first crater
	str r8,[r9]					@ store it back
	add r6,r8					@ and add it to our collmap ref!
	strb r6, [r4, r3]			@ store CRATER in collmap (as 4 or 8) + frame (0-3)
	mov r9,r6					@ save r6 in r9 for the crater draw

@-------------- the CRATER draw code	
		push {r0-r4}				@ We need a check for if crater at top on main, draw also base of sub
		ldr r4, =spriteY+4			@ DO Y COORD CONVERSION
		ldr r4, [r4, r0, lsl #2]
		lsr r4,#5					@ convert to a 32 block
		lsl r4,#5

		ldr r1,=575
		cmp r4,r1
		bpl bottomSR
			ldr r1,=vofsSub		@---- Draw Crater on Top Screen
			ldr r1,[r1]
			sub r4,#384
			add r1,r4
			lsr r1,#5
			lsl r1,#2	
			ldr r2, =spriteX+4			@ DO X COORD CONVERSION
			ldr r2, [r2, r0, lsl #2]
			sub r2,#30					@ 64 - 6 (bullet offset)
			lsr r2, #5
			lsl r2, #2
			mov r0,r2
			bl drawCraterBlockSub	
			b nononoR
			
		bottomSR:
			ldr r1,=vofsSub		@---- Draw crater on Bottom Screen
			ldr r1,[r1]
			sub r4,#576
			add r1,r4
			lsr r1,#5
			lsl r1,#2	
			ldr r2, =spriteX+4				@ DO Y COORD CONVERSION
			ldr r2, [r2, r0, lsl #2]
			sub r2,#30						@ 64 - 6 (bullet offset)
			lsr r2, #5
			lsl r2, #2
			mov r0,r2
			push {r0}
			bl drawCraterBlockMain
			pop {r0}

			cmp r10,#0
			bne nononoR
				ldr r1,=vofsSub				@ Draw Crater on Top Screen
				ldr r1,[r1]
				add r1,#192
				lsr r1,#5
				lsl r1,#2	
				bl drawCraterBlockSub

		nononoR:
		pop {r0-r4}	
@--------------- end of CRATER draw code
	
		mov r10,#24
		bl initBaseExplode			@ Draw the EXPLOSION
									@ pass r5 with the offset for the bullet (ie 6)
		
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

	no_hitR:

	ldmfd sp!, {r0-r6, pc}
	
@-------------- The init EXPLOSION Code
@ first find a blank explosion from 113-127
initBaseExplode:
	stmfd sp!, {r0-r6, lr}
	ldr r4,=spriteActive
	mov r6,#127
	expFindBase:
		ldr r5,[r4,r6, lsl #2]
		cmp r5,#0
		beq startBaseExp
		sub r6,#1
		cmp r6,#111
	bne expFindBase
	ldmfd sp!, {r0-r6, pc}
		
	startBaseExp:
									@ r6 is our ref to the explosion sprite
									@ calculate the x/y to plot explosion
		ldr r1, =spriteX+4			@ DO X COORD CONVERSION
		ldr r1, [r1, r0, lsl #2]	@ r1=our x coord
		add r1, r10					@ our left bullet is right a bit in the sprite
		lsr r1, #5					@ divide x by 32
		lsl r1, #5					@ multiply by 32
		ldr r2, =spriteY+4			@ DO Y COORD CONVERSION
		ldr r2, [r2, r0, lsl #2]	@ r2=our y coord
		ldr r3,=pixelOffsetMain		@ load our pixeloffset (1-32)
		ldr r3,[r3]
		subs r3,#1					@ try to compensate for pixeloffs being 1-32 (need 0-31)
		movmi r3,#31				@ pixel offset is now 0-31
		lsr r2, #5					@ divide bullet coord by 32
		lsl r2, #5					@ times by 32	: this aligns to a block of 32x32
		add r2,r3					@ add them together

		sub r2,#32					@ re align	
									@ r4 is sprite active register already
	mov r5,#5						@ and r6 is the sprite number to use for explosion
	str r5,[r4,r6, lsl #2]			@ set sprite to "base explosion"
	ldr r4,=spriteObj
	mov r5,#12						@ sprite 13-1 as added to on first update in drawsprite.s
	str r5,[r4,r6, lsl #2]			@ set object to explosion frame
	ldr r4,=spriteX
	str r1,[r4,r6, lsl #2]			@ store r1 as X, calculated above
	ldr r4,=spriteY
	str r2,[r4,r6, lsl #2]			@ store r2 as Y, calculated above
	ldr r4,=spriteExplodeDelay
	mov r2,#4						@ Set sprite delay for anim (once evey 4 updates seems to work nice)
	str r2,[r4,r6, lsl #2]

	ldmfd sp!, {r0-r6, pc}			@ all done