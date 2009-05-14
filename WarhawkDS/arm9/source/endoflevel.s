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

	#define BASES_DESTROYED_VALUE			5
	#define TOTAL_BASE_DESTRUCT_VALUE		7500
	#define LEVEL_COMPLETION_BONUS_VALUE	5000
	#define ENERGY_UNIT_VALUE				10

	.arm
	.align
	.text
	.global showEndOfLevel
	.global updateEndOfLevel
	
showEndOfLevel:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode							@ Get gameMode address
	ldr r1, =GAMEMODE_ENDOFLEVEL				@ Set the gameMode to end of level
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
	
	bl initStarData
	
	ldr r0, =levelCount
	ldr r1, =levelNum
	ldr r1, [r1]
	str r1, [r0]
	
	ldr r0, =basesLeft
	ldr r1, [r0]
	ldr r2, =baseCount
	ldr r3, [r2]
	ldr r4, =levelNum
	ldr r5, [r4]
	cmp r1, #0
	movne r3, #0
	moveq r3, r5
	str r3, [r2]
	
	@ Write the palette
	
	ldr r0, =FontPal
	ldr r1, =BG_PALETTE
	ldr r2, =32
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	strh r3, [r1]

	@ Write the tile data
	
	ldr r0 ,=OrbscapeTiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =OrbscapeTilesLen
	bl dmaCopy

	@ Write map
	
	ldr r0, =OrbscapeMap
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =OrbscapeMapLen
	bl dmaCopy
	
	bl clearOAM									@ Reset all sprites
	
	ldr r0, =SpritePal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =512
	bl dmaCopy
	
	@bl initLogoSprites
	
	ldr r0, =wellDoneText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =3									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =levelCompletedText					@ Load out text pointer
	ldr r1, =7									@ x pos
	ldr r2, =5									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =basesDestroyedText					@ Load out text pointer
	ldr r1, =8									@ x pos
	ldr r2, =8									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =basesDestroyedCalcText				@ Load out text pointer
	ldr r1, =7									@ x pos
	ldr r2, =10									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =totalBaseDestructText				@ Load out text pointer
	ldr r1, =6									@ x pos
	ldr r2, =13									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =totalBaseDestructCalcText			@ Load out text pointer
	ldr r1, =7									@ x pos
	ldr r2, =15									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =levelCompletionBonusText			@ Load out text pointer
	ldr r1, =5									@ x pos
	ldr r2, =18									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =levelCompletionBonusCalcText		@ Load out text pointer
	ldr r1, =7									@ x pos
	ldr r2, =20									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText


	ldr r4,=levelCount
	ldr r4,[r4]
	cmp r4,#1
	bne notLevel1
			ldr r0, =levelCompletionSuckerText5			@ Load out text pointer
			ldr r1, =4									@ x pos
			ldr r2, =6									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText

			ldr r0, =levelCompletionSuckerText6			@ Load out text pointer
			ldr r1, =3									@ x pos
			ldr r2, =8									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText	
	notLevel1:
	cmp r4,#2
	bne notLevel2
			ldr r0, =levelCompletionSuckerText7			@ Load out text pointer
			ldr r1, =3									@ x pos
			ldr r2, =5									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText

			ldr r0, =levelCompletionSuckerText8			@ Load out text pointer
			ldr r1, =2									@ x pos
			ldr r2, =7									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText	

			ldr r0, =levelCompletionSuckerText14			@ Load out text pointer
			ldr r1, =2									@ x pos
			ldr r2, =9									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText	
	notLevel2:
	cmp r4,#3
	bne notLevel3
			ldr r0, =levelCompletionSuckerText9			@ Load out text pointer
			ldr r1, =1									@ x pos
			ldr r2, =6									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText

			ldr r0, =levelCompletionSuckerText10			@ Load out text pointer
			ldr r1, =1									@ x pos
			ldr r2, =8									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText	
	notLevel3:
	cmp r4,#4
	bne notLevel4
			ldr r0, =levelCompletionSuckerText11			@ Load out text pointer
			ldr r1, =5									@ x pos
			ldr r2, =5									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText

			ldr r0, =levelCompletionSuckerText12			@ Load out text pointer
			ldr r1, =0									@ x pos
			ldr r2, =7									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText	

			ldr r0, =levelCompletionSuckerText13			@ Load out text pointer
			ldr r1, =1									@ x pos
			ldr r2, =9									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText	
	notLevel4:

	cmp r4,#10
	bne notLevel10
			ldr r0, =levelCompletionSuckerText1			@ Load out text pointer
			ldr r1, =1									@ x pos
			ldr r2, =4									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText

			ldr r0, =levelCompletionSuckerText2			@ Load out text pointer
			ldr r1, =0									@ x pos
			ldr r2, =6									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText

			ldr r0, =levelCompletionSuckerText3			@ Load out text pointer
			ldr r1, =2									@ x pos
			ldr r2, =8									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText

			ldr r0, =levelCompletionSuckerText4			@ Load out text pointer
			ldr r1, =1									@ x pos
			ldr r2, =12									@ y pos
			ldr r3, =0									@ Draw on sub screen
			bl drawText	
	notLevel10:

	bl drawEndOfLevelValues
	
	ldr r0, =hiScoreRawText						@ Read the path to the file
	bl playAudioStream							@ Play the audio stream

	bl fxCopperTextOn							@ Turn on copper text fx
