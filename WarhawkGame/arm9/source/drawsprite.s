#include "warhawk.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

#define BUF_ATTRIBUTE0		(0x07000000)
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
	ldr r0,=spriteActive
	ldr r1,[r0,r8, lsl #2]
	cmp r1,#1							@ Is sprite active?
	beq sprites_Drawn					@ if so, draw it!
	@ Kill sprite
		@ Kill sprite on both screens!!!!!
		@ note: read the setting - daft prat!!!	
		ldr r0,=BUF_ATTRIBUTE0
		add r0,r8, lsl #3
		mov r2,#0
		str r2,[r0]
		add r0,#2
		str r2,[r0]		
		add r0,#2
		str r2,[r0]
		ldr r0,=BUF_ATTRIBUTE0_SUB
		add r0,r8, lsl #3
		mov r2,#0
		str r2,[r0]
		add r0,#2
		str r2,[r0]		
		add r0,#2
		str r2,[r0]
	b sprites_Done
	sprites_Drawn:
	
	ldr r0,=spriteY						@ Load Y coord
	ldr r1,[r0,r8,lsl #2]				@ add ,rX for offsets
	ldr r3,=383-32
	cmp r1,r3
	bmi sprites_Done
	ldr r3,=576+32
	cmp r1,r3
	bpl spriteY_Main_Done				@ Totally ON MAIN
	ldr r3,=576-32
	cmp r1,r3						@ Totally ON SUB
	bmi spriteY_Sub_Done

		@ The sprite is now between 2 screens and needs to be drawn to BOTH!
		@ Draw Y to MAIN screen (lower)
		ldr r0,=BUF_ATTRIBUTE0
		add r0,r8, lsl #3
		ldr r2, =(ATTR0_COLOR_16 | ATTR0_SQUARE)
		ldr r3,=576-32
		sub r1,r3
		cmp r1,#32
		addmi r1,#255
		sub r1,#32
		and r1,#0xff					@ Y is only 0-255
		orr r2,r1
		strh r2,[r0]
		@ Draw X to MAIN screen
		ldr r0,=spriteX					@ get X coord mem space
		ldr r1,[r0,r8,lsl #2]			@ add ,Rx for offsets later!
		cmp r1,#64						@ if less than 64, this is off left of screen
		addmi r1,#512					@ convert coord for offscreen (32 each side)
		sub r1,#64						@ Take 64 off our X
		sub r1,r4						@ account for maps horizontal position
		ldr r3,=0x1ff					@ Make sure 0-512 only as higher would affect attributes
		ldr r0,=BUF_ATTRIBUTE1
		add r0,r8, lsl #3		
		ldr r2, =(ATTR1_SIZE_32)
		and r1,r3
		orr r2,r1
		strh r2,[r0]
			@ Draw Attributes
		ldr r0,=BUF_ATTRIBUTE2
		add r0,r8, lsl #3
		ldr r2,=spriteObj
		ldr r3,[r2,r8, lsl #2]
		ldr r1,=(0 | ATTR2_PRIORITY(SPRITE_PRIORITY) | ATTR2_PALETTE(0))
		orr r1,r3, lsl #4	
		str r1, [r0]

		ldr r0,=spriteY					@ Load Y coord
		ldr r1,[r0,r8,lsl #2]	
	@ Sprite on top screen
	spriteY_Sub_Done:
		@ Draw sprite to SUB screen (r1 holds Y)

		ldr r0,=BUF_ATTRIBUTE0_SUB
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
	subs r8,#1
	bpl SLoop

	mov r15,r14
