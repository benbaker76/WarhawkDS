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
	#define HISCORE_NAME_SIZE		5
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
	.global showHiScoreEntry
	.global updateHiScoreEntry
	.global drawHiScoreText
	.global byte2Int
	
readHiScore:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =hiScoreDatText						@ HiScore.dat filename
	ldr r1, =hiScoreBuffer						@ Buffer

	bl readFileBuffer							@ Read the HiScore.dat
	
	bl DC_FlushAll								@ Flush the cache
	
	ldmfd sp!, {r0-r1, pc} 					@ restore registers and return
	
	@---------------------------------
	
showHiScoreEntry:

	stmfd sp!, {r0-r4, lr}

	ldr r0, =score
	bl byte2Int
	
	ldr r1, =hiScoreValue
	str r0, [r1]
	
	bl getHiScoreIndex							@ Get the hiscore index
	
	ldr r1, =hiScoreIndex						@ Read hiScoreIndex address
	str r0, [r1]								@ Write hiscore index
	
	cmp r0, #-1									@ Is the hiscore index -1? (No hiscore entry)
	beq showHiScoreEntryTitleScreen				@ Yes then go back to the title screen
	
	ldr r0, =gameMode							@ Get gameMode address
	ldr r1, =GAMEMODE_HISCORE_ENTRY				@ Set the gameMode to hiscore entry
	str r1, [r0]								@ Store back gameMode
	
	bl fxOff
	bl fxFadeBlackInit
	bl fxFadeMax
	bl stopSound
	bl stopAudioStream
	bl initVideoMain
	bl initMainTiles							@ Initialize main tiles
	bl resetScrollRegisters						@ Reset scroll registers
	bl clearBG0									@ Clear bgs
	bl clearBG1
	bl clearBG2
	bl clearBG3

	bl initStarData
	
	ldr r0, =cursorPos							@ Reset cursorPos
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =hiScoreValue
	ldr r0, [r0]
	
	bl addHiScore								@ Add the hiscore
	
	ldr r0, =nameAAAAA							@ Load "AAAAA" address
	ldr r1, =nameBuffer							@ Load nameBuffer
	ldrb r3, [r0], #1							@ Copy "AAAAA" to nameBuffer
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	
	ldr r0, =SpritePal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =512
	bl dmaCopy
	
	bl clearOAM									@ Reset all sprites
	
	@ Write the tile data
	ldr r0,=moonPick
	ldr r4,[r0]
	add r4,#1
	cmp r4,#2
	moveq r4,#0
	str r4,[r0]
	cmp r4,#0
	ldreq r0 ,=MoonscapeTiles
	ldrne r0 ,=Moonscape2Tiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldreq r2, =MoonscapeTilesLen
	ldrne r2, =Moonscape2TilesLen
	bl dmaCopy
	
	@ Write map
	
	ldreq r0, =MoonscapeMap
	ldrne r0, =Moonscape2Map
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)			@ destination
	ldr r2, =MoonscapeMapLen
	bl dmaCopy
	mov r0, #0
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	ldr r2, =(32 * 24 * 2)
	bl dmaFillWords

	ldr r0, =FontPal
	ldr r1, =BG_PALETTE
	ldr r2, =32
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	strh r3, [r1]

	@ sprite data

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

	ldr r0, =highInstruct1						@ Load out text pointer
	ldr r1, =3									@ x pos
	ldr r2, =5									@ y pos
	ldr r3, =0									@ Draw on MAIN screen
	bl drawText	

	ldr r0, =highInstruct2						@ Load out text pointer
	ldr r1, =6									@ x pos
	ldr r2, =7									@ y pos
	ldr r3, =0									@ Draw on MAIN screen
	bl drawText		
	
	bl drawHiScoreText							@ Draw the hiscore text
	
	ldr r0, =hiScoreRawText						@ Read the path to the file
	bl playAudioStream							@ Play the audio stream
	
	bl fxColorPulseOn							@ Turn on color pulse fx
	bl fxCopperTextOn							@ Turn on copper text fx
	bl fxFireworksOn
	bl fxFadeIn
	
	ldr r0, =hiScoreIndex
	ldr r1, =colorHilightSub					@ Load colorHilight address
	ldr r2, [r0]								@ Move hiscore index
	add r2, #10									@ Add 10 line offset
	str r2, [r1]								@ Write back to colorHilight
	
	b showHiScoreEntryDone
	
