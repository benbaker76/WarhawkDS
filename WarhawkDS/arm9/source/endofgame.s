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
#include "windows.h"

	#define SPRITE_FRAME_TIME		4

	#define MODE_LARGESHIP			0
	#define MODE_LARGESHIP_FLY		1
	#define MODE_SMALLSHIP_FLY		2
	#define MODE_SMALLSHIP_LANDED	3
	#define MODE_MOTHERSHIP_FLY		4
	#define MODE_MOTHERSHIP_LEFT	5

	.arm
	.align
	.text
	.global showEndOfGame
	.global updateEndOfGame
	
showEndOfGame:

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =gameMode							@ Get gameMode address
	ldr r1, =GAMEMODE_ENDOFGAME					@ Set the gameMode to end of level
	str r1, [r0]								@ Store back gameMode

	bl fxOff
	bl fxFadeBlackInit
	bl fxFadeMax
	bl stopSound
	bl stopAudioStream
	bl initMainTiles							@ Initialize main tiles
	bl resetScrollRegisters						@ Reset scroll registers
	bl clearBG0									@ Clear bgs
	bl clearBG1
	bl clearBG2
	bl clearBG3
	
	bl initStarData
	bl initWindow
	
	ldr r0, =endOfGameMode
	ldr r1, =MODE_LARGESHIP
	str r1, [r0]
	
	ldr r0, =spriteIndex
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =spriteCount
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =spriteFrameCount
	ldr r1, =4
	str r1, [r0]
	
	ldr r0, =hOfs
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =vOfs
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =yOffset
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =vblCounterH
	mov r1, #0
	str r1, [r0]
	
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
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE_SUB)			@ destination
	ldr r2, =LargeShipMapLen
	bl dmaCopy
	
	@ Clear Sprites
	
	bl clearOAM									@ Reset all sprites
	
	@ Load the palette into the palette subscreen area and main

	ldr r0, =FireSpritesPal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =FireSpritesPalLen
	bl dmaCopy
	ldr r1, =SPRITE_PALETTE_SUB
	bl dmaCopy

	@ Write the tile data to VRAM

	ldr r0, =FireSpritesTiles
	ldr r1, =SPRITE_GFX
	ldr r2, =FireSpritesTilesLen
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
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
	
	ldr r0, =wellDoneText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =18									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =optionGameModeComplete
	ldr r0, [r0]
	
	tst r0, #OPTION_GAMEMODECOMPLETE_MENTAL
	bne showEndOfGameWarhawkElite

	ldr r0, =mentalModeUnlockedText				@ Load out text pointer
	ldr r1, =2									@ x pos
	ldr r2, =20									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	b showEndOfGameContinue
	
showEndOfGameWarhawkElite:
	
	ldr r0, =warhawkEliteText					@ Load out text pointer
	ldr r1, =3									@ x pos
	ldr r2, =20									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
showEndOfGameContinue:
	
	bl drawScoreSub
	
	ldr r0, =endOfGameRawText					@ Read the path to the file
	bl playAudioStream							@ Play the audio stream

	bl fxCopperTextOn							@ Turn on copper text fx
	
	mov r0,#1024
	bl fxStarfieldDownOn						@ Turn on starfield
	bl updateLargeShip
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initLargeShipFly					@ Callback function address

	bl startTimer

	bl fxFadeIn
	
	ldmfd sp!, {r0-r3, pc} 					@ restore registers and return
	
	@---------------------------------
	
