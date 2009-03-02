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

	.arm
	.align
	.text
	.global fxFadeIn
	.global fxFadeOut
	.global fxFadeInVBlank
	.global fxFadeOutVBlank
	
fxFadeInit:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =BLEND_CR
	ldr r1, =(BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE | BLEND_FADE_BLACK);
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE | BLEND_FADE_BLACK);
	str r1, [r0]
	
	ldr r0, =BLEND_Y					@ Blend register
	ldr r1, =16							@ Set to black
	strh r1, [r0]						@ Write to BLEND_Y
	
	ldr r0, =SUB_BLEND_Y				@ Blend register
	ldr r1, =16							@ Set to black
	strh r1, [r0]						@ Write to BLEND_Y
	
	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeIn:

	stmfd sp!, {r0-r6, lr}

	bl fxFadeInit
	
	ldr r0, =fxMode					@ lets set the fade effect
	ldr r1, [r0]
	orr r1, #FX_FADE_IN
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeInit
	
	ldr r0, =fxMode					@ lets set the fade effect
	ldr r1, [r0]
	orr r1, #FX_FADE_OUT
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

fxFadeInVBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, [r0]
	
	ldr r3, =16							@ Subtract from 15 to reverse value
	sub r4, r3, r1, lsr #2				@ Divide by 4 to make value 0-15
	
	ldr r2, =BLEND_Y					@ Blend register
	strh r4, [r2]						@ Write to BLEND_Y
	
	ldr r2, =SUB_BLEND_Y				@ Blend register
	strh r4, [r2]						@ Write to SUB_BLEND_Y
	
	ldr r2, =fxMode						@ Get fxMode address
	ldr r3, [r2]						@ Get fxMode value
	add r1, #1							@ Add 1 to pos
	cmp r1, #65							@ Is our fadeValue at 64?
	moveq r1, #0						@ Yes so reset pos
	andeq r3, #~(FX_FADE_IN)			@ Yes turn off effect
	str r1, [r0]						@ Write fadeValue back
	str r3, [r2]						@ Write fxMode back
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeOutVBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, [r0]

	mov r4, r1, lsr #2					@ Divide by 4 to make value 0-15
	
	ldr r2, =BLEND_Y					@ Blend register
	strh r4, [r2]						@ Write to BLEND_Y
	
	ldr r2, =SUB_BLEND_Y				@ Blend register
	strh r4, [r2]						@ Write to SUB_BLEND_Y
	
	ldr r2, =fxMode						@ Get fxMode address
	ldr r3, [r2]						@ Get fxMode value
	add r1, #1							@ Add 1 to pos
	cmp r1, #65							@ Is our fadeValue at 64?
	moveq r1, #0						@ Yes so reset pos
	andeq r3, #~(FX_FADE_OUT)			@ Yes turn off effect
	str r1, [r0]						@ Write fadeValue back
	str r3, [r2]						@ Write fxMode back
	
	ldmfd sp!, {r0-r6, pc}

	.data
	.align

fadeValue:
	.word 0
	
	.pool
	.end