showHiScoreEntryTitleScreen:

	bl showTitleScreen
	
showHiScoreEntryDone:
	
	ldmfd sp!, {r0-r4, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateHiScoreEntry:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =nameBuffer							@ Load nameBuffer
	ldr r1, =cursorPos							@ Load cursorPos address
	ldr r2, =hiScoreTable						@ Load hiScoreTable address
	ldr r3, [r1]								@ Load cursorPos value
	ldrb r4, [r0, r3]							@ Load the ASCII character
	sub r4, #32									@ Subtract 32
	ldrb r4, [r2, r4]							@ Convert to offset
	
	bl readInput
	
	cmp r0, #1									@ if it is 1, keep pressed (from no-key pressed)
	bne updateHiScoreEntrySkip

	ldr r5, =REG_KEYINPUT						@ Read key input register
	ldr r6, [r5]								@ Read key input value
	tst r6, #BUTTON_UP							@ Button up?
	addeq r4, #1								@ Move ASCII character up
	bleq playKeyboardClickSound
	tst r6, #BUTTON_DOWN						@ Button down?
	subeq r4, #1								@ Move ASCII character down
	bleq playKeyboardClickSound
	
	cmp r4, #0									@ ASCII character 0 - 50
	movmi r4, #50								@ if < 0 set to 0
	cmpgt r4, #50								@ If > 50 set to 50
	movgt r4, #0
	
	ldr r5, =hiScoreChars						@ Convert offset to ascii
	ldrb r4, [r5, r4]							@ Load ASCII character
	
	ldr r0, =nameBuffer							@ Load nameBuffer
	ldr r1, =cursorPos							@ Load cursorPos address
	ldr r2, [r1]								@ Load cursorPos value
	strb r4, [r0, r2]							@ Write back ASCII character
	
	ldr r4, =REG_KEYINPUT						@ Read key input register
	ldr r5, [r4]								@ Read key input value
	tst r5, #BUTTON_LEFT						@ Button left?
	subeq r2, #1								@ Move cursor left
	bleq playKeyboardClickSound
	tst r5, #BUTTON_RIGHT						@ Button right?
	addeq r2, #1								@ Move cursor right
	bleq playKeyboardClickSound
	
	cmp r2, #0									@ Cursor in pos 0?
	movlt r2, #0								@ Cursor pos < 0 then make it 0
	cmp r2, #HISCORE_NAME_SIZE-1				@ Cursor pos HISCORE_NAME_SIZE-1?
	movgt r2, #HISCORE_NAME_SIZE-1				@ Cursor pos > HISCORE_NAME_SIZE-1 then make it HISCORE_NAME_SIZE-1
	
	str r2, [r1]								@ Write back to cursorPos
	
	ldr r0, =nameBuffer							@ buffer
	ldr r1, =18									@ x
	ldr r2, =hiScoreIndex						@ y
	ldr r2, [r2]								@ read hiscoreIndex value
	add r2, #10									@ Add 10 to it
	ldr r3, =1									@ sub=1 main=0
	ldr r4, =HISCORE_NAME_SIZE					@ Draw characters
	bl drawTextCount							@ Draw text

updateHiScoreEntrySkip:
	
	bl drawCursorSprite							@ Draw the cursor sprite
	bl scrollStarsHorizFast						@ we will use this instead
	ldr r0, =REG_KEYINPUT						@ Read key input register
	ldr r1, [r0]								@ Read key input value
	tst r1, #BUTTON_A							@ Button A?
	bne updateHiScoreEntryDone					@ Yes, so save the hiscore
	
	ldr r0, =fxFadeOutBusy
	ldr r0, [r0]
	cmp r0, #FADE_BUSY
	beq updateHiScoreEntryDone
	
	bl fxFadeBlackInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =saveHiScore
	str r1, [r0]
	
	bl fxFadeOut
	
updateHiScoreEntryDone:
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawCursorSprite:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =SPRITE_PALETTE_SUB
	ldr r1, =pulseValue
	ldr r1, [r1]
	ldr r2, =CURSOR_COLOR_OFFSET
	lsl r2, #1
	strh r1, [r0, r2]
	
	ldr r0, =OBJ_ATTRIBUTE0_SUB(0)				@ Attrib 0
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_SQUARE)	@ Attrib 0 settings
	orr r1, #(10 * 8 - 2)						@ Orr in the y pos (10 * 8 pixels + 2 pixels so cursor is below text)
	ldr r2, =hiScoreIndex						@ Load the hiScoreIndex address
	ldr r2, [r2]								@ Load the hiScoreIndex value
	add r1, r2, lsl #3							@ Add the hiScoreIndex * 8
	strh r1, [r0]								@ Write to Attrib 0
	
	ldr r0, =OBJ_ATTRIBUTE1_SUB(0)				@ Attrib 1
	ldr r1, =(ATTR1_SIZE_16)					@ Attrib 1 settings
	orr r1, #(18 * 8 - 2)						@ Orr in the x pos (19 * 8 pixels)
	ldr r2, =cursorPos							@ Load the cursorPos address
	ldr r2, [r2]								@ Load the cursorPos value
	add r1, r2, lsl #3							@ Add the cursorPos * 8
	strh r1, [r0]								@ Write to Attrib 1
	
	ldr r0, =OBJ_ATTRIBUTE2_SUB(0)				@ Attrib 2
	mov r1, #ATTR2_PRIORITY(0)					@ Set sprite priority
	strh r1, [r0]								@ Write Attrib 2
	
	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@---------------------------------
	
