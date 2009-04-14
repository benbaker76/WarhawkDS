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

	#define STAR_COUNT					768
	#define STAR_COLOR_OFFSET			11
	#define STAR_COLOR_TRAIL_OFFSET_1	12
	#define STAR_COLOR_TRAIL_OFFSET_2	13
	#define STAR_COLOR_TRAIL_OFFSET_3	14
	#define STAR_TILE_BASE				5
	#define STAR_TILE_BASE_SUB			5

	.arm
	.align
	.text
	.global fxStarfieldOn
	.global fxStarfieldOff
	.global fxStarfieldVBlank
	.global fxStarfieldDownVBlank
	.global fxStarfieldDownOn

fxStarfieldOn:

	stmfd sp!, {r0-r6, lr}
	
	@ Turn off BG3
	
	ldr r0, =REG_DISPCNT							@ Turn off bg3
	ldr r1, [r0]
	eor r1, #DISPLAY_BG3_ACTIVE
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB						@ Turn off bg3
	ldr r1, [r0]
	eor r1, #DISPLAY_BG3_ACTIVE
	str r1, [r0]
	
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
	
	bl randomStars									@ generate em!
	bl drawStars									@ draw them
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_STARFIELD
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------

fxStarfieldDownOn:

	stmfd sp!, {r0-r6, lr}
	
	@ Turn off BG3
	
	ldr r0, =REG_DISPCNT							@ Turn off bg3
	ldr r1, [r0]
	eor r1, #DISPLAY_BG3_ACTIVE
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB						@ Turn off bg3
	ldr r1, [r0]
	eor r1, #DISPLAY_BG3_ACTIVE
	str r1, [r0]
	
	@ Clear the tile data
	
	bl clearStars
	
	@ set the screen up to use numbered tiles from 0-767, a hybrid bitmap!	
	
	mov r0, #0										@ tile number
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)				@ where to store it
	ldr r2, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)		@ where to store it

fxStarfieldOnDownLoop:

	strh r0, [r1], #2
	strh r0, [r2], #2
	add r0, #1
	cmp r0, #(32 * 24)
	
	bne fxStarfieldOnDownLoop
	
	bl randomStarsDual								@ generate em!
	bl drawStarsDown								@ draw them
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_STARFIELD_DOWN
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

fxStarfieldOff:

	stmfd sp!, {r0-r6, lr}
	
	@ Turn on BG3
	
	ldr r0, =REG_DISPCNT							@ Turn off bg3
	ldr r1, [r0]
	orr r1, #DISPLAY_BG3_ACTIVE
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB						@ Turn off bg3
	ldr r1, [r0]
	orr r1, #DISPLAY_BG3_ACTIVE
	str r1, [r0]
	
	@ Write the tile data to VRAM FrontStar BG2

	ldr r0, =StarFrontTiles
	ldr r1, =BG_TILE_RAM(BG2_TILE_BASE)
	ldr r2, =StarFrontTilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(BG2_TILE_BASE_SUB)
	bl dmaCopy

	@ Write the tile data to VRAM BackStar BG3

	ldr r0, =StarBackTiles
	ldr r1, =BG_TILE_RAM(BG3_TILE_BASE)
	add r1, #StarFrontTilesLen
	ldr r2, =StarBackTilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	add r1, #StarFrontTilesLen
	bl dmaCopy
	
	ldr r0, =fxMode
	ldr r1, [r0]
	and r1, #~(FX_STARFIELD)
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxStarfieldVBlank:

	stmfd sp!, {r0-r6, lr}
	
	bl clearStars									@ clear them (could use a dma to clear the screen?)
	bl moveStars									@ move em, based on x/y speeds
	bl drawStars									@ draw the new ones :)
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------

fxStarfieldDownVBlank:

	stmfd sp!, {r0-r6, lr}
	
	bl clearStars									@ clear them (could use a dma to clear the screen?)
	bl moveStarsDown									@ move em, based on x/y speeds
	bl drawStarsDown									@ draw the new ones :)
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
plotStarDual:

	@ this now will never draw out of the 0-767 tiles allocated regardless of x/y

	stmfd sp!, {r0-r8, lr}

	@ r0=x r1=y, r5=palette number to plot
	@ r7=top tiles
	@ r8=bottom tiles

	cmp r1,#192
	movpl r6,r8										@ bottom screen
	movle r6,r7									@ top screen
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
	
	@ ---------------------------------------	
	
