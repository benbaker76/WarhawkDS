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

	#define FONT_COLOR_OFFSET				255
	
	#define COLOR_HILIGHT					COLOR_YELLOW

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
	.global colorHilight

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

	stmfd sp!, {r0-r4, lr}
	
	ldr r0, =colorHilight
	ldr r0, [r0]
	cmp r0, #0
	beq fxCopperTextVBlankContinue
	
	lsl r0, #3
	sub r0, #1
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =REG_VCOUNT
	ldrh r2, [r2]
	ldr r3, =(FONT_COLOR_OFFSET * 2)
	ldr r4, =COLOR_HILIGHT
	cmp r2, r0
	blt fxCopperTextVBlankContinue
	add r0, #8
	cmp r2, r0
	bge fxCopperTextVBlankContinue
	strh r4, [r1, r3]
	b fxCopperTextVBlankDone
	
fxCopperTextVBlankContinue:
	
	ldr r0, =BG_PALETTE
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =REG_VCOUNT
	ldrh r2, [r2]
	add r2, #1
	lsl r2, #1
	ldr r3, =colorPal
	ldrh r2, [r3, r2]
	ldr r3, =(FONT_COLOR_OFFSET * 2)
		
	strh r2, [r0, r3]
	strh r2, [r1, r3]
	
fxCopperTextVBlankDone:
	
	ldmfd sp!, {r0-r4, pc}

	@ ---------------------------------------
	
fxCopperTextVBlank:

	stmfd sp!, {r0-r6, lr}
	
	bl DC_FlushAll
	
	ldr r0, =colorPal
	
	ldr r0, =colorPal
	ldr r1, =colorPal
	add r0, #2
	ldr r2, =(255 * 2)
	bl dmaCopy
	
	ldr r0, =colorPal
	ldrh r1, [r0]
	ldr r2, =(255 * 2)
	strh r1, [r0, r2]
	
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
	
colorHilight:
	.word 0
	
colorOffset:
	.word 0
	
colorWait:
	.word 0
	
	.align
colorPal:
	.hword 0x0c00,0x1c00,0x2800,0x3400,0x4400,0x5000,0x6000,0x6c00
	.hword 0x7c00,0x7c63,0x7cc6,0x7d4a,0x7dad,0x7e10,0x7e94,0x7ef7
	.hword 0x7ef7,0x7e94,0x7e10,0x7dad,0x7d4a,0x7cc6,0x7c63,0x7c00
	.hword 0x6c00,0x6000,0x5000,0x4400,0x3400,0x2800,0x1c00,0x0c00
	.hword 0x0063,0x00e5,0x0148,0x01ab,0x022d,0x0290,0x0313,0x0376
	.hword 0x03f8,0x0ff9,0x1bfa,0x2bfb,0x37fb,0x43fc,0x53fd,0x5ffd
	.hword 0x5ffd,0x53fd,0x43fc,0x37fb,0x2bfb,0x1bfa,0x0ff9,0x03f8
	.hword 0x0376,0x0313,0x0290,0x022d,0x01ab,0x0148,0x00e5,0x0063
	.hword 0x0003,0x0007,0x000a,0x000d,0x0011,0x0014,0x0018,0x001b
	.hword 0x001f,0x0c7f,0x18df,0x295f,0x35bf,0x421f,0x529f,0x5eff
	.hword 0x5eff,0x529f,0x421f,0x35bf,0x295f,0x18df,0x0c7f,0x001f
	.hword 0x001b,0x0018,0x0014,0x0011,0x000d,0x000a,0x0007,0x0003
	.hword 0x0842,0x0c63,0x14a5,0x1ce7,0x2529,0x294a,0x318c,0x39ce
	.hword 0x3def,0x4631,0x4e73,0x5294,0x5ad6,0x6318,0x6739,0x6f7b
	.hword 0x6f7b,0x6739,0x6318,0x5ad6,0x5294,0x4e73,0x4631,0x3def
	.hword 0x39ce,0x318c,0x294a,0x2529,0x1ce7,0x14a5,0x0c63,0x0842
	.hword 0x0c00,0x1c00,0x2800,0x3400,0x4400,0x5000,0x6000,0x6c00
	.hword 0x7c00,0x7c63,0x7cc6,0x7d4a,0x7dad,0x7e10,0x7e94,0x7ef7
	.hword 0x7ef7,0x7e94,0x7e10,0x7dad,0x7d4a,0x7cc6,0x7c63,0x7c00
	.hword 0x6c00,0x6000,0x5000,0x4400,0x3400,0x2800,0x1c00,0x0c00
	.hword 0x0063,0x00e5,0x0148,0x01ab,0x022d,0x0290,0x0313,0x0376
	.hword 0x03f8,0x0ff9,0x1bfa,0x2bfb,0x37fb,0x43fc,0x53fd,0x5ffd
	.hword 0x5ffd,0x53fd,0x43fc,0x37fb,0x2bfb,0x1bfa,0x0ff9,0x03f8
	.hword 0x0376,0x0313,0x0290,0x022d,0x01ab,0x0148,0x00e5,0x0063
	.hword 0x0003,0x0007,0x000a,0x000d,0x0011,0x0014,0x0018,0x001b
	.hword 0x001f,0x0c7f,0x18df,0x295f,0x35bf,0x421f,0x529f,0x5eff
	.hword 0x5eff,0x529f,0x421f,0x35bf,0x295f,0x18df,0x0c7f,0x001f
	.hword 0x001b,0x0018,0x0014,0x0011,0x000d,0x000a,0x0007,0x0003
	.hword 0x0842,0x0c63,0x14a5,0x1ce7,0x2529,0x294a,0x318c,0x39ce
	.hword 0x3def,0x4631,0x4e73,0x5294,0x5ad6,0x6318,0x6739,0x6f7b
	.hword 0x6f7b,0x6739,0x6318,0x5ad6,0x5294,0x4e73,0x4631,0x3def
	.hword 0x39ce,0x318c,0x294a,0x2529,0x1ce7,0x14a5,0x0c63,0x0842
	
	.pool
	.end
