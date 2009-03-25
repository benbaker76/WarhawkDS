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
#include "efs.h"

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
	
	bl initInterruptHandler						@ initialize the interrupt handler
	bl initAudioStream
	
	mov r0, #(EFS_AND_FAT | EFS_DEFAULT_DEVICE)
	mov r1, #0
	bl EFS_Init
	
	bl showIntro1

	@ ------------------------------------
	
mainLoop:

	bl swiWaitForVBlank							@ Wait for vblank
	
	ldr r0, =gameMode
	ldr r1, [r0]
	cmp r1, #GAMEMODE_RUNNING
	beq gameLoop
	cmp r1, #GAMEMODE_STOPPED
	beq mainLoopDone
	cmp r1, #GAMEMODE_GETREADY
	bleq updateGetReady
	cmp r1, #GAMEMODE_LOADING
	bleq updateLoadingScreen
	cmp r1, #GAMEMODE_TITLESCREEN
	bleq updateTitleScreen

	b mainLoop

gameLoop:

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
	bl animateAliens							@ animate the alien sprites
	bl checkGameOver							@ check if the game is over
	bl checkLevelControl						@ check to see if we want to change level
	
	@bl drawDebugText							@ draw some numbers :)

	ldr r0,=levelEnd
	ldr r0,[r0]
	cmp r0,#2
	bleq levelComplete
	
mainLoopDone:

	b mainLoop									@ our main loop
		
	.pool
	.end
