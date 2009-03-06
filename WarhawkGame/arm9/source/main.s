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
	bx lr

main:
	bl gameStop
	bl initVideo
	bl initData									@ setup actual game data
	
	@ Setup the screens and the sprites	
	
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
	mov r1,#1									@ just for checking (though this would NEVER be active at level start)
	ldr r0,=powerUp
@	str r1,[r0]
	
	bl clearBG0
	
	bl gameStart
	
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

	
@	bl checkWave								@ check if time for another alien attack
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
	
	@bl drawDebugText							@ draw some numbers :)
	
	bl checkGameOver
	
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
	
	@ ------------------------------------

	.pool
	.end
