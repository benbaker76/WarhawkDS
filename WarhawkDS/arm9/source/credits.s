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

	.arm
	.align
	.text
	.global showCredits
	.global updateCredits
	
showCredits:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode							@ Get gameMode address
	ldr r1, =GAMEMODE_CREDITS					@ Set the gameMode to credits
	str r1, [r0]								@ Store back gameMode

	bl fxOff
	bl fxFadeBlackInit
	bl fxFadeMax
	bl stopSound
	bl stopAudioStream
	bl initMainTiles							@ Initialize main tiles
	bl resetScrollRegisters						@ Reset scroll registers
	bl clearBG0									@ Clear bg's
	bl clearBG1
	bl clearBG2
	bl clearBG3
	
	bl initVideoBG1_16
	bl initStarData
	bl clearBG0
	
	@ Write the palette

	ldr r0, =FontPal
	ldr r1, =BG_PALETTE
	ldr r2, =FontPalLen
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]

	@ Sprites
	
	@ Clear Sprites
	
	bl clearOAM									@ Reset all sprites

	ldr r0, =hiScoreRawText			 			@ Read the path to the file
	bl playAudioStream							@ Play the audio stream

	bl fxCopperTextOn							@ Turn on copper text fx
@	bl fxStarfieldDownOn						@ Turn on starfield
	bl fxStarburstOn							@ Turn on starburst
	bl fxVertTextScrollerOn						@ Turn on vert text scroller
	bl fxSineWobbleOn
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits01					@ Callback function address

	bl startTimer
	
	ldr r0, =colorPal2
	ldr r1, =colorPalMain
	ldr r2, =(256 * 2)
	bl dmaCopy
	
	ldr r0, =colorNoScrollMain
	mov r1, #1
	str r1, [r0]

	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
initCredits01:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	bl fxFadeMax

	@ Write the tile data
	
	ldr r0 ,=Credits01Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =Credits01TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =Credits01Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =Credits01MapLen
	bl dmaCopy
	
	@ Draw text
	
	ldr r0, =c64LoadingText						@ Load out text pointer
	ldr r1, =0									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits01FadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits01FadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =initCredits02
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

initCredits02:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	bl fxFadeMax
	
	@ Write the tile data
	
	ldr r0 ,=Credits02Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =Credits02TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =Credits02Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =Credits02MapLen
	bl dmaCopy
	
	@ Draw text
	
	ldr r0, =c64TitleText						@ Load out text pointer
	ldr r1, =0									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits02FadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits02FadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =initCredits03
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

initCredits03:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	bl fxFadeMax
	
	@ Write the tile data
	
	ldr r0 ,=Credits03Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =Credits03TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =Credits03Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =Credits03MapLen
	bl dmaCopy
	
	@ Draw text
	
	ldr r0, =c64GameText						@ Load out text pointer
	ldr r1, =0									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits03FadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits03FadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =initCredits04
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits04:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	bl fxFadeMax
	
	@ Write the tile data
	
	ldr r0 ,=Credits04Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =Credits04TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =Credits04Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =Credits04MapLen
	bl dmaCopy
	
	@ Draw text
	
	ldr r0, =xlTitleText						@ Load out text pointer
	ldr r1, =0									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits04FadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits04FadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =initCredits05
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

initCredits05:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	bl fxFadeMax
	
	@ Write the tile data
	
	ldr r0 ,=Credits05Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =Credits05TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =Credits05Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =Credits05MapLen
	bl dmaCopy
	
	@ Draw text
	
	ldr r0, =xlGameText							@ Load out text pointer
	ldr r1, =0									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits05FadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits05FadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =initCredits06
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

initCredits06:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	bl fxFadeMax
	
	@ Write the tile data
	
	ldr r0 ,=Credits06Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =Credits06TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =Credits06Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =Credits06MapLen
	bl dmaCopy
	
	@ Draw text
	
	ldr r0, =cpcTitleText						@ Load out text pointer
	ldr r1, =0									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits06FadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits06FadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =initCredits07
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

initCredits07:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	bl fxFadeMax
	
	@ Write the tile data
	
	ldr r0 ,=Credits07Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =Credits07TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =Credits07Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =Credits07MapLen
	bl dmaCopy
	
	@ Draw text
	
	ldr r0, =cpcGameText						@ Load out text pointer
	ldr r1, =0									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits07FadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits07FadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =initCredits08
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

initCredits08:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	bl fxFadeMax
	
	@ Write the tile data
	
	ldr r0 ,=Credits08Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =Credits08TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =Credits08Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =Credits08MapLen
	bl dmaCopy
	
	@ Draw text
	
	ldr r0, =stLoadingText						@ Load out text pointer
	ldr r1, =0									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits08FadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits08FadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =initCredits09
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

initCredits09:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	bl fxFadeMax
	
	@ Write the tile data
	
	ldr r0 ,=Credits09Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =Credits09TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =Credits09Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =Credits09MapLen
	bl dmaCopy
	
	@ Draw text
	
	ldr r0, =stTitleText						@ Load out text pointer
	ldr r1, =0									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits09FadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits09FadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =initCredits10
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------

initCredits10:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	bl fxFadeMax
	
	@ Write the tile data
	
	ldr r0 ,=Credits10Tiles
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =Credits10TilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =Credits10Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =Credits10MapLen
	bl dmaCopy
	
	@ Draw text
	
	ldr r0, =stGameText							@ Load out text pointer
	ldr r1, =0									@ x pos
	ldr r2, =22									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =5000								@ 5 seconds
	ldr r1, =initCredits10FadeOut				@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
initCredits10FadeOut:

	stmfd sp!, {r0-r6, lr}
	
	bl fxFadeBG0SubBG1SubInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =initCredits01
	str r1, [r0]
	
	bl fxFadeOut
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
updateCredits:

	stmfd sp!, {r0-r6, lr}
	
	bl scrollSBMain
	bl scrollSBSub
	
	ldr r0, =REG_KEYINPUT						@ Read Key Input
	ldr r1, [r0]
	tst r1, #BUTTON_A							@ Start button pressed?
	bleq showTitleScreen
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return

	@---------------------------------
	
	.data
	.align
	
	.align
	
blankText:
	.asciz "                                "
	
	.align
c64LoadingText:
	.asciz "       C64 LOADING SCREEN       "
	
	.align
c64TitleText:
	.asciz "        C64 TITLE SCREEN        "
	
	.align
c64GameText:
	.asciz "        C64 GAME SCREEN         "

	.align
xlTitleText:
	.asciz "        XL TITLE SCREEN         "
	
	.align
xlGameText:
	.asciz "         XL GAME SCREEN         "
	
	.align
cpcTitleText:
	.asciz "        CPC TITLE SCREEN        "
	
	.align
cpcGameText:
	.asciz "        CPC GAME SCREEN         "
	
	.align
stLoadingText:
	.asciz "       ST LOADING SCREEN        "
	
	.align
stTitleText:
	.asciz "        ST TITLE SCREEN         "
	
	.align
stGameText:
	.asciz "        ST GAME SCREEN          "

	.pool
	.end
