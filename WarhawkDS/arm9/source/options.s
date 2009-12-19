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
	.global optionGameModeCurrent
	.global optionGameModeComplete
	.global optionLevelNumNormal
	.global optionLevelNumMental
	.global optionLevelNum

readOptions:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =optionsDatText
	ldr r1, =optionsBuffer
	bl readFileBuffer
	
	bl DC_FlushAll
	
	ldr r0, =optionsBuffer
	
	ldr r1, =optionGameModeCurrent
	ldrb r2, [r0], #1
	str r2, [r1]
	
	ldr r1, =optionGameModeComplete
	ldrb r2, [r0], #1
	str r2, [r1]
	
	ldr r1, =optionLevelNumNormal
	ldrb r2, [r0], #1
	str r2, [r1]
	
	ldr r1, =optionLevelNumMental
	ldrb r2, [r0], #1
	str r2, [r1]
	
	@ More options here
	
	@ --------------- TEST VALUES START ----------------
	
	@ldr r0, =optionGameModeCurrent
	@ldr r1, =OPTION_GAMEMODECURRENT_NORMAL
	@str r1, [r0]

	@ldr r0, =optionGameModeComplete
	@ldr r1, =OPTION_GAMEMODECOMPLETE_NORMAL
	@str r1, [r0]
	
	@ldr r0, =optionLevelNumNormal
	@ldr r1, =LEVEL_16
	@str r1, [r0]
	
	@ldr r0, =optionLevelNumMental
	@ldr r1, =LEVEL_4
	@str r1, [r0]
	
	@ --------------- TEST VALUES END ----------------
	
	ldmfd sp!, {r0-r2, pc}
	
	@------------------------------------

writeOptions:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =optionsBuffer
	
	ldr r1, =optionGameModeCurrent
	ldr r2, [r1]
	strb r2, [r0], #1
	
	ldr r1, =optionGameModeComplete
	ldr r2, [r1]
	strb r2, [r0], #1
	
	ldr r1, =optionLevelNumNormal
	ldr r2, [r1]
	strb r2, [r0], #1
	
	ldr r1, =optionLevelNumMental
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
	
optionGameModeCurrent:
	.word 0
	
optionGameModeComplete:
	.word 0

optionLevelNumNormal:
	.word 0
	
optionLevelNumMental:
	.word 0
	
optionLevelNum:
	.word 0
	
	.align
optionsBuffer:
	.incbin "../../efsroot/Data/Warhawk/Data/Options.dat"

optionsDatText:
	.asciz "/Data/Warhawk/Data/Options.dat"
