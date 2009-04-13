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
	
	mov r6, r0									@ Move the hiscore value into r6
	
	ldr r0, =gameMode							@ Get gameMode address
	ldr r1, =GAMEMODE_ENDOFLEVEL				@ Set the gameMode to end of level
	str r1, [r0]								@ Store back gameMode
	
	ldr r0, =fxMode								@ Get fxMode address
	ldr r1, =FX_NONE							@ Get fxMode value
	str r1, [r0]								@ Turn off all fx
	
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
	
	bl initMainTiles							@ Initialize main tiles
	bl resetScrollRegisters						@ Reset scroll registers
	bl clearBG0									@ Clear bg's
	bl clearBG1
	bl clearBG2
	bl clearBG3
	
	bl clearOAM									@ Reset all sprites
	
	ldr r0, =FontPal
	ldr r1, =BG_PALETTE
	ldr r2, =32
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	strh r3, [r1]
	
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
	
	bl drawEndOfLevelValues
	
	ldr r0, =hiScoreRawText						@ Read the path to the file
	bl playAudioStream							@ Play the audio stream

	bl fxCopperTextOn							@ Turn on copper text fx
@	bl fxStarfieldOn							@ Turn on starfield
	bl fxStarfieldDownOn						@ Turn on starfield (completion version)
	
	ldr r0, =2000								@ 2 seconds
	ldr r1, =calcBasesDestroyed					@ Callback function address
	
	bl startTimer
	
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
	ldr r1, =endOfLevelDone						@ Callback function address
	
	bl startTimer
	
calcEnergyRemainingDone:
	
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateEndOfLevel:

	stmfd sp!, {r0-r8, lr}
	
	bl drawScore								@ update the score with any changes
	bl drawAllEnergyBars						@ Draw the energy bars
	
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@---------------------------------
	
endOfLevelDone:

	stmfd sp!, {r0-r8, lr}

	bl fxCopperTextOff							@ Turn off copper text fx
	bl fxStarfieldOff							@ Turn off starfield
	bl levelNext
	
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@--------------------------------

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
	
	.pool
	.end