drawHiScoreText:

	stmfd sp!, {r0-r5, lr}

	ldr r0, =hiScoreBuffer						@ Load hiScoreBuffer address
	ldr r5, =0									@ Iterator
	
drawHiScoreTextLoop:

	ldr r1, =9									@ x pos
	ldr r2, =10									@ y pos
	add r2, r5									@ Add Iterator
	ldr r3, =1									@ Draw on sub screen
	ldr r4, =HISCORE_VALUE_SIZE					@ Number of characters
	bl drawTextCount
	
	add r0, #HISCORE_VALUE_SIZE
	
	ldr r1, =18									@ x pos
	ldr r2, =10									@ y pos
	add r2, r5									@ Add Iterator
	ldr r3, =1									@ Draw on sub screen
	ldr r4, =HISCORE_NAME_SIZE					@ Number of characters
	bl drawTextCount
	
	add r0, #(HISCORE_NAME_SIZE + HISCORE_CRLF_SIZE)	@ Add Name + CRLF to buffer offset

	add r5, #1									@ Add 1 to iterator
	cmp r5, #HISCORE_ENTRY_COUNT				@ Have we drawn them all?
	bne drawHiScoreTextLoop						@ No, so loop back
	
	ldmfd sp!, {r0-r5, pc} 					@ restore registers and return
	
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
	cmp r3, #HISCORE_ENTRY_COUNT				@ Have we checked all hiscorEs?
	bne getHiScoreIndexLoop						@ Continue on
	
getHiScoreIndexDone:

	mov r0, r2									@ Move the value into r0 to return
	
	ldmfd sp!, {r1-r4, pc} 					@ restore registers and return
	
	@---------------------------------
	
addHiScore:

	stmfd sp!, {r0-r7, lr}
	@ r0 = score value
	
	mov r5, r0									@ Move score
	
	ldr r1, =nameAAAAA							@ Load "AAAAA" address
	ldr r6, =nameBufferTemp						@ Load nameBuffer
	ldr r7, =nameBuffer							@ Load nameBuffer address
	ldrb r3, [r1], #1							@ Copy "AAAAA" to nameBuffer
	strb r3, [r6], #1
	ldrb r3, [r1], #1
	strb r3, [r6], #1
	ldrb r3, [r1], #1
	strb r3, [r6], #1
	ldrb r3, [r1], #1
	strb r3, [r6], #1
	ldrb r3, [r1], #1
	strb r3, [r6], #1
	
	sub r6, #HISCORE_NAME_SIZE

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
	
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	ldrb r3, [r1], #1
	strb r3, [r7], #1
	
	sub r1, #HISCORE_NAME_SIZE
	sub r7, #HISCORE_NAME_SIZE
	
	ldrb r3, [r6], #1
	strb r3, [r1], #1
	ldrb r3, [r6], #1
	strb r3, [r1], #1
	ldrb r3, [r6], #1
	strb r3, [r1], #1
	ldrb r3, [r6], #1
	strb r3, [r1], #1
	ldrb r3, [r6], #1
	strb r3, [r1], #(1 + HISCORE_CRLF_SIZE)
	
	sub r6, #HISCORE_NAME_SIZE
	
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	ldrb r3, [r7], #1
	strb r3, [r6], #1
	
	sub r6, #HISCORE_NAME_SIZE
	sub r7, #HISCORE_NAME_SIZE
	
