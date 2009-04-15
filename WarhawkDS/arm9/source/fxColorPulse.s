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
#include "windows.h"

	#define PULSE_FORWARD		0
	#define PULSE_BACKWARD		1

	.arm
	.align
	.text
	.global fxColorPulseOn
	.global fxColorPulseOff
	.global fxColorPulseVBlank
	.global pulseValue

fxColorPulseOn:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_COLOR_PULSE
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxColorPulseOff:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	and r1, #~(FX_COLOR_PULSE)
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------

fxColorPulseVBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =pulseValue							@ Load pulseValue address
	ldr r1, [r0]								@ Load pulseValue value
	
	ldr r2, =pulseDirection						@ Load pulseDirection address
	ldr r3, [r2]								@ Load pulseDirection value
	cmp r3, #PULSE_FORWARD						@ Are we going forward or backward?
	bne fxColorPulseVBlankBackward				@ Were going backward
		
	add r1, #1									@ Add 1 to pulseValue
	cmp r1, #0x1F								@ Are we at 0x1F? (Pure red)
	moveq r3, #PULSE_BACKWARD					@ Yes then set pulse backward
	str r1, [r0]								@ Write back to pulseValue
	str r3, [r2]								@ Write back to pulseDirection
	b fxColorPulseVBlankDone					@ Branch to done
	
fxColorPulseVBlankBackward:

	sub r1, #1									@ Subtract 1 from pulseValue
	cmp r1, #0									@ Are we at 0? (Pure black)
	moveq r3, #PULSE_FORWARD					@ Change to pulse forward
	str r1, [r0]								@ Write back to pulseValue
	str r3, [r2]								@ Write back to pulseDirection
	
fxColorPulseVBlankDone:
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
	.data
	.align
	
pulseValue:
	.word 0
	
pulseDirection:
	.word 0

	.pool
	.end
