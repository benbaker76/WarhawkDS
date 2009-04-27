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

	#define FIREWORK_COUNT				1
	#define FIREWORK_BURST				512

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

	bl fxFireworkGenerate

@	bl randomStarsMulti									@ generate em!
@	bl moveFireworks									@ draw them

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

fxFireworkGenerate:
	stmfd sp!, {r0-r12, lr}
	@ ok, to generate a firework, all plots are at an initial X,y
	
	ldr r0,=fireworkLife
	bl getRandom
	and r8,#0xff
	add r8,#128
	str r8,[r0]
	
	bl getRandom						@ generate x/y in r0,r1
	
	and r8,#0xff
	lsl r8,#12
	mov r0,r8

	bl getRandom
	and r8,#0xff
	lsl r8,#12
	mov r1,r0
	
		ldr r3,=fireworkX	
		ldr r4,=fireworkY
		ldr r5,=0x1ff
		ldr r6,=fireworkAngle
		ldr r7,=fireworkSpeed
		ldr r9,=fireworkGravity	
		ldr r10,=0x1fff

		mov r2,#FIREWORK_BURST				@ number of particles in a firework
		sub r2,#1
	
	fireworkGenerateLoop:
		str r0,[r3,r2, lsl #2]			@ store X and Y
		str r1,[r4,r2, lsl #2]
	
		bl getRandom
		and r8,r5						@ reduce to 0-511
		str r8,[r6,r2, lsl #2]			@ store angle
		
		bl getRandom
		and r8,r10						@ make 0.xxx-7.xxx (20.12)
		add r8,#512
		str r8,[r7,r2, lsl #2]			@ store speed
		
		mov r8,#0
		str r8,[r9,r2, lsl #2]			@ store gravity
		
		subs r2,#1
	
	bpl fireworkGenerateLoop	

	ldmfd sp!, {r0-r12, pc}


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

@------------------------------------------------

fxMoveFireworks:

	stmfd sp!, {r0-r12, lr}
	
	mov r6,#FIREWORK_COUNT
	sub r6,#1
	
	fireworkNumberLoop:
	
	ldr r1,=fireworkLife
	ldr r1,[r1,r6, lsl #2]
	cmp r1,#0
	beq fireworkNext
	
	push {r6}
	
		mov r7,#FIREWORK_BURST
		sub r7,#1
	
		ldr r11,=COS_bin				@ we will use these a lot, so...
		ldr r12,=SIN_bin				@ keep them out of the loop
		ldr r8,=fireworkX	
		ldr r9,=fireworkY
		ldr r10,=fireworkSpeed
	
		fireworkMoveLoop:
		@ ok, first grab the X and y and update them with speed and cos/sin
			mov r5, r7, lsl#2
			ldr r6,[r10, r5]				@ r6 = speed (keep r6 for y calcs)
			ldr r3,=fireworkAngle
			ldr r3,[r3, r5]				@ r3 = angle (keep r3 for y calcs)
			lsl r3,#1

			ldr r0,[r8, r5]				@ r0 = X coord
			ldrsh r4, [r11,r3]				@ r4 = cosine	( from amgle)
			muls r4,r6						@ r4 = cosine * speed
			adds r0,r4, asr #12				@ add cosine result to x coord	
			ldr r1,[r9, r5]				@ r1 = Y coord
			ldrsh r4, [r12,r3]				@ r4 = sine	
			muls r4,r6						@ r4 = sine * speed
			adds r1,r4, asr #12				@ add sine result to x coord	
	
			ldr r3,=fireworkGravity			@ update gravity	
			ldr r4,[r3, r5]				@ for a good effect, a slower speed generated
			add r1,r4						@ should result in a quicker gravity
			add r4,#64						@ but this will do for now
			str r4,[r3, r5]				@ store gravity back
	
			@ if r0 (x) is now less than 0 or greater than 255
			@ we need to kill it... the same goes for y<0
	
			cmp r0,#0
			bmi fxFireworkNoDraw
			cmp r0,#0xff000
			bgt fxFireworkNoDraw
			cmp r1,#0
			bmi fxFireworkNoDraw
			cmp r1,#0x180000
			blt fxFireworkNoBounce
				mov r1,#0x180000				@ i may take this code out???
				str r4,[r3,r5]					
				ldr r4,=fireworkAngle
				ldr r6,[r4, r5]				@ r3 = angle (keep r3 for y calcs)
				cmp r6,#256
				addlt r6,#256
				movge r2,#1024
				strge r2,[r3,r5]
				str r6,[r4, r5]				@ store angle back
			fxFireworkNoBounce:
	
			str r0,[r8, r7, lsl #2]			@ store new X
			str r1,[r9, r7, lsl #2]			@ store new Y
	
			mov r2,#11							@ set palette
			bl fxDrawFirePixel
	
			fxFireworkNoDraw:
	
			subs r7,#1
		bpl fireworkMoveLoop

		pop {r6}
	
	fireworkNext:
	
	ldr r3,=fireworkLife
	ldr r4,[r3,r6, lsl #2]
	subs r4,#1
	movmi r4,#0
	str r4,[r3,r6, lsl #2]
	blmi fxFireworkGenerate
	subs r6,#1
	
	bpl	fireworkNumberLoop
	
	
	ldmfd sp!, {r0-r12, pc}
















	
fireworkMain:
.word 0
fireworkSub:
.word 0

	.data
	.pool
	.align
fireworkSpeed:
	.space (FIREWORK_COUNT*FIREWORK_BURST)*4	
fireworkX:
	.space (FIREWORK_COUNT*FIREWORK_BURST)*4	
fireworkY:
	.space (FIREWORK_COUNT*FIREWORK_BURST)*4
fireworkAngle:
	.space (FIREWORK_COUNT*FIREWORK_BURST)*4
fireworkGravity:
	.space (FIREWORK_COUNT*FIREWORK_BURST)*4
fireworkLife:
	.space FIREWORK_COUNT*4
	
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

