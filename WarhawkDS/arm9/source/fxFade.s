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
	.global fxFadeBlackInit
	.global fxFadeWhiteInit
	.global fxFadeBG0Init
	.global fxFadeOff
	.global fxFadeBlackIn
	.global fxFadeBlackOut
	.global fxFadeWhiteIn
	.global fxFadeWhiteOut
	.global fxFadeBG0In
	.global fxFadeBG0Out
	.global fxFadeInVBlank
	.global fxFadeOutVBlank
	
fxFadeBlackInit:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =BLEND_CR
	ldr r1, =(BLEND_FADE_BLACK | BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_FADE_BLACK | BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
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
	
fxFadeWhiteInit:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =BLEND_CR
	ldr r1, =(BLEND_FADE_WHITE | BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_FADE_WHITE | BLEND_SRC_BG0 | BLEND_SRC_BG1 | BLEND_SRC_BG2 | BLEND_SRC_BG3 | BLEND_SRC_SPRITE)
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
	
fxFadeBG0Init:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =BLEND_CR
	ldr r1, =(BLEND_ALPHA | BLEND_SRC_BG0 | BLEND_DST_BG0 | BLEND_DST_BG1 | BLEND_DST_BG2 | BLEND_DST_BG3)
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	ldr r1, =(BLEND_ALPHA | BLEND_SRC_BG0 | BLEND_DST_BG0 | BLEND_DST_BG1 | BLEND_DST_BG2 | BLEND_DST_BG3)
	str r1, [r0]
	
	ldr r0, =BLEND_AB					@ Blend register
	ldr r1, =0							@ Set to fade out
	strh r1, [r0]						@ Write to BLEND_AB
	
	ldr r0, =SUB_BLEND_AB				@ Blend register
	ldr r1, =0							@ Set to fade out
	strh r1, [r0]						@ Write to SUB_BLEND_AB
	
	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeOff:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	and r1, #~(FX_FADE_BLACK_IN | FX_FADE_BLACK_OUT | FX_FADE_WHITE_IN | FX_FADE_WHITE_OUT | FX_FADE_BG0_IN | FX_FADE_BG0_OUT)
	str r1, [r0]
	
	ldr r0, =BLEND_CR
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =SUB_BLEND_CR
	mov r1, #0
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeBlackIn:

	stmfd sp!, {r0-r6, lr}

	bl fxFadeBlackInit
	
	ldr r0, =fxMode					@ lets set the fade effect
	ldr r1, [r0]
	orr r1, #FX_FADE_BLACK_IN
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeBlackOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBlackInit
	
	ldr r0, =fxMode					@ lets set the fade effect
	ldr r1, [r0]
	orr r1, #FX_FADE_BLACK_OUT
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeWhiteIn:

	stmfd sp!, {r0-r6, lr}

	bl fxFadeWhiteInit
	
	ldr r0, =fxMode					@ lets set the fade effect
	ldr r1, [r0]
	orr r1, #FX_FADE_WHITE_IN
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeWhiteOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeWhiteInit
	
	ldr r0, =fxMode					@ lets set the fade effect
	ldr r1, [r0]
	orr r1, #FX_FADE_WHITE_OUT
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeBG0In:

	stmfd sp!, {r0-r6, lr}

	bl fxFadeBG0Init
	
	ldr r0, =fxMode					@ lets set the fade effect
	ldr r1, [r0]
	orr r1, #FX_FADE_BG0_IN
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeBG0Out:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0Init
	
	ldr r0, =fxMode					@ lets set the fade effect
	ldr r1, [r0]
	orr r1, #FX_FADE_BG0_OUT
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------


fxFadeInVBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, [r0]
	
	ldr r3, =16							@ Subtract from 15 to reverse value
	sub r4, r3, r1, lsr #2				@ Divide by 4 to make value 0-15
	mov r5, r1, lsr #2					@ Divide by 4 to make value 0-15
	
	ldr r2, =BLEND_Y					@ Blend register
	strh r4, [r2]						@ Write to BLEND_Y
	
	ldr r2, =SUB_BLEND_Y				@ Blend register
	strh r4, [r2]						@ Write to SUB_BLEND_Y
	
	ldr r2, =BLEND_AB					@ Blend register
	mov r6, r4, lsl #8
	orr r6, r5
	strh r6, [r2]						@ Write to BLEND_AB
	
	ldr r2, =SUB_BLEND_AB				@ Blend register
	mov r6, r4, lsl #8
	orr r6, r5
	strh r6, [r2]						@ Write to SUB_BLEND_AB
	
	ldr r2, =fxMode						@ Get fxMode address
	ldr r3, [r2]						@ Get fxMode value
	add r1, #1							@ Add 1 to pos
	cmp r1, #65							@ Is our fadeValue at 64?
	moveq r1, #0						@ Yes so reset pos
	bleq fxFadeOff						@ Yes turn off effect
	str r1, [r0]						@ Write fadeValue back
	str r3, [r2]						@ Write fxMode back
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxFadeOutVBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =fadeValue					@ Get our fadeValue
	ldr r1, [r0]
	
	ldr r3, =16							@ Subtract from 15 to reverse value
	sub r4, r3, r1, lsr #2				@ Divide by 4 to make value 0-15
	mov r5, r1, lsr #2					@ Divide by 4 to make value 0-15
	
	ldr r2, =BLEND_Y					@ Blend register
	strh r5, [r2]						@ Write to BLEND_Y
	
	ldr r2, =SUB_BLEND_Y				@ Blend register
	strh r5, [r2]						@ Write to SUB_BLEND_Y
	
	ldr r2, =BLEND_AB					@ Blend register
	mov r6, r5, lsl #8
	orr r6, r4
	strh r6, [r2]						@ Write to BLEND_AB
	
	ldr r2, =SUB_BLEND_AB				@ Blend register
	mov r6, r5, lsl #8
	orr r6, r4
	strh r6, [r2]						@ Write to SUB_BLEND_AB
	
	ldr r2, =fxMode						@ Get fxMode address
	ldr r3, [r2]						@ Get fxMode value
	add r1, #1							@ Add 1 to pos
	cmp r1, #65							@ Is our fadeValue at 64?
	moveq r1, #0						@ Yes so reset pos
	bleq fxFadeOff						@ Yes turn off effect
	str r1, [r0]						@ Write fadeValue back
	str r3, [r2]						@ Write fxMode back
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

	.data
	.align

fadeValue:
	.word 0
	
	.pool
	.end
