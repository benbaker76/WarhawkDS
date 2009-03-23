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
	.global initTitleScreen
	.global showTitleScreen
	.global updateTitleScreen
	.global drawCreditText

initTitleScreen:

	stmfd sp!, {r0-r6, lr}
	
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
	
	bl drawSFMapScreenMain
	bl drawSFMapScreenSub
	bl drawSBMapScreenMain
	bl drawSBMapScreenSub
	
	bl showTitleScreen
	
	bl fxSpotlightIn
	
	bl fxColorTextOn
	
	ldr r0, =titleRawText						@ Read the path to the file
	bl playAudioStream							@ Play the audio stream
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
showTitleScreen:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_CREDITS
	str r1, [r0]

	bl drawCreditText
	
	ldr r0, =15									@ 15 seconds
	ldr r1, =timerDoneCredits					@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawCreditText:

	stmfd sp!, {r0-r6, lr}
	
	bl clearBG0

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

updateTitleScreen:

	stmfd sp!, {r0-r6, lr}
	
	ldr r1, =REG_KEYINPUT
	ldr r2, [r1]
	ldr r3, =gameMode
	ldr r4, =GAMEMODE_RUNNING
	tst r2, #BUTTON_START
	streq r4, [r3]
	bleq fxColorTextOff
	bleq stopTimer
	bleq initData								@ setup actual game data
	bleq initLevel
	
	bl scrollStarsHoriz
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------

timerDoneCredits:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_HISCORE
	str r1, [r0]
	bl showHiScore
	
	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------

	.data
	.align
	
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