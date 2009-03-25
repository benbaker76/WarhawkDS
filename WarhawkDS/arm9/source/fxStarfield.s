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

	#define STAR_COUNT					512
	#define STAR_COLOR_OFFSET			6
	#define STAR_TILE_BASE				BG2_TILE_BASE
	#define STAR_TILE_BASE_SUB			BG2_TILE_BASE_SUB

	.arm
	.align
	.text
	.global fxStarfieldOn
	.global fxStarfieldOff
	.global fxStarfieldVBlank

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
	
plotStar:

	stmfd sp!, {r0-r6, lr}

	@ r0=x r1=y, r5=palette number to plot, r6=draw to what
	
	mov r3, r1, lsr #3								@ r3 = y / 8
	lsl r3, #5										@ mul by 32 (32 tiles per screen row)
													@ r3= Y Tile number (0,32,64,96, etc)
	mov r4, r0, lsr #3								@ r4 = x / 8
	add r3, r4										@ r3 = tile number to modify (0-767)
	add r4, r6, r3, lsl #5							@ add to tile base, tile number * 32 bytes (for 16 col)
	
	@ r5=first word of required tile
	
	and r1, #0x7									@ take the low 3 bits (0-7) of y (each y is one word)
	and r0, #0x7										@ take the low 3 bits (0-7) of x (each x is halfbyte)
	add r4, r1, lsl #2								@ add y (0-7) to find which of the words to hit in the tile	
	
	@ r4= the word in the tile 0-7	(Y) / r0= nibble to adjust (0-7)	(X)

	lsl r0, #2										@ times r0 (X) by 4 for nibbles (4 bits per colour)
	lsl r5, r0										@ shift the colour to the correct 4 bit space
	ldr r3, [r4]										@ load word at tile pos
	orr r3, r5										@ or our colour in (shifted x units)
	str r3, [r4]										@ store it back
		
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
unplotStar:

	stmfd sp!, {r0-r5, lr}

	@ r0=x r1=y, r5=palette number to plot, r6=draw ro what
	
	mov r3, r1, lsr #3								@ r3 = y / 8
	lsl r3, #5										@ mul by 32 (32 tiles per screen row)
													@ r3= Y Tile number (0,32,64,96, etc)
	mov r4, r0, lsr #3								@ r4 = x / 8
	add r3, r4										@ r3 = tile number to modify (0-767)
	add r4, r6, r3, lsl #5							@ add to tile base, tile number * 32 bytes (for 16 col)
	
	@ r5=first word of required tile
	
	and r1, #0x7									@ take the low 3 bits (0-7) of y (each y is one word)
	and r0, #0x7									@ take the low 3 bits (0-7) of x (each x is halfbyte)
	add r4, r1, lsl #2								@ add y (0-7) to find which of the words to hit in the tile	
	
	@ r4= the word in the tile 0-7	(Y) / r0= nibble to adjust (0-7)	(X)

	lsl r0, #2										@ times r0 (X) by 4 for nibbles (4 bits per colour)
	lsl r5, r0										@ shift the colour to the correct 4 bit space
	ldr r3, [r4]									@ load word at tile pos
	orr r3, r5	
	eor r3, r5										@ flip the bits to erase it!!
	str r3, [r4]									@ store it back
		
	ldmfd sp!, {r0-r5, pc}

	@ ---------------------------------------
	
moveStars:

	stmfd sp!, {r0-r6, lr}
	
	mov r3, #STAR_COUNT								@ Set numstars
	sub r3, #1
	ldr r7, =starXSpeed
	ldr r8, =starXCoord
	ldr r9, =starYSpeed
	ldr r10, =starYCoord
	
moveStarsLoop:
	
	ldrsb r5, [r7, r3]								@ R5 now holds the speed (subs) of the star
	ldrb r6, [r8, r3]								@ r6 now holds the x coord of the star
	adds r6, r5										@ add r5 to r6 using signed bit (+/-)
													@ if we are just moving a starfield left, then..........
	bpl	moveStarMiss
	
	push {r8}
	
	bl getRandom									@ get a random number for a new y coord
	
	and r8, #0xff									@ make 0-255
	mov r9, #6										@ times 6
	mul r8, r9	
	lsr r8, #3										@ divide by 8
	strb r8, [r10, r3] 							@ Store Y (0-191)	
	
	@ now get a speed?
	
	bl getRandom
	
	@ we need a speed from -3 - +3
	
	and r8, #0x7									@ 0-7
	subs r8, #8
	strb r8, [r7, r3] 								@ Store Speed
	
	mov r6, #255
	
	pop {r8}
	
moveStarMiss:

	strb r6, [r8, r3]								@ r8 still holds the mem address of the x registers

@	ldrsb r5, [r9, r3]								@ R5 now holds the speed (subs) of the star
@	ldrb r6, [r10, r3]								@ r6 now holds the y coord of the star
@	adds r6, r5										@ add r5 to r6 using signed bit (+/-)

@	movmi r6, #191
@	cmp r6, #192
@	movpl r6, #0
@	strb r6, [r10, r3]								@ r1 still holds the mem adrless of the x registers
	
	subs r3, #1										@ count down the number of starXSpeed

	bpl moveStarsLoop
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
drawStars:

	stmfd sp!, {r0-r6, lr}
	
	mov r2, #STAR_COUNT								@ Set numstars-1
	sub r3, #1
	mov r5, #STAR_COLOR_OFFSET						@ set palette number to use
	ldr r3, =starXCoord								@ r4=3= coords of X
	ldr r4, =starYCoord								@ r4= coords of Y

drawStarsLoop:
	
	ldrb r0, [r3, r2]								@ make r0 = x coord
	ldrb r1, [r4, r2]								@ make r1 = y corrd
	
	ldr r6, =BG_TILE_RAM_SUB(STAR_TILE_BASE_SUB)	@ set where we are drawing them
	bl plotStar
	ldr r6, =BG_TILE_RAM(STAR_TILE_BASE)			@ set where we are drawing them
	bl plotStar
	
	subs r2, #1										@ go to next star (in reverse)
	bpl drawStarsLoop								@ have we done star 0 yet? if not go back to loop1
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
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
	sub r3, #1
	ldr r4, =starXCoord
	ldr r5, =starYCoord
	ldr r6, =starXSpeed
	ldr r7, =starYSpeed

starloop:
	
	bl getRandom
	
	and r8, #0xff
	strb r8, [r4, r3]								@ Store X

	bl getRandom
	
	and r8, #0xff									@ make 0-255
	mov r9, #6										@ times 6
	mul r8, r9	
	lsr r8, #3										@ divide by 8
	strb r8, [r5, r3] 								@ Store Y (0-191)
	
newRandomStarXSpeed:

	bl getRandom
													@ we need a speed from -3 - +3
	and r8, #0x7									@ 0-7
	subs r8, #8

@	subs r8, #3
@	cmp r8, #0
@	beq newRandomStarXSpeed

	strb r8, [r6, r3] 								@ Store Speed

newRandomStarYSpeed:

@	bl getRandom
@													@ we need a speed from -3 - +3
@	and r8, #0x7									@ 0-7
@	subs r8, #3
@	cmp r8, #0
@
@	beq newRandomStarYSpeed

	mov r8, #0

	strb r8, [r7, r3] 								@ Store Speed
	
	subs r3, #1	
	
	bpl starloop

	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
	.data
	.align

starXCoord:
	.space STAR_COUNT

starYCoord:
	.space STAR_COUNT

starXSpeed:
	.space STAR_COUNT

starYSpeed:
	.space STAR_COUNT	

	.pool
	.end
