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

	#define INPUT_DELAY				16

	.arm
	.align
	.text
	.global readInput
	
readInput:

	stmfd sp!, {r1-r6, lr}
	
	ldr r0, =buttonPress						@ Load hiScoreKeyPress address
	ldr r1, [r0]								@ Load hiScoreKeyPress value
	
	ldr r2, =REG_KEYINPUT						@ Read key input register
	ldr r3, [r2]								@ Read key value
	
	mov r4, r3
	and r4, #(BUTTON_UP	| BUTTON_DOWN | BUTTON_LEFT | BUTTON_RIGHT | BUTTON_A | BUTTON_B | BUTTON_SELECT | BUTTON_START)	
	cmp r4, #(BUTTON_UP	| BUTTON_DOWN | BUTTON_LEFT | BUTTON_RIGHT | BUTTON_A | BUTTON_B | BUTTON_SELECT | BUTTON_START)
	moveq r1, #0								@ if so, set to 0
	addne r1, #1								@ if not, a key is pressed, so add 1
	
	cmp r1, #INPUT_DELAY						@ if we are at INPUT_DELAY, reset to 0 to allow movement
	movpl r1, #1								@ INPUT_DELAY is a delay you may want to adjust to suit?
	
	str r1, [r0]
	
	mov r0, r1
	
	ldmfd sp!, {r1-r6, pc} 					@ restore registers and return
	
	@---------------------------------

	.data
	.align

buttonPress:
	.word 0
	
	.pool
	.end
