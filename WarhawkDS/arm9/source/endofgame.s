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
	
	ldr r0,=vblCounterH						@ if you are gonna reuse vars, they need to be init every time
	mov r1,#0
	str r1,[r0]
	
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
	
	ldr r0 ,=CongratulationsTiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =CongratulationsTilesLen
	bl dmaCopy

	ldr r0, =LargeShipTiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =LargeShipTilesLen
	bl dmaCopy
	
		@ldr r0, =LargeShipTiles
		@ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
		@ldr r2, =LargeShipTilesLen
		@bl dmaCopy
	
	@ Write map
	
	ldr r0, =CongratulationsMap
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =CongratulationsMapLen
	bl dmaCopy

	ldr r0, =LargeShipMap
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE_SUB)			@ destination
	ldr r2, =LargeShipMapLen
	bl dmaCopy
	
		@ldr r0, =LargeShipMap
		@ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)			@ destination
		@ldr r2, =LargeShipMapLen
		@bl dmaCopy
	
	bl drawSBMapScreenMain
	bl drawSBMapScreenSub
	
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
	
	ldr r0, =finalScoreText						@ Load out text pointer
	ldr r1, =10									@ x pos
	ldr r2, =11									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	bl drawScoreSub
	
	ldr r0, =endOfGameRawText					@ Read the path to the file
	bl playAudioStream							@ Play the audio stream

	bl fxCopperTextOn							@ Turn on copper text fx
	bl fxStarfieldDownOn						@ Turn on starfield
	
	ldr r0, =50									@ 50 milliseconds
	ldr r1, =updateFireSpriteIndex				@ Callback function address
	
	bl startTimer
		
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateFireSpriteIndex:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =fireSpriteIndex
	ldr r1, [r0]
	add r1, #1
	cmp r1, #4
	moveq r1, #0
	str r1, [r0]
	
	ldr r0, =50									@ 50 milliseconds
	ldr r1, =updateFireSpriteIndex				@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateFireSprite:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =OBJ_ATTRIBUTE0(0)					@ Attrib 0
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)	@ Attrib 0 settings
	ldr r3, =vOfs								@ Load REG_BG1VOFS address
	ldr r4, [r3]								@ Load VBLANK counter value
	rsb r4, r4, #0								@ Make it negative
	add r4, #160								@ Add the Y offset
	and r4, #0xFF								@ And with 0xFF so no overflow
	orr r1, r4									@ Orr in Y offset with settings
	strh r1, [r0]								@ Write to attrib 0
	
	ldr r0, =OBJ_ATTRIBUTE1(0)					@ Attrib 1
	ldr r1, =(ATTR1_SIZE_32)					@ Attrib 1 settings
	ldr r3, =hOfs								@ Load REG_BG1HOFS address
	ldr r4, [r3]								@ Load VBLANK counter value
	rsb r4, r4, #0								@ Make it negative
	add r4, #112								@ Add the X offset
	ldr r5, =0x1FF								@ Load 0x1FF
	and r4, r5									@ And with 0x1FF so no overflow
	orr r1, r4									@ Orr in X offset with settings
	strh r1, [r0]								@ Write to attrib 1
	
	ldr r0, =OBJ_ATTRIBUTE2(0)					@ Attrib 2
	mov r1, #ATTR2_PRIORITY(0)					@ Set sprite priority
	ldr r2, =fireSpriteIndex
	ldr r2, [r2]
	lsl r2, #4
	orr r1, r2
	strh r1, [r0]								@ Write Attrib 2
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateShipMove:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =REG_BG1HOFS
	ldr r1, [r0]
	ldr r2, =COS_bin							@ Load COS address
	ldr r3, =vblCounterH						@ Load VBLANK counter address
	ldr r3, [r3]								@ Load VBLANK counter value
	ldr r4, =0x1FF								@ Load 0x1FF (511)
	and r3, r4									@ And VBLANK counter with 511
	lsl r3, #1									@ Multiply * 2 (16 bit COS values)
	add r2, r3									@ Add the offset to the COS table
	ldrsh r3, [r2]								@ Read the COS table value (signed 16-bit value)
	lsr r3, #8									@ Right shift COS value to make it smaller
	strh r3, [r0]
	ldr r4, =hOfs
	str r3, [r4]

@ not sure this works :( (remove if you want)

lsr r3,#4
cmp r3,#0
bne  starsTurnRight
	ldr r0,=starDirection
	ldr r1,[r0]
	add r1,#2
	str r1,[r0]
	b starTurnDone

starsTurnRight:
	ldr r0,=starDirection
	ldr r1,[r0]
	sub r1,#2
	str r1,[r0]
	b starTurnDone

starTurnDone:

	ldr r0, =REG_BG1VOFS
	ldr r1, [r0]
	ldr r2, =SIN_bin							@ Load SIN address
	ldr r3, =vblCounterV						@ Load VBLANK counter address
	ldr r3, [r3]								@ Load VBLANK counter value
	ldr r4, =0x1FF								@ Load 0x1FF (511)
	and r3, r4									@ And VBLANK counter with 511
	lsl r3, #1									@ Multiply * 2 (16 bit SIN values)
	add r2, r3									@ Add the offset to the SIN table
	ldrsh r3, [r2]								@ Read the SIN table value (signed 16-bit value)
	lsr r3, #10									@ Right shift SIN value to make it smaller
	strh r3, [r0]								@ Write to attrib 0
	ldr r4, =vOfs
	str r3, [r4]
	
	ldr r0, =vblCounterH
	ldr r1, [r0]
	add r1, #4
	str r1, [r0]
	
	ldr r0, =vblCounterV
	ldr r1, [r0]
	add r1, #2
	str r1, [r0]

	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
updateEndOfGame:

	stmfd sp!, {r0-r6, lr}
	
	bl scrollStarBack							@ Scroll stars
	bl scrollStarBack
	bl scrollStarBack							@ this is the ideal speed.. though perhaps back should take a speed var
	bl updateShipMove
	bl updateFireSprite							@ Update fire sprites
	
	ldr r1, =REG_KEYINPUT						@ Read Key Input
	ldr r2, [r1]
	tst r2, #BUTTON_A							@ Start button pressed?
	bleq stopTimer
	bleq fxStarfieldOff							@ Turn off the spotlight effect
	bleq fxCopperTextOff						@ Turn off the copper text effect
	bleq showHiScoreEntry						@ Got to the hiscore entry
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

	.data
	.align
	
	.align
fireSpriteIndex:
	.word 0
	
	.align
vOfs:
	.word 0
	
	.align
hOfs:
	.word 0
	
	.align
vblCounterH:
	.word 0
	
	.align
vblCounterV:
	.word 1
	
	.align
gameCompleteText:
	.asciz "GAME COMPLETE!"
	
	.align
finalScoreText:
	.asciz "FINAL SCORE:"

	.pool
	.end
