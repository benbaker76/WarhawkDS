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

#include "math.h"

	.arm
	.align
	.text
	.global irqSet
	.global irqInit
	.global irqEnable
	.global irqDisable
	.global irqClear
	.global irqTable

@ fn divf32(int32 num, int32 den)
@ brief Fixed point divide
@ r0 = param num Takes 20.12 numerator and denominator
@ r1 = param den Takes 20.12 numerator and denominator
@ r0 = return returns 20.12 result
divf32:

	stmfd sp!, {r2-r3, lr}

	@ r0 - Number
	@ r1 - Denominator
	
	ldr r2, =REG_DIVCNT					@ Load REG_DIVCNT
	mov r3, #DIV_64_32					@ Load DIV_64_32
	strh r3, [r3]						@ Write it to REG_DIVCNT
	
divf32Loop1:
	
	ldr r3, [r2]						@ Read REG_DIVCNT
	tst r3, #DIV_BUSY					@ Busy?
	bne divf32Loop1						@ Yes, so loop
	
	ldr r3, =REG_DIV_NUMER				@ Load REG_DIV_NUMER
	lsl r0, #12							@ Shift left
	str r0, [r3]						@ Write the num
	
	ldr r3, =REG_DIV_DENOM_L			@ Load REG_DIV_DENOM_L
	str r1, [r3]						@ Write the den
	
divf32Loop2:
	
	ldr r3, [r2]						@ Read REG_DIVCNT
	tst r3, #DIV_BUSY					@ Busy?
	bne divf32Loop2						@ Yes, so loop
	
	ldr r0, =REG_DIV_RESULT_L			@ Get REG_DIV_RESULT_L address
	ldr r0, [r0]						@ Get result and place it in r0
	
	ldmfd sp!, {r2-r3, pc}				@ Return
	
	@ ---------------------------------------------

	.pool
	.end