moveStars:

	stmfd sp!, {r0-r6, lr}
	
	mov r3, #STAR_COUNT								@ Set numstars
	sub r3,#1
	ldr r7, =starSpeed
	ldr r4, =starXCoord
	ldr r10, =starYCoord
	ldr r2, =0x1ff
	
moveStarsLoop:
	
	ldrb r5, [r7, r3]								@ R5 now holds the speed (subs) of the star
	ldrb r6, [r4, r3]								@ r6 now holds the x coord of the star
	subs r6, r5										@ add r5 to r6 using signed bit (+/-)
													@ if we are just moving a starfield left, then..........
	bpl	moveStarMiss

	bl getRandom									@ get a random number for a new y coord
	
	and r8, r2										@ make 0-512
	mov r9, #6										@ times 6
	mul r8, r9	
	lsr r8, #3										@ divide by 8
	str r8, [r10, r3, lsl #2] 						@ Store Y (0-313)	
	
	@ now get a speed?
	
	bl getRandom
	
	@ we need a speed from -3 - +3
	
	and r8, #0x3									@ 0-7
	add r8,#1
	strb r8, [r7, r3] 								@ Store Speed
	
	mov r6, #255
	
moveStarMiss:

	strb r6, [r4, r3]								@ r8 still holds the mem address of the x registers
	
	subs r3, #1										@ count down the number of starSpeed
	bne moveStarsLoop
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
drawStars:

	stmfd sp!, {r0-r6, lr}
	
	mov r2, #STAR_COUNT								@ Set numstars-1
	sub r2,#1
	mov r5, #STAR_COLOR_OFFSET						@ set palette number to use
	ldr r3, =starXCoord								@ r4=3= coords of X
	ldr r4, =starYCoord								@ r4= coords of Y
	ldr r7, =BG_TILE_RAM_SUB(STAR_TILE_BASE_SUB)
	ldr r8, =BG_TILE_RAM(STAR_TILE_BASE)
	ldr r9,=383
drawStarsLoop:
	
	ldrb r0, [r3, r2]								@ make r0 = x coord
	ldr r1, [r4, r2, lsl #2]						@ make r1 = y corrd

	mov r5,#STAR_COLOR_OFFSET
	bl plotStarDual
	add r1,#1
	bl plotStarDual
	mov r5,#STAR_COLOR_TRAIL_OFFSET_1
	sub r1,#1
	add r0,#1
	bl plotStarDual
	add r1,#1
	bl plotStarDual
	mov r5,#STAR_COLOR_TRAIL_OFFSET_2
	sub r1,#1
	add r0,#1
	bl plotStarDual
	add r1,#1
	bl plotStarDual
	
	subs r2, #1										@ go to next star (in reverse)
	bne drawStarsLoop								@ have we done star 0 yet? if not go back to loop1
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

moveStarsDown:

	stmfd sp!, {r0-r6, lr}
	
	mov r3, #STAR_COUNT								@ Set numstars
	sub r3,#1
	ldr r7, =starSpeed
	ldr r4, =starYCoord
	ldr r10, =starXCoord
	
moveStarsDownLoop:
	
	ldrb r5, [r7, r3]								@ R5 now holds the speed of the star
	ldr r6, [r4, r3, lsl #2]						@ r6 now holds the Y coord of the star
	add r6, r5										@ add speed
	cmp r6,#384

	blt	moveStarDownMiss

	bl getRandom									@ get a random number for a new X coord
	
	and r8, #0xff									@ make 0-255
	strb r8, [r10, r3] 							@ Store X (0-255)	
	
	@ now get a speed?
	
	bl getRandom
	
	@ we need a speed from 1 - 4
	
	and r8, #0x7									@ 0-3
	add r8,#1
	strb r8, [r7, r3] 								@ Store Speed
	
	mov r6, #0
	
moveStarDownMiss:

	str r6, [r4, r3, lsl #2]						@ r8 still holds the mem address of the y registers
	
	subs r3, #1										@ count down the number of starSpeed
	bne moveStarsDownLoop
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
drawStarsDown:

	stmfd sp!, {r0-r6, lr}
	
	mov r2, #STAR_COUNT								@ Set numstars-1
	sub r2,#1
	mov r5, #STAR_COLOR_OFFSET						@ set palette number to use
	ldr r3, =starXCoord								@ r4=3= coords of X
	ldr r4, =starYCoord								@ r4= coords of Y
	ldr r7, =BG_TILE_RAM_SUB(STAR_TILE_BASE_SUB)
	ldr r8, =BG_TILE_RAM(STAR_TILE_BASE)
	ldr r9, =383
drawStarsDownLoop:
	
	ldrb r0, [r3, r2]								@ make r0 = x coord
	ldr r1, [r4, r2, lsl #2]						@ make r1 = y corrd
	
	mov r5,#STAR_COLOR_OFFSET						@ set palette number to use	
	bl plotStarDual									@ draw 3 pixel for a trail effect!
	mov r5,#STAR_COLOR_TRAIL_OFFSET_1
	sub r1,#1
	bl plotStarDual
	mov r5,#STAR_COLOR_TRAIL_OFFSET_2
	sub r1,#1
	bl plotStarDual
	mov r5,#STAR_COLOR_TRAIL_OFFSET_3
	sub r1,#1
	bl plotStarDual
	subs r2, #1										@ go to next star (in reverse)
	bne drawStarsDownLoop							@ have we done star 0 yet? if not go back to loop1
	
	ldmfd sp!, {r0-r6, pc}
	
clearStars:

	stmfd sp!, {r0-r6, lr}
	
	mov r0, #0
	ldr r1, =BG_TILE_RAM_SUB(STAR_TILE_BASE_SUB)
	ldr r2, =(32 * 24 * 32)
	bl dmaFillWords
	ldr r1, =BG_TILE_RAM(STAR_TILE_BASE)
	bl dmaFillWords
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

randomStars:

	stmfd sp!, {r0-r6, lr}
	
	mov r3, #STAR_COUNT
	sub r3,#1
	ldr r4, =starXCoord
	ldr r5, =starYCoord
	ldr r6, =starSpeed
	ldr r7, =0x1ff
starloop:
	
	bl getRandom
	
	and r8, #0xff
	strb r8, [r4, r3]								@ Store X

	bl getRandom
	
	and r8, r7										@ make 0-512
	mov r9, #6										@ times 6
	mul r8, r9	
	lsr r8, #3										@ divide by 8
	str r8, [r5, r3, lsl #2] 						@ Store Y (0-383)

	bl getRandom
													@ we need a speed from -1 = -4
	and r8, #0x3									@ 0-3
	add r8, #1
	
	strb r8, [r6, r3] 								@ Store Speed
		
	subs r3, #1	
	bne starloop

	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------

randomStarsDual:

	stmfd sp!, {r0-r6, lr}
	
	mov r3, #STAR_COUNT
	sub r3,#1
	ldr r4, =starXCoord
	ldr r5, =starYCoord
	ldr r6, =starSpeed
	ldr r7, =0x1ff

starloopDual:
	
	bl getRandom
	
	and r8, #0xff
	strb r8, [r4, r3]								@ Store X

	bl getRandom
	
	and r8, r7										@ make 0-512
	mov r9, #6										@ times 6
	mul r8, r9	
	lsr r8, #3										@ divide by 8
	str r8, [r5, r3, lsl #2] 						@ Store Y (0-383)

	bl getRandom
													@ we need a speed from +1 = +4
	and r8, #0x7									@ 0-3
	add r8, #1
	
	strb r8, [r6, r3] 								@ Store Speed
		
	subs r3, #1	
	bne starloopDual

	ldmfd sp!, {r0-r6, pc}	
	
	@ ---------------------------------------
	
	.pool
	.data
	.align
	
starXCoord:
	.space STAR_COUNT

	.align
starYCoord:
	.space STAR_COUNT*4

	.align
starSpeed:
	.space STAR_COUNT

	.end
