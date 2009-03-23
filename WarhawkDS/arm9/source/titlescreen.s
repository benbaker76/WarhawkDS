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
	.global initTitleScreen
	.global showCredits
	.global updateTitleScreen
	.global updateLogoSprites
	.global drawCreditText

initTitleScreen:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_TITLESCREEN
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
	
	bl resetSprites
	
	@ Load the palette into the palette subscreen area and main

	ldr r0, =SpritePal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =512
	bl dmaCopy

	@ Write the tile data to VRAM

	ldr r0, =LogoSpritesTiles
	ldr r1, =SPRITE_GFX
	ldr r2, =LogoSpritesTilesLen
	bl dmaCopy
	
	ldr r0, =StartSpritesTiles
	ldr r1, =SPRITE_GFX
	add r1, #LogoSpritesTilesLen
	ldr r2, =StartSpritesTilesLen
	bl dmaCopy
	
	bl drawSFMapScreenMain
	bl drawSFMapScreenSub
	bl drawSBMapScreenMain
	bl drawSBMapScreenSub
	
	bl showCredits
	
	bl fxCopperTextOn
	
	bl drawStartSprites
	
	bl fxSpotlightIn
	
	ldr r0, =titleRawText						@ Read the path to the file
	bl playAudioStream							@ Play the audio stream
	
	ldr r0, =2									@ 15 seconds
	ldr r1, =showTextScroller					@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
showTextScroller:

	stmfd sp!, {r0-r6, lr}
	
	bl stopTimer
	bl fxTextScrollerOn
	
	ldr r0, =15									@ 15 seconds
	ldr r1, =showCredits						@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
showCredits:

	stmfd sp!, {r0-r6, lr}
	
	bl drawCreditText
	
	ldr r0, =15									@ 15 seconds
	ldr r1, =showHiScore						@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawCreditText:

	stmfd sp!, {r0-r6, lr}
	
	bl clearBG0Sub

	ldr r0, =proteusDevelopmentsText			@ Load out text pointer
	ldr r1, =3									@ x pos
	ldr r2, =10									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =asmCodingText						@ Load out text pointer
	ldr r1, =9									@ x pos
	ldr r2, =12									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =flashAndHeadKazeText				@ Load out text pointer
	ldr r1, =7									@ x pos
	ldr r2, =13									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =graffixText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =15									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =badToadAndLoboText					@ Load out text pointer
	ldr r1, =8									@ x pos
	ldr r2, =16									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =musixText							@ Load out text pointer
	ldr r1, =12									@ x pos
	ldr r2, =18									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =someoneText						@ Load out text pointer
	ldr r1, =15									@ x pos
	ldr r2, =19									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =aRetroBytesPortalProductionText	@ Load out text pointer
	ldr r1, =1									@ x pos
	ldr r2, =21									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawStartSprites:

	stmfd sp!, {r0-r6, lr}
	
	mov r4, #0
	
drawStartSpritesLoop:
	
	ldr r0, =OBJ_ATTRIBUTE0(0)
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)
	add r0, r4, lsl #3
	mov r2, #7
	add r0, r2, lsl #3
	mov r5, #148
	and r5, #0xFF
	orr r1, r5
	strh r1, [r0]
	
	ldr r0, =OBJ_ATTRIBUTE1(0)
	ldr r1, =(ATTR1_SIZE_16)
	add r0, r4, lsl #3
	mov r2, #7
	add r0, r2, lsl #3
	mov r5, #80
	add r5, r4, lsl #4
	ldr r6, =0x1FF
	and r5, r6
	orr r1, r5
	strh r1, [r0]
	
	ldr r0, =OBJ_ATTRIBUTE2(0)
	add r0, r4, lsl #3
	mov r2, #7
	mov r3, #ATTR2_PRIORITY(0)
	add r0, r2, lsl #3
	mov r1, r4, lsl #2
	add r1, r2, lsl #4
	orr r1, r3
	strh r1, [r0]
	
	add r4, #1
	cmp r4, #6
	bne drawStartSpritesLoop
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateStartSprites:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =SPRITE_PALETTE
	ldr r1, =FONT_COLOR_OFFSET
	add r0, r1, lsl #1
	ldr r2, =pulseValue
	ldr r3, [r2]
	
	ldr r4, =pulseDirection
	ldr r5, [r4]
	cmp r5, #0
	bne updateStartSpritesBackward
	
	add r3, #1
	cmp r3, #0x1F
	moveq r5, #1
	str r3, [r2]
	str r5, [r4]
	strh r3, [r0]	
	b updateStartSpritesDone
	
