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
	.global drawSprite

drawSprite:
	mov r8,#127				@ our counter for 128 sprites, do not think we need them all though
	ldr r4,=horizDrift	 	@ here we will set r4 as an adder for sprite offset
	ldr r4,[r4]				@ against our horizontal scroll
	
	SLoop:
	cmp r8,#0				@ if we are on our ship
	moveq r4,#0				@ then we dont need to add anything
							@ as our ship is not tied to the background
	
	@ If coord is <192 then plot on sub (upper)
	@ if >256 plot on main (lower)
	@ but, if on crossover, we need to plot 2 ships!!!
	@ one on each screen in the correct location!!
	@ Last section best commented!
	ldr r0,=spriteActive				@ r2 is pointer to the sprite active setting
	ldr r1,[r0,r8, lsl #2]				@ add sprite number * 8
	cmp r1,#0							@ Is sprite active? (anything other than 0)
	bne sprites_Drawn					@ if so, draw it!
										@ if not Kill sprite
		@ Kill sprite on both screens!!!!!
		@ note: read the setting - daft prat!!!
		mov r1, #ATTR0_DISABLED
		ldr r0,=BUF_ATTRIBUTE0
		add r0,r8, lsl #3
		str r1,[r0]
		ldr r0,=BUF_ATTRIBUTE0_SUB
		add r0,r8, lsl #3
		str r1,[r0]
	b sprites_Done

	sprites_Drawn:
	
	ldr r0,=spriteY						@ Load Y coord
	ldr r1,[r0,r8,lsl #2]				@ add ,rX for offsets
	ldr r3,=383-32						@ if it offscreen?
	cmp r1,r3							@ if it is less than - then it is in whitespace
	bmi sprites_Done					@ so, no need to draw it!
	ldr r3,=576+32						@ now is it on the main screen
	cmp r1,r3							@ check
	bpl spriteY_Main_Done				@ if so, we need only draw to main
	ldr r3,=576-32						@ is it totally on the sub
	cmp r1,r3						@ Totally ON SUB
	bmi spriteY_Sub_Done

		@ The sprite is now between 2 screens and needs to be drawn to BOTH!
		@ Draw Y to MAIN screen (lower)
		ldr r0,=BUF_ATTRIBUTE0			@ get the sprite attribute0 base
		add r0,r8, lsl #3				@ add spritenumber *8
		ldr r2, =(ATTR0_COLOR_16 | ATTR0_SQUARE)
		ldr r3,=576-32					@ make r3 the value of top screen -sprite height
		sub r1,r3						@ subtract our sprites y coord
		cmp r1,#32						@ check if it is less than sprites height (off top)
		addmi r1,#255					@ if so, add #255 (make it offscreen)
		sub r1,#32						@ take our height off
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
		strh r2,[r0]					@ and store back
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2			@ load ref to attribute2
		add r0,r8, lsl #3				@ add sprite number * 8
		ldr r2,=spriteObj				@ make r2 a ref to our data for the sprites object
		ldr r3,[r2,r8, lsl #2]			@ r3=spriteobj+ sprite number *4 (stored in words)
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY) | ATTR2_PALETTE(0))
		orr r1,r3, lsl #4				@ or r1 with sprite pointer *16 (for sprite data block)
		str r1, [r0]					@ store it all back

		ldr r0,=spriteY					@ Load Y coord
		ldr r1,[r0,r8,lsl #2]			
	@ DRAW the Sprite on top screen
	spriteY_Sub_Done:
		@ Draw sprite to SUB screen (r1 holds Y)

		ldr r0,=BUF_ATTRIBUTE0_SUB		@ this all works in the same way as other sections
		add r0,r8, lsl #3
		ldr r2, =(ATTR0_COLOR_16 | ATTR0_SQUARE)
		ldr r3,=384
		cmp r1,r3
		addmi r1,#255
		sub r1,r3
		and r1,#0xff					@ Y is only 0-255
		orr r2,r1
		strh r2,[r0]
		@ Draw X
		ldr r0,=spriteX					@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]			@ add ,rX for offsets
		cmp r1,#64						@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#64						@ Take 64 off our X
		sub r1,r4						@ account for maps horizontal position
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1_SUB		@
		add r0,r8, lsl #3
		ldr r2, =(ATTR1_SIZE_32)
		and r1,r3
		orr r2,r1
		strh r2,[r0]
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2_SUB
		add r0,r8, lsl #3
		ldr r2,=spriteObj
		ldr r3,[r2,r8, lsl #2]
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY) | ATTR2_PALETTE(0))
		orr r1,r3, lsl #4		
		str r1, [r0]

		@ Need to kill same sprite on MAIN screen - or do we???
		@ Seeing that for this to occur, the sprite is offscreen on MAIN!
	
		b sprites_Done
	
	spriteY_Main_Done:
		@ Draw sprite to MAIN
		ldr r0,=BUF_ATTRIBUTE0
		add r0,r8, lsl #3
		ldr r2, =(ATTR0_COLOR_16 | ATTR0_SQUARE)	@ These will not change in our game!
		ldr r3,=576-32				@ Calculate offsets
		sub r1,r3					@ R1 is STILL out Y coorrd
		cmp r1,#32					@ Acound for partial display
		addmi r1,#255				@ Modify if so (create a wrap)
		sub r1,#32					@ Take our sprite height off
		and r1,#0xff				@ Y is only 0-255
		orr r2,r1					@ Orr Y back with data in R2
		strh r2,[r0]				@ Store Y back
		@ Draw X
		ldr r0,=spriteX				@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]		@ add ,rX for offsets
		cmp r1,#64					@ if less than 64, this is off left of screen
		addmi r1,#512				@ convert coord for offscreen (32 each side)
		sub r1,#64					@ Take 64 off our X
		
		sub r1,r4					@ account for maps horizontal position
		
		ldr r3,=0x1ff				@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1
		add r0,r8, lsl #3			@ Add offset (attribs in blocks of 8)
		ldr r2, =(ATTR1_SIZE_32)	@ Need a way to modify! 16384,32768,49152 = 16,32,64
		and r1,r3					@ kick out extranious on the Coord
		orr r2,r1					@ Stick the Coord and Data together
		strh r2,[r0]				@ and store them!
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2		@ Find out Buffer Attribute
		add r0,r8, lsl #3			@ multiply by 8 to find location (in r0)
		ldr r2,=spriteObj			@ Find our sprite to draw
		ldr r3,[r2,r8, lsl #2]		@ store in words (*2)
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY) | ATTR2_PALETTE(0))	@ Set Palette - do we need to keep doing this?
		orr r1,r3, lsl #4			@ Orr them together, R3 is mult by 16 (16 tiles in sprite *2)
		
		str r1, [r0]				@ Store it all back
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
			cmp r1,#768
			bpl noMoreBase
			
			ldr r0,=spriteExplodeDelay
			ldr r1,[r0,r8,lsl #2]
			subs r1,#1
			movmi r1,#3
			str r1,[r0,r8,lsl #2]
			bpl noMoreStuff
			
			ldr r0,=spriteObj
			ldr r1,[r0,r8,lsl #2]				@ load anim frame
			add r1,#1							@ add 1
			str r1,[r0,r8,lsl #2]				@ store it back
			cmp r1,#22							@ are we at the end frame?
			bne noMoreStuff
				noMoreBase:
				ldr r0,=spriteActive
				mov r1,#0						@ kill sprite (next update)
				str r1,[r0,r8,lsl #2]
			b noMoreStuff
		alienExplodes:
		cmp r1,#4								@ -------------- Alien explosion
		bne shardAnimates
			
			ldr r0,=spriteY						@ Load Y coord
			ldr r1,[r0,r8,lsl #2]
			add r1,#1							@ add 1 and store back
			str r1,[r0,r8,lsl #2]
			cmp r1,#768
			bpl noMoreAlien
			
			ldr r0,=spriteExplodeDelay			@ check our animation delay
			ldr r1,[r0,r8,lsl #2]
			subs r1,#1							@ take 1 off the count					
			movmi r1,#3							@ and reset if <0
			str r1,[r0,r8,lsl #2]
			bpl noMoreStuff
			
			ldr r0,=spriteObj
			ldr r1,[r0,r8,lsl #2]				@ load anim frame
			add r1,#1							@ add 1
			str r1,[r0,r8,lsl #2]				@ store it back
			cmp r1,#13							@ are we at the end frame?
			bne noMoreStuff
				noMoreAlien:
				ldr r0,=spriteActive
				mov r1,#0						@ kill sprite (next update)
				str r1,[r0,r8,lsl #2]	
			b noMoreStuff

		shardAnimates:
		cmp r1,#6								@ -------------- Shard Animation
		bne whatNext
			
			ldr r0,=spriteY						@ Load Y coord
			ldr r1,[r0,r8,lsl #2]
			add r1,#3							@ add 1 and store back
			str r1,[r0,r8,lsl #2]
			cmp r1,#768
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
				ldr r0,=spriteActive
				mov r1,#0						@ kill sprite (next update)
				str r1,[r0,r8,lsl #2]	
			b noMoreStuff


		whatNext:

		noMoreStuff:
	subs r8,#1
	bpl SLoop

	mov r15,r14
	