@	bl fxStarfieldOn							@ Turn on starfield
@	bl fxStarfieldDownOn
	bl fxStarfieldMultiOn
	
	ldr r0, =2000								@ 2 seconds
	ldr r1, =calcBasesDestroyed					@ Callback function address
	
	bl startTimer
	
	bl fxFadeIn
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawEndOfLevelValues:

	stmfd sp!, {r0-r8, lr}

	ldr r10, =levelNum							@ Pointer to data
	ldr r10, [r10]								@ Read value
	mov r8, #5									@ y pos
	mov r9, #2									@ Number of digits
	mov r11, #13								@ x pos
	bl drawDigits								@ Draw
	
	ldr r10, =basesShot							@ Pointer to data
	ldr r10, [r10]								@ Read value
	mov r8, #10									@ y pos
	mov r9, #2									@ Number of digits
	mov r11, #7									@ x pos
	bl drawDigits								@ Draw
	
	ldr r10, =BASES_DESTROYED_VALUE				@ Pointer to data
	mov r8, #10									@ y pos
	mov r9, #4									@ Number of digits
	mov r11, #12								@ x pos
	bl drawDigits								@ Draw
	
	ldr r10, =basesShot
	ldr r10, [r10]
	ldr r1, =BASES_DESTROYED_VALUE
	mul r10, r1	
	mov r8, #10									@ y pos
	mov r9, #6									@ Number of digits
	mov r11, #19								@ x pos
	bl drawDigits								@ Draw
	
	ldr r10, =baseCount							@ Pointer to data
	ldr r10, [r10]								@ Read value
	mov r8, #15									@ y pos
	mov r9, #2									@ Number of digits
	mov r11, #7									@ x pos
	bl drawDigits								@ Draw
	
	ldr r10, =TOTAL_BASE_DESTRUCT_VALUE			@ Pointer to data
	mov r8, #15									@ y pos
	mov r9, #4									@ Number of digits
	mov r11, #12								@ x pos
	bl drawDigits								@ Draw
	
	ldr r10, =baseCount
	ldr r10, [r10]
	ldr r1, =TOTAL_BASE_DESTRUCT_VALUE
	mul r10, r1	
	mov r8, #15									@ y pos
	mov r9, #6									@ Number of digits
	mov r11, #19								@ x pos
	bl drawDigits								@ Draw
	
	ldr r10, =levelCount						@ Pointer to data
	ldr r10, [r10]								@ Read value
	mov r8, #20									@ y pos
	mov r9, #2									@ Number of digits
	mov r11, #7									@ x pos
	bl drawDigits								@ Draw
	
	ldr r10, =LEVEL_COMPLETION_BONUS_VALUE		@ Pointer to data
	mov r8, #20									@ y pos
	mov r9, #4									@ Number of digits
	mov r11, #12								@ x pos
	bl drawDigits								@ Draw
	
	ldr r10, =levelCount
	ldr r10, [r10]
	ldr r1, =LEVEL_COMPLETION_BONUS_VALUE
	mul r10, r1	
	mov r8, #20									@ y pos
	mov r9, #6									@ Number of digits
	mov r11, #19								@ x pos
	bl drawDigits								@ Draw

	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@---------------------------------
	
