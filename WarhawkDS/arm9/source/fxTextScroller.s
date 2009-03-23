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
	.global fxTextScrollerOn
	.global fxTextScrollerOff
	.global fxTextScrollerHBlank
	.global fxTextScrollerVBlank

fxTextScrollerOn:

	stmfd sp!, {r0-r6, lr}
	
	bl stopTimer
	
	ldr r0, =REG_DISPCNT
	ldr r1, [r0]
	orr r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
	ldr r2, =WIN_IN							@ Make bg's appear inside the window
	ldr r3, [r2]
	orr r3, #(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]
	
	ldr r2, =WIN_OUT						@ Make bg's appear inside the window
	ldr r3, [r2]
	orr r3, #(WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]
	
	ldr r2, =WIN0_Y0						@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_Y1						@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r2, =WIN0_X0						@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_X1						@ Bottom pos
	ldr r3, =255
	strb r3, [r2]
	
	ldr r0, =scrollPos
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_TEXT_SCROLLER
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxTextScrollerOff:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =REG_DISPCNT
	ldr r1, [r0]
	and r1, #~(DISPLAY_WIN0_ON)
	str r1, [r0]
	
	ldr r0, =REG_BG0HOFS
	mov r1, #0
	strb r1, [r0]
	
	ldr r0, =WIN_IN
	mov r1, #0
	strh r1, [r0]
	
	ldr r0, =fxMode
	ldr r1, [r0]
	and r1, #~(FX_TEXT_SCROLLER)
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxTextScrollerHBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r2, =WIN0_X0						@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_X1						@ Bottom pos
	ldr r3, =255
	strb r3, [r2]
	
	ldr r0, =REG_VCOUNT
	ldrb r0, [r0]
	
	cmp r0, #182
	blt fxTextScrollerHBlankDone
	
	ldr r2, =WIN0_X0						@ Top pos
	ldr r3, =8
	strb r3, [r2]
	
	ldr r2, =WIN0_X1						@ Bottom pos
	ldr r3, =248
	strb r3, [r2]
	
fxTextScrollerHBlankDone:
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxTextScrollerVBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =scrollText
	ldr r1, =textPos
	ldr r2, [r1]
	add r0, r2
	ldrb r2, [r0]
	mov r3, #0
	cmp r2, #0
	streq r3, [r1]
	
	ldr r1, =scrollPos
	ldr r1, [r1]
	ldr r2, =23									@ y pos
	ldr r3, =0									@ Draw on sub screen
	ldr r4, =1									@ Maximum number of characters
	bl drawTextCount
	
	ldr r0, =hofsScroll
	ldrb r1, [r0]
	ldr r2, =textPos
	ldr r3, [r2]
	ldr r4, =scrollPos
	ldr r5, [r4]
	add r1, #1
	ldr r6, =0x7
	and r6, r1
	cmp r6, #0
	addeq r3, #1
	addeq r5, #1
	and r5, #0x1F
	ldr r6, =REG_BG0HOFS
	str r3, [r2]
	str r5, [r4]
	strb r1, [r6]
	strb r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
	.data
	.align
	
textPos:
	.word 0

scrollPos:
	.word 0
	
hofsScroll:
	.word 0

scrollText:
	.asciz "YO FLASH! WASSUP? HOPE YOU LIKE THIS LATEST COMMIT WITH SCROLLY AND LOGO!! I GUESS WE CAN PUT A PROPER RANT HERE WITH THANKS AND GREETZ... FOR NOW THO I WILL SIGN OFF AND SAY CYA L8R! ...               "
	
	.pool
	.end
