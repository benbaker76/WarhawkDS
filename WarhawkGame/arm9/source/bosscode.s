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
	beq checkBossInitFail		@ if he is active, let "bossAttack" do the work
	ldr r0,=yposSub
	ldr r0,[r0]
	cmp r0,#352
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
	
	
	
	
	
	ldmfd sp!, {r1-r2, pc}
	bossActiveScroll:
		@ here we need to update all 9 sprites by 1 Y pos.
		@ and check when time to "LAUNCH", set bossman to 2
		@ So, take y coord, add 1, call bossDraw!

checkBossInitFail:
	ldmfd sp!, {r1-r2, pc}

@------------------ BOSS ATTACK CODE	
bossAttack:
	stmfd sp!, {r1-r2, lr}
	ldr r0,=bossMan
	ldr r0,[r0]
	cmp r0,#2
	movne r15,r14

	@ Boss attack code goes in here - somehow!!
	@ BUGGER ME!! Here we need to move the boss and take care of its firing needs
	@ What joy, what fun, what?
	
	ldmfd sp!, {r1-r2, pc}

@------------------ ALL THIS DOES IS DRAW THE BOSS BASED ON TOP LEFT X/Y	
bossDraw:
	stmfd sp!, {r1-r2, lr}
	
	
	
	ldmfd sp!, {r1-r2, pc}
	
	.pool
	.end