calcBasesDestroyed:

	stmfd sp!, {r0-r8, lr}
	
	ldr r2, =basesShot
	ldr r3, [r2]
	cmp r3, #0
	beq calcBasesDestroyedNext

	ldr r0, =adder+7							@ add 10 to the score
	mov r1, #5
	strb r1, [r0]
	bl addScore
	
	sub r3, #1
	str r3, [r2]
	
	bl playSteelSound
	
	ldr r0, =20									@ 20 milliseconds
	ldr r1, =calcBasesDestroyed					@ Callback function address
	bl startTimer
	
	b calcBasesDestroyedDone
	
calcBasesDestroyedNext:

	ldr r0, =1000								@ 1 seconds
	ldr r1, =calcTotalBaseDestruct				@ Callback function address
	
	bl startTimer
	
calcBasesDestroyedDone:

	bl drawEndOfLevelValues
	
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@---------------------------------
	
calcTotalBaseDestruct:

	stmfd sp!, {r0-r8, lr}
	
	ldr r2, =baseCount
	ldr r3, [r2]
	cmp r3, #0
	beq calcTotalBaseDestructNext

	ldr r0, =adder+7							@ add 7500 to the score
	mov r1, #0
	strb r1, [r0]
	sub r0, #1
	mov r1, #0
	strb r1, [r0]
	sub r0, #1
	mov r1, #5
	strb r1, [r0]
	sub r0, #1
	mov r1, #7
	strb r1, [r0]
	bl addScore
	
	sub r3, #1
	str r3, [r2]
	
	bl playSteelSound
	
	ldr r0, =20									@ 20 milliseconds
	ldr r1, =calcTotalBaseDestruct				@ Callback function address
	bl startTimer
	
	b calcTotalBaseDestructDone
	
calcTotalBaseDestructNext:

	ldr r0, =1000								@ 1 seconds
	ldr r1, =calcLevelCompletionBonus			@ Callback function address
	
	bl startTimer
	
calcTotalBaseDestructDone:

	bl drawEndOfLevelValues
	
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@---------------------------------
	
calcLevelCompletionBonus:

	stmfd sp!, {r0-r8, lr}
	
	ldr r2, =levelCount
	ldr r3, [r2]
	cmp r3, #0
	beq calcLevelCompletionBonusNext

	ldr r0, =adder+7							@ add 5000 to the score
	mov r1, #0
	strb r1, [r0]
	sub r0, #1
	mov r1, #0
	strb r1, [r0]
	sub r0, #1
	mov r1, #0
	strb r1, [r0]
	sub r0, #1
	mov r1, #5
	strb r1, [r0]
	bl addScore
	
	sub r3, #1
	str r3, [r2]
	
	bl playSteelSound
	
	ldr r0, =20									@ 20 milliseconds
	ldr r1, =calcLevelCompletionBonus			@ Callback function address
	bl startTimer
	
	b calcLevelCompletionBonusDone
	
calcLevelCompletionBonusNext:

	ldr r0, =1000								@ 1 seconds
	ldr r1, =calcEnergyRemaining				@ Callback function address
	
	bl startTimer
	
calcLevelCompletionBonusDone:

	bl drawEndOfLevelValues
	
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@---------------------------------
	
