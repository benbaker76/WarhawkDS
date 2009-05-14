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

	#define FIREWORK_COUNT				6
	#define PARTICLE_COUNT				128
	
	@ 5 * 256 = 128, times 4 = 5120 pixels plotted :(
	@ this is always going to be a lot slower that framebuffer as the calcs
	@ for the tile and pixle write consume a lot of cpu!
	@ what is better 5*256 or 10*128???

	.arm
	.align
	.text
	.global fxFireworksOn
	.global fxFireworksOff
	.global fxFireworksVBlank

fxFireworksOn:

	stmfd sp!, {r0-r3, lr}
	
	bl initVideoStars
	
	@ Clear the tile data
	
	bl clearFireworks
	
	@ set the screen up to use numbered tiles from 0-767, a hybrid bitmap!	
	
	mov r0, #0										@ tile number
	ldr r2, =BG_MAP_RAM(BG2_MAP_BASE)				@ where to store it
	ldr r3, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)		@ where to store it

fxFireworksOnLoop:

	mov r1, r0
	orr r1, #(1 << 12)								@ Set palette entry 1
	strh r1, [r2], #2
	strh r1, [r3], #2
	add r0, #1
	cmp r0, #(32 * 24)
	
	bne fxFireworksOnLoop
	
	mov r0, #FIREWORK_COUNT	
	sub r0,#1
	
createFireworksLoop:

	bl generateFireworks							@ r0=firework to generate
	subs r0,#1
	
	bpl createFireworksLoop
	
	ldr r0, =fireworkPalette
	ldr r1, =BG_PALETTE
	ldr r2, =8*2
	ldr r3, =16*2
	add r1, r3
	bl dmaCopy
	ldr r1, =BG_PALETTE_SUB
	add r1, r3
	bl dmaCopy

	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_FIREWORKS
	str r1, [r0]
	
	ldmfd sp!, {r0-r3, pc}

	@ ---------------------------------------

fxFireworksOff:

	stmfd sp!, {r0-r1, lr}
	
	bl initVideoMain
	
	ldr r0, =fxMode
	ldr r1, [r0]
	bic r1, #FX_FIREWORKS
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}

	@ ---------------------------------------
	
fxFireworksVBlank:

	stmfd sp!, {r0, lr}
	
	bl clearFireworks								@ clear them (could use a dma to clear the screen?)
	bl updateFireworks								@ move em, based on x/y speeds and plot
	
	ldmfd sp!, {r0, pc}

	@ ---------------------------------------