updateStartSpritesBackward:

	sub r3, #1
	cmp r3, #0
	moveq r5, #0
	str r3, [r2]
	str r5, [r4]
	strh r3, [r0]
	
updateStartSpritesDone:
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
	
updateLogoSprites:

	stmfd sp!, {r0-r6, lr}
	
	mov r4, #0
	
updateLogoSpritesLoop:
	
	ldr r0, =OBJ_ATTRIBUTE0(0)
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)
	add r0, r4, lsl #3
	ldr r3, =SIN_bin
	ldr r5, =vblCounter
	ldr r5, [r5]
	add r5, r4, lsl #5
	ldr r6, =0x1FF
	and r5, r6
	lsl r5, #1
	add r3, r5
	ldrsh r5, [r3]
	lsr r5, #6
	add r5, #64
	and r5, #0xFF
	orr r1, r5
	strh r1, [r0]
	
	ldr r0, =OBJ_ATTRIBUTE1(0)
	ldr r1, =(ATTR1_SIZE_32)
	add r0, r4, lsl #3
	ldr r3, =SIN_bin
	ldr r5, =vblCounter
	ldr r5, [r5]
	add r5, r4, lsl #5
	ldr r6, =0x1FF
	and r5, r6
	lsl r5, #1
	add r3, r5
	ldrsh r5, [r3]
	lsr r5, #6
	add r5, #16
	add r5, r4, lsl #5
	ldr r6, =0x1FF
	and r5, r6
	orr r1, r5
	strh r1, [r0]
	
	ldr r0, =OBJ_ATTRIBUTE2(0)
	add r0, r4, lsl #3
	mov r1, r4, lsl #4
	mov r3, #ATTR2_PRIORITY(1)
	orr r1, r3
	strh r1, [r0]
	
	add r4, #1
	cmp r4, #7
	bne updateLogoSpritesLoop
	
	ldr r0, =vblCounter
	ldr r1, [r0]
	add r1, #2
	str r1, [r0]
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------

updateTitleScreen:

	stmfd sp!, {r0-r6, lr}
	
	bl scrollStarsHoriz
	bl updateLogoSprites
	bl updateStartSprites
	
	ldr r1, =REG_KEYINPUT
	ldr r2, [r1]
	ldr r3, =gameMode
	ldr r4, =GAMEMODE_RUNNING
	tst r2, #BUTTON_A
	streq r4, [r3]
	bleq fxSpotlightOff
	bleq fxTextScrollerOff
	bleq fxCopperTextOff
	bleq stopTimer
	bleq initData								@ setup actual game data
	bleq initLevel
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------

	.data
	.align
	
vblCounter:
	.word 0

pulseValue:
	.word 0
	
pulseDirection:
	.word 0
	
proteusDevelopmentsText:
	.asciz "@2009 PROTEUS DEVELOPMENTS"

asmCodingText:
	.asciz "- ASM CODING -"

flashAndHeadKazeText:
	.asciz "FLASH AND HEADKAZE"
	
graffixText:
	.asciz "- GRAFFIX -"
	
badToadAndLoboText:
	.asciz "LOBO AND BADTOAD"
	
musixText:
	.asciz "- MUSIX -"
	
someoneText:
	.asciz "???"

aRetroBytesPortalProductionText:
	.asciz "A RETROBYTES PORTAL PRODUCTION"
	
	.pool
	.end