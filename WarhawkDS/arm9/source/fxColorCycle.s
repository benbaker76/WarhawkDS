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
	.global fxColorCycleOn
	.global fxColorCycleOff
	.global fxColorCycleVBlank

fxColorCycleOn:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =BG_PALETTE
	ldr r1, =bgPalette
	ldr r2, =256*2
	bl dmaCopy
	ldr r0, =BG_PALETTE_SUB
	ldr r1, =bgPaletteSub
	bl dmaCopy
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_COLOR_CYCLE
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxColorCycleOff:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	and r1, #~(FX_COLOR_CYCLE)
	str r1, [r0]
	
	ldr r0, =bgPalette
	ldr r1, =BG_PALETTE
	ldr r2, =256*2
	bl dmaCopy
	ldr r0, =bgPaletteSub
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------

fxColorCycleVBlank:

	stmfd sp!, {r0-r6, lr}
	
	bl DC_FlushAll
	
	ldr r0, =BG_PALETTE
	ldrh r3, [r0]
	
	ldr r0, =BG_PALETTE_SUB
	ldrh r4, [r0]
	
	ldr r0, =BG_PALETTE
	ldr r1, =BG_PALETTE
	add r0, #2
	ldr r2, =(255 * 2)
	bl dmaCopy
	ldr r0, =BG_PALETTE_SUB
	ldr r1, =BG_PALETTE_SUB
	add r0, #2
	ldr r2, =(255 * 2)
	bl dmaCopy
	
	ldr r0, =BG_PALETTE
	ldr r1, =(255 * 2)
	strh r3, [r0, r1]
	ldr r0, =BG_PALETTE_SUB
	strh r4, [r0, r1]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
	.data
	.align
	
bgPalette:
	.space 256*2								@ Palette Backup
	
	.align
bgPaletteSub:
	.space 256*2								@ Palette Backup

	.pool
	.end
