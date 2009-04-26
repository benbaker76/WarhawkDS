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
	
	ldr r0, =IRQ_TIMER2						@ TIMER3 interrupt
	ldr r1, =interruptHandlerTimer2			@ Function Address
	bl irqSet
	
	ldr r0, =(IRQ_VBLANK | IRQ_HBLANK | IRQ_TIMER1 | IRQ_TIMER2)		@ Interrupts
	bl irqEnable							@ Enable
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
interruptHandlerVBlank:

	stmfd sp!, {r0-r6, lr}
	
	bl fxVBlank
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
interruptHandlerHBlank:

	stmfd sp!, {r0-r6, lr}
	
	bl fxHBlank
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
interruptHandlerTimer1:

	stmfd sp!, {r0-r6, lr}
	
	bl audioStreamTimer1
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
interruptHandlerTimer2:

	stmfd sp!, {r0-r6, lr}
	
	bl timerTimer2
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------

	.pool
	.end
