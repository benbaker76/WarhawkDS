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
	.global waitforVblank
	.global waitforNoblank

waitforVblank:
	stmfd sp!, {r0-r6, lr} 
	
	ldr r0,=levelEnd
	ldrb r1, [r0]
	cmp r1,#0
	beq levelBlank
		@ Do our effect for the boss battle!
		ldr r3,=sinus1					@ address of sine
		ldr r5,=REG_BG2HOFS_SUB			@ Preset memory adresses for Horiz Scroll
		ldr r6,=REG_BG2HOFS
		ldr r7,=REG_BG3HOFS_SUB
		ldr r8,=REG_BG3HOFS
		mov r1,#0						@ r1 is our sine/Raster counter
		ldr r0, =REG_VCOUNT
		holdOn:
			ldrh r2, [r0]				@ r2 = raster position <-- (This fixed the problem on h/w -HK)				
			cmp r2,r1					@ check if we are at our raster pos?
		bne holdOn						@ if not, keep waiting
			ldrb r4,[r3,r1]			@ load r4 with sine1 position plus our raster position offest
			strh r4,[r5]	
			strh r4,[r6]
			strh r4,[r7]
			strh r4,[r8]
			add r1,#1					@ add 1 to the raster count (the raster number we are modifying)
			cmp r1,#193					@ check if we are down to our end position
		bne holdOn						@ if not, let us do another line
		ldmfd sp!, {r0-r6, pc}
	
	levelBlank:
	ldr r0, =REG_VCOUNT
	waitVBlankSub:									
	ldrh r1,[r0]						@ read REG_VCOUNT into r2
	cmp r1, #193						@ 193 is, of course, the first scanline of vblank
	bne waitVBlankSub					@ loop if r2 is not equal to (NE condition) 193
	
	ldmfd sp!, {r0-r6, pc}
	
waitforNoblank:
	stmfd sp!, {r0-r6, lr} 
	
	ldr r0, =REG_VCOUNT
	waitVBlankNo:									
	ldrh r1, [r0]						@ read REG_VCOUNT into r2
	cmp r1, #255	
	bmi waitVBlankNo					@ Changed from bne as it was often missed!
	
	ldmfd sp!, {r0-r6, pc}

	.pool
	.end
