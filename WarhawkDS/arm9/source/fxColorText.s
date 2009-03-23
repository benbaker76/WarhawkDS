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

	#define FONT_COLOR_OFFSET	11
	#define COLOR_WHITE			0x7FFF

	.arm
	.align
	.text
	.global fxCopperTextOn
	.global fxCopperTextOff
	.global fxCopperTextHBlank
	.global fxCopperTextVBlank
	.global fxColorCycleTextOn
	.global fxColorCycleTextOff
	.global fxColorCycleTextHBlank

fxCopperTextOn:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_COPPER_TEXT
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxCopperTextOff:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	and r1, #~(FX_COPPER_TEXT)
	str r1, [r0]
	
	ldr r0, =BG_PALETTE
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =COLOR_WHITE
	ldr r3, =(FONT_COLOR_OFFSET * 2)
	strh r2, [r0, r3]
	strh r2, [r1, r3]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxColorCycleTextOn:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_COLOR_CYCLE_TEXT
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxColorCycleTextOff:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	and r1, #~(FX_COLOR_CYCLE_TEXT)
	str r1, [r0]
	
	ldr r0, =BG_PALETTE
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =COLOR_WHITE
	ldr r3, =(FONT_COLOR_OFFSET * 2)
	strh r2, [r0, r3]
	strh r2, [r1, r3]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxCopperTextHBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =BG_PALETTE
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =REG_VCOUNT
	ldrh r2, [r2]
	add r2, #1
	lsl r2, #1
	ldr r3, =colorPal
	ldrh r2, [r3, r2]
	ldr r3, =(FONT_COLOR_OFFSET * 2)
	ldr r4, =COLOR_WHITE
		
	strh r2, [r0, r3]
	strh r2, [r1, r3]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxCopperTextVBlank:

	stmfd sp!, {r0-r6, lr}
	
	bl DC_FlushAll
	
	ldr r0, =colorPal
	ldrh r3, [r0]
	
	ldr r0, =colorPal
	ldr r1, =colorPal
	add r0, #2
	ldr r2, =(255 * 2)
	bl dmaCopy
	
	ldr r0, =colorPal
	ldr r1, =(255 * 2)
	strh r3, [r0, r1]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxColorCycleTextHBlank:

	stmfd sp!, {r0-r6, lr}
	
	bl getRandom
	
	ldr r0, =BG_PALETTE
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =colorOffset
	ldr r2, [r2]
	ldr r3, =(FONT_COLOR_OFFSET * 2)
	
	ldrh r5, [r0, r2]
	ldrh r6, [r1, r2]
	
	strh r5, [r0, r3]
	strh r6, [r1, r3]
	
	ldr r0, =colorWait
	ldr r1, [r0]
	ldr r2, =colorOffset
	ldr r3, [r2]
	add r1, #1
	cmp r1, #4
	moveq r1, #0
	moveq r3, r8
	andeq r3, #0xF
	str r1, [r0]
	str r3, [r2]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
	.data
	.align
	
colorOffset:
	.word 0
	
colorWait:
	.word 0
	
colorPal:
	.hword 0x44ce,0x44ce,0x5511,0x5d73,0x65f6,0x5d73,0x5511,0x44ce
	.hword 0x5d6d,0x5d6d,0x6a32,0x6ed6,0x777b,0x6ed6,0x6a32,0x5d6d
	.hword 0x1e4a,0x1e4a,0x26cd,0x2eee,0x4332,0x2eee,0x26cd,0x1e4a
	.hword 0x5ead,0x5ead,0x66f2,0x6f35,0x779a,0x6f35,0x66f2,0x5ead
	.hword 0x2993,0x2993,0x3a16,0x4a98,0x5f1b,0x4a98,0x3a16,0x2993
	.hword 0x3737,0x3737,0x539b,0x63bc,0x7bff,0x63bc,0x539b,0x3737
	.hword 0x4e73,0x4e73,0x5ef7,0x6b5a,0x739c,0x6b5a,0x5ef7,0x4e73
	.hword 0x4373,0x4373,0x4f96,0x67ba,0x7fff,0x67ba,0x4f96,0x4373
	.hword 0x44ce,0x44ce,0x5511,0x5d73,0x65f6,0x5d73,0x5511,0x44ce
	.hword 0x5d6d,0x5d6d,0x6a32,0x6ed6,0x777b,0x6ed6,0x6a32,0x5d6d
	.hword 0x1e4a,0x1e4a,0x26cd,0x2eee,0x4332,0x2eee,0x26cd,0x1e4a
	.hword 0x5ead,0x5ead,0x66f2,0x6f35,0x779a,0x6f35,0x66f2,0x5ead
	.hword 0x2993,0x2993,0x3a16,0x4a98,0x5f1b,0x4a98,0x3a16,0x2993
	.hword 0x3737,0x3737,0x539b,0x63bc,0x7bff,0x63bc,0x539b,0x3737
	.hword 0x4e73,0x4e73,0x5ef7,0x6b5a,0x739c,0x6b5a,0x5ef7,0x4e73
	.hword 0x4373,0x4373,0x4f96,0x67ba,0x7fff,0x67ba,0x4f96,0x4373
	.hword 0x44ce,0x44ce,0x5511,0x5d73,0x65f6,0x5d73,0x5511,0x44ce
	.hword 0x5d6d,0x5d6d,0x6a32,0x6ed6,0x777b,0x6ed6,0x6a32,0x5d6d
	.hword 0x1e4a,0x1e4a,0x26cd,0x2eee,0x4332,0x2eee,0x26cd,0x1e4a
	.hword 0x5ead,0x5ead,0x66f2,0x6f35,0x779a,0x6f35,0x66f2,0x5ead
	.hword 0x2993,0x2993,0x3a16,0x4a98,0x5f1b,0x4a98,0x3a16,0x2993
	.hword 0x3737,0x3737,0x539b,0x63bc,0x7bff,0x63bc,0x539b,0x3737
	.hword 0x4e73,0x4e73,0x5ef7,0x6b5a,0x739c,0x6b5a,0x5ef7,0x4e73
	.hword 0x4373,0x4373,0x4f96,0x67ba,0x7fff,0x67ba,0x4f96,0x4373
	.hword 0x44ce,0x44ce,0x5511,0x5d73,0x65f6,0x5d73,0x5511,0x44ce
	.hword 0x5d6d,0x5d6d,0x6a32,0x6ed6,0x777b,0x6ed6,0x6a32,0x5d6d
	.hword 0x1e4a,0x1e4a,0x26cd,0x2eee,0x4332,0x2eee,0x26cd,0x1e4a
	.hword 0x5ead,0x5ead,0x66f2,0x6f35,0x779a,0x6f35,0x66f2,0x5ead
	.hword 0x2993,0x2993,0x3a16,0x4a98,0x5f1b,0x4a98,0x3a16,0x2993
	.hword 0x3737,0x3737,0x539b,0x63bc,0x7bff,0x63bc,0x539b,0x3737
	.hword 0x4e73,0x4e73,0x5ef7,0x6b5a,0x739c,0x6b5a,0x5ef7,0x4e73
	.hword 0x4373,0x4373,0x4f96,0x67ba,0x7fff,0x67ba,0x4f96,0x4373
	
	.pool
	.end