initWindow:

	stmfd sp!, {r0-r1, lr}

	ldr r0, =REG_DISPCNT
	ldr r1, [r0]
	orr r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB
	ldr r1, [r0]
	orr r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
	ldr r0, =WIN_IN								@ Make bgs appear inside the window
	ldr r1, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r1, [r0]
	
	ldr r0, =SUB_WIN_IN							@ Make bgs appear inside the window
	ldr r1, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r1, [r0]
	
	ldr r0, =WIN_OUT							@ Make bgs appear inside the window
	ldr r1, =(WIN0_BG0 | WIN0_BG2 | WIN0_BG3 | WIN0_BLENDS)
	strh r1, [r0]
	
	ldr r0, =SUB_WIN_OUT						@ Make bgs appear inside the window
	ldr r1, =(WIN0_BG0 | WIN0_BG2 | WIN0_BG3 | WIN0_BLENDS)
	strh r1, [r0]
	
	ldr r0, =WIN0_Y0							@ Top pos
	ldr r1, =0
	strb r1, [r0]
	
	ldr r0, =WIN0_Y1							@ Bottom pos
	ldr r1, =192
	strb r1, [r0]
	
	ldr r0, =SUB_WIN0_Y0						@ Top pos
	ldr r1, =0
	strb r1, [r0]
	
	ldr r0, =SUB_WIN0_Y1						@ Bottom pos
	ldr r1, =192
	strb r1, [r0]
	
	ldr r0, =WIN0_X0							@ Left pos
	ldr r1, =0
	strb r1, [r0]
	
	ldr r0, =WIN0_X1							@ Right pos
	ldr r1, =255
	strb r1, [r0]
	
	ldr r0, =SUB_WIN0_X0						@ Left pos
	ldr r1, =0
	strb r1, [r0]
	
	ldr r0, =SUB_WIN0_X1						@ Right pos
	ldr r1, =255
	strb r1, [r0]
	
	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------
	
resetWindow:

	stmfd sp!, {r0-r1, lr}

	ldr r0, =WIN0_Y0							@ Top pos
	ldr r1, =0
	strb r1, [r0]
	
	ldr r0, =WIN0_Y1							@ Bottom pos
	ldr r1, =192
	strb r1, [r0]
	
	ldr r0, =SUB_WIN0_Y0						@ Top pos
	ldr r1, =0
	strb r1, [r0]
	
	ldr r0, =SUB_WIN0_Y1						@ Bottom pos
	ldr r1, =192
	strb r1, [r0]

	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
clearWindow:

	stmfd sp!, {r0-r1, lr}

	ldr r0, =REG_DISPCNT
	ldr r1, [r0]
	bic r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB
	ldr r1, [r0]
	bic r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
	ldr r0, =WIN_IN							@ Make bg's appear inside the window
	ldr r1, =0
	strh r1, [r0]
	
	ldr r0, =SUB_WIN_IN						@ Make bg's appear inside the window
	ldr r1, =0
	strh r1, [r0]

	ldmfd sp!, {r0-r1, pc}
	
	@ ---------------------------------------
	
initLargeShipFly:

	stmfd sp!, {r0-r2, lr}

	ldr r0, =endOfGameMode
	ldr r1, =MODE_LARGESHIP_FLY
	str r1, [r0]
	
	bl fxCopperTextOff
	bl clearBG0
	
	bl DC_FlushAll
	
	ldr r0, =LargeShipTiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =LargeShipTilesLen
	bl dmaCopy
	
	ldr r0, =LargeShipMap
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =LargeShipMapLen
	bl dmaCopy
	
	bl updateLargeShipFly
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initSmallShipFly					@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@---------------------------------
	
initSmallShipFly:

	stmfd sp!, {r0-r3, lr}

	ldr r0, =endOfGameMode
	ldr r1, =MODE_SMALLSHIP_FLY
	str r1, [r0]
	
	bl fxFadeBlackInit
	bl fxFadeMax
	
	ldr r0, =spriteIndex
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =spriteCount
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =spriteFrameCount
	ldr r1, =3
	str r1, [r0]
	
	ldr r0, =yOffset
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =WIN_OUT						@ Make bg's appear inside the window
	ldr r1, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_BLENDS)
	strh r1, [r0]
	
	ldr r0, =SUB_WIN_OUT					@ Make bg's appear inside the window
	ldr r1, =(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_BLENDS)
	strh r1, [r0]
	
	bl clearBG1
	bl resetWindow
	bl updateSmallShipFly
	
	@ Clear Sprites
	
	bl clearOAM									@ Reset all sprites
	
	@ Write the palette

	ldr r0, =WarShipPal
	ldr r1, =BG_PALETTE
	ldr r2, =WarShipPalLen
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	
	ldr r0, =WarShipTiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =WarShipTilesLen
	bl dmaCopy
	
	ldr r0, =WarShipMap
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =WarShipMapLen
	bl dmaCopy
	
	@ Load the palette into the palette subscreen area and main

	ldr r0, =SpritesPal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =SpritesPalLen
	bl dmaCopy
	ldr r1, =SPRITE_PALETTE_SUB
	bl dmaCopy

	@ Write the tile data to VRAM

	ldr r0, =SpritesTiles
	ldr r1, =SPRITE_GFX
	ldr r2, =SpritesTilesLen
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
	bl dmaCopy
	
	ldr r0, =4000								@ 2 seconds
	ldr r1, =initSmallShipLanded				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r3, pc} 					@ restore registers and return
	
	@---------------------------------
	
