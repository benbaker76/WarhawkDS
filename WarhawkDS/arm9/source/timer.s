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

#include "system.h"
#include "audio.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "ipc.h"
#include "timers.h"

	.arm
	.text
	.align
	.global startTimer
	.global stopTimer
	.global timerTimer3
	
startTimer:

	@ r0 - timer count in milliseconds
	@ r1 - callback function address

	stmfd sp!, {r0-r6, lr}
	
	bl stopTimer
	
	ldr r2, =timerCount
	str r0, [r2]
	
	ldr r2, =callbackAddress
	str r1, [r2]
	
	ldr r0, =timerElapsed
	ldr r1, =0
	str r1, [r0]
	
	ldr r0, =TIMER2_DATA
	ldr r1, =TIMER_FREQ(1000)
	strh r1, [r0]
	
	ldr r0, =TIMER2_CR
	ldr r1, =TIMER_ENABLE | TIMER_DIV_1
	strh r1, [r0]
	
	ldr r0, =TIMER3_DATA
	ldr r1, =(0x10000 - 1)								@ Change to (0x10000 - 1000) for seconds
	strh r1, [r0]

	ldr r0, =TIMER3_CR
	ldr r1, =(TIMER_ENABLE | TIMER_IRQ_REQ | TIMER_CASCADE)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}								@ Return
	
	@ ---------------------------------------------

stopTimer:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =TIMER2_CR
	ldrh r1, [r0]
	and r1, #~(TIMER_ENABLE)
	strh r1, [r0]

	ldr r0, =TIMER3_CR
	ldrh r1, [r0]
	and r1, #~(TIMER_ENABLE)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}								@ Return
	
	@ ---------------------------------------------

timerTimer3:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =timerElapsed
	ldr r1, [r0]
	
	ldr r2, =timerCount
	ldr r2, [r2]
	cmp r1, r2
	bleq stopTimer
	
	push {lr}

	adr	lr, timerReturn
	ldr r0, =callbackAddress
	ldr r0, [r0]
	bxeq r0
	
timerReturn:
	
	pop {lr}
	
	ldr r0, =timerElapsed
	ldr r1, [r0]
	add r1, #1
	str r1, [r0]
	
	@mov r8, r1
	@ldr r0, =debugString
	@bl drawDebugString

	ldmfd sp!, {r0-r6, pc}								@ Return
	
	@ ---------------------------------------------

	.data
	.align
	
timerElapsed:
	.word 0
	
timerCount:
	.word 0
	
callbackAddress:
	.word 0

	.pool
	.end