calcEnergyRemaining:

	stmfd sp!, {r0-r8, lr}
	
	ldr r2, =energy
	ldr r3, [r2]
	cmp r3, #0
	beq calcEnergyRemainingNext

	ldr r0, =adder+7							@ add 10 to the score
	mov r1, #0
	strb r1, [r0]
	sub r0, #1
	mov r1, #1
	strb r1, [r0]
	bl addScore
	
	sub r3, #1
	str r3, [r2]
	
	bl playSteelSound
	
	ldr r0, =20									@ 20 milliseconds
	ldr r1, =calcEnergyRemaining				@ Callback function address
	bl startTimer
	
	b calcEnergyRemainingDone
	
calcEnergyRemainingNext:

	ldr r0, =4000								@ 2 seconds
	
	@ FADE DOES NOT WORK WHEN STARFIELD IS ENABLED!!! WHY???
	
	ldr r1, =showEndOfLevelFadeOut				@ Callback function address
	@ldr r1, =showLevelNext
	
	bl startTimer
	
calcEnergyRemainingDone:
	
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@---------------------------------
	
showEndOfLevelFadeOut:

	stmfd sp!, {r0-r8, lr}
	
	bl fxFadeBlackInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =showLevelNext
	str r1, [r0]
@bl fxStarfieldOff	
	bl fxFadeOut
bl clearBG0
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateEndOfLevel:

	stmfd sp!, {r0-r8, lr}
	
	bl drawScore								@ update the score with any changes
	bl drawAllEnergyBars						@ Draw the energy bars
	@bl updateLogoSprites
	
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@---------------------------------

	.data
	.align
	
baseCount:
	.word 0
	
levelCount:
	.word 0
	
	.align
wellDoneText:
	.asciz "WELL DONE!"

	.align
levelCompletedText:
	.asciz "LEVEL 00 COMPLETED"
	
	.align
basesDestroyedText:
	.asciz "BASES DESTROYED"
	
	.align
basesDestroyedCalcText:
	.asciz "00 x 0000 = 000000"

	.align
totalBaseDestructText:
	.asciz "TOTAL BASE DESTRUCT"
	
	.align
totalBaseDestructCalcText:
	.asciz "00 x 0000 = 000000"
	
	.align
levelCompletionBonusText:
	.asciz "LEVEL COMPLETION BONUS"
	
	.align
levelCompletionBonusCalcText:
	.asciz "00 x 0000 = 000000"

	.align
levelCompletionSuckerText1:
	.asCiz "SO, THINK YOU'VE DONE SO WELL,"
	.align
levelCompletionSuckerText2:
	.asCiz "CLEARING THE ORIGINAL 10 LEVELS?"
	.align
levelCompletionSuckerText3:
	.asCiz "SADLY, THINGS GET FAR WORSE!"
	.align
levelCompletionSuckerText4:
	.asCiz "OH, NEARLY FORGOT, 'GOOD LUCK'"

	.align	
levelCompletionSuckerText5:
	.asCiz "SO, YOU CLEARED LEVEL 1?"
	.align
levelCompletionSuckerText6:
	.asCiz "ALL I CAN SAY IS 'WHOOPEE'"

	.align	
levelCompletionSuckerText7:
	.asCiz "SO LEVEL 2 DONE AND DUSTED"		@26
	.align
levelCompletionSuckerText8:
	.asCiz "IT MUST BE TOO EASY FOR YOU?"	@28	
	.align
levelCompletionSuckerText14:
	.asCiz "(NOW YOU EVEN GET POWERUPS!)"	@28	


	.align
levelCompletionSuckerText9:
	.asCiz "WELL DONE FOR CLEARING A WHOLE"	@30
	.align
levelCompletionSuckerText10:
	.asCiz "3 LEVELS, YOU MUST BE SO PROUD"	@30		

	.align
levelCompletionSuckerText11:
	.asCiz "REALLY SNOWBALLING NOW"	@22
	.align
levelCompletionSuckerText12:
	.asCiz "PERHAPS YOU SHOULD HAVE A BIT OF"	@32	
	.align
levelCompletionSuckerText13:
	.asCiz "A REST, MAYBE A LIE DOWN ALSO?"	@30	
	.pool
	.end
