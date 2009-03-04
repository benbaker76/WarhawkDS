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

	stmfd sp!, {r0-r9, lr}

	ldr r0, =sinTable2				@ Address of sine table
	ldr r8, =sinTable
	ldr r1, =REG_BG2HOFS_SUB		@ Horizontal scroll register offset
	ldr r2, =REG_BG3HOFS_SUB		@ Horizontal scroll register offset
	ldr r3, =REG_BG2HOFS			@ Horizontal scroll register offset
	ldr r4, =REG_BG3HOFS			@ Horizontal scroll register offset
	ldr r5, =REG_VCOUNT				@ Sine offset address
	ldrb r6, [r5]					@ Sine offset
	mov r9,r6
	
	ldrb r7, [r0, r6]				@ Load the sine value offset
	strh r7, [r1]					@ Write it to the scroll register
	add r6,#192
	cmp r6,#256
	subpl r6,#256
	ldrb r7, [r0, r6]				@ Load the sine value offset	
	strh r7, [r3]
	mov r6,r9
	ldrb r7, [r8, r6]
	strh r7, [r2]					@ Write it to the scroll register
	add r6,#192
	cmp r6,#256
	subpl r6,#256
	ldrb r7, [r8, r6]				@ Load the sine value offset	
	strh r7, [r4]					@ Write it to the scroll register
	
	mov r6,r9
	add r6, #1						@ Add one to the count
	cmp r6, #192					@ Have we reached the end of the sin table?
	moveq r6, #0					@ Yes so reset
	@strb r6, [r5]					@ Write it back to our sineOffset
	
	ldmfd sp!, {r0-r9, pc}
	
	@ ---------------------------------------

	.data
	.align

sineOffset:
	.word 0

	.pool
	.end