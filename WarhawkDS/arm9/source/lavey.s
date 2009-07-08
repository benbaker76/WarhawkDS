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

	#define LAVEY_ANIM_TIMER				6

	.arm
	.align
	.text
	.global initLaVey
	.global updateLaVey
	.global laVayPhrase
	
initLaVey:

	stmfd sp!, {r0-r1, lr}
	
	@ r0 - syllable value
	
@	ldr r1,=laVayPhrase		@ use this to set the correct phrase for testing only!
@	mov r2,#6
@	str r2,[r1]
	
	ldr r1, =laVeyCount
	mov r2, #0
	str r2, [r1]
	
	mov r1,#0
	ldr r2,=laVayTalkPoss
	str r1,[r2]
	
	ldr r1, =laVeyTalk
	str r0, [r1]
	
	ldr r1, =laVeyWait
	mov r2, #100
	str r2, [r1]

	ldr r0, =gameMode
	ldr r1, [r0]
	cmp r1, #GAMEMODE_BIGBOSS_LAVEY
	ldreq r4,=laVeyTalk1
	beq initLaVeySkip
	
		ldr r0,=laVayPhrase
		ldr r1,[r0]	
		cmp r1,#0
		ldreq r4,=laVeyTalk2
		cmp r1,#1
		ldreq r4,=laVeyTalk3
		cmp r1,#2
		ldreq r4,=laVeyTalk4
		cmp r1,#3
		ldreq r4,=laVeyTalk5
		cmp r1,#4
		ldreq r4,=laVeyTalk6
		cmp r1,#5
		ldreq r4,=laVeyTalk7
		cmp r1,#6
		ldreq r4,=laVeyTalk8		

	initLaVeySkip:
	ldr r2,=laVayChat
	str r4,[r2]
	
	bl swiWaitForVBlank
	
	bl drawLaVey1
	
	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawLaVey1:

	stmfd sp!, {r0-r2, lr}

	@ Write the tile data
	
	ldr r0 ,=AntonLaVey1Tiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =AntonLaVey1TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =AntonLaVey1Map
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =AntonLaVey1MapLen
	bl dmaCopy
	
	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawLaVey2:

	stmfd sp!, {r0-r2, lr}

	@ Write the tile data
	
	ldr r0 ,=AntonLaVey2Tiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =AntonLaVey2TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =AntonLaVey2Map
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =AntonLaVey2MapLen
	bl dmaCopy
	
	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawLaVey3:

	stmfd sp!, {r0-r2, lr}

	@ Write the tile data
	
	ldr r0 ,=AntonLaVey3Tiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =AntonLaVey3TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =AntonLaVey3Map
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =AntonLaVey3MapLen
	bl dmaCopy
	
	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateLaVey:

	stmfd sp!, {r0-r4, lr}
	
	ldr r0, =laVeyWait
	ldr r1, [r0]
	subs r1, #1
	movmi r1, #0
	str r1, [r0]
	cmp r1, #1
	bne noLaVeyChattering

		ldr r0, =gameMode
		ldr r2, [r0]
		cmp r2, #GAMEMODE_BIGBOSS_LAVEY
		bleq playDefeatMeSound
		beq noLaVeyChattering
			
			ldr r0,=laVayPhrase
			ldr r1,[r0]
			
			cmp r1,#0
			bleq playWellDoneSound
			cmp r1,#1
			bleq playLaughSound
			cmp r1,#2
			bleq playNeverDefeatSound
			cmp r1,#3
			bleq playNoTimeSound
			cmp r1,#4
			bleq playTryAgainSound
			cmp r1,#5
			bleq playFedUpSound
			cmp r1,#6
			bleq playLastWarningSound
			
			add r1,#1
			cmp r1,#7
			moveq r1,#0
			str r1,[r0]
		
	noLaVeyChattering:
	cmp r1,# 0
	bne updateLaVeyDone

	ldr r0, =laVeyCount
	ldr r1, [r0]
	add r1, #1
	cmp r1, #LAVEY_ANIM_TIMER
	moveq r1, #0
	str r1, [r0]
	bne updateLaVeyDone
	
		ldr r0,=laVayChat
		ldr r4,[r0]
	
		ldr r2,=laVayTalkPoss		
		ldr r1,[r2]							@ r1 = pos in speech	

		ldr r0,[r4, r1, lsl #2]				@ r0 = lip value (hmmm wine!!)
	
		cmp r0,#255
		addne r1,#1
		str r1,[r2]

		cmp r0, #0
		bleq drawLaVey1
		cmp r0, #1
		bleq drawLaVey1
		cmp r0, #2
		bleq drawLaVey2
		cmp r0, #3
		bleq drawLaVey3
		cmp r0, #255
		bleq drawLaVey1

updateLaVeyDone:

	ldmfd sp!, {r0-r4, pc} 					@ restore registers and return
	
	@---------------------------------

	.data
	.align
	
laVeyCount:
	.word 0

laVeyWait:
	.word 0

laVeyTalk:
	.word 0
laVeyTalk1:									@ big boss (now you must defeat me)
	.word 3,2,2,0,0,2,3,3,1,3,3,3,0,0,3,2,2,2,2,0,0,0,0,2,2,2,2,2,2,2,2,255
laVeyTalk2:									@ Well done mortal
	.word 3,3,2,2,2,2,2,0,0,3,3,0,0,0,0,0,0,0,0,0,0,0,3,3,2,2,1,1,2,2,2,2,255
laVeyTalk3:									@ laugh
	.word 2,2,3,3,2,2,3,3,2,2,3,3,2,2,3,3,1,1,2,2,1,1,2,2,1,1,2,2,1,1,2,2,2,2,3,3,255
laVeyTalk4:									@ youll never defeat me
	.word 2,2,3,3,2,2,3,1,2,0,0,0,3,3,2,2,2,0,0,0,2,2,2,2,2,2,2,2,255
laVeyTalk5:									@ i dont have time for this
	.word 2,2,3,0,2,2,3,3,0,0,0,3,2,2,0,0,0,0,3,3,2,2,2,2,2,255
laVeyTalk6:									@ try and try again
	.word 2,2,3,3,0,0,0,0,0,0,0,0,0,3,2,0,0,0,2,2,3,3,0,2,2,2,2,2,2,2,255
laVeyTalk7:									@ im getting a little fed up with you
	.word 3,3,0,0,0,2,2,2,1,3,3,3,3,0,0,0,0,0,0,0,2,2,3,0,0,0,0,0,0,0,2,2,2,0,0,3,3,3,3,3,3,3,255
laVeyTalk8:									@ this is your last warning
	.word 3,2,0,0,0,0,0,0,2,2,0,0,0,3,2,1,2,0,0,0,0,0,0,0,3,3,3,1,2,2,2,2,2,2,255
	
laVayTalkPoss:
	.word 0
laVayChat:
	.word 0
laVayPhrase:
	.word 0

	.pool
	.end