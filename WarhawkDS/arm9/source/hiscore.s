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

	#define HISCORE_VALUE_SIZE		7
	#define HISCORE_NAME_SIZE		3
	#define HISCORE_CRLF_SIZE		2
	#define HISCORE_ENTRY_COUNT		10
	#define HISCORE_ENTRY_SIZE		(HISCORE_VALUE_SIZE + HISCORE_NAME_SIZE + HISCORE_CRLF_SIZE)
	#define HISCORE_TOTAL_SIZE		HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE

	.arm
	.align
	.text
	.global readHiScore
	.global showHiScore
	.global showHiScoreEntry
	.global updateHiScoreEntry
	
readHiScore:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =hiScoreDatText
	ldr r1, =hiScoreBuffer
	
	bl readFileBuffer
	
	bl DC_FlushAll
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------

showHiScore:

	stmfd sp!, {r0-r6, lr}
	
	bl clearBG0Sub

	bl drawHiScoreText
	
	ldr r0, =15									@ 15 seconds
	ldr r1, =showCredits						@ Callback function address
	
	bl startTimer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
showHiScoreEntry:

	@ r0 - hiscore value

	stmfd sp!, {r0-r6, lr}
	
	mov r6, r0
	
	ldr r0, =gameMode
	ldr r1, =GAMEMODE_HISCORE_ENTRY
	str r1, [r0]
	
	ldr r0, =fxMode						@ Get fxMode address
	ldr r1, =FX_NONE					@ Get fxMode value
	str r1, [r0]
	
	bl initMainTiles
	bl resetScrollRegisters
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3
	
	mov r0, r6
	bl getHiScoreIndex
	
	ldr r1, =hiScoreIndex
	str r0, [r1]
	
	cmp r0, #-1
	bleq initTitleScreen
	beq showHiScoreEntryDone
	
	ldr r0, =nameAAA
	ldr r1, =nameEntryBuffer
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	
	mov r0, r6
	ldr r1, =nameEntryBuffer
	bl addHiScore

	ldr r0, =CursorSpritePal
	ldr r1, =SPRITE_PALETTE_SUB
	ldr r2, =CursorSpritePalLen
	bl dmaCopy
	
	bl resetSprites

	@ Write the tile data to VRAM

	ldr r0, =CursorSpriteTiles
	ldr r1, =SPRITE_GFX_SUB
	ldr r2, =CursorSpriteTilesLen
	bl dmaCopy
	
	bl clearBG0Sub
	
	ldr r0, =wellDoneText						@ Load out text pointer
	ldr r1, =11									@ x pos
	ldr r2, =5									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =enterNameText						@ Load out text pointer
	ldr r1, =5									@ x pos
	ldr r2, =7									@ y pos
	ldr r3, =1									@ Draw on sub screen
	bl drawText
	
	ldr r0, =hiScoreRawText						@ Read the path to the file
	bl playAudioStream							@ Play the audio stream

	bl drawHiScoreText
	
	bl fxCopperTextOn
	bl fxStarfieldOn
	
showHiScoreEntryDone:
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateHiScoreEntry:

	stmfd sp!, {r0-r8, lr}
	
	ldr r0, =nameEntryBuffer
	ldr r1, =cursorPos
	ldr r2, [r1]
	ldrb r3, [r0, r2]
	
	ldr r8, =hiScoreKeyPress
	ldr r7, [r8]								@ we should never need to reset this value, the code does it for us
	
	ldr r4, =REG_KEYINPUT
	ldr r5, [r4]
	
	mov r4, r5
	and r4, #241								@ check all the used keys for entry are clear!
	cmp r4, #241
	moveq r7, #0								@ if so, set to 0
	addne r7, #1								@ if not, a key is pressed, so add 1
	
	cmp r7, #16									@ if we are at 16, reset to 0 to allow movement
	movpl r7, #0								@ 16 is a delay you may want to adjust to suit?
	bpl hiScoreEntryOK
	
	cmp r7, #1									@ if it is 1, keep pressed (from no-key pressed)
	bne hiScoreEntrySkip
	
