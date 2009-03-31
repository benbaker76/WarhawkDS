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

	.arm
	.align
	.text
	
	.global paletteGrey
	
	
	@ was gonna add a function to take all 3 RGB values and find the average and store that in each
	@ but i think this looked great anyway?
	
paletteGrey:
	stmfd sp!, {r0-r6, lr}
	
		@ well, it isnt, but i like the look???
	

		ldr r1, =BG_PALETTE
		ldr r2, =BG_PALETTE_SUB
		
	mov r0,#255
	add r0,#256
	
	greyLoop:
		ldrh r3,[r1,r0]
		
		and r3,#0xf
		strh r3,[r1,r0]
		strh r3,[r2,r0]
		
		subs r0,#1
	bpl greyLoop
	ldmfd sp!, {r0-r6, pc}

