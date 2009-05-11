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
	.global fxSineWobbleOn
	.global fxSineWobbleOff
	.global fxSineWobbleVBlank
	
fxSineWobbleOn:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode					@ lets set the sine wobble effect
	ldr r1, [r0]
	orr r1, #FX_SINE_WOBBLE
	str r1, [r0]
	
	ldr r0, =sineOfsMain
	ldr r1, =192 * 4
	str r1, [r0]
	
	ldr r0, =sineOfsSub
	ldr r1, =0
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxSineWobbleOff:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode					@ lets unset the sine wobble effect
	ldr r1, [r0]
	bic r1, #FX_SINE_WOBBLE
	str r1, [r0]
	
	@mov r0, #0
	@mov r1, #0
	@mov r2, #0
	@mov r3, #0
	@mov r4, #0
	
	@bl dmaTransfer
	
	mov r0, #2
	mov r1, #0
	mov r2, #0
	mov r3, #0
	mov r4, #0
	
	bl dmaTransfer
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

fxSineWobbleVBlank:

	stmfd sp!, {r0-r7, lr}

	ldr r0, =SIN_bin						@ Address of sine table
	ldr r1, =hOfsBufMain					@ Horizontal scroll register offset
	ldr r2, =hOfsBufSub						@ Horizontal scroll register offset
	ldr r3, =sineOfsMain
	ldr r3, [r3]
	ldr r4, =sineOfsSub
	ldr r4, [r4]
	ldr r5, =0x3FF
	mov r6, #0
	
fxSineWobbleVBlankLoop:
	
	add r7, r3, r6, lsl #2
	and r7, r5
	ldrsh r7, [r0, r7]						@ Load the SIN value
	asr r7, #8								@ Right shift the SIN value
	strh r7, [r1], #2
	
	add r7, r4, r6, lsl #2
	and r7, r5
	ldrsh r7, [r0, r7]						@ Load the SIN value
	asr r7, #8								@ Right shift the SIN value
	strh r7, [r2], #2
	
	add r6, #1
	cmp r6, #192
	bne fxSineWobbleVBlankLoop
	
	ldr r1, =hOfsBufMain					@ Horizontal scroll register offset
	ldr r2, =hOfsBufSub						@ Horizontal scroll register offset
	
	ldr r6, =(192 * 2)
	ldrh r7, [r1]
	strh r7, [r1, r6]
	
	ldrh r7, [r2]
	strh r7, [r2, r6]
	
	ldr r0, =sineOfsMain
	ldrh r1, [r0]
	add r1, #8
	strh r1, [r0]
	
	ldr r0, =sineOfsSub
	ldrh r1, [r0]
	add r1, #8
	strh r1, [r0]
	
	bl DC_FlushAll
	
	@mov r0, #0								@ Dma channel
	@ldr r1, =hOfsBufMain					@ Source
	@add r1, #2
	@ldr r2, =REG_BG1HOFS					@ Dest
	@mov r3, #1								@ Count
	@ldr r4, =(DMA_ENABLE | DMA_REPEAT | DMA_START_HBL | DMA_DST_RESET)
	
	@bl dmaTransfer
	
	mov r0, #2								@ Dma channel
	ldr r1, =hOfsBufSub						@ Source
	add r1, #2
	ldr r2, =REG_BG1HOFS_SUB				@ Dest
	mov r3, #1								@ Count
	ldr r4, =(DMA_ENABLE | DMA_REPEAT | DMA_START_HBL | DMA_DST_RESET)
	
	bl dmaTransfer
	
	ldmfd sp!, {r0-r7, pc}
	
	@ ---------------------------------------
	
	.data
	.align
	
sineOfsMain:
	.word 0
	
sineOfsSub:
	.word 0
	
	.align
hOfsBufMain:
	.space ((192+1) * 2)
	
	.align
hOfsBufSub:
	.space ((192+1) * 2)

	.pool
	.end