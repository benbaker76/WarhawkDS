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
	.align
	.text
	.global addScore
	.global drawScore

addScore:
	stmfd sp!, {r0-r6, lr}
	
	@ To use the score adder, just store the digits in 'adder' a byte for each and call this.
	@ the adder is cleared on exit to stop in keep counting digits.

	mov r0,#7			@ r0 = start digit offset in score and adder
	ldr r3,=score
	ldr r4,=adder
	addLoop:
		ldrb r1,[r3,r0]
		ldrb r2,[r4,r0]
		add r5,r1,r2
		cmp r5,#10
		bmi addPassed
			sub r5,#10		
			sub r0,#1
			ldrb r6,[r3,r0]
			add r6,#1
			strb r6,[r3,r0]
			add r0,#1
		addPassed:
		strb r5,[r3,r0]
		mov r5,#0
		strb r5,[r4,r0]
		
		subs r0,#1
		bne addLoop
	
	ldmfd sp!, {r0-r6, pc}
	
drawDigit:
	@ r0 - digit
	@ r1 - number
	stmfd sp!, {r2-r6, lr} 

	ldr r2, =BG_MAP_RAM(BG0_MAP_BASE)
	add r2, #1024+256+64+32+32
	mov r3, #4
	mov r4, #0
	mla r2, r0, r3, r2
	mov r3, #4
	mov r4, #2
	mla r3, r1, r3, r4
	strh r3, [r2]
	add r2, #2
	add r3, #1
	strh r3, [r2]
	add r2, #63
	add r3, #1
	strh r3, [r2]
	add r2, #1
	add r3, #1
	strh r3, [r2]

	ldmfd sp!, {r2-r6, pc}

drawScore:
	stmfd sp!, {r0-r6, lr}
	
	mov r0,#7
	ldr r2,=score
	digitLoop:
		ldrb r1,[r2,r0]
		bl drawDigit
		subs r0,#1
	bpl digitLoop
	
	ldmfd sp!, {r0-r6, pc}

	.pool
	.end
