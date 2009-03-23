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
	.global clearBG0
	.global clearBG0Sub
	.global clearBG1
	.global clearBG2
	.global clearBG3

clearBG0:
	stmfd sp!, {r0-r6, lr} 

	mov r0, #0
	ldr r1, =BG_MAP_RAM(BG0_MAP_BASE)
	ldr r2, =2048
	bl dmaFillWords
	ldr r1, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB)
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}
	
clearBG0Sub:
	stmfd sp!, {r0-r6, lr} 

	mov r0, #0
	ldr r1, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB)
	ldr r2, =2048
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}
	
clearBG1:
	stmfd sp!, {r0-r6, lr} 

	mov r0, #0
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)
	ldr r2, =2048
	bl dmaFillWords
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}
	
clearBG2:
	stmfd sp!, {r0-r6, lr} 

	mov r0, #0
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)
	ldr r2, =1024
	bl dmaFillWords
	ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}
	
clearBG3:
	stmfd sp!, {r0-r6, lr} 

	mov r0, #0
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)
	ldr r2, =1024
	bl dmaFillWords
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}

	.pool
	.end