generateFireworks:

	stmfd sp!, {r0-r12, lr}
	
	@ ok, to generate a firework, all plots are at an initial X,y
	@ will need to pass this the number of the firework!
	@ r0=firework to generate....
	@ so r0 * PARTICLE_COUNT = start pos
	
	bl playFireworksSound				@ Play fireworks sound

	ldr r2,=fireworkLife
	bl getRandom
	and r8,#0xff
	add r8,#64
	str r8,[r2,r0, lsl #2]				@ life of firework (r0 = firework number)

	mov r1,#PARTICLE_COUNT				@ number of particles in a burst
	mul r12,r1,r0						@ r12= offset - firework number*burst amount

	lsl r12,#2							@ THIS IS WHAT IS FUCKING FORGOT - TWAT!!!!
										@ A RESTLESS NIGHT FOR THIS!!! GGGRRRrrr!!!

	bl getRandom						@ generate x/y in r0,r1
	and r8,#0xff
	lsl r8,#12
	mov r0,r8							@ X coord

	bl getRandom
	and r8,#0xBf
	lsl r8,#12
	mov r1,r8							@ Y coord

	bl getRandom						@ colour
	and r8,#0x7							@ 0-7
	mov r3, r8
	
	ldr r5,=0x1ff
	ldr r6,=fireworkAngle
	ldr r7,=fireworkSpeed
	ldr r9,=fireworkGravity	
	ldr r10,=0xfff
	ldr r11,=fireworkColor

	mov r2,#PARTICLE_COUNT				@ number of particles in a firework
	sub r2,#1							@ minus 1
		
	generateFireworksLoop:
	
		ldr r4,=fireworkX	
		str r0,[r4,r12]			@ store X and Y
		ldr r4,=fireworkY
		str r1,[r4,r12]
	
		bl getRandom
		and r8,r5					@ reduce to 0-511
		str r8,[r6,r12]			@ store angle
		
		bl getRandom
		and r8,r10					@ make 0.xxx-7.xxx (20.12)
	@	add r8,#64
		str r8,[r7,r12]			@ store speed
		
		mov r8,#0
		str r8,[r9,r12]			@ store gravity

		str r3,[r11,r12]			@ store color value
		
		add r12,#4
		subs r2,#1
	
	bpl generateFireworksLoop	

	ldmfd sp!, {r0-r12, pc}

	@ ---------------------------------------
	
drawParticle:

	stmfd sp!, {r0-r7, lr}
	
	@ pass r0,r1 = x/y
	@ r2 = palette entry
	
	push {r1}
	cmp r1,#0xc0000									@ 192 in 20.12 format
	ldrpl r6,=BG_TILE_RAM(STAR_BG2_TILE_BASE)		@ bottom screen
	ldrlt r6,=BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)@ top screen
	subpl r1,#0xC0000								@ 192 in 20.12 format
	mov r5, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r5, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r5, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r5, lsl #5							@ r3 now = tile base offset from tilemem
	and r5,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r5, lsr #10]						@ load word at tile pos
	and r7,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r7, #10										@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r2, lsl r7								@ or our colour in (shifted x units)
	str r4, [r3, r5, lsr #10]						@ store it back	

	add r0,#0x1000	
	mov r5, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r5, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r5, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r5, lsl #5							@ r3 now = tile base offset from tilemem
	and r5,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r5, lsr #10]						@ load word at tile pos
	and r7,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r7, #10										@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r2, lsl r7								@ or our colour in (shifted x units)
	str r4, [r3, r5, lsr #10]						@ store it back		
	
	pop {r1}
	add r1,#0x1000
	sub r0,#0x1000
	cmp r1,#0xc0000									@ 192 in 20.12 format
	ldrpl r6,=BG_TILE_RAM(STAR_BG2_TILE_BASE)		@ bottom screen
	ldrlt r6,=BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)@ top screen
	subpl r1,#0xC0000								@ 192 in 20.12 format
	mov r5, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r5, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r5, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r5, lsl #5							@ r3 now = tile base offset from tilemem
	and r5,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r5, lsr #10]						@ load word at tile pos
	and r7,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r7, #10										@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r2, lsl r7								@ or our colour in (shifted x units)
	str r4, [r3, r5, lsr #10]						@ store it back	
	
	add r0,#0x1000	
	mov r5, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
	lsl r5, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
	add r5, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
	add r3,r6, r5, lsl #5							@ r3 now = tile base offset from tilemem
	and r5,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
	ldr r4, [r3, r5, lsr #10]						@ load word at tile pos
	and r7,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
	lsr r7, #10										@ times r0 (X) by 4 for nibbles (4 bits per colour)
	orr r4, r2, lsl r7								@ or our colour in (shifted x units)
	str r4, [r3, r5, lsr #10]						@ store it back		

	
	ldmfd sp!, {r0-r7, pc}

	@ ---------------------------------------

updateFireworks:

	stmfd sp!, {r0-r12, lr}
	
		mov r7,#PARTICLE_COUNT*FIREWORK_COUNT
		sub r7,#1
		@ need to calculte r7 based on firework numbers
		
		ldr r11,=COS_bin				@ we will use these a lot, so...
		ldr r12,=SIN_bin				@ keep them out of the loop
		ldr r8,=fireworkX	
		ldr r9,=fireworkY
		ldr r10,=fireworkSpeed

		updateFireworksLoop:

		@ ok, first grab the X and y and update them with speed and cos/sin
		
			mov r5, r7, lsl #2
			ldr r6,[r10, r5]				@ r6 = speed (keep r6 for y calcs)
			ldr r3,=fireworkAngle
			ldr r3,[r3, r5]				@ r3 = angle (keep r3 for y calcs)
			lsl r3, #1

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
		
			str r0,[r8, r5]				@ store new X
			str r1,[r9, r5]				@ store new Y
	
			ldr r4,=fireworkColor
			ldr r2,[r4, r5]				@ r2=firework colour

			cmp r0,#0
			bmi updateFireworksNoDraw
			cmp r0,#0xff000
			bgt updateFireworksNoDraw
			cmp r1,#0
			bmi updateFireworksNoDraw
			cmp r1,#0x180000
			bpl updateFireworksNoDraw
			
				push {r7}
				push {r1}
				cmp r1,#0xc0000									@ 192 in 20.12 format
				ldrpl r6,=BG_TILE_RAM(STAR_BG2_TILE_BASE)		@ bottom screen
				ldrlt r6,=BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)@ top screen
				subpl r1,#0xC0000								@ 192 in 20.12 format
				mov r5, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
				lsl r5, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
				add r5, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
				add r3,r6, r5, lsl #5							@ r3 now = tile base offset from tilemem
				and r5,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
				ldr r4, [r3, r5, lsr #10]						@ load word at tile pos
				and r7,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
				lsr r7, #10										@ times r0 (X) by 4 for nibbles (4 bits per colour)
				orr r4, r2, lsl r7								@ or our colour in (shifted x units)
				str r4, [r3, r5, lsr #10]						@ store it back	
				add r0,#0x1000	
				mov r5, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
				lsl r5, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
				add r5, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
				add r3,r6, r5, lsl #5							@ r3 now = tile base offset from tilemem
				and r5,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
				ldr r4, [r3, r5, lsr #10]						@ load word at tile pos
				and r7,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
				lsr r7, #10										@ times r0 (X) by 4 for nibbles (4 bits per colour)
				orr r4, r2, lsl r7								@ or our colour in (shifted x units)
				str r4, [r3, r5, lsr #10]						@ store it back		
				pop {r1}
				add r1,#0x1000
				sub r0,#0x1000
				cmp r1,#0xc0000									@ 192 in 20.12 format
				ldrpl r6,=BG_TILE_RAM(STAR_BG2_TILE_BASE)		@ bottom screen
				ldrlt r6,=BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)@ top screen
				subpl r1,#0xC0000								@ 192 in 20.12 format
				mov r5, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
				lsl r5, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
				add r5, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
				add r3,r6, r5, lsl #5							@ r3 now = tile base offset from tilemem
				and r5,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
				ldr r4, [r3, r5, lsr #10]						@ load word at tile pos
				and r7,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
				lsr r7, #10										@ times r0 (X) by 4 for nibbles (4 bits per colour)
				orr r4, r2, lsl r7								@ or our colour in (shifted x units)
				str r4, [r3, r5, lsr #10]						@ store it back	
				add r0,#0x1000	
				mov r5, r1, lsr #15								@ r9 = y / 8 (+12) (THESE COMMENTS DO NOT REALLY MATCH NOW)
				lsl r5, #5										@ mul by 32 (32 tiles per screen row) (r9=tile, 0,32,64...)
				add r5, r0, lsr #15								@ add r9 x coord divided by 32768 (accounts for 20.12)
				add r3,r6, r5, lsl #5							@ r3 now = tile base offset from tilemem
				and r5,r1, #0x7000								@ take the low 3 bits (0-7) of y (each y is one word)
				ldr r4, [r3, r5, lsr #10]						@ load word at tile pos
				and r7,r0, #0x7000								@ take the low 3 bits (0-7) of x (each x is halfbyte)
				lsr r7, #10										@ times r0 (X) by 4 for nibbles (4 bits per colour)
				orr r4, r2, lsl r7								@ or our colour in (shifted x units)
				str r4, [r3, r5, lsr #10]						@ store it back	
				pop {r7}

			updateFireworksNoDraw:
	
			subs r7,#1
		bpl updateFireworksLoop

	@ generate new firework based on life

	mov r0,#FIREWORK_COUNT
	sub r0,#1
	ldr r3,=fireworkLife

	updateFireworksGenLoop:
	
		ldr r4,[r3,r0, lsl #2]			@ load the life of the firework based on r0 into r4
		subs r4,#1						@ take 1 off the life
		str r4,[r3,r0, lsl #2]			@ store it back
		bleq generateFireworks			@ regenerate based on r0 (firework count)
		subs r0,#1
	bpl updateFireworksGenLoop	
	
	ldmfd sp!, {r0-r12, pc}
	
	@ ---------------------------------------
	
clearFireworks:

	stmfd sp!, {r0-r2, lr}

	mov r0, #0
	ldr r1, =BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)
	ldr r2, =(32 * 24 * 32)
	bl dmaFillWords
	ldr r1, =BG_TILE_RAM(STAR_BG2_TILE_BASE)
	bl dmaFillWords
	
	ldmfd sp!, {r0-r2, pc}
	
	@ ---------------------------------------

	.data
	.align

fireworkSpeed:
	.space (FIREWORK_COUNT*PARTICLE_COUNT*4)	
	
fireworkX:
	.space (FIREWORK_COUNT*PARTICLE_COUNT*4)
	
fireworkY:
	.space (FIREWORK_COUNT*PARTICLE_COUNT*4)
	
fireworkAngle:
	.space (FIREWORK_COUNT*PARTICLE_COUNT*4)
	
fireworkGravity:
	.space (FIREWORK_COUNT*PARTICLE_COUNT*4)
	
fireworkColor:
	.space (FIREWORK_COUNT*PARTICLE_COUNT*4)
	
fireworkLife:
	.space (FIREWORK_COUNT*4)
	
fireworkPalette:
	.hword COLOR_RED, COLOR_LIME, COLOR_BLUE, COLOR_YELLOW, COLOR_CYAN, COLOR_MAGENTA, COLOR_ORANGE, COLOR_VIOLET
	
	.pool
	.end

	@ ---------------------------------------

	@ plot code (condensed)

	r1=y (20.12)
	r0=x (20.12)
	r2=palette number
	
	uses r3,r4,r5,r6

	cmp r1,#0xc0000									@ 192 in 20.12 format
	ldrpl r6,BG_TILE_RAM(STAR_BG2_TILE_BASE)		@ bottom screen
	ldrlt r6,BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)@ top screen
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

