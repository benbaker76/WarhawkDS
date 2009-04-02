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

	.arm
	.align
	.text
	
	.global fxPaletteFadeToRed
	.global fxPaletteFadeToRedVBlank
	.global fxPaletteInvert
	.global fxPaletteBleach
	.global fxPaletteRestore
	
	
	@ was gonna add a function to take all 3 RGB values and find the average and store that in each to make it grey
	@ but i think this looked great anyway?
	
fxPaletteFadeToRed:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fadeToRedValue
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_PALETTE_FADE_TO_RED
	str r1, [r0]

	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxPaletteFadeToRedVBlank:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =BG_PALETTE
	ldr r1, =BG_PALETTE_SUB
	ldr r2, =255
	
fxPaletteFadeToRedLoop:
	
	ldrh r3, [r0]
	mov r4, r3
	mov r5, r3
	lsr r4, #5
	lsr r5, #10
	and r3, #0x1F
	and r4, #0x1F
	and r5, #0x1F
	cmp r3, #0x1F
	addlt r3, #1
	cmp r4, #0
	subgt r4, #1
	cmp r5, #0
	subgt r5, #1
	lsl r4, #5
	lsl r5, #10
	orr r3, r4
	orr r3, r5
	strh r3, [r0], #2
	
	ldrh r3, [r1]
	mov r4, r3
	mov r5, r3
	lsr r4, #5
	lsr r5, #10
	and r3, #0x1F
	and r4, #0x1F
	and r5, #0x1F
	cmp r3, #0x1F
	addlt r3, #1
	cmp r4, #0
	subgt r4, #1
	cmp r5, #0
	subgt r5, #1
	lsl r4, #5
	lsl r5, #10
	orr r3, r4
	orr r3, r5
	strh r3, [r1], #2
	
	subs r2, #1	
	bpl fxPaletteFadeToRedLoop
	
	ldr r0, =fadeToRedValue
	ldr r1, [r0]
	ldr r2, =fxMode
	ldr r3, [r2]
	add r1, #1
	cmp r1, #0xF
	andeq r3, #~(FX_PALETTE_FADE_TO_RED)
	str r1, [r0]
	str r3, [r2]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxPaletteBleach:

	stmfd sp!, {r0-r6, lr}
	
	@ well, it isnt, but i like the look???
	
	ldr r0, =BG_PALETTE
	ldr r1, =bgPalette
	ldr r2, =256*2
	bl dmaCopy
	ldr r0, =BG_PALETTE_SUB
	ldr r1, =bgPaletteSub
	bl dmaCopy

	ldr r1, =BG_PALETTE
	ldr r2, =BG_PALETTE_SUB
		
	mov r0,#255
	add r0,#256
	
fxPaletteBleachLoop:
	
	ldrh r3,[r1,r0]

	add r3,#128
	
	strh r3,[r1,r0]
	strh r3,[r2,r0]
	
	subs r0,#1
	
	bpl fxPaletteBleachLoop
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------
	
fxPaletteInvert:

	stmfd sp!, {r0-r6, lr}
	
	@ well, it isnt, but i like the look???
	
	ldr r0, =BG_PALETTE
	ldr r1, =bgPalette
	ldr r2, =256*2
	bl dmaCopy
	ldr r0, =BG_PALETTE_SUB
	ldr r1, =bgPaletteSub
	bl dmaCopy

	ldr r0, =BG_PALETTE
	ldr r1, =BG_PALETTE_SUB
		
	mov r2, #255
	
fxPaletteInvertLoop:
	
	ldrh r3, [r0]
	ldrh r4, [r1]
	ldrh r5, =0xFFFF
	eor r3, r5
	eor r4, r5
	strh r3, [r0], #2
	strh r4, [r1], #2
	
	subs r2, #1
	bpl fxPaletteInvertLoop
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------

fxPaletteRestore:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =bgPalette
	ldr r1, =BG_PALETTE
	ldr r2, =256*2
	bl dmaCopy
	ldr r0, =bgPaletteSub	
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
		
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
	.align
	.data
	
fadeToRedValue:
	.word 0
	
bgPalette:
	.space 256*2								@ Palette Backup
	
bgPaletteSub:
	.space 256*2								@ Palette Backup
	
	.pool
	.end
