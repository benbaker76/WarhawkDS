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
	.global initSystem
	.global main
	.global gameStart
	.global gameStop

initSystem:
	stmfd sp!, {r0-r2, lr}
	
	mov r0, #0						@ Clear video display registers
	ldr r1, =0x04000000
	mov r2, #0x56
	bl dmaFillWords
	ldr r1, =0x04001008
	bl dmaFillWords
	
	ldr r0, =VRAM_CR
	mov r1, #0
	strb r1, [r0]
	ldr r0, =VRAM_E_CR
	strb r1, [r0]
	ldr r0, =VRAM_F_CR
	strb r1, [r0]
	ldr r0, =VRAM_G_CR
	strb r1, [r0]
	ldr r0, =VRAM_H_CR
	strb r1, [r0]
	ldr r0, =VRAM_I_CR
	strb r1, [r0]
	
	ldr r0, =REG_DISPCNT
	mov r1, #0
	str r1, [r0]
	ldr r0, =REG_DISPCNT_SUB
	str r1, [r0]
	
	ldmfd sp!, {r0-r2, pc}

main:
	bl gameStop
	bl initVideo
	bl initData									@ setup actual game data
	
	@ Setup the screens and the sprites	
	
levelLoop:	
	
	bl initLevel
	bl initInterruptHandler						@ initialize the interrupt handler
	bl initSprites
	bl initLevelSprites
	
	@ firstly, lets draw all the screen data ready for play
	@ and display the ship sprite
	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3	
	
	bl drawMapScreenMain
	bl drawMapScreenSub
	bl drawSFMapScreenMain
	bl drawSFMapScreenSub
	bl drawSBMapScreenMain
	bl drawSBMapScreenSub
	bl levelDrift
	bl drawScore
	bl drawSprite
	bl drawGetReadyText
	bl drawAllEnergyBars
	@bl playInGameMusic
	
	@ Fade in
	
	@bl fxSpotlightIn
	bl fxFadeBlackIn
	bl fxMosaicIn
	@bl fxScanline
	@bl fxWipeInLeft
	@bl fxCrossWipe
	@bl fxSineWobbleOn

	bl waitforFire								@ wait for a short while to start game

	bl clearBG0
	
	bl gameStart

@ldr r0,=levelEnd
@mov r1,#2
@str r1,[r0]

	
	@ ------------------------------------
	
gameLoop:

	bl swiWaitForVBlank							@ Wait for vblank
	
	ldr r0, =gameMode
	ldr r1, [r0]
	cmp r1, #GAMEMODE_STOPPED
	bleq gameLoopDone

	bl moveShip									@ check and move your ship
	bl alienFireMove							@ check and move alien bullets
	bl fireCheck								@ check for your wish to shoot!
	bl drawScore								@ update the score with any changes
	bl drawAllEnergyBars
	bl checkPowerUp								@ check for and use powerup
	bl checkWave								@ check if time for another alien attack
	bl moveAliens								@ move the aliens and detect colisions with you
	bl initHunterMine							@ check if we should chuck another mine or hunter into the mix
	bl scrollMain								@ Scroll Level Data
	bl scrollSub								@ Main + Sub
	bl levelDrift								@ update level with the horizontal drift
	bl moveBullets								@ check and then moves bullets
	bl scrollStars								@ Scroll Stars (BG2,BG3)		
	bl checkEndOfLevel							@ Set Flag for end-of-level (use later to init BOSS)
	bl checkBossInit							@ Check if we should set the offscreen boss up??
	bl drawSprite								@ drawsprites and do update bloom effect
	bl animateAliens
	bl checkGameOver
	bl checkLevelSkip							@ Check to see if we want to skip a level
	@bl drawDebugText							@ draw some numbers :)

	ldr r0,=levelEnd
	ldr r0,[r0]
	cmp r0,#2
	beq levelComplete
	
gameLoopDone:

	b gameLoop									@ our main loop
	
	@ ------------------------------------

gameStart:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_RUNNING
	str r1, [r0]
		
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
gameStop:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_STOPPED
	str r1, [r0]
		
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
checkGameOver:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =energy
	ldr r1, [r0]
	cmp r1, #0
	bne checkGameOverDone
	beq checkGameOverDone
	bl fxFadeBlackOut
	bl fxMosaicOut
	
	bl drawAllEnergyBars	

	ldr r0, =gameOverText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =10									@ y pos
	ldr r3, =0									@ Draw on main screen
	bl drawText
	
	ldr r0, =gameOverText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =10									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	bl gameStop
	
checkGameOverDone:
		
	ldmfd sp!, {r0-r6, pc}
	
@------------------------------- THIS IS WHERE WE KEEP THINGS GOING WHILE WE EXPLODE THE BOSS
@------------------------------- SOME NICE EFFECT??? WHO KNOWS

levelComplete:
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
	str r1,[r0]				@ set current sprite number
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
			beq levelNext
			add r1,#1
			str r1,[r0]
	notTimeToEndDeath:
	
	b bossDeathLoop
	
@------------------------------

checkLevelSkip:

	ldr r1,=REG_KEYINPUT
	ldr r2,[r1]
	tst r2,#BUTTON_L
	beq levelBack
	tst r2,#BUTTON_R
	beq levelNext

	bx lr
	
@------------------------------ THIS IS WHERE WE ADD THE SCORES AND PREPARE FOR PREVIOUS LEVEL

levelBack:
	ldr r0, =fxMode				@ turn off all fx
	ldr r1, =FX_NONE
	str r1, [r0]

	ldr r0,=levelNum
	ldr r1,[r0]
	sub r1,#1
	cmp r1,#0
	moveq r1,#LEVEL_COUNT
	str r1,[r0]

	ldr r0,=levelEnd
	mov r1,#0
	str r1,[r0]

	b levelLoop

@------------------------------ THIS IS WHERE WE ADD THE SCORES AND PREPARE FOR NEXT LEVEL
levelNext:
	ldr r0, =fxMode				@ turn off all fx
	ldr r1, =FX_NONE
	str r1, [r0]

	ldr r0,=levelNum
	ldr r1,[r0]
	add r1,#1
	cmp r1,#LEVEL_COUNT + 1
	moveq r1,#1
	str r1,[r0]

	ldr r0,=levelEnd
	mov r1,#0
	str r1,[r0]

	b levelLoop
	
	.pool
	.end