addHiScoreContinue:
	
	add r4, #1									@ Add to iterator
	cmp r4, #HISCORE_ENTRY_COUNT				@ Done all hiscore's?
	bne addHiScoreLoop							@ No so loop
	
	ldmfd sp!, {r0-r7, pc} 					@ restore registers and return
	
	@---------------------------------
	
saveHiScore:

	stmfd sp!, {r0-r3, lr}
	
	bl fxOff
	bl fxFadeBlackInit
	bl fxFadeMax
	bl stopSound
	bl stopAudioStream							@ Turn off music
	
	ldr r0, =colorHilightSub					@ Load colorHilight address
	mov r1, #0									@ Zero
	str r1, [r0]								@ Set it to zero to turn off
	
	ldr r0, =nameBuffer							@ Load nameBuffer
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
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	
	ldr r0, =hiScoreDatText						@ Write to HiScore.dat
	ldr r1, =hiScoreBuffer
	@ldr r2, =HISCORE_TOTAL_SIZE
	bl writeFileBuffer
	
	bl DC_FlushAll								@ Flush cache
	
	bl showTitleScreen
	
	ldmfd sp!, {r0-r3, pc} 					@ restore registers and return
	
	@---------------------------------
	
int2Ascii:
	
	@ r0 = value
	@ r1 = pointer to buffer
	
	stmfd sp!, {r0-r5, lr}
	
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
	
	ldmfd sp!, {r0-r5, pc} 					@ restore registers and return
	
	@---------------------------------
	
ascii2Int:
	
	@ r0 = pointer to buffer
	@ r0 = return value
	
	stmfd sp!, {r1-r5, lr}
	
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
	
	ldmfd sp!, {r1-r5, pc} 					@ restore registers and return
	
	@---------------------------------

byte2Int:
	
	@ r0 = pointer to buffer
	@ r0 = return value
	
	stmfd sp!, {r1-r5, lr}
	
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
	
	ldmfd sp!, {r1-r5, pc}
	
	@---------------------------------
	
	.data
	.align
	
cursorPos:
	.word 0

moonPick:
	.word 0	

hiScoreValue:
	.word 0
	
hiScoreIndex:
	.word 0
	
	.align
nameBufferTemp:
	.asciz "     "

	.align
nameBuffer:
	.asciz "     "

	.align
nameAAAAA:
	.asciz "     "
	
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
highInstruct1:
	.asciz "USE D-PAD TO ENTER LETTERS"

	.align
highInstruct2:
	.asciz "PRESS FIRE TO FINISH"

	.align
hiScoreBuffer:
	.incbin "../../efsroot/HiScore.dat"
	
	.align
hiScoreChars:
	.ascii " ABCDEFGHIJKLMNOPQRSTUVWXYZ.,0123456789?()!*-=+#@;:"	@ 50 CHARS
	
	.align
hiScoreTable:
	.byte 0x00,0x2a,0x00,0x2f,0x00,0x00,0x00,0x00
	.byte 0x28,0x29,0x2b,0x2e,0x1c,0x2c,0x1b,0x00
	.byte 0x1d,0x1e,0x1f,0x20,0x21,0x22,0x23,0x24
	.byte 0x25,0x26,0x32,0x31,0x00,0x2d,0x00,0x27
	.byte 0x30,0x01,0x02,0x03,0x04,0x05,0x06,0x07
	.byte 0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
	.byte 0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17
	.byte 0x18,0x19,0x1a,0x00,0x00,0x00,0x00,0x00
	
	.pool
	.end