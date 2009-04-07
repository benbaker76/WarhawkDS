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
#include "efs.h"

	#define LEVEL_VALUE_SIZE			1
	#define LEVEL_CRLF_SIZE				2

	.arm
	.align
	.text
	.global readOptions
	.global writeOptions
	.global optionLevelNum

readOptions:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =optionsDatText
	ldr r1, =optionsBuffer
	bl readFileBuffer
	
	ldr r0, =optionsBuffer
	ldr r1, =optionLevelNum
	ldrb r2, [r0], #LEVEL_VALUE_SIZE
	str r2, [r1]
	
	add r0, #LEVEL_CRLF_SIZE
	
	@ More options here
	
	ldmfd sp!, {r0-r2, pc}
	
	@------------------------------------

writeOptions:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =optionsBuffer
	ldr r1, =optionLevelNum
	ldr r2, [r1]
	strb r2, [r0], #LEVEL_VALUE_SIZE

	add r0, #LEVEL_CRLF_SIZE
	
	@ More options here
	
	ldr r0, =optionsDatText
	ldr r1, =optionsBuffer
	bl writeFileBuffer
	
	ldmfd sp!, {r0-r2, pc}
	
	@------------------------------------

	.data
	.align

optionLevelNum:
	.word 0
	
optionsDatText:
	.asciz "/Options.dat"
	
	.align
optionsBuffer:
	.incbin "../../efsroot/Options.dat"

