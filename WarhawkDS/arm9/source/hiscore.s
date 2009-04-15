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

	#define HISCORE_VALUE_SIZE		8	
	#define HISCORE_NAME_SIZE		3
	#define HISCORE_CRLF_SIZE		2
	#define HISCORE_ENTRY_COUNT		10
	#define HISCORE_ENTRY_SIZE		(HISCORE_VALUE_SIZE + HISCORE_NAME_SIZE + HISCORE_CRLF_SIZE)
	#define HISCORE_TOTAL_SIZE		HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE
	
	#define INPUT_DELAY				16
	#define CURSOR_COLOR_OFFSET		11

	.arm
	.align
	.text
	.global readHiScore
	.global showHiScore
	.global showHiScoreEntry
	.global updateHiScoreEntry
	.global byte2Int
	
readHiScore:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =hiScoreDatText						@ HiScore.dat filename
	ldr r1, =hiScoreBuffer						@ Buffer

	bl readFileBuffer							@ Read the HiScore.dat
	
	bl DC_FlushAll								@ Flush the cache
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------

showHiScore:

	stmfd sp!, {r0-r6, lr}
	
	bl clearBG0Sub								@ Clear BG0 (Sub screen)

	bl drawHiScoreText							@ Draw the hiscore text
	
	ldr r0, =15000								@ 15 seconds
	ldr r1, =showCredits						@ Callback function address
	
	bl startTimer								@ Start the timer
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
showHiScoreEntry:

	@ r0 - hiscore value

	stmfd sp!, {r0-r6, lr}
	
	mov r6, r0									@ Move the hiscore value into r6
	
	ldr r0, =cursorPos							@ Reset cursorPos
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =hiScoreIndex						@ Reset hiscoreIndex
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =gameMode							@ Get gameMode address
	ldr r1, =GAMEMODE_HISCORE_ENTRY				@ Set the gameMode to hiscore entry
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
	
	mov r0, r6									@ Move hiScore value to r0
	bl getHiScoreIndex							@ Get the hiscore index
	
	ldr r1, =hiScoreIndex						@ Read hiScoreIndex address
	str r0, [r1]								@ Write hiscore index
	
	cmp r0, #-1									@ Is the hiscore index -1? (No hiscore entry)
	bleq showTitleScreen						@ Yes then go back to the title screen
	beq showHiScoreEntryDone					@ And were done
	
	ldr r1, =colorHilight						@ Load colorHilight address
	mov r2, r0									@ Move hiscore index
	add r2, #10									@ Add 10 line offset
	str r2, [r1]								@ Write back to colorHilight
	
	ldr r0, =nameAAA							@ Load "AAA" address
	ldr r1, =nameEntryBuffer					@ Load nameEntryBuffer
	ldrb r3, [r0], #1							@ Copy "AAA" to nameEntryBuffer
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	
	mov r0, r6									@ Move hiscore value to r0
	ldr r1, =nameEntryBuffer					@ Load nameEntryBuffer address
	bl addHiScore								@ Add the hiscore
	
	ldr r0, =CursorSpritePal					@ Load the cursor sprite palette
	ldr r1, =SPRITE_PALETTE_SUB
	ldr r2, =CursorSpritePalLen
	bl dmaCopy
	
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

	@ Write the tile data to VRAM

	ldr r0, =CursorSpriteTiles					@ Load cursor sprite tiles
	ldr r1, =SPRITE_GFX_SUB
	ldr r2, =CursorSpriteTilesLen
	bl dmaCopy
	
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
	
	bl drawHiScoreText							@ Draw the hiscore text
	
	ldr r0, =hiScoreRawText						@ Read the path to the file
	bl playAudioStream							@ Play the audio stream
	
	bl fxColorPulseOn							@ Turn on color pulse fx
	bl fxCopperTextOn							@ Turn on copper text fx
	bl fxStarfieldOn							@ Tune on starfield
	