initSmallShipLanded:

	stmfd sp!, {r0-r1, lr}

	ldr r0, =endOfGameMode
	ldr r1, =MODE_SMALLSHIP_LANDED
	str r1, [r0]
	
	bl updateSmallShipLanded
	
	ldr r0, =2000								@ 2 seconds
	ldr r1, =initMotherShipFly					@ Callback function address
	
	bl startTimer

	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------
	
initMotherShipFly:

	stmfd sp!, {r0-r1, lr}

	ldr r0, =endOfGameMode
	ldr r1, =MODE_MOTHERSHIP_FLY
	str r1, [r0]
	
	ldr r0, =WIN_OUT						@ Make bg's appear inside the window
	ldr r1, =(WIN0_BG0 | WIN0_BG2 | WIN0_BG3 | WIN0_BLENDS)
	strh r1, [r0]
	
	ldr r0, =SUB_WIN_OUT					@ Make bg's appear inside the window
	ldr r1, =(WIN0_BG0 | WIN0_BG2 | WIN0_BG3 | WIN0_BLENDS)
	strh r1, [r0]
	
	bl resetWindow
	bl updateMotherShipFly
	
	ldr r0, =3000								@ 1 seconds
	ldr r1, =initEndOfGame						@ Callback function address
	
	bl startTimer

	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------
	
initEndOfGame:

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =endOfGameMode
	ldr r1, =MODE_MOTHERSHIP_LEFT
	str r1, [r0]
	
	bl clearBG0
	bl clearBG1
	bl clearOAM
	bl clearWindow

	ldr r0, =gameOverText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =12									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =gameOverText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =12									@ y pos
	ldr r3, =0									@ Draw on main screen
	bl drawText
	
	ldr r0, =3000								@ 3 seconds
	ldr r1, =initGameOverFadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxCopperTextOn

	ldmfd sp!, {r0-r3, pc} 					@ restore registers and return
	
	@---------------------------------
	
initGameOverFadeOut:

	stmfd sp!, {r0-r1, lr}
	
	bl fxFadeBlackInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =showCredits
	str r1, [r0]
	
	bl fxFadeOut

	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateSpriteIndex:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =spriteCount
	ldr r1, [r0]
	cmp r1, #SPRITE_FRAME_TIME
	moveq r1, #0
	add r1, #1
	str r1, [r0]
	bne updateSpriteIndexDone
	
	ldr r0, =spriteIndex
	ldr r1, [r0]
	ldr r2, =spriteFrameCount
	ldr r2, [r2]
	add r1, #1
	cmp r1, r2
	moveq r1, #0
	str r1, [r0]
	
