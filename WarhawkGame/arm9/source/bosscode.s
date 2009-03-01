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

	.global checkBossInit
	.global bossAttack
	.global bossIsShot
	
@----------------- BOSS INIT CODE	
checkBossInit:
	stmfd sp!, {r1-r2, lr}
	@ this uses yposSub to tell when we should display the BOSS
	@ Perhaps levelend will tell us when to move him???
	@ not sure?
	@ we will use bossMan as a flag to say that he is HERE!!!
	@ 0= no, 1=yes, but not ready to move, 2=attack time
	ldr r0,=bossMan
	ldr r0,[r0]
	cmp r0,#1
	beq bossActiveScroll		@ Use this to scroll the Boss with the bg1
	cmp r0,#2
	bne bossInit
		bl bossAttack			@ if he is active, let "bossAttack" do the work
		b checkBossInitFail
	bossInit:
	ldr r0,=yposSub
	ldr r0,[r0]
	cmp r0,#352					@ scroll pos to init BOSS
	bne checkBossInitFail		@ not time yet :(
		@ here we need to lay all the sprites and data out for the boss
		
		mov r1,#1
		ldr r0,=bossMan
		str r1,[r0]				@ set to "scroll mode" (So he will move with scroll only!)
	
		@ FIRST, we need to copy the sprites from "BossShipTiles" into our tiles from sprite ??
		@ set r0 to the source based on the level
		@ set r1 to the destination in our sprite tiles
		ldr r0, =BossShipsTiles
		ldr r1,=level
		ldr r1,[r1]
		sub r1,#1
		mov r2,#9
		mul r1,r2				@ *9 sprites per boss (level*9)*512
		lsl r1,#9				@ multiply by 512
		add r0,r1				@ add to base
		
		ldr r1, =SPRITE_GFX
		add r1,#55*512			@ boss starts as sprite 55

		ldr r2, =512*9			@ 9 sprites to copy
		bl dmaCopy
		ldr r1, =SPRITE_GFX_SUB
		add r1,#55*512
		bl dmaCopy	
		@ OK, that is that boss sprites assigned (55-63)
		@ now we need to activate them (113-x)
		@ we will uses spriteActive of #128 for a boss
		mov r0,#55					@ r0 = sprite object
		mov r1,#113					@ r1 = sprite number
		ldr r2,=spriteActive
		bossSpriteLoop:
			mov r3,#128
			ldr r2,=spriteActive
			str r3,[r2, r1, lsl #2]	@ activate the sprite
			ldr r2,=spriteObj
			str r0,[r2, r1, lsl #2]	@ Store the sprites image
			mov r3,#128
			ldr r2,=spriteIdent
			str r3,[r2, r1, lsl #2]	@ set the ident to 128 (so the unit flashes as one)
			
			add r0,#1
			add r1,#1
			cmp r0,#64
		bne bossSpriteLoop
		ldr r1,=bossX					@ set X coord
		mov r0,#144+32
		ldr r2,=horizDrift
		ldr r2,[r2]
	@	add r0,r2
		str r0,[r1]
		ldr r1,=bossY					@ set y coord
		mov r0,#288-42
		str r0,[r1]
		ldr r1,=bossHits				@ set hits to kill
		mov r0,#256
		str r0,[r1]
		
		bl bossDraw
	
	ldmfd sp!, {r1-r2, pc}
	bossActiveScroll:
		@ here we need to update all 9 sprites by 1 Y pos.
		@ and check when time to "LAUNCH", set bossman to 2
		@ So, take y coord, add 1, call bossDraw!
		ldr r0,=levelEnd
		ldr r0,[r0]
		cmp r0,#1
		bne bossStillScroll
			ldr r0,=bossMan
			mov r1,#2
			str r1,[r0]
		@	b checkBossInitFail	
		bossStillScroll:
		ldr r0,=bossY
		ldr r1,[r0]
		add r1,#1
		str r1,[r0]
		bl bossDraw
		

checkBossInitFail:
	ldmfd sp!, {r1-r2, pc}

@------------------ ALL THIS DOES IS DRAW THE BOSS BASED ON TOP LEFT X/Y	
bossDraw:
	stmfd sp!, {r1-r2, lr}
	ldr r6,=bossX
	ldr r6,[r6]					@ r1 =x
	ldr r2,=bossY
	ldr r2,[r2]					@ r2 =y
	
	mov r4,#113					@ r4 = sprite number to draw
	mov r5,#0					@ horizontal counter
	bossDrawLoop:
	
		ldr r3,=spriteX
		str r6,[r3, r4, lsl #2]	@ store X
		ldr r3,=spriteY
		str r2,[r3, r4, lsl #2]	@ store y
		
		@ now we need to detect against your ship using alienCollideCheck
		@ r1 must be the aliens offset
		
		ldr r1,=spriteActive
		add r1, r4, lsl #2
		bl alienCollideCheck
		
		add r5,#1
		cmp r5,#3
		addne r6,#32
		bne bossDrawNotX
			mov r5,#0
			add r2,#32
			sub r6,#64
		bossDrawNotX:
		add r4,#1
		cmp r4,#122
	bne bossDrawLoop	
	
	ldmfd sp!, {r1-r2, pc}
		
@------------------ BOSS HAS TAKEN A SHOT!!!
bossIsShot:
	@ r0 = bullet offset
	@ r4 = sprite offset
	@ r7 = bullets danage value
	stmfd sp!, {r0-r8, lr}

				@ ok, now we need to see how many hits to kill
		ldr r8,=bossHits
		ldr r6,[r8]
		subs r6,r7
		str r6,[r8]
		cmp r6,#0
		bmi bossIsDead
			@ make the boss "FLASH"
			mov r7,#113
			bossBloomLoop:
				ldr r5,=spriteBloom
				mov r3,#16
				str r3,[r5, r7, lsl #2]
				add r7,#1
				cmp r7,#123
			bne bossBloomLoop
		
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
			sub r8,#1
			mov r6,#1
			strb r6,[r8]
			bl addScore	
			bl playShipArmourHit1Sound

	ldmfd sp!, {r0-r8, pc}

@------------------ KILL THE BOSS
bossIsDead:
	stmfd sp!, {r0-r8, lr}
	
	ldmfd sp!, {r0-r8, pc}

@------------------ BOSS ATTACK CODE	
bossAttack:
	stmfd sp!, {r0-r8, lr}


	@ Boss attack code goes in here - somehow!!
	@ BUGGER ME!! Here we need to move the boss and take care of its firing needs
	@ What joy, what fun, what?
	@ whatever data we need to use must be set in bossInit













	
	bl bossDraw
	ldmfd sp!, {r0-r8, pc}



	.pool
	.end