showHiScoreEntryDone:
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateHiScoreEntry:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =nameEntryBuffer					@ Load nameEntryBuffer
	ldr r1, =cursorPos							@ Load cursorPos address
	ldr r2, [r1]								@ Load cursorPos value
	ldrb r3, [r0, r2]							@ Load the ASCII character
	
	bl readInput
	
	cmp r0, #1									@ if it is 1, keep pressed (from no-key pressed)
	bne hiScoreEntrySkip

	ldr r4, =REG_KEYINPUT						@ Read key input register
	ldr r5, [r4]								@ Read key input value
	tst r5, #BUTTON_UP							@ Button up?
	addeq r3, #1								@ Move ASCII character up
	tst r5, #BUTTON_DOWN						@ Button down?
	subeq r3, #1								@ Move ASCII character down
	
	cmp r3, #32									@ ASCII character 32 - 90
	movlt r3, #32								@ if < 32 set to 32
	cmp r3, #90									@ If > 90 set to 90
	movgt r3, #90
	
	ldr r0, =nameEntryBuffer					@ Load nameEntryBuffer
	ldr r1, =cursorPos							@ Load cursorPos address
	ldr r2, [r1]								@ Load cursorPos value
	strb r3, [r0, r2]							@ Write back ASCII character
	
	ldr r4, =REG_KEYINPUT						@ Read key input register
	ldr r5, [r4]								@ Read key input value
	tst r5, #BUTTON_LEFT						@ Button left?
	subeq r2, #1								@ Move cursor left
	tst r5, #BUTTON_RIGHT						@ Button right?
	addeq r2, #1								@ Move cursor right
	
	cmp r2, #0									@ Cursor in pos 0?
	movlt r2, #0								@ Cursor pos < 0 then make it 0
	cmp r2, #2									@ Cursor pos 2?
	movgt r2, #2								@ Cursor pos > 2 then make it 2
	
	str r2, [r1]								@ Write back to cursorPos
	
	ldr r0, =nameEntryBuffer					@ buffer
	ldr r1, =19									@ x
	ldr r2, =hiScoreIndex						@ y
	ldr r2, [r2]								@ read hiscoreIndex value
	add r2, #10									@ Add 10 to it
	ldr r3, =1									@ sub=1 main=0
	ldr r4, =3									@ Draw 3 characters
	bl drawTextCount							@ Draw text

hiScoreEntrySkip:
	
	bl drawCursorSprite							@ Draw the cursor sprite

	ldr r0, =REG_KEYINPUT						@ Read key input register
	ldr r1, [r0]								@ Read key input value
	tst r1, #BUTTON_A							@ Button A?
	bleq saveHiScore							@ Yes, so save the hiscore
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawCursorSprite:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =SPRITE_PALETTE_SUB
	ldr r1, =pulseValue
	ldr r1, [r1]
	ldr r2, =CURSOR_COLOR_OFFSET
	lsl r2, #1
	strh r1, [r0, r2]
	
	ldr r0, =OBJ_ATTRIBUTE0_SUB(0)				@ Attrib 0
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)	@ Attrib 0 settings
	orr r1, #(10 * 8 + 2)						@ Orr in the y pos (10 * 8 pixels + 2 pixels so cursor is below text)
	ldr r2, =hiScoreIndex						@ Load the hiScoreIndex address
	ldr r2, [r2]								@ Load the hiScoreIndex value
	add r1, r2, lsl #3							@ Add the hiScoreIndex * 8
	strh r1, [r0]								@ Write to Attrib 0
	
	ldr r0, =OBJ_ATTRIBUTE1_SUB(0)				@ Attrib 1
	ldr r1, =(ATTR1_SIZE_8)						@ Attrib 1 settings
	orr r1, #(19 * 8)							@ Orr in the x pos (19 * 8 pixels)
	ldr r2, =cursorPos							@ Load the cursorPos address
	ldr r2, [r2]								@ Load the cursorPos value
	add r1, r2, lsl #3							@ Add the cursorPos * 8
	strh r1, [r0]								@ Write to Attrib 1
	
	ldr r0, =OBJ_ATTRIBUTE2_SUB(0)				@ Attrib 2
	mov r1, #ATTR2_PRIORITY(0)					@ Set sprite priority
	strh r1, [r0]								@ Write Attrib 2
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawHiScoreText:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =hiScoreBuffer						@ Load hiScoreBuffer address
	ldr r5, =0									@ Iterator
	
