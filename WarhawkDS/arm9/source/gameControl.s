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
	.global showGameStart
	.global showGameContinue
	.global showGameStop
	.global showGamePause
	.global showGameContinue
	.global checkGameContinue
	.global checkGamePause
	.global updateGameUnPause
	.global checkGameOver
	
showGameStart:

	stmfd sp!, {lr}

	bl initData									@ setup actual game data
	bl initLevel								@ Start level
	
	ldmfd sp!, {pc}
	
	@ ------------------------------------
	
showGameContinue:

	stmfd sp!, {lr}

	bl initDataGameContinue						@ setup actual game data
	bl initLevel								@ Start level
	
	ldmfd sp!, {pc}
	
	@ ------------------------------------
	
showGameStop:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_STOPPED
	str r1, [r0]
		
	ldmfd sp!, {r0-r6, pc}

	@ ------------------------------------
	
checkGameContinue:

	stmfd sp!, {r0-r3, lr}
	
	bl getLevelNum
	
	ldr r0, =levelNum
	ldr r1, [r0]
	ldr r2, =optionLevelNum
	ldr r3, [r2]
	
	cmp r1, r3
	ble checkGameContinueDone
	
	ldr r3, =LEVEL_4
	cmp r1, r3
	strge r3, [r2]

	ldr r3, =LEVEL_8
	cmp r1, r3
	strge r3, [r2]
	
	ldr r3, =LEVEL_12
	cmp r1, r3
	strge r3, [r2]
	
	ldr r3, =LEVEL_16
	cmp r1, r3
	strge r3, [r2]
	
	bl writeOptions
	bl setLevelNum
	
checkGameContinueDone:
	
	ldmfd sp!, {r0-r3, pc}

	@ ------------------------------------
	
checkGamePause:

	stmfd sp!, {r0-r1, lr}

	ldr r0, =REG_KEYINPUT						@ Read Key Input
	ldr r1, [r0]
	tst r1, #BUTTON_START						@ Start button pressed?
	bleq showGamePause
		
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------

showGamePause:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_PAUSED
	str r1, [r0]
	
	ldr r0, =pausedText				@ Load out text pointer
	ldr r1, =13						@ x pos
	ldr r2, =10						@ y pos
	ldr r3, =0						@ Draw on sub screen
	bl drawText
	
	ldr r0, =pausedText				@ Load out text pointer
	ldr r1, =13						@ x pos
	ldr r2, =10						@ y pos
	ldr r3, =1						@ Draw on main screen
	bl drawText
	
	bl fxCopperTextOn
	
	ldr r0, =buttonWaitPress
	mov r1,#1
	str r1,[r0]						@ set the button to active
	mov r1,#0
	ldr r0, =pauseStartHeld
	str r1,[r0]
		
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------
	
updateGameUnPause:								@ SORRY about messing with this HK!! :)

	stmfd sp!, {r0-r1, lr}

	ldr r0,=pauseStartHeld
	ldr r1,[r0]
	cmp r1,#1
	beq showGameUnPause

	mov r1,#BUTTON_START						@ set keyWait to check for START as an option
	bl keyWait									@ ANY BL from here crashes?
	cmp r1,#1
	beq updateGameUnPauseWait

		ldr r0, =buttonWaitPress	
		mov r1,#1
		str r1,[r0]								@ set the button to active, we need this clear for release
		ldr r0, =pauseStartHeld
		str r1,[r0]								@ tell the code we are waiting for release to continue

	updateGameUnPauseWait:	
	ldmfd sp!, {r0-r1, pc}

showGameUnPause:

	mov r1,#BUTTON_START						@ set keyWait to check for START as an option
	bl keyWait									@ ANY BL from here crashes?
	ldr r1,=buttonWaitPress
	ldr r0,[r1]
	cmp r0,#0
	bne showGameUnPauseWait

		ldr r0, =gameMode
		ldr r1, =GAMEMODE_RUNNING
		str r1, [r0]
		bl fxCopperTextOff
		bl clearBG0Partial

	showGameUnPauseWait:
	ldmfd sp!, {r0-r1, pc}
		
	@ ------------------------------------
	
checkGameOver:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =energy
	ldr r1, [r0]
	cmp r1, #0
	beq activatePlayerDeath
	
	b checkGameOverDone

activatePlayerDeath:

	ldr r0,=playerDeath
	ldr r1,[r0]
	cmp r1,#0
	moveq r1,#1
	str r1,[r0]
	
checkGameOverDone:
		
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------

pauseStartHeld:
	.word 0

	.pool
	.end
