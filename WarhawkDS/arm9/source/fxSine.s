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
	.global fxSineWobbleHBlank
	
fxSineWobbleOn:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode					@ lets set the sine wobble effect
	ldr r1, [r0]
	orr r1, #FX_SINE_WOBBLE
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxSineWobbleOff:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode					@ lets unset the sine wobble effect
	ldr r1, [r0]
	and r1, #~(FX_SINE_WOBBLE)
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

fxSineWobbleHBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =SIN_bin				@ Address of sine table
	ldr r1, =REG_VCOUNT				@ REG_VCOUNT address
	ldrh r1, [r1]					@ REG_VCOUNT value
	
	add r0, r1, lsl #1				@ Add the REG_VCOUNT * 2 (16 bit values in SIN table)
	ldrsh r1, [r0]					@ Load the SIN value
	asr r1, #6						@ Right shift the SIN value 4 bits plus 2 bits to make it smaller
	rsb r1, r1, #0					@ Reverse subtract to make it negative (r1=#0 - r1)
	
	ldr r2, =REG_BG2HOFS_SUB		@ Horizontal scroll register offset
	strh r1, [r2]
	
	add r0, #(192 * 2)				@ Add our Main screen offset (* 2 for 16 bit values)
	
	ldrsh r1, [r0]					@ Load the SIN value
	asr r1, #6						@ Right shift the SIN value 4 bits plus 2 bits to make it smaller
	rsb r1, r1, #0					@ Reverse subtract to make it negative (r1=#0 - r1)
	
	ldr r2, =REG_BG2HOFS			@ Horizontal scroll register offset
	strh r1, [r2]
	
	@ -------------------------
	
	ldr r0, =SIN_bin				@ Address of sine table
	ldr r1, =REG_VCOUNT				@ REG_VCOUNT address
	ldrh r1, [r1]					@ REG_VCOUNT value

	add r0, r1, lsl #1				@ Add the REG_VCOUNT * 2 (16 bit values in SIN table)	
	ldrsh r1, [r0]					@ Load the SIN value
	asr r1, #7						@ Right shift the SIN value 4 bits plus 3 bits to make it smaller
	
	ldr r2, =REG_BG3HOFS_SUB		@ Horizontal scroll register offset
	strh r1, [r2]
	
	add r0, #(192 * 2)				@ Add our Main screen offset (* 2 for 16 bit values)
		
	ldrsh r1, [r0]					@ Load the SIN value
	asr r1, #7						@ Right shift the SIN value 4 bits plus 3 bits to make it smaller
	
	ldr r2, =REG_BG3HOFS			@ Horizontal scroll register offset
	strh r1, [r2]

	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

	.pool
	.end