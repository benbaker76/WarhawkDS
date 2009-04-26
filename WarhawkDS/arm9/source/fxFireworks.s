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
@	bl moveFireworks									@ draw them

	@ dummy values
	mov r0,#32
	lsl r0,#12
	ldr r1,=fireworkXCoord
	str r0,[r1]
	ldr r0,=383
	lsl r0,#12
	ldr r1,=fireworkYCoord
	str r0,[r1]
	mov r0,#11
	ldr r1,=fireworkShade
	strb r0,[r1]
	mov r0,#1
	lsl r0,#12
	ldr r1,=fireworkSpeed
	str r0,[r1]	
	ldr r0,=400											@ this should be +/- 64 of 384
	ldr r1,=fireworkDirection							@ dont think we will need this, only for the explosion perhaps???
	str r0,[r1]
	ldr r0,=100
	ldr r1,=fireworkLife
	str r0,[r1]
	mov r0,#1
	ldr r1,=fireworkCurveDir
	str r0,[r1]
	
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
	and r1, #~(FX_FIREWORKS)
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxFireworksVBlank:

	stmfd sp!, {r0, lr}
	
	bl clearStars									@ clear them (could use a dma to clear the screen?)
	bl fxMoveFireworks								@ move em, based on x/y speeds and plot
	
	ldmfd sp!, {r0, pc}

	@ ---------------------------------------
	
