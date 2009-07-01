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

	#define STAR_COUNT					1024
	#define STAR_COLOR_OFFSET			11
	#define STAR_COLOR_TRAIL_OFFSET_1	12
	#define STAR_COLOR_TRAIL_OFFSET_2	13
	#define STAR_COLOR_TRAIL_OFFSET_3	14

	.arm
	.align
	.text
	.global fxStarfieldOn
	.global fxStarfieldDownOn
	.global fxStarfieldMultiOn
	.global fxStarburstOn
	.global fxStarfieldOff
	.global fxStarfieldVBlank
	.global fxStarfieldDownVBlank
	.global fxStarfieldMultiVBlank
	.global fxStarburstVBlank
	.global starDirection
	.global clearStars
	.global randomStarsMulti
	.global moveStarsMulti

fxStarfieldOn:

	stmfd sp!, {r0-r2, lr}

	mov r0,#STAR_COUNT
	ldr r1,=starAmount
	str r0,[r1]
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_STARFIELD
	str r1, [r0]
	
	bl initVideoStars
	
	@ Clear the tile data
	
	bl clearStars
	
	@ set the screen up to use numbered tiles from 0-767, a hybrid bitmap!	
	
	mov r0, #0										@ tile number
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)				@ where to store it
	ldr r2, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)		@ where to store it

fxStarfieldOnLoop:

	strh r0, [r1], #2
	strh r0, [r2], #2
	add r0, #1
	cmp r0, #(32 * 24)
	
	bne fxStarfieldOnLoop

	ldr r1,=0x3fff	
	bl randomStarsMulti									@ generate em!
	bl moveStarsMulti									@ draw them
	ldr r0,=starDirection
	mov r1,#256
	str r1,[r0]
	
	ldmfd sp!, {r0-r2, pc}

	@ ---------------------------------------

fxStarburstOn:

	stmfd sp!, {r0-r2, lr}

	mov r0,#STAR_COUNT
	mov r0,#768											@ stars kill the wibble on the pics in hardware!! (sadly)
	ldr r1,=starAmount
	str r0,[r1]
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_STARBURST
	str r1, [r0]
	
	bl initVideoStars
	
	@ Clear the tile data
	
	bl clearStars
	
	@ set the screen up to use numbered tiles from 0-767, a hybrid bitmap!	
	
	mov r0, #0										@ tile number
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)				@ where to store it
	ldr r2, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)		@ where to store it

fxStarburstOnLoop:

	strh r0, [r1], #2
	strh r0, [r2], #2
	add r0, #1
	cmp r0, #(32 * 24)
	
	bne fxStarburstOnLoop

	ldr r1,=0x3fff	
	bl randomStarburst									@ generate em!
	bl moveStarburst									@ draw them
	
	ldmfd sp!, {r0-r2, pc}

	@ ---------------------------------------

fxStarfieldDownOn:
	@ pass r0 as number of stars to plot
	stmfd sp!, {r0-r2, lr}

	mov r1,#STAR_COUNT
	cmp r0,r1
	movgt r0,r1
	ldr r1,=starAmount
	str r0,[r1]
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_STARFIELD_DOWN
	str r1, [r0]
	
	bl initVideoStars
	
	@ Clear the tile data
	
	bl clearStars
	
	@ set the screen up to use numbered tiles from 0-767, a hybrid bitmap!	
	
	mov r0, #0										@ tile number
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)				@ where to store it
	ldr r2, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)		@ where to store it

fxStarfieldDownOnLoop:

	strh r0, [r1], #2
	strh r0, [r2], #2
	add r0, #1
	cmp r0, #(32 * 24)
	
	bne fxStarfieldDownOnLoop
	
	ldr r1,=0x7fff
	bl randomStarsMulti								@ generate em!
	bl moveStarsMulti									@ draw them
	
	ldr r0,=starDirection
	mov r1,#128
	str r1,[r0]
	
	ldmfd sp!, {r0-r2, pc}
	
	@ ---------------------------------------

