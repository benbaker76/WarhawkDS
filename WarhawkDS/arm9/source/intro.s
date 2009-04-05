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

	#define FONT_COLOR_OFFSET	11

	.arm
	.align
	.text
	.global showIntro1
	.global showIntro2
	.global showIntro3
	.global updateIntro

showIntro1:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_INTRO
	str r1, [r0]
	
	@ Write the palette

	ldr r0, =ProteusPal
	ldr r1, =BG_PALETTE
	ldr r2, =ProteusPalLen
	bl dmaCopy
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy

	@ Write the tile data
	
	ldr r0 ,=ProteusTiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =ProteusTilesLen
	bl dmaCopy

	ldr r0, =HeadsoftTiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =HeadsoftTilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =ProteusMap
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =ProteusMapLen
	bl dmaCopy

	ldr r0, =HeadsoftMap
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =HeadsoftMapLen
	bl dmaCopy
	
	bl fxFadeWhiteIn
	
	ldr r0, =3									@ 2 seconds
	ldr r1, =showIntro2							@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
showIntro2:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_INTRO
	str r1, [r0]
	
	@ Write the palette

	ldr r0, =ProteusPal
	ldr r1, =BG_PALETTE
	ldr r2, =ProteusPalLen
	bl dmaCopy
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy

	@ Write the tile data
	
	ldr r0 ,=InfectuousTiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =InfectuousTilesLen
	bl dmaCopy

	ldr r0, =PPOTTiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =PPOTTilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =InfectuousMap
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =InfectuousMapLen
	bl dmaCopy

	ldr r0, =PPOTMap
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =PPOTMapLen
	bl dmaCopy
	
	bl fxFadeWhiteIn
	
	ldr r0, =3									@ 2 seconds
	ldr r1, =showIntro3							@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
showIntro3:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_INTRO
	str r1, [r0]
	
	@ Write the palette

	ldr r0, =ProteusPal
	ldr r1, =BG_PALETTE
	ldr r2, =ProteusPalLen
	bl dmaCopy
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy

	@ Write the tile data
	
	ldr r0 ,=RetrobytesTiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =RetrobytesTilesLen
	bl dmaCopy

	ldr r0, =WebTiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =WebTilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =RetrobytesMap
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =RetrobytesMapLen
	bl dmaCopy

	ldr r0, =WebMap
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =WebMapLen
	bl dmaCopy
	
	bl fxFadeWhiteIn
	
	ldr r0, =3									@ 2 seconds
	ldr r1, =showLoading						@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateIntro:

	stmfd sp!, {r0-r6, lr}
	
	ldr r1, =REG_KEYINPUT
	ldr r2, [r1]
	tst r2, #BUTTON_START
	bleq stopTimer
	bleq gameStart								@ Start the game
	
	ldr r1, =REG_KEYINPUT
	ldr r2, [r1]
	tst r2, #BUTTON_A
	bleq stopTimer
	bleq initTitleScreen
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
	.data
	.align
	
	.pool
	.end