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
	.section	.itcm,"ax",%progbits
	.align
	.global initInterruptHandler
	.global gameStart
	.global gameStop
	
initInterruptHandler:

	stmfd sp!, {r0-r6, lr}

	bl irqInit								@ Initialize Interrupts
		
	ldr r0, =IRQ_VBLANK						@ VBLANK interrupt
	ldr r1, =interruptHandlerVBlank			@ Function Address
	bl irqSet								@ Set the interrupt
	
	ldr r0, =IRQ_HBLANK						@ HBLANK interrupt
	ldr r1, =interruptHandlerHBlank			@ Function Address
	bl irqSet								@ Set the interrupt
	
	ldr r0, =(IRQ_VBLANK | IRQ_HBLANK)		@ Interrupts
	bl irqEnable							@ Enable
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
interruptHandlerVBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r0, [r0]
	
	cmp r0, #0
	bleq interruptHandlerHBlank
	tst r0, #FX_FADE_IN
	blne fxFadeInVBlank
	tst r0, #FX_FADE_OUT
	blne fxFadeOutVBlank
	tst r0, #FX_MOSAIC_IN
	blne fxMosaicInVBlank
	tst r0, #FX_MOSAIC_OUT
	blne fxMosaicOutVBlank
	tst r0, #FX_SPOTLIGHT_IN
	blne fxSpotlightInVBlank
	tst r0, #FX_SPOTLIGHT_OUT
	blne fxSpotlightOutVBlank
	tst r0, #FX_SCANLINE
	blne fxScanlineVBlank
	tst r0, #FX_WIPE_IN_LEFT
	blne fxWipeInLeftVBlank
	tst r0, #FX_WIPE_IN_RIGHT
	blne fxWipeInRightVBlank
	tst r0, #FX_WIPE_OUT_UP
	blne fxWipeOutUpVBlank
	tst r0, #FX_WIPE_OUT_DOWN
	blne fxWipeOutDownVBlank
	tst r0, #FX_CROSSWIPE
	blne fxCrossWipeVBlank
	
	ldr r0, =gameMode
	ldr r1, [r0]
	cmp r1, #GAMEMODE_STOPPED
	bleq interruptHandlerVBlankDone
	
	bl moveShip			@ check and move your ship
	
	bl moveBullets		@ check and then moves bullets
	bl alienFireMove	@ check and move alien bullets
	bl fireCheck		@ check for your wish to shoot!

	bl drawScore		@ update the score with any changes
	bl drawAllEnergyBars

	
	bl checkWave		@ check if time for another alien attack
	bl moveAliens		@ move the aliens and detect colisions with you

	bl initHunterMine	@ check if we should chuck another mine or hunter into the mix


	bl scrollMain		@ Scroll Level Data
	bl scrollSub		@ Main + Sub
	bl levelDrift		@ update level with the horizontal drift
	bl scrollStars		@ Scroll Stars (BG2,BG3)		
	bl checkEndOfLevel	@ Set Flag for end-of-level (use later to init BOSS)
	bl checkBossInit	@ Check if we should set the offscreen boss up??
	bl drawSprite		@ drawsprites and do update bloom effect
	bl animateAliens
	
@	bl drawDebugText	@ draw some numbers :)
	
	bl checkGameOver
	
interruptHandlerVBlankDone:
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
interruptHandlerHBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r0, [r0]
	
	cmp r0, #0
	bleq interruptHandlerHBlankDone
	tst r0, #FX_SINE_WOBBLE
	blne fxSineWobbleHBlank
	tst r0, #FX_SCANLINE
	blne fxScanlineHBlank
	tst r0, #FX_CROSSWIPE
	blne fxCrossWipeHBlank
	
interruptHandlerHBlankDone:
	
	ldmfd sp!, {r0-r6, pc}
	
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
	
	bl fxFadeOut
	bl fxMosaicOut
	
	bl drawAllEnergyBars	

	ldr r0, =gameOverText			@ Load out text pointer
	ldr r1, =11						@ x pos
	ldr r2, =10						@ y pos
	ldr r3, =0						@ Draw on main screen
	bl drawText
	
	ldr r0, =gameOverText			@ Load out text pointer
	ldr r1, =11						@ x pos
	ldr r2, =10						@ y pos
	ldr r3, =1						@ Draw on sub screen
	bl drawText
	
	bl gameStop
	
checkGameOverDone:
		
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
	.align
	.data
	
gameMode:

	.word 0

	.pool
	.end