drawHiScoreTextLoop:

	ldr r1, =10									@ x pos
	ldr r2, =10									@ y pos
	add r2, r5									@ Add Iterator
	ldr r3, =1									@ Draw on sub screen
	ldr r4, =HISCORE_VALUE_SIZE					@ Number of characters
	bl drawTextCount
	
	add r0, #HISCORE_VALUE_SIZE
	
	ldr r1, =19									@ x pos
	ldr r2, =10									@ y pos
	add r2, r5									@ Add Iterator
	ldr r3, =1									@ Draw on sub screen
	ldr r4, =HISCORE_NAME_SIZE					@ Number of characters
	bl drawTextCount
	
	add r0, #(HISCORE_NAME_SIZE + HISCORE_CRLF_SIZE)	@ Add Name + CRLF to buffer offset

	add r5, #1									@ Add 1 to iterator
	cmp r5, #HISCORE_ENTRY_COUNT				@ Have we drawn them all?
	bne drawHiScoreTextLoop						@ No, so loop back
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
getHiScoreIndex:

	stmfd sp!, {r1-r4, lr}
	
	@ r0 = score value
	@ r0 = return index (-1=No hiscore, or number)
	
	mov r4, r0									@ Move score value
	
	ldr r1, =hiScoreBuffer						@ Load hiScoreBuffer
	mov r2, #-1									@ Move -1 (no hiscore entry)
	mov r3, #0									@ Set iterator to 0
	
getHiScoreIndexLoop:

	mov r0, r1									@ Move hiScoreBuffer
	bl ascii2Int								@ Call ascii2Int (r0 = value)
	
	cmp r4, r0									@ Compare the score to hiscore value in buffer
	ble getHiScoreIndexContinue					@ Less than or equal to so we continue
	
	mov r2, r3									@ Greater than so we have a hiscore, store it in r2 for return
	
	b getHiScoreIndexDone						@ We have a hiscore so were done
	
getHiScoreIndexContinue:

	add r1, #HISCORE_ENTRY_SIZE					@ Contine to next hiscore entry
	
	add r3, #1									@ Add 1 to iterator
	cmp r3, #HISCORE_ENTRY_COUNT				@ Have we checked all hiscore's?
	bne getHiScoreIndexLoop						@ Continue on
	
getHiScoreIndexDone:

	mov r0, r2									@ Move the value into r0 to return
	
	ldmfd sp!, {r1-r4, pc} 					@ restore registers and return
	
	@---------------------------------
	
addHiScore:

	stmfd sp!, {r0-r7, lr}
	
	@ r0 = score value
	@ r1 = pointer to name text
	
	mov r5, r0									@ Move score
	mov r6, r1									@ Move name pointer
	ldr r7, =nameBuffer							@ Load nameBuffer

	ldr r1, =hiScoreBuffer						@ Load hiScoreBuffer
	mov r4, #0									@ Reset iterator
	