fxStarfieldMultiOn:

	stmfd sp!, {r0-r2, lr}

	mov r0,#STAR_COUNT
	ldr r1,=starAmount
	str r0,[r1]
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_STARFIELD_MULTI
	str r1, [r0]
	
	bl initVideoStars
	
	@ Clear the tile data
	
	bl clearStars
	
	@ set the screen up to use numbered tiles from 0-767, a hybrid bitmap!	
	
	mov r0, #0										@ tile number
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)				@ where to store it
	ldr r2, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)		@ where to store it

fxStarfieldMultiOnLoop:

	strh r0, [r1], #2
	strh r0, [r2], #2
	add r0, #1
	cmp r0, #(32 * 24)
	
	bne fxStarfieldMultiOnLoop

	ldr r1,=0x3fff										@ r1=max speed
	bl randomStarsMulti									@ generate em!
	bl moveStarsMulti									@ draw them
	
	ldmfd sp!, {r0-r2, pc}

	@ ---------------------------------------

fxStarfieldOff:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	bic r1, #(FX_STARFIELD | FX_STARFIELD_DOWN | FX_STARFIELD_MULTI | FX_STARBURST)
	str r1, [r0]

	bl initVideoMain
	
	ldmfd sp!, {r0-r1, pc}

	@ ---------------------------------------
	
fxStarfieldVBlank:

	stmfd sp!, {r0, lr}
	
	bl clearStars									@ clear them (could use a dma to clear the screen?)
	bl moveStarsMulti								@ move em, based on x/y speeds and plot
	
	ldmfd sp!, {r0, pc}

	@ ---------------------------------------

fxStarburstVBlank:

	stmfd sp!, {r0, lr}
	
	bl clearStars									@ clear them (could use a dma to clear the screen?)
	bl moveStarburst								@ move em, based on x/y speeds and plot

	ldmfd sp!, {r0, pc}

	@ ---------------------------------------

fxStarfieldMultiVBlank:

	stmfd sp!, {r0-r1, lr}
	
	bl clearStars									@ clear them (could use a dma to clear the screen?)
	bl moveStarsMulti								@ move em, based on x/y speeds, and redraw
	
	ldr r0,=starDirection
	ldr r1,[r0]
	add r1,#1
	cmp r1,#512
	movpl r1,#0
	str r1,[r0]
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------	

clearStars:

	stmfd sp!, {r0-r2, lr}
	
	mov r0, #0
	ldr r1, =BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)
	ldr r2, =(32 * 24 * 32)
	bl dmaFillWords
	ldr r1, =BG_TILE_RAM(STAR_BG2_TILE_BASE)
	bl dmaFillWords
	
	ldmfd sp!, {r0-r2, pc}
	
	@ ---------------------------------------

