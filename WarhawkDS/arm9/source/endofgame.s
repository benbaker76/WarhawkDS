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
	.global showEndOfGame
	.global updateEndOfGame
	
showEndOfGame:

	stmfd sp!, {r0-r6, lr}
	
	mov r6, r0									@ Move the hiscore value into r6
	
	ldr r0, =gameMode							@ Get gameMode address
	ldr r1, =GAMEMODE_ENDOFGAME					@ Set the gameMode to end of level
	str r1, [r0]								@ Store back gameMode
	
	ldr r0, =fxMode								@ Get fxMode address
	ldr r1, =FX_NONE							@ Get fxMode value
	str r1, [r0]								@ Turn off all fx
	
	bl initMainTiles							@ Initialize main tiles
	bl resetScrollRegisters						@ Reset scroll registers
	bl clearBG0									@ Clear bg's
	bl clearBG1
	bl clearBG2
	bl clearBG3
	
	@ Write the palette

	ldr r0, =LargeShipPal
	ldr r1, =BG_PALETTE
	ldr r2, =LargeShipPalLen
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	
	@ Write the tile data
	
	ldr r0 ,=CongratulationsTiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =CongratulationsTilesLen
	bl dmaCopy

	ldr r0, =LargeShipTiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =LargeShipTilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =CongratulationsMap
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =CongratulationsMapLen
	bl dmaCopy

	ldr r0, =LargeShipMap
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =LargeShipMapLen
	bl dmaCopy
	
	@ Clear Sprites
	
	bl clearOAM									@ Reset all sprites
	
	@ Load the palette into the palette subscreen area and main

	ldr r0, =FireSpritesPal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =FireSpritesPalLen
	bl dmaCopy

	@ Write the tile data to VRAM

	ldr r0, =FireSpritesTiles
	ldr r1, =SPRITE_GFX
	ldr r2, =FireSpritesTilesLen
	bl dmaCopy
	
	ldr r0, =gameCompleteText					@ Load out text pointer
	ldr r1, =9									@ x pos
	ldr r2, =5									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =endOfGameRawText					@ Read the path to the file
	bl playAudioStream							@ Play the audio stream

	bl fxCopperTextOn							@ Turn on copper text fx
	bl fxStarfieldDownOn						@ Turn on starfield
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateFireSprite:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =OBJ_ATTRIBUTE0(0)					@ Attrib 0
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)	@ Attrib 0 settings
	orr r1, #160								@ Orr in the y pos
	strh r1, [r0]								@ Write to Attrib 0
	
	ldr r0, =OBJ_ATTRIBUTE1(0)					@ Attrib 1
	ldr r1, =(ATTR1_SIZE_32)					@ Attrib 1 settings
	orr r1, #112								@ Orr in the x pos
	strh r1, [r0]								@ Write to Attrib 1
	
	ldr r0, =OBJ_ATTRIBUTE2(0)					@ Attrib 2
	mov r1, #ATTR2_PRIORITY(0)					@ Set sprite priority
	strh r1, [r0]								@ Write Attrib 2
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateEndOfGame:

	stmfd sp!, {r0-r6, lr}
	
	bl updateFireSprite							@ Update fire sprites
	
	ldr r1, =REG_KEYINPUT						@ Read Key Input
	ldr r2, [r1]
	tst r2, #BUTTON_A							@ Start button pressed?
	bleq fxStarfieldOff							@ Turn off the spotlight effect
	bleq fxCopperTextOff						@ Turn off the copper text effect
	bleq showTitleScreen						@ Got to start of game
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

	.data
	.align
	
	.align
gameCompleteText:
	.asciz "GAME COMPLETE!"

	.pool
	.end