hiScoreEntryOK:
	
	tst r5, #BUTTON_UP
	addeq r3, #1
	tst r5, #BUTTON_DOWN
	subeq r3, #1
	
	cmp r3, #32
	movlt r3, #32
	cmp r3, #90
	movgt r3, #90
	
	strb r3, [r0, r2]
	
	ldr r0, =nameEntryBuffer
	ldr r1, =cursorPos
	ldr r2, [r1]
	ldr r3, [r0, r2]
	
	ldr r4, =REG_KEYINPUT
	ldr r5, [r4]
	tst r5, #BUTTON_LEFT
	subeq r2, #1
	tst r5, #BUTTON_RIGHT
	addeq r2, #1
	
	cmp r2, #0
	movlt r2, #0
	cmp r2, #2
	movgt r2, #2
	
	str r2, [r1]
	
	ldr r0, =nameEntryBuffer					@ buffer
	ldr r1, =19									@ x
	ldr r2, =hiScoreIndex						@ y
	ldr r2, [r2]
	add r2, #10
	ldr r3, =1									@ sub=1 main=0
	ldr r4, =3									@ characters
	bl drawTextCount

hiScoreEntrySkip:
	
	bl drawCursorSprite

	str r7,[r8]
	
	ldr r0, =REG_KEYINPUT
	ldr r1, [r0]
	tst r1, #BUTTON_A
	bleq saveHiScore
	
	ldmfd sp!, {r0-r8, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawCursorSprite:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =OBJ_ATTRIBUTE0_SUB(0)
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)
	orr r1, #(10 * 8 + 2)
	ldr r2, =hiScoreIndex
	ldr r2, [r2]
	add r1, r2, lsl #3
	strh r1, [r0]
	
	ldr r0, =OBJ_ATTRIBUTE1_SUB(0)
	ldr r1, =(ATTR1_SIZE_8)
	orr r1, #(19 * 8)
	ldr r2, =cursorPos
	ldr r2, [r2]
	add r1, r2, lsl #3
	strh r1, [r0]
	
	ldr r0, =OBJ_ATTRIBUTE2_SUB(0)
	mov r1, #ATTR2_PRIORITY(0)
	strh r1, [r0]
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawHiScoreText:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =hiScoreBuffer
	ldr r5, =0
	
drawHiScoreTextLoop:

	ldr r1, =10									@ x pos
	ldr r2, =10									@ y pos
	add r2, r5
	ldr r3, =1									@ Draw on sub screen
	ldr r4, =HISCORE_VALUE_SIZE					@ Number of characters
	bl drawTextCount
	
	add r0, #HISCORE_VALUE_SIZE
	
	ldr r1, =19									@ x pos
	ldr r2, =10									@ y pos
	add r2, r5
	ldr r3, =1									@ Draw on sub screen
	ldr r4, =HISCORE_NAME_SIZE					@ Number of characters
	bl drawTextCount
	
	add r0, #(HISCORE_NAME_SIZE + HISCORE_CRLF_SIZE)

	add r5, #1
	cmp r5, #HISCORE_ENTRY_COUNT
	bne drawHiScoreTextLoop
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
getHiScoreIndex:

	stmfd sp!, {r1-r4, lr}
	
	@ r0 = hiscore value
	@ r0 = return index (-1=No hiscore, or number)
	
	mov r4, r0
	
	ldr r1, =hiScoreBuffer
	mov r2, #-1
	mov r3, #0
	
getHiScoreIndexLoop:

	mov r0, r1
	bl ascii2Int
	
	cmp r4, r0
	ble getHiScoreIndexContinue
	
	mov r2, r3
	
	b getHiScoreIndexDone
	
getHiScoreIndexContinue:

	add r1, #HISCORE_ENTRY_SIZE
	
	add r3, #1
	cmp r3, #HISCORE_ENTRY_COUNT
	bne getHiScoreIndexLoop
	
getHiScoreIndexDone:

	mov r0, r2
	
	ldmfd sp!, {r1-r4, pc} 					@ restore registers and return
	
	@---------------------------------
	
addHiScore:

	stmfd sp!, {r0-r7, lr}
	
	@ r0 = hiscore value
	@ r1 = pointer to name text
	
	mov r5, r0
	mov r6, r1
	ldr r7, =nameBuffer

	ldr r1, =hiScoreBuffer
	ldr r4, =0
	
