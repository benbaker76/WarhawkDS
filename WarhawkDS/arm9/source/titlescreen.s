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
	.global showTitleScreen
	.global showCredits
	.global updateTitleScreen
	.global drawCreditText

showTitleScreen:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode							@ Set game mode
	ldr r1, =GAMEMODE_TITLESCREEN
	str r1, [r0]
	
	ldr r0, =fxMode								@ Get fxMode address
	ldr r1, =FX_NONE							@ Get fxMode value
	str r1, [r0]
	
	bl initCheat
	bl initMainTiles							@ Initialize main tiles
	bl resetScrollRegisters						@ Reset the scroll registers
	bl clearBG0									@ Clear bgs
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
	
	ldr r0 ,=TitleTopTiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =TitleTopTilesLen
	bl dmaCopy

	ldr r0, =TitleBottomTiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =TitleBottomTilesLen
	bl dmaCopy
	
	@ Write map
	
	ldr r0, =TitleTopMap
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =TitleTopMapLen
	bl dmaCopy

	ldr r0, =TitleBottomMap
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =TitleBottomMapLen
	bl dmaCopy
	
	@ Sprites
	
	bl clearOAM
	
	@ Load the palette into the palette subscreen area and main

	ldr r0, =SpritePal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =512
	bl dmaCopy

	@ Write the tile data to VRAM
	
	ldr r0, =StartSpritesTiles
	ldr r1, =SPRITE_GFX
	add r1, #LogoSpritesTilesLen
	ldr r2, =StartSpritesTilesLen
	bl dmaCopy
	
	bl drawSFMapScreenMain
	bl drawSFMapScreenSub
	bl drawSBMapScreenMain
	bl drawSBMapScreenSub
	
	bl drawCreditText
	
	bl initLogoSprites
	@bl drawStartSprites
	
	ldr r0, =ppotRawText						@ Read the path to the file
	bl playAudioStream							@ Play the audio stream
	
	bl fxColorPulseOn
	bl fxCopperTextOn
	bl fxSpotlightIn	
	bl fxFadeBlackIn
	
	ldr r0, =2000								@ 2 seconds
	ldr r1, =showTextScroller					@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
showTextScroller:

	stmfd sp!, {r0-r6, lr}
	
	bl fxTextScrollerOn
	
	ldr r0, =15000								@ 15 seconds
	ldr r1, =showCredits						@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
showCredits:

	stmfd sp!, {r0-r6, lr}
	
	bl drawCreditText
	
	ldr r0, =15000								@ 15 seconds
	ldr r1, =showHiScore						@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawCreditText:

	stmfd sp!, {r0-r6, lr}
	
	bl clearBG0Sub

	ldr r0, =proteusDevelopmentsText			@ Load out text pointer
	ldr r1, =3									@ x pos
	ldr r2, =7									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =andHeadSoftText					@ Load out text pointer
	ldr r1, =10									@ x pos
	ldr r2, =8									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =asmCodingText						@ Load out text pointer
	ldr r1, =9									@ x pos
	ldr r2, =11									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =flashAndHeadKazeText				@ Load out text pointer
	ldr r1, =7									@ x pos
	ldr r2, =12									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =graffixText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =14									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =badToadAndLoboText					@ Load out text pointer
	ldr r1, =8									@ x pos
	ldr r2, =15									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =musixText							@ Load out text pointer
	ldr r1, =12									@ x pos
	ldr r2, =17									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =PPOTText							@ Load out text pointer
	ldr r1, =7									@ x pos
	ldr r2, =18									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText

	ldr r0, =spaceFractalText					@ Load out text pointer
	ldr r1, =10									@ x pos
	ldr r2, =19									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =aRetroBytesPortalProductionText	@ Load out text pointer
	ldr r1, =1									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawStartSprites:

	stmfd sp!, {r0-r6, lr}
	
	mov r4, #0									@ Reset iterator
	
