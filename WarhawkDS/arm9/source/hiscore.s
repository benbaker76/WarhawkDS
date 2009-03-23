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
	.global showHiScore

showHiScore:

	stmfd sp!, {r0-r6, lr}
	
	@ int writeHiScore(char *pName, int score)
	
	@ldr r0, =benText
	@ldr r1, =21000
	@bl writeHiScore
	@bl DC_FlushAll
	
	bl clearBG0Sub

	bl drawHiScoreText
	
	ldr r0, =15									@ 15 seconds
	ldr r1, =showCredits						@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawHiScoreText:

	stmfd sp!, {r0-r6, lr}
	
	ldr r5, =0
	
drawHiScoreTextLoop:

	mov r0, r5
	
	bl readHiScoreValue
	
	mov r10, r0									@ value
	mov r8, #10									@ y pos
	add r8, r5									@ add y offset
	mov r9, #7									@ Number of digits
	mov r11, #10								@ x pos
	bl drawDigits				

	ldr r0, =buffer
	mov r1, r5
	
	bl readHiScoreName
	
	ldr r0, =buffer
	ldr r1, =19									@ x pos
	ldr r2, =10									@ y pos
	add r2, r5
	ldr r3, =1									@ Draw on sub screen
	bl drawText

	add r5, #1
	cmp r5, #10
	bne drawHiScoreTextLoop
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------

	.data
	.align

buffer:
	.space 4
	
benText:
	.asciz "BEN"
	
	.pool
	.end