addHiScoreLoop:

	mov r0, r1
	bl ascii2Int
	
	cmp r5, r0
	addle r1, #HISCORE_ENTRY_SIZE
	ble addHiScoreContinue
	
	mov r3, r0
	mov r0, r5
	
	bl int2Ascii
	
	mov r5, r3
	
	add r1, #HISCORE_VALUE_SIZE
	
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	
	sub r1, #3
	sub r7, #3
	
	ldrb r3, [r6], #1
	strb r3, [r1], #1
	ldrb r3, [r6], #1
	strb r3, [r1], #1
	ldrb r3, [r6], #1
	strb r3, [r1], #(1 + HISCORE_CRLF_SIZE)
	
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	
	sub r6, #3
	sub r7, #3
	
addHiScoreContinue:
	
	add r4, #1
	cmp r4, #HISCORE_ENTRY_COUNT
	bne addHiScoreLoop
	
	ldmfd sp!, {r0-r7, pc} 					@ restore registers and return
	
	@---------------------------------
	
saveHiScore:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =nameEntryBuffer
	ldr r1, =hiScoreBuffer
	ldr r2, =hiScoreIndex
	ldr r2, [r2]
	mov r3, #HISCORE_ENTRY_SIZE
	mul r2, r3
	add r2, #HISCORE_VALUE_SIZE
	add r1, r2
	
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	
	ldr r0, =hiScoreDatText
	ldr r1, =hiScoreBuffer
	ldr r2, =HISCORE_TOTAL_SIZE
	bl writeFileBuffer
	
	bl DC_FlushAll
	
	@ldr r0, =hiScoreBuffer
	@bl drawDebugString
	
	bl fxCopperTextOff
	bl fxStarfieldOff
	
	bl initTitleScreen
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
int2Ascii:
	
	@ r0 = value
	@ r1 = pointer to buffer
	
	stmfd sp!, {r0-r6, lr}
	
	mov r4, r1
	add r4, #HISCORE_VALUE_SIZE-1
	mov r5, #0
	mov r1, r0

int2AsciiLoop:
	
	mov r2, #10									@ This is our divider
	bl divideNumber								@ call our code to divide r1 by r2 and return r0 with fraction
	add r1, #0x30
	strb r1, [r4]
	sub r4, #1
	mov r1, r0									@ put the result back in r1 (original r1/10)
	add r5, #1
	cmp r5, #HISCORE_VALUE_SIZE
	beq int2AsciiDone
	cmp r1, #0									@ is our result 0 yet, if not, we have more to do
	bne int2AsciiLoop
	
	mov r1, #0x30
	
int2AsciiAddZerosLoop:

	strb r1, [r4]
	sub r4, #1
	
	add r5, #1
	cmp r5, #HISCORE_VALUE_SIZE
	bne int2AsciiAddZerosLoop

int2AsciiDone:
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
ascii2Int:
	
	@ r0 = pointer to buffer
	@ r0 = return value
	
	stmfd sp!, {r1-r6, lr}
	
	add r0, #HISCORE_VALUE_SIZE-1
	
	mov r1, #0
	mov r2, #0
	mov r3, #1

ascii2IntLoop:
	
	ldrb r4, [r0]
	sub r0, #1
	sub r4, #0x30
	mul r4, r3
	add r1, r4
	mov r5, #10
	mul r3, r5
	add r2, #1
	cmp r2, #HISCORE_VALUE_SIZE
	bne ascii2IntLoop
	
	mov r0, r1
	
	ldmfd sp!, {r1-r6, pc} 					@ restore registers and return
	
	@---------------------------------

	.data
	.align

hiScoreKeyPress:
	.word 0
	
cursorPos:
	.word 0
	
hiScoreIndex:
	.word 0
	
hiScoreDatText:
	.asciz "/HiScore.dat"
	
wellDoneText:
	.asciz "WELL DONE!"
	
enterNameText:
	.asciz "PLEASE ENTER YOUR NAME"
	
hiScoreBuffer:
	.string "0704016MEL\n"
	.string "0050000ACM\n"
	.string "0045000NAR\n"
	.string "0040000UP \n"
	.string "0035000BTH\n"
	.string "0030000INU\n"
	.string "0025000S G\n"
	.string "0020000 PO\n"
	.string "0015000AL \n"
	.string "0010000NUO\n"

nameBuffer:
	.asciz "   "
	
nameEntryBuffer:
	.asciz "   "
	
nameAAA:
	.asciz "AAA"
	
	.pool
	.end