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

	.arm
	.align
	.text
	.global readOptions
	.global writeOptions
	.global optionLevelNum
	.global optionMentalVer

readOptions:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =optionsDatText
	ldr r1, =optionsBuffer
	bl readFileBuffer
	
	bl DC_FlushAll
	
	ldr r0, =optionsBuffer
	ldr r1, =optionLevelNum
	ldrb r2, [r0], #1
	str r2, [r1]
	
	ldr r1, =optionMentalVer
	ldrb r2, [r0], #1
	str r2, [r1]
	
	@ldr r0, =optionLevelNum						@ Read optionLevelNum address
	@ldr r1, =8
	@str r1, [r0]								@ Read optionLevelNum value

	@ More options here
	
	ldmfd sp!, {r0-r2, pc}
	
	@------------------------------------

writeOptions:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =optionsBuffer
	ldr r1, =optionLevelNum
	ldr r2, [r1]
	strb r2, [r0], #1
	
	ldr r1, =optionMentalVer
	ldr r2, [r1]
	strb r2, [r0], #1
	
	@ More options here
	
	ldr r0, =optionsDatText
	ldr r1, =optionsBuffer
	bl writeFileBuffer
	
	bl DC_FlushAll
	
	ldmfd sp!, {r0-r2, pc}
	
	@------------------------------------

	.data
	.align

optionLevelNum:
	.word 1
	
optionMentalVer:
	.word 0
	
	.align
optionsBuffer:
	.incbin "../../efsroot/Options.dat"

optionsDatText:
	.asciz "/Options.dat"
