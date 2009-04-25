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

	#define FIREWORK_COUNT				64

	.arm
	.align
	.text
	.global fxFireworksOn
	.global fxFireworksOff
	.global fxFireworksVBlank

fxFireworksOn:

	stmfd sp!, {r0-r6, lr}
	
	bl initVideoStar
	
	@ Clear the tile data
	
	bl clearStars
	
	@ set the screen up to use numbered tiles from 0-767, a hybrid bitmap!	
	
	mov r0, #0										@ tile number
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)				@ where to store it
	ldr r2, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)		@ where to store it

fxFireworksOnLoop:

	strh r0, [r1], #2
	strh r0, [r2], #2
	add r0, #1
	cmp r0, #(32 * 24)
	
	bne fxFireworksOnLoop

@	bl randomStarsMulti									@ generate em!
@	bl moveStarsMulti									@ draw them
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_FIREWORKS
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------

fxFireworksOff:

	stmfd sp!, {r0-r6, lr}
	
	bl initVideoMain
	
	ldr r0, =fxMode
	ldr r1, [r0]
@	and r1, #~(FX_FIREWORKS)
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxFireworksVBlank:

	stmfd sp!, {r0, lr}
	
	bl clearStars									@ clear them (could use a dma to clear the screen?)
@	bl moveStarsMulti								@ move em, based on x/y speeds and plot
	
	ldmfd sp!, {r0, pc}

	@ ---------------------------------------
	
fireworkMain:
.word 0
fireworkSub:
.word 0

	.data
	.pool
	.align

fireWorkDirection:
	.word 0
fireworkShade:					@ bytes
	.space FIREWORK_COUNT
fireworkSpeed:
	.space FIREWORK_COUNT*4	
fireworkYCoord:
	.space FIREWORK_COUNT*4
fireworkXCoord:
	.space FIREWORK_COUNT*4

	.end


@ plot code (condensed)

	r1=y (20.12)
	r0=x (20.12)

	ldr r6,=BG_TILE_RAM(STAR_BG2_TILE_BASE)
	str r6,starMain										@ store like this a quicker to retrieve directly
	ldr r6,=BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)
	str r6,starSub										@ these 2 vars MUST remain local for speed

	uses r3,r4,r6,r9,r11


	cmp r1,#0xc0000									@ 192 in 20.12 format
	ldrpl r6,fireworkMain							@ bottom screen
	ldrlt r6,fireworkSub							@ top screen
	subpl r1,#0xC0000								@ 192 in 20.12 format
	mov r9, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r9, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r9, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r9, lsl #5							@ r3 now = tile base offset from tilemem
	and r9,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r9, lsr #10]						@ load word at tile pos
	and r11,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r11, #10									@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r5, lsl r11							@ or our colour in (shifted x units)
	str r4, [r3, r9, lsr #10]						@ store it back