updateSpriteIndexDone:
	
	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateSpriteMain:

	stmfd sp!, {r0-r4, lr}
	
	ldr r0, =OBJ_ATTRIBUTE0(0)					@ Attrib 0
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)	@ Attrib 0 settings
	ldr r2, =vOfs								@ Load REG_BG1VOFS address
	ldr r3, [r2]								@ Load VBLANK counter value
	rsb r3, r3, #0								@ Make it negative
	add r3, #160								@ Add the Y offset
	and r3, #0xFF								@ And with 0xFF so no overflow
	orr r1, r3									@ Orr in Y offset with settings
	strh r1, [r0]								@ Write to attrib 0
	
	ldr r0, =OBJ_ATTRIBUTE1(0)					@ Attrib 1
	ldr r1, =(ATTR1_SIZE_32)					@ Attrib 1 settings
	ldr r2, =hOfs								@ Load REG_BG1HOFS address
	ldr r3, [r2]								@ Load VBLANK counter value
	rsb r3, r3, #0								@ Make it negative
	add r3, #112								@ Add the X offset
	ldr r4, =0x1FF								@ Load 0x1FF
	and r3, r4									@ And with 0x1FF so no overflow
	orr r1, r3									@ Orr in X offset with settings
	strh r1, [r0]								@ Write to attrib 1
	
	ldr r0, =OBJ_ATTRIBUTE2(0)					@ Attrib 2
	mov r1, #ATTR2_PRIORITY(0)					@ Set sprite priority
	ldr r2, =spriteIndex
	ldr r2, [r2]
	lsl r2, #4
	orr r1, r2
	strh r1, [r0]								@ Write Attrib 2
	
	ldmfd sp!, {r0-r4, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateSpriteSub:

	stmfd sp!, {r0-r4, lr}
	
	ldr r0, =OBJ_ATTRIBUTE0_SUB(0)				@ Attrib 0
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)	@ Attrib 0 settings
	ldr r2, =vOfs								@ Load REG_BG1VOFS address
	ldr r3, [r2]								@ Load VBLANK counter value
	add r3, #64
	rsb r3, r3, #0								@ Make it negative
	add r3, #160								@ Add the Y offset
	and r3, #0xFF								@ And with 0xFF so no overflow
	orr r1, r3									@ Orr in Y offset with settings
	strh r1, [r0]								@ Write to attrib 0
	
	ldr r0, =OBJ_ATTRIBUTE1_SUB(0)				@ Attrib 1
	ldr r1, =(ATTR1_SIZE_32)					@ Attrib 1 settings
	ldr r2, =hOfs								@ Load REG_BG1HOFS address
	ldr r3, [r2]								@ Load VBLANK counter value
	rsb r3, r3, #0								@ Make it negative
	add r3, #112								@ Add the X offset
	ldr r4, =0x1FF								@ Load 0x1FF
	and r3, r4									@ And with 0x1FF so no overflow
	orr r1, r3									@ Orr in X offset with settings
	strh r1, [r0]								@ Write to attrib 1
	
	ldr r0, =OBJ_ATTRIBUTE2_SUB(0)				@ Attrib 2
	mov r1, #ATTR2_PRIORITY(0)					@ Set sprite priority
	ldr r2, =spriteIndex
	ldr r2, [r2]
	lsl r2, #4
	orr r1, r2
	strh r1, [r0]								@ Write Attrib 2
	
	ldmfd sp!, {r0-r4, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateWindow:

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =yOffset
	ldr r1, [r0]
	add r1, #1
	str r1, [r0]
	
	ldr r2, =SUB_WIN0_Y0						@ Top pos
	ldr r3, =192
	sub r3, r1
	cmp r3, #0
	movle r3, #0
	strb r3, [r2]
	
	ldr r2, =WIN0_Y1							@ Bottom pos
	ldr r3, =192
	sub r3, r1
	cmp r3, #0
	movle r3, #0
	strb r3, [r2]
	
	ldr r0, =yOffset
	ldr r1, [r0]
	cmp r1, #256
	blt updateWindowDone
	
	ldr r2, =SUB_WIN0_Y1						@ Bottom pos
	ldr r3, =256+192
	sub r3, r1
	cmp r3, #0
	movle r3, #0
	strb r3, [r2]
	
updateWindowDone:
	
	ldmfd sp!, {r0-r3, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateShipMoveMain:

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =REG_BG1HOFS
	ldr r1, =COS_bin							@ Load COS address
	ldr r2, =vblCounterH						@ Load VBLANK counter address
	ldr r2, [r2]								@ Load VBLANK counter value
	ldr r3, =0x1FF								@ Load 0x1FF (511)
	and r2, r3									@ And VBLANK counter with 511
	lsl r2, #1									@ Multiply * 2 (16 bit COS values)
	add r1, r2									@ Add the offset to the COS table
	ldrsh r2, [r1]								@ Read the COS table value (signed 16-bit value)
	lsr r2, #8									@ Right shift COS value to make it smaller
	strh r2, [r0]
	ldr r3, =hOfs
	str r2, [r3]

	@ not sure this works :( (remove if you want)

	lsr r2, #4
	cmp r2, #0
	bne starsTurnRight
	ldr r0, =starDirection
	ldr r1, [r0]
	add r1, #2
	str r1, [r0]
	b starTurnDone

starsTurnRight:
	ldr r0, =starDirection
	ldr r1, [r0]
	sub r1, #2
	str r1, [r0]
	b starTurnDone

starTurnDone:

	ldr r0, =REG_BG1VOFS
	ldr r1, =SIN_bin							@ Load SIN address
	ldr r2, =vblCounterV						@ Load VBLANK counter address
	ldr r2, [r2]								@ Load VBLANK counter value	
	ldr r3, =0x1FF								@ Load 0x1FF (511)
	and r2, r3									@ And VBLANK counter with 511
	lsl r2, #1									@ Multiply * 2 (16 bit SIN values)
	add r1, r2									@ Add the offset to the SIN table
	ldrsh r2, [r1]								@ Read the SIN table value (signed 16-bit value)
	lsr r2, #10									@ Right shift SIN value to make it smaller	

	ldr r3, =yOffset
	ldr r3, [r3]
	add r2, r3

	strh r2, [r0]								@ Write to attrib 0

	ldr r3, =vOfs
	str r2, [r3]
	
	ldmfd sp!, {r0-r3, pc} 					@ restore registers and return

	@---------------------------------
	
updateShipMoveSub:

	stmfd sp!, {r0-r4, lr}
	
	ldr r0, =REG_BG1HOFS_SUB
	ldr r1, =COS_bin							@ Load COS address
	ldr r2, =vblCounterH						@ Load VBLANK counter address
	ldr r2, [r2]								@ Load VBLANK counter value
	ldr r4, =0x1FF								@ Load 0x1FF (511)
	and r2, r4									@ And VBLANK counter with 511
	lsl r2, #1									@ Multiply * 2 (16 bit COS values)
	add r1, r2									@ Add the offset to the COS table
	ldrsh r2, [r1]								@ Read the COS table value (signed 16-bit value)
	lsr r2, #8									@ Right shift COS value to make it smaller
	strh r2, [r0]
	
	ldr r0, =REG_BG1VOFS_SUB
	ldr r1, =SIN_bin							@ Load SIN address
	ldr r2, =vblCounterV						@ Load VBLANK counter address
	ldr r2, [r2]								@ Load VBLANK counter value	
	ldr r3, =0x1FF								@ Load 0x1FF (511)
	and r2, r3									@ And VBLANK counter with 511
	lsl r2, #1									@ Multiply * 2 (16 bit SIN values)
	add r1, r2									@ Add the offset to the SIN table
	ldrsh r2, [r1]								@ Read the SIN table value (signed 16-bit value)
	lsr r2, #10									@ Right shift SIN value to make it smaller
	
	ldr r3, =endOfGameMode
	ldr r3, [r3]
	cmp r3, #MODE_SMALLSHIP_FLY
	beq updateShipMoveSubDone
	cmp r3, #MODE_SMALLSHIP_LANDED
	beq updateShipMoveSubDone
	
	ldr r3, =yOffset
	ldr r3, [r3]
	add r2, r3
	
	ldr r3, =endOfGameMode
	ldr r3, [r3]
	cmp r3, #MODE_MOTHERSHIP_FLY
	beq updateShipMoveSubDone
	
	add r2, #64
	
updateShipMoveSubDone:
	
	strh r2, [r0]								@ Write to attrib 0

	ldmfd sp!, {r0-r4, pc} 					@ restore registers and return

	@---------------------------------
	
updateLargeShip:

	stmfd sp!, {lr}
	
	bl scrollSBMain
	bl scrollSBSub
	bl updateShipMoveMain
	bl updateSpriteIndex
	bl updateSpriteMain
	
	ldmfd sp!, {pc} 						@ restore registers and return

	@---------------------------------
	
updateLargeShipFly:

	stmfd sp!, {lr}
	
	bl scrollSBMain
	bl scrollSBSub
	bl updateShipMoveMain
	bl updateShipMoveSub
	bl updateSpriteIndex
	bl updateSpriteMain
	bl updateSpriteSub
	bl updateWindow

	ldmfd sp!, {pc} 						@ restore registers and return

	@---------------------------------

updateSmallShipFly:

	stmfd sp!, {lr}
	
	bl scrollSBMain
	bl scrollSBSub
	bl updateShipMoveMain
	bl updateShipMoveSub
	bl updateSpriteIndex
	bl updateSpriteMain
	bl updateSpriteSub
	bl updateWindow
	
	ldmfd sp!, {pc} 						@ restore registers and return

	@---------------------------------
	
updateSmallShipLanded:

	stmfd sp!, {r0-r1, lr}
	
	bl scrollSBMain
	bl scrollSBSub
	bl updateShipMoveMain
	bl updateShipMoveSub
	bl updateSpriteIndex
	bl updateSpriteMain
	bl updateSpriteSub
	
	ldr r0, =yOffset
	ldr r1, [r0]
	sub r1, #1
	cmp r1, #256
	movlt r1, #256
	str r1, [r0]

	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return

	@---------------------------------
	
updateMotherShipFly:

	stmfd sp!, {lr}
	
	bl scrollSBMain
	bl scrollSBSub
	bl updateShipMoveMain
	bl updateShipMoveSub
	bl updateSpriteIndex
	bl updateSpriteMain
	bl updateSpriteSub
	bl updateWindow

	ldmfd sp!, {pc} 						@ restore registers and return

	@---------------------------------
	
updateMotherShipLeft:

	stmfd sp!, {lr}
	
	bl scrollSBMain
	bl scrollSBSub
	bl updateShipMoveMain
	bl updateShipMoveSub

	ldmfd sp!, {pc} 						@ restore registers and return

	@---------------------------------
	
updateEndOfGame:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =endOfGameMode
	ldr r1, [r0]
	
	cmp r1, #MODE_LARGESHIP
	bleq updateLargeShip
	cmp r1, #MODE_LARGESHIP_FLY
	bleq updateLargeShipFly
	cmp r1, #MODE_SMALLSHIP_FLY
	bleq updateSmallShipFly
	cmp r1, #MODE_SMALLSHIP_LANDED
	bleq updateSmallShipLanded
	cmp r1, #MODE_MOTHERSHIP_FLY
	bleq updateMotherShipFly
	cmp r1, #MODE_MOTHERSHIP_LEFT
	bleq updateMotherShipLeft
	
	ldr r0, =vblCounterH
	ldr r1, [r0]
	add r1, #4
	str r1, [r0]
	
	ldr r0, =vblCounterV
	ldr r1, [r0]
	add r1, #2
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return

	@---------------------------------

	.data
	.align
	
	.align
spriteIndex:
	.word 0
	
	.align
spriteFrameCount:
	.word 0
	
	.align
spriteCount:
	.word 0
	
	.align
hOfs:
	.word 0
	
	.align
vOfs:
	.word 0
	
	.align
vblCounterH:
	.word 0
	
	.align
vblCounterV:
	.word 1
	
	.align
yOffset:
	.word 0
	
	.align
endOfGameMode:
	.word 0
	
	.align
gameCompleteText:
	.asciz "GAME COMPLETE!"
	
	.align
finalScoreText:
	.asciz "FINAL SCORE:"
	
	.align
gameOverText:
	.asciz "GAME OVER!"
	
	.align
wellDoneText:
	.asciz "WELL DONE!"
	
	.align
mentalModeUnlockedText:
	.asciz "MENTAL MODE IS NOW UNLOCKED!"
	
	.align
warhawkEliteText:
	.asciz "YOU ARE THE WARHAWK ELITE!"

	.pool
	.end
