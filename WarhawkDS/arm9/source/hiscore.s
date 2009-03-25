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

	#define HISCORE_VALUE_SIZE		7
	#define HISCORE_NAME_SIZE		3
	#define HISCORE_CRLF_SIZE		2
	#define HISCORE_ENTRY_COUNT		10
	#define HISCORE_ENTRY_SIZE		(HISCORE_VALUE_SIZE + HISCORE_NAME_SIZE + HISCORE_CRLF_SIZE)
	#define HISCORE_TOTAL_SIZE		HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE

	.arm
	.align
	.text
	.global showHiScore

showHiScore:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =hiscoreDatText
	ldr r1, =hiscoreBuffer
	
	bl readFileBuffer
	
	@ldr r0, =1234567
	@ldr r1, =hiscoreBuffer
	
	@bl int2Ascii
	
	@ldr r0, =hiscoreBuffer
	
	@bl ascii2Int
	
	
	
	@ldr r0, =41000
	@ldr r1, =benText
	
	@bl addHiScore
	
	
	
	@ldr r0, =41000
	@bl getHiScoreIndex
	
	@mov r8, r0
	@ldr r0, =debugString
	@bl drawDebugString
	
	
	
	
	bl clearBG0Sub

	bl drawHiScoreText
	
	ldr r0, =15									@ 15 seconds
	ldr r1, =showCredits						@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawHiScoreText:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =hiscoreBuffer
	ldr r5, =0
	
drawHiScoreTextLoop:

	ldr r1, =10									@ x pos
	ldr r2, =10									@ y pos
	add r2, r5
	ldr r3, =1									@ Draw on sub screen
	ldr r4, =HISCORE_VALUE_SIZE					@ Number of characters
	bl drawTextCount
	
	add r0, #HISCORE_VALUE_SIZE
	
	ldr r1, =19									@ x pos
	ldr r2, =10									@ y pos
	add r2, r5
	ldr r3, =1									@ Draw on sub screen
	ldr r4, =HISCORE_NAME_SIZE					@ Number of characters
	bl drawTextCount
	
	add r0, #(HISCORE_NAME_SIZE + HISCORE_CRLF_SIZE)

	add r5, #1
	cmp r5, #HISCORE_ENTRY_COUNT
	bne drawHiScoreTextLoop
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
getHiScoreIndex:

	stmfd sp!, {r1-r4, lr}
	
	@ r0 = hiscore value
	@ r0 = return index (0=No hiscore, or number)
	
	mov r4, r0
	
	ldr r1, =hiscoreBuffer
	mov r2, #0
	mov r3, #0
	
getHiScoreIndexLoop:

	mov r0, r1
	bl ascii2Int
	
	cmp r4, r0
	ble getHiScoreIndexContinue
	
	mov r2, r3
	
	b getHiScoreIndexDone
	
getHiScoreIndexContinue:

	add r1, #HISCORE_ENTRY_SIZE
	
	add r3, #1
	cmp r3, #HISCORE_ENTRY_COUNT
	bne getHiScoreIndexLoop
	
getHiScoreIndexDone:

	mov r0, r2
	
	ldmfd sp!, {r1-r4, pc} 					@ restore registers and return
	
	@---------------------------------
	
addHiScore:

	stmfd sp!, {r0-r7, lr}
	
	@ r0 = hiscore value
	@ r1 = pointer to name text
	
	mov r5, r0
	mov r6, r1
	ldr r7, =nameBuffer

	ldr r1, =hiscoreBuffer
	ldr r4, =0
	
addHiScoreLoop:

	mov r0, r1
	bl ascii2Int
	
	cmp r5, r0
	addle r1, #HISCORE_ENTRY_SIZE
	ble addHiScoreContinue
	
	mov r3, r0
	mov r0, r5
	
	bl int2Ascii
	
	mov r5, r3
	
	add r1, #HISCORE_VALUE_SIZE
	
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	
	sub r1, #3
	sub r7, #3
	
	ldrb r3, [r6], #1
	strb r3, [r1], #1
	ldrb r3, [r6], #1
	strb r3, [r1], #1
	ldrb r3, [r6], #1
	strb r3, [r1], #(1 + HISCORE_CRLF_SIZE)
	
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	
	sub r6, #3
	sub r7, #3
	
addHiScoreContinue:
	
	add r4, #1
	cmp r4, #HISCORE_ENTRY_COUNT
	bne addHiScoreLoop
	
	ldmfd sp!, {r0-r7, pc} 					@ restore registers and return
	
	@---------------------------------
	
int2Ascii:
	
	@ r0 = value
	@ r1 = pointer to buffer
	
	stmfd sp!, {r0-r6, lr}
	
	mov r4, r1
	add r4, #HISCORE_VALUE_SIZE-1
	mov r5, #0
	mov r1, r0

int2AsciiLoop:
	
	mov r2, #10									@ This is our divider
	bl divideNumber								@ call our code to divide r1 by r2 and return r0 with fraction
	add r1, #0x30
	strb r1, [r4]
	sub r4, #1
	mov r1, r0									@ put the result back in r1 (original r1/10)
	add r5, #1
	cmp r5, #HISCORE_VALUE_SIZE
	beq int2AsciiDone
	cmp r1, #0									@ is our result 0 yet, if not, we have more to do
	bne int2AsciiLoop
	
	mov r1, #0x30
	
int2AsciiAddZerosLoop:

	strb r1, [r4]
	sub r4, #1
	
	add r5, #1
	cmp r5, #HISCORE_VALUE_SIZE
	bne int2AsciiAddZerosLoop

int2AsciiDone:
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
ascii2Int:
	
	@ r0 = pointer to buffer
	@ r0 = return value
	
	stmfd sp!, {r1-r6, lr}
	
	add r0, #HISCORE_VALUE_SIZE-1
	
	mov r1, #0
	mov r2, #0
	mov r3, #1

ascii2IntLoop:
	
	ldrb r4, [r0]
	sub r0, #1
	sub r4, #0x30
	mul r4, r3
	add r1, r4
	mov r5, #10
	mul r3, r5
	add r2, #1
	cmp r2, #HISCORE_VALUE_SIZE
	bne ascii2IntLoop
	
	mov r0, r1
	
	ldmfd sp!, {r1-r6, pc} 					@ restore registers and return
	
	@---------------------------------

	.data
	.align
	
nameBuffer:
	.space 3

hiscoreBuffer:
	.space HISCORE_TOTAL_SIZE
	
hiscoreDatText:
	.asciz "/HiScore.dat"
	
benText:
	.asciz "BEN"
	
	.pool
	.end