addHiScoreLoop:

	mov r0, r1									@ Move the hiscoreBuffer address into r0
	bl ascii2Int								@ Convert to integer into r0
	
	cmp r5, r0									@ Compare hiscore value to the score
	addle r1, #HISCORE_ENTRY_SIZE				@ Less than or equal to, branch buffer to next entry
	ble addHiScoreContinue						@ Less than or equal to, branch to continue
	
	mov r3, r0									@ Make a copy
	mov r0, r5									@ Move score into into r0
	
	bl int2Ascii								@ Covert it to ASCII
	
	mov r5, r3									@ Move it back
	
	add r1, #HISCORE_VALUE_SIZE					@ Add the score size
	
	ldrb r3, [r1], #1							@ Copy current name to nameBuffer
	strb r3, [r7], #1
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	
	sub r1, #3									@ Go back 3 letters
	sub r7, #3
	
	ldrb r3, [r6], #1							@ Copy last name to hiScoreBuffer
	strb r3, [r1], #1
	ldrb r3, [r6], #1
	strb r3, [r1], #1
	ldrb r3, [r6], #1
	strb r3, [r1], #(1 + HISCORE_CRLF_SIZE)

	mov r6, r7									@ Move current name pointer into r6
	
addHiScoreContinue:
	
	add r4, #1									@ Add to iterator
	cmp r4, #HISCORE_ENTRY_COUNT				@ Done all hiscore's?
	bne addHiScoreLoop							@ No so loop
	
	ldmfd sp!, {r0-r7, pc} 					@ restore registers and return
	
	@---------------------------------
	
saveHiScore:

	stmfd sp!, {r0-r6, lr}
	
	bl stopAudioStream
	
	ldr r0, =colorHilight						@ Load colorHilight address
	mov r1, #0									@ Zero
	str r1, [r0]								@ Set it to zero to turn off
	
	ldr r0, =nameEntryBuffer					@ Load nameEntryBuffer
	ldr r1, =hiScoreBuffer						@ Load hiScoreBuffer
	ldr r2, =hiScoreIndex						@ Load hiScoreIndex address
	ldr r2, [r2]								@ Load hiScoreIndex value
	mov r3, #HISCORE_ENTRY_SIZE					@ Jump to the hiscore entry
	mul r2, r3
	add r2, #HISCORE_VALUE_SIZE					@ Add the value to get to the name
	add r1, r2
	
	ldrb r3, [r0], #1							@ Write name to hiscore
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	
	ldr r0, =hiScoreDatText						@ Write to HiScore.dat
	ldr r1, =hiScoreBuffer
	ldr r2, =HISCORE_TOTAL_SIZE
	bl writeFileBuffer
	
	bl DC_FlushAll								@ Flush cache
	
	@ldr r0, =hiScoreBuffer
	@bl drawDebugString
	
	bl fxColorPulseOff							@ Turn off color pulse
	bl fxCopperTextOff							@ Turn off copper text
	bl fxStarfieldOff							@ Turn off starfield

	bl showTitleScreen							@ Go back to titlescreen
	
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

byte2Int:
	
	@ r0 = pointer to buffer
	@ r0 = return value
	
	stmfd sp!, {r1-r6, lr}
	
	add r0, #HISCORE_VALUE_SIZE-1
	
	mov r1, #0
	mov r2, #0
	mov r3, #1

byte2IntLoop:
	
	ldrb r4, [r0]
	sub r0, #1
	mul r4, r3
	add r1, r4
	mov r5, #10
	mul r3, r5
	add r2, #1
	cmp r2, #HISCORE_VALUE_SIZE
	bne byte2IntLoop
	
	mov r0, r1
	
	ldmfd sp!, {r1-r6, pc}
	
	@---------------------------------
	
	.data
	.align
	
cursorPos:
	.word 0
	
hiScoreIndex:
	.word 0
	
	.align
nameBuffer:
	.asciz "   "

	.align
nameEntryBuffer:
	.asciz "   "

	.align
nameAAA:
	.asciz "AAA"
	
	.align
hiScoreDatText:
	.asciz "/HiScore.dat"
	
	.align
wellDoneText:
	.asciz "WELL DONE!"

	.align
enterNameText:
	.asciz "PLEASE ENTER YOUR NAME"

	.align
hiScoreBuffer:
	.incbin "../../efsroot/HiScore.dat"
	
	.pool
	.end