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
	.global gameStop
	.global gamePause
	.global checkGameOver
	
gameStop:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_STOPPED
	str r1, [r0]
		
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
gamePause:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_PAUSED
	str r1, [r0]
		
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------
	
checkGameOver:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =energy
	ldr r1, [r0]
	cmp r1, #0
	bne checkGameOverDone
	beq checkGameOverDone
	bl fxFadeBlackOut
	bl fxMosaicOut
	
	bl drawAllEnergyBars	

	ldr r0, =gameOverText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =10									@ y pos
	ldr r3, =0									@ Draw on main screen
	bl drawText
	
	ldr r0, =gameOverText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =10									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	bl gameStop
	
checkGameOverDone:
		
	ldmfd sp!, {r0-r6, pc}

	.pool
	.end
