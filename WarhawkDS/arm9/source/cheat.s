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

	#define	CHEAT_AMOUNT 		3
	
	.arm
	.align
	.text
	.global initCheat
	.global updateCheatCheck
	
initCheat:

	stmfd sp!, {r0-r8, lr}

	ldr r0, =cheatSection
	mov r1, #0
	str r1, [r0]
	
	ldmfd sp!, {r0-r8, pc}
	
	@---------------------------------

updateCheatCheck:								@ WHY THE HELL DOES THIS FAIL - too much red wine?
												@ first check is ok, then it only allows the first press?
												@ it should move onto the next? madness!!
	stmfd sp!, {r0-r8, lr}
	
	ldr r1, =REG_KEYINPUT						@ Read Key Input
	ldr r2, [r1]
	ldr r8,=1023								@ all buttons clear (but in DS=set?)
	cmp r2,r8
	beq noCheatKey								@ if no key pressed, no need to check!

	ldr r5,=cheatRelease
	ldr r6,[r5]
	cmp r2,r6									@ are we still pressing the same key?
	bne updateCheatCheckDone					@ if not, we can check for cheat
	
	ldr r1,=cheatSequence						@ the problem must be in HERE???
	ldr r4,=cheatSection
	ldr r4,[r4]									@ r4 = what part of key sequence? (0 to Max)
	ldr r3,[r1,r4, lsr #2]						@ r3 = pattern to be chacked against (DOES NOT WORK CORRECTLY)
	
	@ this TST fails? I always looks for an entry that ISNT the key we are after (the first?)???
	
	tst r2,r3									@ are we pressing the correct key? (r2 = key press)
	beq	keyMissed								@ if not, reset sequence

	@ ok, we have a match

		str r2,[r5]								@ set the key pressed into cheatRelease (so it does not regester another press)
	
		add r4,#1								@ add 1 to our sequence
		cmp r4,#CHEAT_AMOUNT
		beq activateCheat						@ have we hit the correct number of keys?
		
		ldr r0,=cheatSection
		str r4,[r0]								@ store the new count back (we are now on the next phase)
	
			b updateCheatCheckDone				@ and quit!
		
	keyMissed:									@ you did not press the correct key
	ldr r0,=cheatSection						@ so, reset back to the first
	mov r1,#0
	str r1,[r0]

	b updateCheatCheckDone						@ and quit

	noCheatKey:
	ldr r0,=cheatRelease						@ clear key press code
	mov r8,#0
	str r8,[r0]									@ store 1023 in key code (all keys released)
	
	b updateCheatCheckDone
	
	activateCheat:
	
	ldr r0, =cheatActiveText					@ Load out text pointer
	ldr r1, =10									@ x pos
	ldr r2, =18									@ y pos
	ldr r3, =0									@ Draw on SUB screen
	bl drawText
	
updateCheatCheckDone:

	ldr r10,=cheatSection
	ldr r10,[r10]								@ Read value
	mov r8,#16									@ y pos
	mov r9,#3									@ Number of digits
	mov r11, #0									@ x pos
	bl drawDigits								@ Draw

	ldmfd sp!, {r0-r8, pc}
	
	@---------------------------------

	.data
	.align
	
cheatSection:
	.word 0

	.align
cheatSequence:									@ in the current check - you must use different key for each part!
	.word BUTTON_UP, BUTTON_DOWN, BUTTON_UP

	.align
cheatRelease:
	.word 0
	
	.align
cheatActiveText:
	.asciz "CHEAT ACTIVE"

	.pool
	.end