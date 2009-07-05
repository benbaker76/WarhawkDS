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


	.arm
	.align
	.text
	.global drawText
	.global drawTextCount
	.global drawDigits
	
drawText:
	
	@ r0 = pointer to null terminated text
	@ r1 = x pos
	@ r2 = y pos
	@ r3 = 0 = Main, 1 = Sub

	stmfd sp!, {r4-r5, lr} 
	
	ldr r4, =BG_MAP_RAM(BG0_MAP_BASE)	@ Pointer to main
	ldr r5, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB) @ Pointer to sub
	cmp r3, #1						@ Draw on sub screen?
	moveq r4, r5					@ Yes so store subscreen pointer
	add r4, r1, lsl #1				@ Add x position
	add r4, r2, lsl #6				@ Add y multiplied by 64

drawTextLoop:

	ldrb r5, [r0], #1				@ Read r1 [text] and add 1 to [text] offset
	cmp r5, #0						@ Null character?
	beq drawTextDone				@ Yes so were done
	sub r5, #32						@ ASCII character - 32 to get tile offset
	add r5, #42						@ Skip 42 tiles (score digits)
	orr r5, #(15 << 12)				@ Orr in the palette number (n << 12)
	strh r5, [r4], #2				@ Write the tile number to our 32x32 map and move along
	b drawTextLoop

drawTextDone:
	
	ldmfd sp!, {r4-r5, pc}
	
	@ ---------------------------------------------
	
drawTextCount:
	
	@ r0 = pointer to null terminated text
	@ r1 = x pos
	@ r2 = y pos
	@ r3 = 0 = Main, 1 = Sub
	@ r4 = max number of characters

	stmfd sp!, {r0-r6, lr} 
	
	ldr r5, =BG_MAP_RAM(BG0_MAP_BASE)	@ Pointer to main
	ldr r6, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB) @ Pointer to sub
	cmp r3, #1						@ Draw on sub screen?
	moveq r5, r6					@ Yes so store subscreen pointer
	add r5, r1, lsl #1				@ Add x position
	add r5, r2, lsl #6				@ Add y multiplied by 64

drawTextCountLoop:

	ldrb r6, [r0], #1				@ Read r1 [text] and add 1 to [text] offset
	cmp r6, #0						@ Null character?
	beq drawTextCountDone			@ Yes so were done
	sub r6, #32						@ ASCII character - 32 to get tile offset
	add r6, #42						@ Skip 42 tiles (score digits)
	orr r6, #(15 << 12)				@ Orr in the palette number (n << 12)
	strh r6, [r5], #2				@ Write the tile number to our 32x32 map and move along
	subs r4, #1
	bne drawTextCountLoop

drawTextCountDone:
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ---------------------------------------------

drawDigits:

	@ Ok, to use this we need to pass it a few things!!!
	@ r10 = number to display
	@ r8 = height to display to
	@ r9 = number of Digits to display
	@ r11 = X coord
	
	stmfd sp!, {r0-r10, lr}
	
	cmp r9,#0						@ if you forget to set r9 (or are using it)
	moveq r9,#4						@ we will default to 4 digits

	ldr r5,=digits					@ r5 = pointer to our digit store	
	mov r1,#31
	mov r2,#0
	
	debugClear:						@ clear our digits
		strb r2,[r5,r1]
		subs r1,#1
	bpl debugClear
	
	mov r6,#31						@ r6 is the digit we are to store 0-31 (USING WORDS)
	mov r1,r10
	convertLoop:	
		mov r2,#10					@ This is our divider
		bl divideNumber				@ call our code to divide r1 by r2 and return r0 with fraction
		strb r1,[r5,r6]			@ lets store our fraction in our digit data
		mov r1,r0					@ put the result back in r1 (original r1/10)
		subs r6,#1					@ take one off our digit counter
	@	cmp r1,#0					@ is our result 0 yet, if not, we have more to do
	bne convertLoop	

	ldr r0, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB)	@ make r0 a pointer to screen memory bg bitmap sub address
	mov r1,#0
	add r1, r8, lsl #6
	add r0, r1
	add r0, r11, lsl #1
	ldr r1, =digits					@ Get address of text characters to draw

	mov r2,#32
	sub r2,r9						
	add r1,r2						@ r1 = offset from digit reletive to number of digits to draw (r8)
	mov r2,r9						@ r2 = number of digits to draw

digitsLoop:
	ldrb r3,[r1],#1					@ Read r1 [text] and add 1 to [text] offset
	@add r3,#136					@ offset for 0. We only have chars as a tile in sub screen (+136 for our c64 digits)
	add r3,#58						@ offset for 0. We only have chars as a tile in sub screen
	orr r3, #(15 << 12)				@ Orr in the palette number (n << 12)
	strh r3, [r0], #2				@ Write the tile number to our 32x32 map and move along
	subs r2, #1						@ Move along one
	bne digitsLoop					@ And loop back until done
	
	ldmfd sp!, {r0-r10, pc}
	
	@ ---------------------------------------------
	
	.pool
	.end