randomStarburst:
	stmfd sp!, {r0-r11, lr}

	@ r1 is passed for the max speed (0x3fff is a good starter)
	ldr r0,=starAmount
	ldr r3,[r0]
	sub r3,#1
	ldr r4, =starXCoord32
	ldr r5, =starYCoord
	ldr r6, =starSpeed
	ldr r10, =starShade
	ldr r11, =starDir
	ldr r7,=0x1ff

	starburstloopMulti:
	
		mov r8,#128
		lsl r8,#12
		str r8, [r4, r3, lsl #2]						@ Store X
		mov r8,#192
		lsl r8,#12
		str r8, [r5, r3, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction
		and r8, r7
		str r8, [r11, r3, lsl #2]

		bl getRandom									@ generate speed
		and r8, r1	
		add r8,#1024
		str r8, [r6, r3, lsl #2] 						@ Store Speed
	
		bl getRandom									@ generate colours
		and r8,#0x3
		add r8,#11
		cmp r8,#14
		movpl r8,#13		
		strb r8,[r10, r3]

		subs r3, #1	
	bne starburstloopMulti

	ldmfd sp!, {r0-r11, pc}
	
	@ ---------------------------------------

randomStarsMulti:

	stmfd sp!, {r0-r10, lr}
	@ r1 is passed for the max speed (0x3fff is a good starter)
	ldr r0,=starAmount
	ldr r3,[r0]
	sub r3,#1
	ldr r4, =starXCoord32
	ldr r5, =starYCoord
	ldr r6, =starSpeed
	ldr r10, =starShade
	ldr r7, =0x1ff
starloopMulti:
	
	bl getRandom	
	and r8, #0xff
	lsl r8,#12
	str r8, [r4, r3, lsl #2]								@ Store X

	bl getRandom
	and r8, r7										@ make 0-512
	mov r9, #6										@ times 6
	mul r8, r9	
	lsr r8, #3										@ divide by 8
	lsl r8,#12
	str r8, [r5, r3, lsl #2] 						@ Store Y (0-383)

	bl getRandom									@ generate speed
	and r8, r1	
	add r8, #255
	str r8, [r6, r3, lsl #2] 						@ Store Speed
	
	bl getRandom									@ generate colours
	and r8,#0x3
	add r8,#11
	cmp r8,#14
	movpl r8,#13
	strb r8,[r10, r3]

	subs r3, #1	
	bne starloopMulti

	ldmfd sp!, {r0-r10, pc}

@----------------------------------

moveStarsMulti:

	stmfd sp!, {r0-r12, lr}
	
	ldr r6,=BG_TILE_RAM(STAR_BG2_TILE_BASE)
	str r6,starMain										@ store like this a quicker to retrieve directly
	ldr r6,=BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)
	str r6,starSub										@ these 2 vars MUST remain local for speed
	
	ldr r0,=starAmount
	ldr r10,[r0]
	sub r10,#1
	ldr r4, =starSpeed
	ldr r3, =starYCoord
	ldr r2, =starXCoord32
	ldr r12, =starShade

	ldr r0,=starDirection
	ldr r0,[r0]
	lsl r0,#1
	ldr r7,=COS_bin
	ldrsh r7, [r7,r0]								@ r7= 16bit signed cos
	ldr r8,=SIN_bin
	ldrsh r8, [r8,r0]								@ r8= 16bit signed sin
	
moveStarsMultiLoop:
	ldr r6, [r4, r10, lsl #2] 						@ R6 now holds the speed of the star

	ldr r0, [r2, r10, lsl #2]						@ r0 is now X coord value					MOVE X
	muls r9,r6,r7									@ mul cos by speed
	adds r0,r9, asr #12								@ add to x
	ldr r9,=0xfffff									@ reset to 0.12-255.12 (this is 1 cycle quicker than compairs)
	ands r0,r9
	str r0, [r2,r10, lsl #2]
			
	ldr r1, [r3, r10, lsl #2]						@ r1 now holds the Y coord of the star		MOVE Y
	muls r9,r6,r8
	adds r1,r9, asr #12								@ add to Y coord (signed)
	movmi r1,#0x180000								@ reset at boundries (shifted 12)
	cmppl r1,#0x180000
	movpl r1,#0
	str r1, [r3, r10, lsl #2]						@ store y 20.12
	
	ldrb r5,[r12,r10]								@ star colour
	push {r3,r4}									@ just not ENOUGH registers :(
	push {r1}										@ store y
	cmp r1,#0xc0000									@ 192 in 20.12 format
	ldrpl r6,starMain								@ bottom screen
	ldrlt r6,starSub								@ top screen
	subpl r1,#0xC0000								@ 192 in 20.12 format
	mov r9, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r9, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r9, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r9, lsl #5							@ r3 now = tile base offset from tilemem
	and r9,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r9, lsr #10]						@ load word at tile pos
	and r11,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r11, #10									@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r5, lsl r11								@ or our colour in (shifted x units)
	str r4, [r3, r9, lsr #10]						@ store it back
	add r0,#0x1000									@ add 1 to x
	mov r9, r1, lsr #15								@ r9 = y / 8 (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r9, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r9, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r9, lsl #5							@ r3 now = tile base offset from tilemem
	and r9,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r9, lsr #10]						@ load word at tile pos
	and r11,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r11, #10									@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r5, lsl r11								@ or our colour in (shifted x units)
	str r4, [r3, r9, lsr #10]						@ store it back
	pop {r1}										@ restore y and recalulate screen base
	add r1,#0x1000									@ add 1 to y
	cmp r1,#0xc0000									@ 192 in 20.12 format
	ldrpl r6,starMain								@ bottom screen
	ldrlt r6,starSub								@ top screen
	subpl r1,#0xC0000								@ 192 in 20.12 format
	mov r9, r1, lsr #15								@ r9 = y / 8 (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r9, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r9, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r9, lsl #5							@ r3 now = tile base offset from tilemem
	and r9,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r9, lsr #10]						@ load word at tile pos
	and r11,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r11, #10									@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r5, lsl r11								@ or our colour in (shifted x units)
	str r4, [r3, r9, lsr #10]						@ store it back
	sub r0,#0x1000									@ take 1 off x
	mov r9, r1, lsr #15								@ r9 = y / 8 (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r9, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r9, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r9, lsl #5							@ r3 now = tile base offset from tilemem
	and r9,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r9, lsr #10]						@ load word at tile pos
	and r11,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r11, #10									@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r5, lsl r11								@ or our colour in (shifted x units)
	str r4, [r3, r9, lsr #10]						@ store it back
	pop {r3,r4}										@ restore registers
	subs r10, #1									@ count down the number of starSpeed
	bne moveStarsMultiLoop
	
	ldmfd sp!, {r0-r12, pc}

@----------------------------------

moveStarburst:
	stmfd sp!, {r0-r12, lr}
	ldr r6,=BG_TILE_RAM(STAR_BG2_TILE_BASE)
	str r6,starMain										@ store like this a quicker to retrieve directly
	ldr r6,=BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)
	str r6,starSub										@ these 2 vars MUST remain local for speed
	
	ldr r0,=starAmount
	ldr r10,[r0]
	sub r10,#1
	ldr r4, =starSpeed
	ldr r3, =starYCoord
	ldr r2, =starXCoord32
	ldr r12, =starShade

moveStarburstLoop:
	ldr r0,=starDir
	ldr r0,[r0, r10, lsl #2]
	lsl r0,#1
	ldr r7,=COS_bin
	ldrsh r7, [r7,r0]								@ r7= 16bit signed cos
	ldr r8,=SIN_bin
	ldrsh r8, [r8,r0]								@ r8= 16bit signed sin

	ldr r6, [r4, r10, lsl #2] 						@ R6 now holds the speed of the star

	ldr r0, [r2, r10, lsl #2]						@ r0 is now X coord value					MOVE X
	muls r9,r6,r7									@ mul cos by speed
	adds r0,r9, asr #12								@ add to x

	bmi burstRegenerate
	cmp r0,#0xff000
	bge burstRegenerate
	
	str r0, [r2,r10, lsl #2]
			
	ldr r1, [r3, r10, lsl #2]						@ r1 now holds the Y coord of the star		MOVE Y
	muls r9,r6,r8
	adds r1,r9, asr #12								@ add to Y coord (signed)

	bmi burstRegenerate
	cmp r1,#0x180000
	bge burstRegenerate

	str r1, [r3, r10, lsl #2]						@ store y 20.12
	
	ldrb r5,[r12,r10]								@ star colour
	
	push {r3,r4}									@ just not ENOUGH registers :(
	push {r1}										@ store y
	cmp r1,#0xc0000									@ 192 in 20.12 format
	ldrpl r6,starMain								@ bottom screen
	ldrlt r6,starSub								@ top screen
	subpl r1,#0xC0000								@ 192 in 20.12 format
	mov r9, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r9, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r9, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r9, lsl #5							@ r3 now = tile base offset from tilemem
	and r9,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r9, lsr #10]						@ load word at tile pos
	and r11,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r11, #10									@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r5, lsl r11								@ or our colour in (shifted x units)
	str r4, [r3, r9, lsr #10]						@ store it back
	add r0,#0x1000									@ add 1 to x
	mov r9, r1, lsr #15								@ r9 = y / 8 (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r9, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r9, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r9, lsl #5							@ r3 now = tile base offset from tilemem
	and r9,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r9, lsr #10]						@ load word at tile pos
	and r11,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r11, #10									@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r5, lsl r11								@ or our colour in (shifted x units)
	str r4, [r3, r9, lsr #10]						@ store it back
	pop {r1}										@ restore y and recalulate screen base
	add r1,#0x1000									@ add 1 to y
	cmp r1,#0xc0000									@ 192 in 20.12 format
	ldrpl r6,starMain								@ bottom screen
	ldrlt r6,starSub								@ top screen
	subpl r1,#0xC0000								@ 192 in 20.12 format
	mov r9, r1, lsr #15								@ r9 = y / 8 (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r9, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r9, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r9, lsl #5							@ r3 now = tile base offset from tilemem
	and r9,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r9, lsr #10]						@ load word at tile pos
	and r11,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r11, #10									@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r5, lsl r11								@ or our colour in (shifted x units)
	str r4, [r3, r9, lsr #10]						@ store it back
	sub r0,#0x1000									@ take 1 off x
	mov r9, r1, lsr #15								@ r9 = y / 8 (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r9, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r9, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r9, lsl #5							@ r3 now = tile base offset from tilemem
	and r9,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r9, lsr #10]						@ load word at tile pos
	and r11,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r11, #10									@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r5, lsl r11								@ or our colour in (shifted x units)
	str r4, [r3, r9, lsr #10]						@ store it back
	pop {r3,r4}										@ restore registers

burstSkip:

	subs r10, #1									@ count down the number of starSpeed
	bne moveStarburstLoop

	ldmfd sp!, {r0-r12, pc}

burstRegenerate:

		mov r8,#128
		lsl r8,#12
		str r8, [r2, r10, lsl #2]						@ Store X
		mov r8,#192
		lsl r8,#12
		str r8, [r3, r10, lsl #2] 						@ Store Y

		bl getRandom									@ generate direction
		ldr r6,=0x1ff
		and r8, r6
		ldr r0,=starDir
		str r8, [r0, r10, lsl #2]

		bl getRandom									@ generate speed
		ldr r6,=0x3fff
		and r8, r6	
		add r8,#1024
		ldr r0,=starSpeed
		str r8, [r0, r10, lsl #2] 						@ Store Speed
	
	b burstSkip


starMain:
.word 0
starSub:
.word 0

	.data
	.pool
	.align
starAmount:
	.word 0
starDirection:
	.word 0
starShade:
	.space STAR_COUNT
starSpeed:
	.space STAR_COUNT*4	
starYCoord:
	.space STAR_COUNT*4
starXCoord32:
	.space STAR_COUNT*4
starDir:
	.space STAR_COUNT*4
	.end

	@ ---------------------------------------
	
plotStarDual:

	@ this now will never draw out of the 0-767 tiles allocated regardless of x/y
	@-----------------------------------------------------
	@ i have left this here for comparison, it is not used
	@-----------------------------------------------------
	stmfd sp!, {r0-r8, lr}

	@ r0=x r1=y, r5=palette number to plot
	@ r7=top tiles
	@ r8=bottom tiles

	cmp r1,#192
	movpl r6,r8										@ bottom screen
	movle r6,r7										@ top screen
	subpl r1,#192
	
	mov r3, r1, lsr #3								@ r3 = y / 8
	lsl r3, #5										@ mul by 32 (32 tiles per screen row)
													@ r3= Y Tile number (0,32,64,96, etc)
	mov r4, r0, lsr #3								@ r4 = x / 8
	adds r3, r4										@ r3 = tile number to modify (0-767)
	bmi noPlotStar									@ make sure we never plot out of range
	cmp r3,#768
	bge noPlotStar									@ make sure we never plot out of range
	add r4, r6, r3, lsl #5							@ add to tile base, tile number * 32 bytes (for 16 col)
	
	@ r5=first word of required tile
	
	and r1, #0x7									@ take the low 3 bits (0-7) of y (each y is one word)
	and r0, #0x7									@ take the low 3 bits (0-7) of x (each x is halfbyte)
	add r4, r1, lsl #2								@ add y (0-7) to find which of the words to hit in the tile	
	
	@ r4= the word in the tile 0-7	(Y) / r0= nibble to adjust (0-7)	(X)

	lsl r0, #2										@ times r0 (X) by 4 for nibbles (4 bits per colour)
	lsl r5, r0										@ shift the colour to the correct 4 bit space
	ldr r3, [r4]									@ load word at tile pos
	orr r3, r5										@ or our colour in (shifted x units)
	str r3, [r4]									@ store it back
	noPlotStar:	
	ldmfd sp!, {r0-r8, pc}
	