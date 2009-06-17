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
#include "sprite.h"
#include "ipc.h"

	.arm
	.align
	.text
	.global initStarData
	.global initStarTiles
	
initStarData:

	stmfd sp!, {r0-r6, lr}
	
	mov r0,#0
	ldr r1,=pixelOffsetSFSub
	str r0,[r1]
	ldr r1,=pixelOffsetSFMain
	str r0,[r1]
	ldr r1,=pixelOffsetSBSub
	str r0,[r1]
	ldr r1,=pixelOffsetSBMain
	str r0,[r1]

	mov r0,#256
	ldr r1,=vofsSFMain
	str r0,[r1]
	ldr r1,=vofsSBMain
	str r0,[r1]
	ldr r1,=vofsSFSub
	str r0,[r1]
	ldr r1,=vofsSBSub
	str r0,[r1]

	mov r0,#736
	ldr r1,=yposSFMain
	str r0,[r1]
	ldr r1,=yposSBMain
	str r0,[r1]
	ldr r1,=yposSFSub
	str r0,[r1]
	ldr r1,=yposSBSub
	str r0,[r1]

	ldr r0, =hofsSF
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =hofsSB
	mov r1, #0
	str r1, [r0]

	@ Write the tile data
	
	ldr r0, =StarFrontTiles
	ldr r1, =BG_TILE_RAM(STAR_BG2_TILE_BASE)
	ldr r2, =StarFrontTilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(STAR_BG2_TILE_BASE_SUB)
	bl dmaCopy

	@ Write the tile data to VRAM BackStar BG3

	ldr r0, =StarBackTiles
	ldr r1, =BG_TILE_RAM(STAR_BG3_TILE_BASE)
	add r1, #StarFrontTilesLen
	ldr r2, =StarBackTilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(STAR_BG3_TILE_BASE_SUB)
	add r1, #StarFrontTilesLen
	bl dmaCopy
	
	bl drawSBMapScreenMain
	bl drawSBMapScreenSub
		
	ldmfd sp!, {r0-r6, pc}
	
	@---------------------------------
	
	.pool
	.end