fxDrawFirePixel:
	stmfd sp!, {r0-r6, lr}
	@ pass r0,r1 = x/y
	@ r2 = palette entry
	
	ldr r6,=BG_TILE_RAM(STAR_BG2_TILE_BASE)
	str r6,fireworkMain										@ store like this a quicker to retrieve directly
	ldr r6,=BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)
	str r6,fireworkSub										@ these 2 vars MUST remain local for speed

	cmp r1,#0xc0000									@ 192 in 20.12 format
	ldrpl r6,fireworkMain							@ bottom screen
	ldrlt r6,fireworkSub							@ top screen
	subpl r1,#0xC0000								@ 192 in 20.12 format
	mov r5, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r5, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r5, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r5, lsl #5							@ r3 now = tile base offset from tilemem
	and r5,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r5, lsr #10]						@ load word at tile pos

	and r6,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r6, #10										@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r2, lsl r6								@ or our colour in (shifted x units)

	str r4, [r3, r5, lsr #10]						@ store it back	
	ldmfd sp!, {r0-r6, pc}

fxMoveFireworks:

	stmfd sp!, {r0-r11, lr}
	

	@ move in the set direction 

	ldr r8,=fireworkDirection
	ldr r9,[r8]
	lsl r9,#1
	ldr r4,=fireworkSpeed
	ldr r4,[r4]						@ r4,=speed	of star	
	
	ldr r7,=COS_bin
	ldrsh r7, [r7,r9]				@ r7= 16bit signed cos (for X)
	ldr r3,=fireworkXCoord
	ldr r0,[r3]						@ r0=X coord

	muls r10,r4,r7					@ mul cos by speed
	adds r0,r10, asr #12			@ add to x

	ldr r7,=SIN_bin
	ldrsh r7, [r7,r9]				@ r7= 16bit signed cos (for Y)
	ldr r3,=fireworkYCoord
	ldr r1,[r3]						@ r1=Y coord

	muls r10,r4,r7					@ mul sin by speed
	adds r1,r10, asr #12			@ add to Y
	
	@ r0,r1 hold X/Y coords
	
	ldr r3,=fireworkLife
	ldr r4,[r3]
	cmp r4,#0
	subne r4,#1
	strne r4,[r3]
	bne fxFireworkOK
	
		@ the firework has flown to its max height? what the fuck now???
		ldr r3,=fireworkCurveDir
		ldr r3,[r3]					@ 0=left/1=right
		cmp r3,#0
		beq fireworkLeft
			@ ok, we are curving right (dir 384-(0)-128)
			ldr r3,=fireworkDirection
			ldr r4,[r3]
			
			
			ldr r5,=fireworkRotateSpeed
			ldr r5,[r5]
			
			
			
			
			
			
			
			add r4,#2				@ speed of curve (we will need to affect this)
			cmp r4,#512
			movpl r4,#0
			cmp r4,#384	
			bpl fireworkCurveDone
				cmp r4,#128
				movpl r4,#128
			b fireworkCurveDone
		
		fireworkLeft:
			ldr r3,=fireworkDirection
			ldr r4,[r3]	


			@ add code later



		fireworkCurveDone:
			@ now we need to add a hint of gravity?
			
		cmp r4,#256
		blt fireworkAccel
			@ we need to pull the firework down here!
			ldr r5,=fireworkXSpeed
			ldr r6,[r5]
			cmp r4,#384
			bmi fireworkAccelX
				subs r6,#16
			fireworkAccelX:
				adds r6,#16
			fireworkAccelDone:
			str r6,[r5]
			adds r0,r6		
		
		b fireworkGravityDone
		
		fireworkAccel:
			@ here, we are fully falling - increase speed??
			
			ldr r5,=fireworkYSpeed
			ldr r6,[r5]
			cmp r6,#-1
			beq fireworkGravityDone
			adds r6,#64
			str r6,[r5]
			add r1,r6
		
		
		
		fireworkGravityDone:

		str r4,[r3]				@ R4 has now been affected by the curve	(fireworkDirection)
	
	fxFireworkOK:
	
		@ ok, we now need to check Y coord
		cmp r1,#0x180000		@ 384 in 20.12
		blt fireworkNoBounce
			mov r1,#0x180000
			sub r1,#4
			@ now change the direction and slow the speed
			ldr r5,=fireworkDirection
			ldr r6,[r5]
			add r6,#256
			str r6,[r5]
			ldr r5,=fireworkYSpeed
			mov r6,#-1
			str r6,[r5]
			ldr r5,=fireworkSpeed
			ldr r6,[r5]
			subs r6,#768
			movmi r6,#0
			str r6,[r5]
			
		
		
		
		
		
		
		
		
		fireworkNoBounce:
	
	
	
	@fxFireworkDraw:
	
	
	
	
	
	
	
	
	
	
	mov r2,#11						@ r2= palette to plot
	
	
	
	
	
	
	ldr r7,=fireworkXCoord
	str r0,[r7]	
	ldr r7,=fireworkYCoord
	str r1,[r7]
	
	
	bl fxDrawFirePixel
	

	ldmfd sp!, {r0-r11, pc}
















	
fireworkMain:
.word 0
fireworkSub:
.word 0

	.data
	.pool
	.align
fireworkDelay:
	.word 0

fireworkShade:					@ bytes
	.space FIREWORK_COUNT
fireworkSpeed:
	.space FIREWORK_COUNT*4	
fireworkXSpeed:
	.space FIREWORK_COUNT*4	
fireworkYSpeed:
	.space FIREWORK_COUNT*4	
fireworkYCoord:
	.space FIREWORK_COUNT*4
fireworkXCoord:
	.space FIREWORK_COUNT*4
fireWorkPhase:
	.space FIREWORK_COUNT*4
fireworkDirection:
	.space FIREWORK_COUNT*4
fireworkLife:
	.space FIREWORK_COUNT*4
fireworkCurveDir:
	.space FIREWORK_COUNT*4
fireworkRotateSpeed:
	.space FIREWORK_COUNT
	
	.end


@ plot code (condensed)

	r1=y (20.12)
	r0=x (20.12)
	r2=palette number
	
	uses r3,r4,r5,r6


	ldr r6,=BG_TILE_RAM(STAR_BG2_TILE_BASE)
	str r6,starMain										@ store like this a quicker to retrieve directly
	ldr r6,=BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)
	str r6,starSub										@ these 2 vars MUST remain local for speed

	cmp r1,#0xc0000									@ 192 in 20.12 format
	ldrpl r6,fireworkMain							@ bottom screen
	ldrlt r6,fireworkSub							@ top screen
	subpl r1,#0xC0000								@ 192 in 20.12 format
	mov r5, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r5, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r5, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r5, lsl #5							@ r3 now = tile base offset from tilemem
	and r5,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r5, lsr #10]						@ load word at tile pos

	and r6,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r6, #10										@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r2, lsl r6								@ or our colour in (shifted x units)

	str r4, [r3, r5, lsr #10]						@ store it back