drawStartSpritesLoop:
	
	ldr r0, =OBJ_ATTRIBUTE0(0)					@ Attrib 0
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)	@ Attrib 0 settings
	add r0, r4, lsl #3							@ Iterator * 8 (OBJ_ATTRIBUTE0(n))
	mov r2, #7									@ Skip 7 sprites (Logo Sprites)
	add r0, r2, lsl #3							@ Add offset
	mov r5, #160								@ Y Position 160
	and r5, #0xFF								@ And 0xFF
	orr r1, r5									@ Or in the Y Position
	strh r1, [r0]								@ Write back attrib 0
	
	ldr r0, =OBJ_ATTRIBUTE1(0)					@ Attrib 1
	ldr r1, =(ATTR1_SIZE_16)					@ Attrib 1 settings
	add r0, r4, lsl #3							@ Iterator * 8 (OBJ_ATTRIBUTE1(n))
	mov r2, #7									@ Skip 7 sprites (Logo Spites)
	add r0, r2, lsl #3							@ Add offset
	mov r5, #38									@ X Position
	add r5, r4, lsl #4							@ Each sprite * 16
	ldr r6, =0x1FF								@ Load 0x1FF
	and r5, r6									@ X Position And 0x1FF
	orr r1, r5									@ Or in X Position
	strh r1, [r0]								@ Write back to attrib 1
	
	ldr r0, =OBJ_ATTRIBUTE2(0)					@ Attrib 2
	add r0, r4, lsl #3							@ Iterator * 8 (OBJ_ATTRIBUTE2(n))
	mov r3, #ATTR2_PRIORITY(0)					@ Set sprite priority
	mov r2, #7									@ Skip 7 sprites (Logo Spites)
	add r0, r2, lsl #3							@ Calculate tile position (* 8)
	mov r1, r4, lsl #2							@ Iterator * 4
	add r1, r2, lsl #4							@ Add Tile position
	orr r1, r3									@ Orr in tile position
	strh r1, [r0]								@ Write back to attrib 2
	
	add r4, #1									@ Add 1 to Iterator
	cmp r4, #11									@ All sprites drawn?
	bne drawStartSpritesLoop					@ No so go back and loop
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateStartSprites:

	stmfd sp!, {r0-r6, lr}
	
	mov r4, #0									@ Reset iterator
	
