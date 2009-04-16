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

initInterruptHandler:

	stmfd sp!, {r0-r6, lr}

	bl irqInit								@ Initialize Interrupts
		
	ldr r0, =IRQ_VBLANK						@ VBLANK interrupt
	ldr r1, =interruptHandlerVBlank			@ Function Address
	bl irqSet								@ Set the interrupt
	
	ldr r0, =IRQ_HBLANK						@ HBLANK interrupt
	ldr r1, =interruptHandlerHBlank			@ Function Address
	bl irqSet								@ Set the interrupt
	
	ldr r0, =IRQ_TIMER1						@ TIMER1 interrupt
	ldr r1, =interruptHandlerTimer1			@ Function Address
	bl irqSet
	
	ldr r0, =IRQ_TIMER3						@ TIMER3 interrupt
	ldr r1, =interruptHandlerTimer3			@ Function Address
	bl irqSet
	
	ldr r0, =(IRQ_VBLANK | IRQ_HBLANK | IRQ_TIMER1 | IRQ_TIMER3)		@ Interrupts
	bl irqEnable							@ Enable
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
interruptHandlerVBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r0, [r0]
	
	cmp r0, #0
	beq interruptHandlerVBlankDone
	tst r0, #FX_FADE_BLACK_IN
	blne fxFadeBlackInVBlank
	tst r0, #FX_FADE_BLACK_OUT
	blne fxFadeBlackOutVBlank
	tst r0, #FX_FADE_WHITE_IN
	blne fxFadeWhiteInVBlank
	tst r0, #FX_FADE_WHITE_OUT
	blne fxFadeWhiteOutVBlank
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
	tst r0, #FX_COLOR_CYCLE
	blne fxColorCycleVBlank
	tst r0, #FX_COLOR_PULSE
	blne fxColorPulseVBlank
	tst r0, #FX_COPPER_TEXT
	blne fxCopperTextVBlank
	tst r0, #FX_TEXT_SCROLLER
	blne fxTextScrollerVBlank
	tst r0, #FX_STARFIELD
	blne fxStarfieldVBlank
	tst r0, #FX_PALETTE_FADE_TO_RED
	blne fxPaletteFadeToRedVBlank
	tst r0, #FX_STARFIELD_DOWN
	blne fxStarfieldVBlank
	tst r0, #FX_STARFIELD_MULTI
	blne fxStarfieldMultiVBlank
interruptHandlerVBlankDone:
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
interruptHandlerHBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r0, [r0]
	
	cmp r0, #0
	beq interruptHandlerHBlankDone
	tst r0, #FX_SINE_WOBBLE
	blne fxSineWobbleHBlank
	tst r0, #FX_SCANLINE
	blne fxScanlineHBlank
	tst r0, #FX_CROSSWIPE
	blne fxCrossWipeHBlank
	tst r0, #FX_COPPER_TEXT
	blne fxCopperTextHBlank
	tst r0, #FX_COLOR_CYCLE_TEXT
	blne fxColorCycleTextHBlank
	tst r0, #FX_TEXT_SCROLLER
	blne fxTextScrollerHBlank
	
interruptHandlerHBlankDone:
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
interruptHandlerTimer1:

	stmfd sp!, {r0-r6, lr}
	
	bl audioStreamTimer1
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
interruptHandlerTimer3:

	stmfd sp!, {r0-r6, lr}
	
	bl timerTimer3
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------

	.pool
	.end
