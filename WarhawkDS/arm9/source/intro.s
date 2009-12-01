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
	.global showIntro1
	.global showIntro2
	.global showIntro3
	.global updateIntro
	.global introMonkey

showIntro1:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_INTRO
	str r1, [r0]
	
	bl initVideoBG2_256
	
	bl fxFadeBlackInit
	bl fxFadeMax
	
	@ Write the palette

	ldr r0, =ProteusPal
	ldr r1, =BG_PALETTE
	ldr r2, =ProteusPalLen
	mov r3, #0
	bl dmaCopy
	strh r3, [r1]
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	strh r3, [r1]

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
	
	@ Write the tile data
	
	ldr r0 ,=InfectuousTiles
	ldr r1, =BG_TILE_RAM_SUB(BG2_TILE_BASE_SUB)
	ldr r2, =InfectuousTilesLen
	bl dmaCopy

	ldr r0, =PPOTTiles
	ldr r1, =BG_TILE_RAM(BG2_TILE_BASE)
	ldr r2, =PPOTTilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =InfectuousMap
	ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)	@ destination
	ldr r2, =InfectuousMapLen
	bl dmaCopy

	ldr r0, =PPOTMap
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)			@ destination
	ldr r2, =PPOTMapLen
	bl dmaCopy
	
	ldr r0, =4000								@ 4 seconds
	ldr r1, =showIntro1FadeOut					@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@---------------------------------
	
showIntro1FadeOut:

	stmfd sp!, {r0-r1, lr}
	
	bl fxFadeBG1BG2Init
	bl fxFadeMin
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =showIntro2
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------
	
showIntro2:

	stmfd sp!, {r0-r2, lr}
	
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
	
	@ Write the tile data
	
	ldr r0 ,=RetrobytesTiles
	ldr r1, =BG_TILE_RAM_SUB(BG2_TILE_BASE_SUB)
	ldr r2, =RetrobytesTilesLen
	bl dmaCopy

	ldr r0, =WebTiles
	ldr r1, =BG_TILE_RAM(BG2_TILE_BASE)
	ldr r2, =WebTilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =RetrobytesMap
	ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)	@ destination
	ldr r2, =RetrobytesMapLen
	bl dmaCopy

	ldr r0, =WebMap
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)			@ destination
	ldr r2, =WebMapLen
	bl dmaCopy
	
	ldr r0, =4000								@ 4 seconds
	ldr r1, =showIntro2FadeOut					@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@---------------------------------
	
showIntro2FadeOut:

	stmfd sp!, {r0-r1, lr}
	
	bl fxFadeBG1BG2Init
	bl fxFadeMin
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =showIntro3
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------
	
showIntro3:

	stmfd sp!, {r0-r2, lr}
	
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
	
	ldr r0, =4000								@ 4 seconds
	ldr r1, =showIntro3FadeOut					@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@---------------------------------
	
showIntro3FadeOut:

	stmfd sp!, {r0-r1, lr}
	
	bl fxFadeBlackInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =showLoading
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateIntro:

	stmfd sp!, {r0-r2, lr}
	
	ldr r1, =REG_KEYINPUT
	ldr r2, [r1]
	tst r2, #BUTTON_START
	
	ldr r1,=introMonkey
	
	bne introSkipper
		mov r2,#1
		str r2,[r1]
		b introSkipper2
		
	introSkipper:
		ldr r2,[r1]
		cmp r2,#1
		
		bleq stopTimer
		bleq showTitleScreen
	
	introSkipper2:
	
	ldr r1, =REG_KEYINPUT
	ldr r2, [r1]
	tst r2, #BUTTON_A
	bleq stopTimer
	bleq showTitleScreen
	
	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@---------------------------------
	
	.data
	.align
	
	introMonkey:
	.word 0
	
	.pool
	.end