updateStartSpritesLoop:
	
	ldr r0, =OBJ_ATTRIBUTE0(0)					@ Attrib 0
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)	@ Attrib 0 settings
	add r0, r4, lsl #3							@ Iterator * 8 (OBJ_ATTRIBUTE0(n))
	mov r2, #7									@ Skip 7 sprites (Logo Sprites)
	add r0, r2, lsl #3							@ Add offset
	ldr r3, =SIN_bin							@ Load SIN address
	ldr r5, =vblCounter							@ Load VBLANK counter address
	ldr r5, [r5]								@ Load VBLANK counter value
	add r5, r4, lsl #5							@ Add the iterator * 32
	ldr r6, =0x1FF								@ Load 0x1FF (511)
	and r5, r6									@ And VBLANK counter with 511
	lsl r5, #1									@ Multiply * 2 (16 bit SIN values)
	add r3, r5									@ Add the offset to the SIN table
	ldrsh r5, [r3]								@ Read the SIN table value (signed 16-bit value)
	lsr r5, #10									@ Right shift SIN value to make it smaller
	add r5, #160								@ Add the Y offset
	and r5, #0xFF								@ And with 0xFF so no overflow
	orr r1, r5									@ Orr in Y offset with settings
	strh r1, [r0]								@ Write to attrib 0
	
	ldr r0, =OBJ_ATTRIBUTE1(0)					@ Attrib 1
	ldr r1, =(ATTR1_SIZE_16)					@ Attrib 1 settings
	add r0, r4, lsl #3							@ Iterator * 8 (OBJ_ATTRIBUTE1(n))
	mov r2, #7									@ Skip 7 sprites (Logo Spites)
	add r0, r2, lsl #3							@ Add offset
	ldr r3, =COS_bin							@ Load COS address
	ldr r5, =vblCounter							@ Load VBLANK counter address
	ldr r5, [r5]								@ Load VBLANK counter value
	add r5, r4, lsl #5							@ Add the iterator * 32
	ldr r6, =0x1FF								@ Load 0x1FF (511)
	and r5, r6									@ And VBLANK counter with 511
	lsl r5, #1									@ Multiply * 2 (16 bit COS values)
	add r3, r5									@ Add the offset to the COS table
	ldrsh r5, [r3]								@ Read the COS table value (signed 16-bit value)
	lsr r5, #10									@ Right shift COS value to make it smaller
	add r5, #40									@ Add the X offset
	add r5, r4, lsl #4							@ Add Iterator * 16 to X Offset
	ldr r6, =0x1FF								@ Load 0x1FF
	and r5, r6									@ And with 0x1FF so no overflow
	orr r1, r5									@ Orr in X offset with settings
	strh r1, [r0]								@ Write to attrib 1
	
	ldr r0, =OBJ_ATTRIBUTE2(0)					@ Attrib 2
	add r0, r4, lsl #3							@ Iterator * 8 (OBJ_ATTRIBUTE2(n))
	mov r3, #ATTR2_PRIORITY(0)					@ Set sprite priority
	mov r2, #7									@ Skip 7 sprites (Logo Spites)
	add r0, r2, lsl #3							@ Calculate tile position (* 8)
	mov r1, r4, lsl #2							@ Iterator * 4
	add r1, r2, lsl #4							@ Add Tile position
	orr r1, r3									@ Or in settings
	strh r1, [r0]								@ Write to attrib 2
	
	add r4, #1									@ Add 1 to iterator
	cmp r4, #11									@ Drawn 10 sprites yet?
	bne updateStartSpritesLoop					@ No so loop
	
	@ ----- COUNTER -----
	
	ldr r0, =vblCounter							@ Load VBLANK counter
	ldr r1, [r0]								@ Load VBLANK value
	add r1, #4									@ Add 4 to VBLANK counter
	str r1, [r0]								@ Store back
	
	@ ----- PULSE -----
	
	ldr r0, =SPRITE_PALETTE						@ Load address to sprite palette
	ldr r1, =10									@ Color offset 10
	add r0, r1, lsl #1							@ Add offset * 2 (16 bit value)
	ldr r2, =pulseValue							@ Load pulseValue address
	ldr r3, [r2]								@ Load pulseValue value
	strh r3, [r0]								@ Write to palette
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------

updateTitleScreen:

	stmfd sp!, {r0-r6, lr}
	
	@ldr r1, =REG_KEYINPUT						@ Read Key Input
	@ldr r2, [r1]
	@tst r2, #BUTTON_A							@ Start button pressed?
	@bleq initTitleScreen
	
	bl scrollStarsHoriz							@ Scroll stars
	bl updateLogoSprites						@ Update logo sprites
	bl updateStartSprites						@ Update start sprites
	bl updateCheatCheck							@ check for cheat sequence
	
	ldr r1, =REG_KEYINPUT						@ Read Key Input
	ldr r2, [r1]
	tst r2, #BUTTON_START						@ Start button pressed?
	bleq fxColorPulseOff						@ Turn of color pulse effect
	bleq fxSpotlightOff							@ Turn off the spotlight effect
	bleq fxTextScrollerOff						@ Turn off the scroller effect
	bleq fxCopperTextOff						@ Turn off the copper text effect
	bleq stopTimer								@ Stop the timer
	bleq gameStart								@ Start the game
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

	.data
	.align
	
vblCounter:
	.word 0
	
	.align
proteusDevelopmentsText:
	.asciz "@2009 PROTEUS DEVELOPMENTS"
	
	.align
andHeadSoftText:
	.asciz "AND HEADSOFT"

	.align
asmCodingText:
	.asciz "- ASM CODING -"

	.align
flashAndHeadKazeText:
	.asciz "FLASH AND HEADKAZE"
	
	.align
graffixText:
	.asciz "- GRAFFIX -"
	
	.align
badToadAndLoboText:
	.asciz "LOBO AND BADTOAD"
	
	.align
musixText:
	.asciz "- MUSIX -"
	
	.align
PPOTText:
	.asciz "PRESS PLAY ON TAPE"
	
	.align
spaceFractalText:
	.asciz "SPACE FRACTAL"

	.align
aRetroBytesPortalProductionText:
	.asciz "A RETROBYTES PORTAL PRODUCTION"

	.pool
	.end