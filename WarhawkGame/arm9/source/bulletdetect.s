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
	.global detectALN
	
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

			cmp r4,#33
			bpl nonono
				ldr r1,=vofsSub				@ Draw Crater on Top Screen
				ldr r1,[r1]
				add r1,#192
				add r1,r4
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
		ldr r0,=adder+7				@ add 65 to the score
		mov r1,#5
		strb r1,[r0]
		sub r0,#1
		mov r1,#6
		strb r1,[r0]
		sub r0,#1
		bl addScore

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

			cmp r4,#33
			bpl nononoR
				ldr r1,=vofsSub				@ Draw Crater on Top Screen
				ldr r1,[r1]
				add r1,#192
				add r1,r4
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
		ldr r0,=adder+7				@ add 65 to the score
		mov r1,#5
		strb r1,[r0]
		sub r0,#1
		mov r1,#6
		strb r1,[r0]
		bl addScore

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
	
@-------------------------------------------------------------------	
detectALN:						@ OUR CODE TO CHECK IF BULLET (OFFSET R0) IS IN COLLISION WITH AN ALIEN

	stmfd sp!, {r0-r8, lr}
	@ First we need to grab the X and Y of the bullet and cycle trough the aliens to find a hit
	ldr r1, =spriteX+4			
	ldr r1, [r1, r0, lsl #2]	@ r1= BULLET X
	ldr r2, =spriteY+4			
	ldr r2, [r2, r0, lsl #2]	@ r2= BULLET Y
	add r2,#4
	
	mov r3,#63					@ Alien index (sprites 17 - 80 = 64)

	detectAlienLoop:
		ldr r4,=spriteActive+68		@ add 68 (17*4) for start of aliens
		add r4,r3, lsl #2			@ r4=aliens base offset so we can use the "offs" for data grabbing
		ldr r5,[r4]
		cmp r5,#0
		beq detectNoAlien
		cmp r5,#4
		bpl detectNoAlien
		
		@ Found an ALIEN!!
			@ Do checks
			mov r8,#sptXOffs
			ldr r6,[r4,r8]					@ r6=current Alien X
			add r6,#24						
			cmp r6,r1						@ r1=Bullet x
			bmi detectNoAlien
			sub r6,#24
			add r1,#24
			cmp r6,r1
			sub r1,#24
			bpl detectNoAlien

			mov r8,#sptYOffs
			ldr r6,[r4,r8]					@ r6=current Alien y
			add r6,#24
			cmp r6,r2						@ r2=bullet y
			bmi detectNoAlien
			sub r6,#24
			add r2,#24
			cmp r6,r2
			sub r2,#24
			bpl detectNoAlien
				@ ok, now we need to see how many hits to kill
				mov r8,#sptHitsOffs
				ldr r6,[r4,r8]
				subs r6,#1
				str r6,[r4,r8]
				cmp r6,#0
				bmi detectAlienKill	@	*IS DEAD*
					@ MULTISHOT ALIEN *NOT DEAD*
					@ kill BuLLET
					mov r6,#0
					ldr r8,=spriteActive+4
					str r6, [r8,r0, lsl #2]
					
					mov r8,#sptBloomOffs
					ldr r6,[r4,r8]			@ load palette number (bloom)
					cmp r6,#0				@ if it zero
					moveq r6,#16			@ if so, we can do bloom (we have 11 pallets for this)
					str r6,[r4,r8]			@ store it back
		
					@ ok, alien not dead yet!!, so, play "Hit" sound
					@ and perhaps a "shard" (mini explosion) activated under BaseExplosion?
					mov r8,#sptXOffs
					ldr r6,[r4,r8]
					mov r6,r1			@ just test with bullet x (comment out to use alien x)
					mov r8,#sptYOffs
					ldr r7,[r4,r8]
					bl drawShard
					
					@ add score
					ldr r8,=adder+7				@ add 5 to the score
					mov r6,#5
					strb r6,[r8]
					bl addScore	
					bl playShipArmourHit1Sound
					b detectNoAlien
			
			detectAlienKill:
				@ explode alien
				mov r6,#4
				str r6,[r4]
				mov r6,#6
				mov r8,#sptObjOffs
				str r6,[r4,r8]
				mov r6,#4
				mov r8,#sptExpDelayOffs
				str r6,[r4,r8]
				@ kill BuLLET
				mov r6,#0
				ldr r8,=spriteActive+4
				str r6, [r8,r0, lsl #2]
				@ add score
				ldr r8,=adder+7				@ add 78 to the score
				mov r6,#8
				strb r6,[r8]
				sub r8,#1
				mov r6,#7
				strb r6,[r8]
				bl addScore		
				bl playAlienExplodeSound
	
		detectNoAlien:
		subs r3,#1
		bpl detectAlienLoop
	
	ldmfd sp!, {r0-r8, pc}
@--------------------------- Draw "shard" at alien coord r6,r7	
drawShard:
	stmfd sp!, {r1-r3, lr}

	ldr r1,=spriteActive
	mov r2,#127
	shardFindBase:
		ldr r3,[r1,r2, lsl #2]
		cmp r3,#0
		beq startShard
		sub r2,#1
		cmp r2,#111
	bne shardFindBase
	ldmfd sp!, {r1-r3, pc}
	
	startShard:
	@ r2=sprite number to use for a shard! (6 is active ident for a shard)

	mov r3,#6						@ and r6 is the sprite number to use for explosion
	str r3,[r1,r2, lsl #2]			@ set sprite to "base explosion"
	ldr r1,=spriteObj
	mov r3,#22						@ sprite 13-1 as added to on first update in drawsprite.s
	str r3,[r1,r2, lsl #2]			@ set object to explosion frame
	ldr r1,=spriteX
	str r6,[r1,r2, lsl #2]			@ store r1 as X, calculated above
	ldr r1,=spriteY
	add r7,#24
	str r7,[r1,r2, lsl #2]			@ store r2 as Y, calculated above
	ldr r1,=spriteExplodeDelay
	mov r3,#2						@ Set sprite delay for anim (once evey 4 updates seems to work nice)
	str r3,[r1,r2, lsl #2]
	ldmfd sp!, {r1-r3, pc}
