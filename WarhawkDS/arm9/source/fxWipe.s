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
	.global fxWipeInLeft
	.global fxWipeInRight
	.global fxWipeOutUp
	.global fxWipeOutDown
	.global fxWipeInLeftVBlank
	.global fxWipeInRightVBlank
	.global fxWipeOutUpVBlank
	.global fxWipeOutDownVBlank

fxWipeInit:

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
	
	ldr r0, =scroll							@ Get our scroll position
	mov r1, #0
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

fxWipeInLeft:

	stmfd sp!, {r0-r6, lr}
	
	bl fxWipeInit
	
	ldr r0, =fxMode					@ lets set the wipe effect
	ldr r1, [r0]
	orr r1, #FX_WIPE_IN_LEFT
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxWipeInRight:

	stmfd sp!, {r0-r6, lr}
	
	bl fxWipeInit
	
	ldr r0, =fxMode					@ lets set the wipe effect
	ldr r1, [r0]
	orr r1, #FX_WIPE_IN_RIGHT
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxWipeOutUp:

	stmfd sp!, {r0-r6, lr}
	
	bl fxWipeInit
	
	ldr r0, =fxMode					@ lets set the wipe effect
	ldr r1, [r0]
	orr r1, #FX_WIPE_OUT_UP
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxWipeOutDown:

	stmfd sp!, {r0-r6, lr}
	
	bl fxWipeInit
	
	ldr r0, =fxMode					@ lets set the wipe effect
	ldr r1, [r0]
	orr r1, #FX_WIPE_OUT_DOWN
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxWipeInLeftVBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =scroll							@ Get our scroll position
	ldr r1, [r0]

	ldr r2, =WIN_OUT						@ make bg0 appear outside the window
	ldr r3, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]
	
	ldr r2, =WIN_IN							@ reset the winin reg
	ldr r3, =0
	strh r3, [r2]

	ldr r2, =WIN0_X0						@ Left pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_X1						@ Right pos
	ldr r3, =255
	sub r4, r3, r1
	strb r4, [r2]
	
	ldr r2, =WIN0_Y0						@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_Y1						@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r2, =SUB_WIN_OUT					@ make bg0 appear outside the window
	ldr r3, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]
	
	ldr r2, =SUB_WIN_IN						@ reset the winin reg
	ldr r3, =0
	strh r3, [r2]

	ldr r2, =SUB_WIN0_X0					@ Left pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_X1					@ Right pos
	ldr r3, =255
	sub r4, r3, r1
	strb r4, [r2]
	
	ldr r2, =SUB_WIN0_Y0					@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_Y1					@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r2, =fxMode
	ldr r3, [r2]
	add r1, #4								@ Speed of the wipe
	cmp r1, #255							@ Switch mode when the wipe is done
	andgt r3, #~(FX_WIPE_IN_LEFT)
	blgt clearWindow
	str r1, [r0]
	str r3, [r2]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

	
fxWipeInRightVBlank:						@ Right side wipe

	stmfd sp!, {r0-r6, lr}

	ldr r0, =scroll							@ Get our scroll position
	ldr r1, [r0]

	ldr r2, =WIN_OUT						@ Reset the WIN_OUT reg
	ldr r3, =0
	strh r3, [r2]
	
	ldr r2, =WIN_IN							@ Make bg0 appear inside the window
	ldr r3, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]

	ldr r2, =WIN0_X0						@ Left pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_X1						@ Right pos
	strb r1, [r2]
	
	ldr r2, =WIN0_Y0						@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_Y1						@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r2, =SUB_WIN_OUT					@ Reset the SUB_WIN_OUT reg
	ldr r3, =0
	strh r3, [r2]
	
	ldr r2, =SUB_WIN_IN						@ Make bg0 appear inside the window
	ldr r3, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]

	ldr r2, =SUB_WIN0_X0					@ Left pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_X1					@ Right pos
	strb r1, [r2]
	
	ldr r2, =SUB_WIN0_Y0					@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_Y1					@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r2, =fxMode
	ldr r3, [r2]
	add r1, #4								@ Speed of the wipe
	cmp r1, #255							@ Switch mode when the wipe is done
	andgt r3, #~(FX_WIPE_IN_RIGHT)
	blgt clearWindow
	str r1, [r0]
	str r3, [r2]

	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxWipeOutUpVBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =scroll							@ Get our scroll position
	ldr r1, [r0]

	ldr r2, =WIN_OUT						@ Reset the WIN_OUT reg
	ldr r3, =0
	strh r3, [r2]
	
	ldr r2, =WIN_IN							@ Make bg0 appear inside the window
	ldr r3, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]

	ldr r2, =WIN0_X0						@ Left pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_X1						@ Right pos
	ldr r3, =255
	strb r3, [r2]
	
	ldr r2, =WIN0_Y0						@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_Y1						@ Bottom pos
	ldr r3, =192
	sub r4, r3, r1
	strb r4, [r2]
	
	ldr r2, =SUB_WIN_OUT					@ Reset the SUB_WIN_OUT reg
	ldr r3, =0
	strh r3, [r2]
	
	ldr r2, =SUB_WIN_IN						@ Make bg0 appear inside the window
	ldr r3, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]

	ldr r2, =SUB_WIN0_X0					@ Left pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_X1					@ Right pos
	ldr r3, =255
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_Y0					@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_Y1					@ Bottom pos
	ldr r3, =192
	sub r4, r3, r1
	strb r4, [r2]
	
	ldr r2, =fxMode
	ldr r3, [r2]
	add r1, #4								@ Speed of the wipe
	cmp r1, #255							@ Switch mode when the wipe is done
	andgt r3, #~(FX_WIPE_OUT_UP)
	blgt clearWindow
	str r1, [r0]
	str r3, [r2]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxWipeOutDownVBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =scroll							@ Get our scroll position
	ldr r1, [r0]

	ldr r2, =WIN_OUT						@ Reset the WIN_OUT reg
	ldr r3, =0
	strh r3, [r2]
	
	ldr r2, =WIN_IN							@ Make bg0 appear inside the window
	ldr r3, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]

	ldr r2, =WIN0_X0						@ Left pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_X1						@ Right pos
	ldr r3, =255
	strb r3, [r2]
	
	ldr r2, =WIN0_Y0						@ Top pos
	strb r1, [r2]
	
	ldr r2, =WIN0_Y1						@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r2, =SUB_WIN_OUT					@ Reset the SUB_WIN_OUT reg
	ldr r3, =0
	strh r3, [r2]
	
	ldr r2, =WIN_IN							@ Make bg0 appear inside the window
	ldr r3, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]

	ldr r2, =SUB_WIN0_X0					@ Left pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_X1					@ Right pos
	ldr r3, =255
	strb r3, [r2]
	
	ldr r2, =SUB_WIN0_Y0					@ Top pos
	strb r1, [r2]
	
	ldr r2, =SUB_WIN0_Y1					@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r2, =fxMode
	ldr r3, [r2]
	add r1, #4								@ Speed of the wipe
	cmp r1, #255							@ Switch mode when the wipe is done
	andgt r3, #~(FX_WIPE_OUT_DOWN)
	blgt clearWindow
	str r1, [r0]
	str r3, [r2]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

	.data
	.align

scroll:
	.word 0

	.pool
	.end
