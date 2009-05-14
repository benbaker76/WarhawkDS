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
	.global fxMosaicOff
	.global fxMosaicIn
	.global fxMosaicOut
	.global fxMosaicInVBlank
	.global fxMosaicOutVBlank

fxMosaicInit:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =REG_BG0CNT					@ BG 0 Register
	ldr r1, [r0]
	orr r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG1CNT					@ BG 1 Register
	ldr r1, [r0]
	orr r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG2CNT					@ BG 2 Register
	ldr r1, [r0]
	orr r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG3CNT					@ BG 3 Register
	ldr r1, [r0]
	orr r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG0CNT_SUB				@ SUB BG 0 Register
	ldr r1, [r0]
	orr r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG1CNT_SUB				@ SUB BG 1 Register
	ldr r1, [r0]
	orr r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG2CNT_SUB				@ SUB BG 2 Register
	ldr r1, [r0]
	orr r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG3CNT_SUB				@ SUB BG 3 Register
	ldr r1, [r0]
	orr r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =mosaicValue				@ Get our mosaicValue
	ldr r1, =0							@ Reset value
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxMosaicOff:
	
	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	bic r1, #(FX_MOSAIC_IN | FX_MOSAIC_OUT)
	str r1, [r0]
	
	ldr r0, =REG_BG0CNT					@ BG 0 Register
	ldr r1, [r0]
	bic r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG1CNT					@ BG 1 Register
	ldr r1, [r0]
	bic r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG2CNT					@ BG 2 Register
	ldr r1, [r0]
	bic r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG3CNT					@ BG 3 Register
	ldr r1, [r0]
	bic r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG0CNT_SUB				@ SUB BG 0 Register
	ldr r1, [r0]
	bic r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG1CNT_SUB				@ SUB BG 1 Register
	ldr r1, [r0]
	bic r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG2CNT_SUB				@ SUB BG 2 Register
	ldr r1, [r0]
	bic r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldr r0, =REG_BG3CNT_SUB				@ SUB BG 3 Register
	ldr r1, [r0]
	bic r1, #BG_MOSAIC_ON				@ Turn on mosaic
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxMosaicIn:

	stmfd sp!, {r0-r1, lr}

	bl fxMosaicInit
	
	ldr r0, =fxMode					@ lets set the mosaic effect
	ldr r1, [r0]
	orr r1, #FX_MOSAIC_IN
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxMosaicOut:

	stmfd sp!, {r0-r1, lr}

	bl fxMosaicInit
	
	ldr r0, =fxMode					@ lets set the mosaic effect
	ldr r1, [r0]
	orr r1, #FX_MOSAIC_OUT
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
fxMosaicInVBlank:

	stmfd sp!, {r0-r4, lr}

	ldr r0, =mosaicValue				@ Get our mosaicValue
	ldr r1, [r0]
	
	ldr r3, =15							@ Subtract from 15 to reverse value
	sub r4, r3, r1, lsr #2				@ Divide by 4 to make value 0-15
	
	ldr r2, =MOSAIC_CR					@ Mosaic register
	mov r3, r4							@ MOSAIC_BG_H
	add r3, r4, lsl #4					@ MOSAIC_BG_V
	strh r3, [r2]						@ Write to MOSAIC_CR
	
	ldr r2, =SUB_MOSAIC_CR				@ Mosaic register
	mov r3, r4							@ MOSAIC_BG_H
	add r3, r4, lsl #4					@ MOSAIC_BG_V
	strh r3, [r2]						@ Write to SUB_MOSAIC_CR
	
	add r1, #1							@ Add 1 to pos
	cmp r1, #64							@ Is our pos 64?
	moveq r1, #0						@ Yes so reset pos
	bleq fxMosaicOff					@ Yes turn off effect
	str r1, [r0]						@ Write pos back
	
	ldmfd sp!, {r0-r4, pc}
	
	@ ---------------------------------------
	
fxMosaicOutVBlank:

	stmfd sp!, {r0-r4, lr}

	ldr r0, =mosaicValue				@ Get our mosaicValue
	ldr r1, [r0]

	mov r4, r1, lsr #2					@ Divide by 4 to make value 0-15
	
	ldr r2, =MOSAIC_CR					@ Mosaic register
	mov r3, r4							@ MOSAIC_BG_H
	add r3, r4, lsl #4					@ MOSAIC_BG_V
	strh r3, [r2]						@ Write to MOSAIC_CR
	
	ldr r2, =SUB_MOSAIC_CR				@ Mosaic register
	mov r3, r4							@ MOSAIC_BG_H
	add r3, r4, lsl #4					@ MOSAIC_BG_V
	strh r3, [r2]						@ Write to SUB_MOSAIC_CR
	
	add r1, #1							@ Add 1 to pos
	cmp r1, #64							@ Is our pos 64?
	moveq r1, #0						@ Yes so reset pos
	bleq fxMosaicOff					@ Yes turn off effect
	str r1, [r0]						@ Write pos back

	ldmfd sp!, {r0-r4, pc}
	
	@ ---------------------------------------

	.data
	.align

mosaicValue:
	.word 0
	
	.pool
	.end

