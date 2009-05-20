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

#define BUF_ATTRIBUTE0		(0x07000000)	@ WE CAN move these back to REAL registers!!
#define BUF_ATTRIBUTE1		(0x07000002)
#define BUF_ATTRIBUTE2		(0x07000004)
#define BUF_ATTRIBUTE0_SUB	(0x07000400)
#define BUF_ATTRIBUTE1_SUB	(0x07000402)
#define BUF_ATTRIBUTE2_SUB	(0x07000404)


	.arm
	.align
	.text
	.global drawSprite
	.global generateExplosion

drawSprite:
	stmfd sp!, {lr}
	
	ldr r0,=deathMode
	ldr r0,[r0]
	cmp r0,#DEATHMODE_ALL_DONE
	blt drawSpriteActive
	ldmfd sp!, {pc}
	drawSpriteActive:
	
	mov r8,#127 			@ our counter for 128 sprites, do not think we need them all though
	ldr r4,=horizDrift	 	@ here we will set r4 as an adder for sprite offset
	ldr r4,[r4]				@ against our horizontal scroll
	
	SLoop:
	cmp r8,#0				@ if we are on our ship
	moveq r4,#0				@ then we dont need to add anything
							@ as our ship is not tied to the background
	
	ldr r0,=spriteY
	ldr r1,[r0,r8, lsl #2]
	cmp r1,#SCREEN_MAIN_WHITESPACE
	bpl killSprite

	ldr r0,=spriteActive				@ r2 is pointer to the sprite active setting
	ldr r1,[r0,r8, lsl #2]				@ add sprite number * 4
	cmp r1,#0							@ Is sprite active? (anything other than 0)
	bne sprites_Drawn					@ if so, draw it!
										@ if not Kill sprite
		killSprite:
		mov r3, #ATTR0_DISABLED			@ Kill the sprite on Main Screen
		ldr r0,=BUF_ATTRIBUTE0
		add r0,r8, lsl #3
		strh r3,[r0]

		ldr r0,=spriteActive
		ldr r2,[r0,r8, lsl #2]
		cmp r2,#128						@ if it is a boss - dont kill it!!!
		bge sprites_Done				@ we have to treat a boss differently
		
		sprites_Must_Kill:
		cmp r1,#SCREEN_MAIN_WHITESPACE+32
		bge sprites_Really_Dead
		
		ldr r0,=spriteActive			@ r2 is pointer to the sprite active setting
		ldr r1,[r0,r8, lsl #2]			@ add sprite number * 4
		cmp r1,#0						@ Is sprite active? (anything other than 0)
		bne sprites_Drawn				@ if so, draw it!		
		
		sprites_Really_Dead:
		@ this is a TOTALL kill of the sprite and ALL data!
		
			@ldr r0,=spriteActive
			@mov r1,#0
			@str r1,[r0, r8,lsl #2]
			ldr r0,=spriteActive
			add r0, r8, lsl#2
			mov r1,#0
			str r1,[r0]
			add r0,#512+512+512			@ skip x/y as this effects player explosion
			mov r2,#0
			spriteClearLoop:			@ this clears all
				str r1,[r0]
				add r0,#512
				add r2,#1
				cmp r2,#27
			bne spriteClearLoop
		
			mov r1, #ATTR0_DISABLED			@ this should destroy the sprite
			ldr r0,=BUF_ATTRIBUTE0			@ if does not for some reason???
			add r0,r8, lsl #3
			strh r1,[r0]
			ldr r0,=BUF_ATTRIBUTE0_SUB
			add r0,r8, lsl #3
			strh r1,[r0]

			b sprites_Done

	sprites_Drawn:
	@ first, update out BLOOM effect, if bloom is >0 sub 1
	ldr r0,=spriteBloom
	ldr r1,[r0,r8,lsl #2]
	cmp r1,#0
	subne r1,#1
	str r1,[r0,r8,lsl #2]

	@ If coord is <192 then plot on sub (upper)
	@ if >256 plot on main (lower)
	@ but, if on crossover, we need to plot 2 ships!!!
	@ one on each screen in the correct location!!
	@ Last section best commented!

	
	ldr r0,=spriteY						@ Load Y coord
	ldr r1,[r0,r8,lsl #2]				@ add ,rX for offsets
	cmp r1,#SCREEN_MAIN_WHITESPACE		@ if is is > than screen base, do NOT draw it
	bpl sprites_Done

	ldr r3,=SCREEN_SUB_WHITESPACE-32	@ if it offscreen?
	cmp r1,r3							@ if it is less than - then it is in whitespace
	bmi sprites_Done					@ so, no need to draw it!
	ldr r3,=SCREEN_MAIN_TOP @+32			@ now is it on the main screen
	@ make above -32 for DS mode
	cmp r1,r3							@ check
	bpl spriteY_Main_Done				@ if so, we need only draw to main
	ldr r3,=SCREEN_MAIN_TOP-32			@ is it totally on the sub
	cmp r1,r3							@ Totally ON SUB
	bmi spriteY_Sub_Only

		@ The sprite is now between 2 screens and needs to be drawn to BOTH!
		@ Draw Y to MAIN screen (lower)
		ldr r0,=BUF_ATTRIBUTE0			@ get the sprite attribute0 base
		add r0,r8, lsl #3				@ add spritenumber *8
		ldr r2, =(ATTR0_COLOR_16 | ATTR0_SQUARE)
		ldr r3,=SCREEN_MAIN_TOP@+32			@ make r3 the value of top screen -sprite height (was -32)
		@ make above +32 for DS mode
		sub r1,r3						@ subtract our sprites y coord
		and r1,#0xff					@ Y is only 0-255
		orr r2,r1						@ or with our attributes from earlier
		strh r2,[r0]					@ store it in sprite attribute0
		@ Draw X to MAIN screen
		ldr r0,=spriteX					@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]			@ add ,Rx for offsets later!
		cmp r1,#64						@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#64						@ Take 64 off our X
		sub r1,r4						@ account for maps horizontal position
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1			@ get our ref to attribute1
		add r0,r8, lsl #3				@ add our sprite number * 8
		ldr r2, =(ATTR1_SIZE_32)		@ set to 32x32 (we may need to change this later)
		and r1,r3						@ and sprite y with 0x1ff (keep in region)
		orr r2,r1						@ orr result with the attribute
		ldr r3,=spriteHFlip
		ldr r3,[r3,r8, lsl #2]			@ load flip H
		orr r2, r3, lsl #12
		strh r2,[r0]					@ and store back
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2			@ load ref to attribute2
		add r0,r8, lsl #3				@ add sprite number * 8
		ldr r2,=spriteObj				@ make r2 a ref to our data for the sprites object
		ldr r3,[r2,r8, lsl #2]			@ r3=spriteobj+ sprite number *4 (stored in words)
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY))
		ldr r2,=spriteBloom				@ get our palette (bloom) number
		ldr r2,[r2,r8, lsl #2]			@ r2 = valuse
		orr r1,r2, lsl #12				@ orr it with attribute2 *4096 (to set palette bits)
		orr r1,r3, lsl #4				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back

		ldr r0,=spriteY					@ Load Y coord
		ldr r1,[r0,r8,lsl #2]			
	@ DRAW the Sprite on top screen
	spriteY_Sub_Done:
		@ Draw sprite to SUB screen (r1 holds Y)

		ldr r0,=BUF_ATTRIBUTE0_SUB		@ this all works in the same way as other sections
		add r0,r8, lsl #3
		ldr r2, =(ATTR0_COLOR_16 | ATTR0_SQUARE)
		ldr r3,=SCREEN_SUB_TOP
		cmp r1,r3
		addmi r1,#256
		sub r1,r3
		and r1,#0xff					@ Y is only 0-255
		orr r2,r1
		strh r2,[r0]
		@ Draw X
		ldr r0,=spriteX					@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]			@ add ,rX for offsets
		cmp r1,#SCREEN_LEFT				@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#SCREEN_LEFT				@ Take 64 off our X
		sub r1,r4						@ account for maps horizontal position
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1_SUB		@
		add r0,r8, lsl #3
		ldr r2, =(ATTR1_SIZE_32)
		and r1,r3
		orr r2,r1
		ldr r3,=spriteHFlip
		ldr r3,[r3,r8, lsl #2]			@ load flip H
		orr r2, r3, lsl #12
		strh r2,[r0]
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2_SUB
		add r0,r8, lsl #3
		ldr r2,=spriteObj
		ldr r3,[r2,r8, lsl #2]
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY)) @ add palette here *****
		ldr r2,=spriteBloom
		ldr r2,[r2,r8, lsl #2]
		orr r1,r2, lsl #12
		orr r1,r3, lsl #4				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back

		@ Need to kill same sprite on MAIN screen - or do we???
		@ Seeing that for this to occur, the sprite is offscreen on MAIN!
	
		b sprites_Done
		
	@ DRAW the Sprite on top screen and KILL the sprite on SUB!!!
	spriteY_Sub_Only:
		@ Draw sprite to SUB screen ONLY (r1 holds Y)
		
		mov r3, #ATTR0_DISABLED			@ Kill the SAME number sprite on Main Screen
		ldr r0,=BUF_ATTRIBUTE0
		add r0,r8, lsl #3
		strh r3,[r0]

		ldr r0,=BUF_ATTRIBUTE0_SUB		@ this all works in the same way as other sections
		add r0,r8, lsl #3
		ldr r2, =(ATTR0_COLOR_16 | ATTR0_SQUARE)
		ldr r3,=SCREEN_SUB_TOP
		cmp r1,r3
		addmi r1,#256
		sub r1,r3
		and r1,#0xff					@ Y is only 0-255
		orr r2,r1
		strh r2,[r0]
		@ Draw X
		ldr r0,=spriteX					@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]			@ add ,rX for offsets
		cmp r1,#SCREEN_LEFT				@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#SCREEN_LEFT				@ Take 64 off our X
		sub r1,r4						@ account for maps horizontal position
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1_SUB		@
		add r0,r8, lsl #3
		ldr r2, =(ATTR1_SIZE_32)
		and r1,r3
		orr r2,r1
		ldr r3,=spriteHFlip
		ldr r3,[r3,r8, lsl #2]			@ load flip H
		orr r2, r3, lsl #12
		strh r2,[r0]
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2_SUB
		add r0,r8, lsl #3
		ldr r2,=spriteObj
		ldr r3,[r2,r8, lsl #2]
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY)) @ add palette here *****
		ldr r2,=spriteBloom
		ldr r2,[r2,r8, lsl #2]
		orr r1,r2, lsl #12
		orr r1,r3, lsl #4				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back

		@ Need to kill same sprite on MAIN screen - or do we???
		@ Seeing that for this to occur, the sprite is offscreen on MAIN!
	
		b sprites_Done	
	spriteY_Main_Done:
		mov r3, #ATTR0_DISABLED			@ Kill the SAME number sprite on Sub Screen
		ldr r0,=BUF_ATTRIBUTE0_SUB
		add r0,r8, lsl #3
		strh r3,[r0]
		@ Draw sprite to MAIN
		ldr r0,=BUF_ATTRIBUTE0
		add r0,r8, lsl #3
		ldr r2, =(ATTR0_COLOR_16 | ATTR0_SQUARE)	@ These will not change in our game!
		ldr r3,=SCREEN_MAIN_TOP-32	@ Calculate offsets
		sub r1,r3					@ R1 is STILL out Y coorrd
		cmp r1,#32					@ Acound for partial display
		addmi r1,#256				@ Modify if so (create a wrap)
		sub r1,#32					@ Take our sprite height off
		and r1,#0xff				@ Y is only 0-255
		orr r2,r1					@ Orr Y back with data in R2
		strh r2,[r0]				@ Store Y back
		@ Draw X
		ldr r0,=spriteX				@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]		@ add ,rX for offsets
		cmp r1,#SCREEN_LEFT			@ if less than 64, this is off left of screen
		addmi r1,#512				@ convert coord for offscreen (32 each side)
		sub r1,#SCREEN_LEFT			@ Take 64 off our X
		
		sub r1,r4					@ account for maps horizontal position
		
		ldr r3,=0x1ff				@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1
		add r0,r8, lsl #3			@ Add offset (attribs in blocks of 8)
		ldr r2, =(ATTR1_SIZE_32)	@ Need a way to modify! 16384,32768,49152 = 16,32,64
		and r1,r3					@ kick out extranious on the Coord
		orr r2,r1					@ Stick the Coord and Data together
		ldr r3,=spriteHFlip
		ldr r3,[r3,r8, lsl #2]			@ load flip H
		orr r2, r3, lsl #12
		strh r2,[r0]				@ and store them!
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2		@ Find out Buffer Attribute
		add r0,r8, lsl #3			@ multiply by 8 to find location (in r0)
		ldr r2,=spriteObj			@ Find our sprite to draw
		ldr r3,[r2,r8, lsl #2]		@ store in words (*2)
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY))
		ldr r2,=spriteBloom
		ldr r2,[r2,r8, lsl #2]
		orr r1,r2, lsl #12
		orr r1,r3, lsl #4				@ or r1 with sprite pointer *16 (for sprite data block)
		strh r1, [r0]					@ store it all back
		@ Need to kill same sprite on SUB screen - or do we???
		@ Seeing that for this to occur, the sprite is offscreen on SUB!

	sprites_Done:
	
		ldr r0,=spriteActive				@ r2 is pointer to the sprite active setting
		ldr r1,[r0,r8, lsl #2]
		cmp r1,#5								@ ---------------- Base explosion
		bne alienExplodes
			
			ldr r0,=spriteY						@ Load Y coord
			ldr r1,[r0,r8,lsl #2]
			add r1,#1							@ add 1 and store back
			str r1,[r0,r8,lsl #2]
			cmp r1,#SCREEN_MAIN_WHITESPACE
			bpl noMoreBase
			
			ldr r0,=spriteExplodeDelay
			ldr r1,[r0,r8,lsl #2]
			subs r1,#1
			movmi r1,#4
			str r1,[r0,r8,lsl #2]
			bpl noMoreStuff
			
			ldr r0,=spriteObj
			ldr r1,[r0,r8,lsl #2]				@ load anim frame
			add r1,#1							@ add 1
			str r1,[r0,r8,lsl #2]				@ store it back
			cmp r1,#23							@ are we at the end frame?
			bne noMoreStuff
				noMoreBase:
				ldr r0,=spriteY
				mov r1,#SPRITE_KILL
				str r1,[r0,r8,lsl #2]
			b noMoreStuff
		alienExplodes:
		cmp r1,#4								@ -------------- Alien explosion
		bne shardAnimates

			ldr r0,=spriteExplodeDelay			@ check our animation delay
			ldr r1,[r0,r8,lsl #2]
			subs r1,#1							@ take 1 off the count					
			movmi r1,#4							@ and reset if <0
			str r1,[r0,r8,lsl #2]
			bpl noMoreStuff
			
			ldr r0,=spriteObj
			ldr r1,[r0,r8,lsl #2]				@ load anim frame
			add r1,#1							@ add 1
			str r1,[r0,r8,lsl #2]				@ store it back
			cmp r1,#14							@ are we at the end frame?
			bne noMoreStuff
				ldr r0,=spriteY
				mov r1,#SPRITE_KILL
				str r1,[r0,r8,lsl #2]

			b noMoreStuff

		shardAnimates:
		cmp r1,#6								@ -------------- Shard Animation
		bne moveDropShip
			
			ldr r0,=spriteY						@ Load Y coord
			ldr r1,[r0,r8,lsl #2]
			add r1,#3							@ add 3 (to Y) and store back
			str r1,[r0,r8,lsl #2]
			cmp r1,#SCREEN_MAIN_WHITESPACE
			bpl noMoreShard
			
			ldr r0,=spriteExplodeDelay			@ check our animation delay
			ldr r1,[r0,r8,lsl #2]
			subs r1,#1							@ take 1 off the count					
			movmi r1,#2							@ and reset if <0
			str r1,[r0,r8,lsl #2]
			bpl noMoreStuff
			
			ldr r0,=spriteObj
			ldr r1,[r0,r8,lsl #2]				@ load anim frame
			add r1,#1							@ add 1
			str r1,[r0,r8,lsl #2]				@ store it back
			cmp r1,#26							@ are we at the end frame?
			bne noMoreStuff
				noMoreShard:
				ldr r0,=spriteY
				mov r1,#SPRITE_KILL
				str r1,[r0,r8,lsl #2]

			b noMoreStuff
		moveDropShip:
		cmp r1,#9
		bne movePowerup2							@ --------------- Drop ship
			ldr r0,=bigBossMode
			ldr r0,[r0]
			cmp r0,#BIGBOSSMODE_NONE
			beq movePowerup3
			
				ldr r0,=spriteActive
				mov r1,#0
				str r1,[r0, r8, lsl #2]
				b noMoreStuff
			
			movePowerup3:

			ldr r0,=spriteY
			ldr r1,[r0,r8,lsl #2]
			add r1,#3							@ move it down screen
			str r1,[r0,r8,lsl #2]
			b noMoreStuff
		movePowerup2:
		cmp r1,#10
		bne movePlayerExplosion
			bl movePowerUp
			b noMoreStuff

		movePlayerExplosion:
		cmp r1,#11								@ -------------- Player explosion
		bne slowPlayerExplosion
			
			ldr r0,=spriteY						@ Load Y coord
			ldr r1,[r0,r8,lsl #2]
			add r1,#1
			str r1,[r0,r8,lsl #2]
			cmp r1,#768
			bpl noMorePexp
			
			ldr r0,=spriteExplodeDelay			@ check our animation delay
			ldr r1,[r0,r8,lsl #2]
			subs r1,#2							@ take 1 off the count					
			movmi r1,#4							@ and reset if <0
			str r1,[r0,r8,lsl #2]
			bpl noMoreStuff
			
			ldr r0,=spriteObj
			ldr r1,[r0,r8,lsl #2]				@ load anim frame
			add r1,#1							@ add 1
			str r1,[r0,r8,lsl #2]				@ store it back
			cmp r1,#14							@ are we at the end frame?
			bne noMoreStuff
				noMorePexp:
				ldr r0,=spriteY
				mov r1,#SPRITE_KILL
				str r1,[r0,r8,lsl #2]

			b noMoreStuff

		slowPlayerExplosion:
		cmp r1,#12								@ -------------- Player explosion
		bne bigBossExplodeSLOW

			ldr r0,=spriteExplodeDelay			@ check our animation delay
			ldr r1,[r0,r8,lsl #2]
			subs r1,#1							@ take 1 off the count					
			movmi r1,#12						@ and reset if <0
			str r1,[r0,r8,lsl #2]
			bpl noMoreStuff
			
			ldr r0,=spriteObj
			ldr r1,[r0,r8,lsl #2]				@ load anim frame
			add r1,#1							@ add 1
			str r1,[r0,r8,lsl #2]				@ store it back
			cmp r1,#14							@ are we at the end frame?
			bne noMoreStuff
				ldr r0,=spriteY
				mov r1,#SPRITE_KILL
				str r1,[r0,r8,lsl #2]
	
				b noMoreStuff
	
		bigBossExplodeSLOW:
		cmp r1,#13								@ -------------- big boss explode
		bne fallingShip

			ldr r0,=spriteY						@ Load Y coord
			ldr r1,[r0,r8,lsl #2]
			add r1,#6
			str r1,[r0,r8,lsl #2]
			cmp r1,#768
			bpl noMorePexp2

			ldr r0,=spriteExplodeDelay			@ check our animation delay
			ldr r1,[r0,r8,lsl #2]
			subs r1,#1							@ take 1 off the count					
			movmi r1,#8						@ and reset if <0
			str r1,[r0,r8,lsl #2]
			bpl noMoreStuff
			
			ldr r0,=spriteObj
			ldr r1,[r0,r8,lsl #2]				@ load anim frame
			add r1,#1							@ add 1
			str r1,[r0,r8,lsl #2]				@ store it back
			cmp r1,#14							@ are we at the end frame?
			bne noMoreStuff
				noMorePexp2:
				ldr r0,=spriteY
				mov r1,#SPRITE_KILL
				str r1,[r0,r8,lsl #2]

		fallingShip:
		cmp r1,#14								@ -------------- a falling alien
		bne noMoreStuff

			ldr r0,=spriteY						@ Load Y coord
			ldr r1,[r0,r8,lsl #2]
			add r1,#5
			str r1,[r0,r8,lsl #2]
			cmp r1,#768
			bpl noMoreDroppings

			mov r7,r8							@ use r1 as offset now, we need r8 for random
			bl getRandom
			and r8,#0xf
			ldr r0,=spriteBloom
			str r8,[r0, r7, lsl #2]
			@ try and generate a random explosion
			bl getRandom
			and r8,#0xff
			cmp r8,#8
			bpl noFallingExplode

				@ ok, we now need to pass X and Y coords to the explode code
				@ use r0, r1 for X and Y
				ldr r0,=spriteX						@ Load Y coord
				ldr r0,[r0,r7,lsl #2]
				ldr r8,=spriteY						@ Load Y coord
				ldr r1,[r8,r7,lsl #2]

				bl generateExplosion

			noFallingExplode:
			mov r8,r7								@ restore r8
			b noMoreStuff
			noMoreDroppings:
			ldr r0,=spriteY
			mov r1,#SPRITE_KILL
			str r1,[r0,r8,lsl #2]
				
		noMoreStuff:

	subs r8,#1
	bpl SLoop

	ldmfd sp!, {pc}
	
generateExplosion:
	@ pass xxx as x and y of explosion
	stmfd sp!, {r0-r8, lr}
	mov r7,#111
	ldr r6,=spriteActive+68
	fxExplodeLoop:
		ldr r3,[r6,r7,lsl #2]
		cmp r3,#0
		beq fxExploder
		subs r7,#1
		cmp r7,#64
	bpl fxExplodeLoop
	ldmfd sp!, {r0-r8, pc}	
	
	fxExploder:
	add r6, r7, lsl #2
	@ r6 is now the pointer to a free spot for an explosion
	@ use _OFFS to address it
	
	mov r3,#4					@ set to a player explosion
	str r3,[r6]					@ spriteActive set to 11
	mov r3,#6
	mov r7,#SPRITE_OBJ_OFFS
	str r3,[r6,r7]				@ set the frame (start at 6)
	mov r8,#4					
	mov r7,#SPRITE_EXP_DELAY_OFFS
	str r8,[r6,r7]				@ set the delay

	mov r7,#SPRITE_X_OFFS
	str r0,[r6,r7]				@ store explosion X

	mov r7,#SPRITE_Y_OFFS
	str r1,[r6,r7]				@ store explosion X	

	bl getRandom
	and r8,#0x1					@ randomly flip the explosion
	mov r7,#SPRITE_HORIZ_FLIP_OFFS
	str r8,[r6,r7]
	
	mov r7,#SPRITE_FIRE_TYPE_OFFS
	mov r3,#0
	str r3,[r6,r7]				@ we NEED to clear this :)
	mov r7,#SPRITE_FIRE_SPEED_OFFS
	mov r3,#0
	str r3,[r6,r7]

	bl playExplosionSound	
	

	
	ldmfd sp!, {r0-r8, pc}	
	.pool
	.end
