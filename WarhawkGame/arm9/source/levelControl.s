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
	.global checkLevelControl
	.global bossJump
	.global levelBack
	.global levelNext
	.global levelComplete

checkLevelControl:

	stmfd sp!, {r0-r2, lr}

	ldr r1,=REG_KEYINPUT
	ldr r2,[r1]
	tst r2,#BUTTON_L
	bleq levelBack
	tst r2,#BUTTON_R
	bleq levelNext
	tst r2,#BUTTON_START
	bleq initLevel
	tst r2,#BUTTON_SELECT
	bleq bossJump
	
	ldmfd sp!, {r0-r2, pc}
	
@------------------------------

bossJump:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =vofsMain
	ldr r1, =256+32
	str r1, [r0]

	ldr r0, =vofsSub
	ldr r1, =256+32
	str r1, [r0]
	
	ldr r0, =yposMain
	ldr r1, =256+192
	str r1, [r0]

	ldr r0, =yposSub
	ldr r1, =256+192
	str r1, [r0]
	
	ldr r0, =pixelOffsetMain
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =pixelOffsetSub
	mov r1, #0
	str r1, [r0]
	
	bl drawMapScreenMain
	bl drawMapScreenSub
	
	ldmfd sp!, {r0-r2, pc}
	
@------------------------------

levelBack:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0,=levelNum
	ldr r1,[r0]
	sub r1,#1
	cmp r1,#0
	moveq r1,#LEVEL_COUNT
	str r1,[r0]

	bl initLevel
	
	ldmfd sp!, {r0-r2, pc}

@------------------------------

levelNext:

	stmfd sp!, {r0-r2, lr}

	ldr r0,=levelNum
	ldr r1,[r0]
	add r1,#1
	cmp r1,#LEVEL_COUNT + 1
	moveq r1,#1
	str r1,[r0]

	bl initLevel
	
	ldmfd sp!, {r0-r2, pc}

@------------------------------

levelComplete:

	stmfd sp!, {r0-r2, lr}

	@ Anything to set up???
	
	@ Well we need a way to init a big boss explode, we can generate a random number
	@ from 0-95 and use that for the x and y of explosions and also file them from
	@ start to end, overwriting active number 128 (boss sprites)
	@ this may look ok???
	@ well, we need to set variables for bossExploder to use
	@ explodeSpriteBoss = current number of the sprite to use
	@ explodeSpriteBossCount = count the times through the loop
	@ when this has been done enough, we will need to set a little delay
	@ to wait for all explosions to have finished, then set levelEnd to 3
	@ That should be easy, will keep the exploding stuff in bosscode.s
	
	ldr r0,=explodeSpriteBoss
	mov r1,#17
	str r1,[r0]									@ set current sprite number
	ldr r0,=explodeSpriteBossCount
	mov r1,#0
	str r1,[r0]
	
	@ dummy values for now!
	@ldr r0,=bossX
	@mov r1,#250
	@str r1,[r0]
	@ldr r0,=bossY
	@mov r1,#400
	@str r1,[r0]

	@ PLAY A "LARGE" EXPLOSION SOUND HERE!!

bossDeathLoop:

	bl swiWaitForVBlank							@ Wait for vblank
	bl moveShip									@ check and move your ship
	bl alienFireMove							@ check and move alien bullets
	bl fireCheck								@ check for your wish to shoot!
	bl drawScore								@ update the score with any changes
	bl moveAliens								@ move the aliens and detect colisions with you
	bl levelDrift								@ update level with the horizontal drift
	bl moveBullets								@ check and then moves bullets
	bl scrollStars								@ Scroll Stars (BG2,BG3)		
	bl drawSprite								@ drawsprites and do update bloom effect
	bl animateAliens
	bl checkBossInit							@ so we can still move him as he DIES	
	bl bossExploder

	ldr r0,=levelEnd
	ldr r0,[r0]
	cmp r0,#3									@ if levelEnd=3, just wait for explosions to finish
	
	bne notTimeToEndDeath
	
		ldr r0,=explodeSpriteBossCount			@ use this as a little delay to let explosions settle
		ldr r1,[r0]
		cmp r1,#128								@ delay for explosions
		beq levelFinishDone
		add r1,#1
		str r1,[r0]

notTimeToEndDeath:
	
	b bossDeathLoop
	
levelFinishDone:

	bl levelNext
	
	ldmfd sp!, {r0-r2, pc}
	
@------------------------------
	
	.pool
	.end
