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
	.global showLoading
	.global updateLoading	

showLoading:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_LOADING
	str r1, [r0]
	
	@ Write the palette

	ldr r0, =TitleTopPal
	ldr r1, =BG_PALETTE
	ldr r2, =TitleTopPalLen
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]

	@ Write the tile data
	
	ldr r0 ,=LoadingTopTiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =LoadingTopTilesLen
	bl dmaCopy

	ldr r0, =LoadingBottomTiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =LoadingBottomTilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =LoadingTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =LoadingTopMapLen
	bl dmaCopy

	ldr r0, =LoadingBottomMap
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =LoadingBottomMapLen
	bl dmaCopy
	
	ldr r0, =3									@ 1 second
	ldr r1, =timerDoneLoading					@ Callback function address
	
	bl startTimer
	
	bl fxColorCycleTextOn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
timerDoneLoading:

	stmfd sp!, {r0-r1, lr}
	
	bl fxColorCycleTextOff
	bl initTitleScreen
	
	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateLoading:

	stmfd sp!, {r0-r6, lr}
	
	ldr r1, =REG_KEYINPUT
	ldr r2, [r1]
	tst r2, #BUTTON_START
	bleq stopTimer
	bleq gameStart								@ Start the game
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------

	.data
	.align
	
	.pool
	.end