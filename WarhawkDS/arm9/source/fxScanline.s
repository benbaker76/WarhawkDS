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

	.arm
	.align
	.text
	.global fxScanline
	.global fxScanlineVBlank
	.global fxScanlineHBlank

fxScanline:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =REG_DISPCNT
	ldr r1, [r0]
	orr r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB
	ldr r1, [r0]
	orr r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
	ldr r2, =WIN_IN							@ Make bg's appear inside the window
	ldr r3, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]
	
	ldr r2, =SUB_WIN_IN						@ Make bg's appear inside the window
	ldr r3, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]
	
	ldr r2, =WIN0_Y0						@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_Y1						@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_Y0					@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_Y1					@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r0, =scanx
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =fxMode					@ lets set the spotlight effect
	ldr r1, [r0]
	orr r1, #FX_SCANLINE
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
clearWindow:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =REG_DISPCNT
	ldr r1, [r0]
	and r1, #~(DISPLAY_WIN0_ON)
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB
	ldr r1, [r0]
	and r1, #~(DISPLAY_WIN0_ON)
	str r1, [r0]
	
	ldr r2, =WIN_IN							@ Make bg's appear inside the window
	ldr r3, =0
	strh r3, [r2]
	
	ldr r2, =SUB_WIN_IN						@ Make bg's appear inside the window
	ldr r3, =0
	strh r3, [r2]

	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

fxScanlineVBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =scanx
	ldr r1, [r0]
	add r1, #3
	str r1, [r0]
	
	ldr r0, =fxMode
	ldr r2, [r0]
	mov r3, #~(FX_SCANLINE)
	cmp r1, #255
	andgt r2, r3
	blgt clearWindow
	str r2, [r0]

	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxScanlineHBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =REG_VCOUNT
	ldrh r1, [r0]
	and r1, #0x1
	
	cmp r1, #0
	bne fxScanlineShow
	
	ldr r2, =WIN0_X0						@ Right pos
	ldr r3, =0
	strb r3, [r2]
	ldr r2, =SUB_WIN0_X0					@ Right pos
	strb r3, [r2]
	
	ldr r2, =WIN0_X1						@ Left pos
	ldr r3, =scanx
	ldrb r3, [r3]
	strb r3, [r2]
	ldr r2, =SUB_WIN0_X1					@ Left pos
	strb r3, [r2]
	
	b fxScanlineDone
	
fxScanlineShow:

	ldr r2, =WIN0_X0						@ Right pos
	ldr r3, =255
	ldr r4, =scanx
	ldrb r4, [r4]
	sub r3, r4
	strb r3, [r2]
	ldr r2, =SUB_WIN0_X0					@ Right pos
	strb r3, [r2]

	ldr r2, =WIN0_X1						@ Left pos
	ldr r3, =255
	strb r3, [r2]
	ldr r2, =SUB_WIN0_X1					@ Left pos
	strb r3, [r2]
	
fxScanlineDone:

	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------

	.data
	.align

scanx:
	.word 0

	.pool
	.end