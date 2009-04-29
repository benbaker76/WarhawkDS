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
	.global initLogoSprites
	.global updateLogoSprites
	
initLogoSprites:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =LogoSpritesTiles
	ldr r1, =SPRITE_GFX
	ldr r2, =LogoSpritesTilesLen
	bl dmaCopy

	ldr r0, =OBJ_ROTATION_HDX(0)
	ldr r1, =OBJ_ROTATION_VDY(0)
	mov r2, #256
	strh r2, [r0]
	strh r2, [r1]
	
	ldr r0, =OBJ_ROTATION_VDX(0)
	ldr r1, =OBJ_ROTATION_HDY(0)
	mov r2, #0
	strh r2, [r0]
	strh r2, [r1]
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
updateLogoSprites:

	stmfd sp!, {r0-r6, lr}
	
	mov r4, #0									@ Reset iterator
	
updateLogoSpritesLoop:

	ldr r0, =OBJ_ATTRIBUTE0(0)					@ Attrib 0
	ldr r1, =(ATTR0_COLOR_16 | ATTR0_ROTSCALE_DOUBLE | ATTR0_SQUARE)	@ Attrib 0 settings
	add r0, r4, lsl #3							@ Iterator * 8 (OBJ_ATTRIBUTE0(n))
	ldr r3, =SIN_bin							@ Load SIN address
	ldr r5, =vblCounter							@ Load VBLANK counter address
	ldr r5, [r5]								@ Load VBLANK counter value
	add r5, r4, lsl #5							@ Add the iterator * 32
	ldr r6, =0x1FF								@ Load 0x1FF (511)
	and r5, r6									@ And VBLANK counter with 511
	lsl r5, #1									@ Multiply * 2 (16 bit SIN values)
	add r3, r5									@ Add the offset to the SIN table
	ldrsh r5, [r3]								@ Read the SIN table value (signed 16-bit value)
	lsr r5, #6									@ Right shift SIN value to make it smaller
	add r5, #64									@ Add the Y offset
	and r5, #0xFF								@ And with 0xFF so no overflow
	orr r1, r5									@ Orr in Y offset with settings
	strh r1, [r0]								@ Write to attrib 0
	
	ldr r0, =OBJ_ATTRIBUTE1(0)					@ Attrib 1
	ldr r1, =(ATTR1_ROTDATA(0) | ATTR1_SIZE_32)		@ Attrib 1 settings
	add r0, r4, lsl #3							@ Iterator * 8 (OBJ_ATTRIBUTE1(n))
	ldr r3, =COS_bin							@ Load COS address
	ldr r5, =vblCounter							@ Load VBLANK counter address
	ldr r5, [r5]								@ Load VBLANK counter value
	add r5, r4, lsl #5							@ Add the iterator * 32
	ldr r6, =0x1FF								@ Load 0x1FF (511)
	and r5, r6									@ And VBLANK counter with 511
	lsl r5, #1									@ Multiply * 2 (16 bit COS values)
	add r3, r5									@ Add the offset to the COS table
	ldrsh r5, [r3]								@ Read the COS table value (signed 16-bit value)
	lsr r5, #7									@ Right shift COS value to make it smaller
	add r5, #4									@ Add the X offset
	add r5, r4, lsl #5							@ Add Iterator * 32 to X Offset
	ldr r6, =0x1FF								@ Load 0x1FF
	and r5, r6									@ And with 0x1FF so no overflow
	orr r1, r5									@ Orr in X offset with settings
	strh r1, [r0]								@ Write to attrib 1
		
	ldr r0, =OBJ_ATTRIBUTE2(0)					@ Attrib 2
	add r0, r4, lsl #3							@ Iterator * 8 (OBJ_ATTRIBUTE2(n))
	mov r1, r4, lsl #4							@ Iterator * 16
	mov r3, #ATTR2_PRIORITY(1)					@ Set sprite priority
	orr r1, r3									@ Or in settings
	strh r1, [r0]								@ Write to attrib 2
	
	mov r0, #0
	ldr r3, =SIN_bin							@ Load SIN address
	ldr r5, =vblCounter							@ Load VBLANK counter address
	ldr r1, [r5]								@ Load VBLANK counter value
	add r1, r4, lsl #5							@ Add the iterator * 32
	ldr r6, =0x1FF								@ Load 0x1FF (511)
	and r1, r6									@ And VBLANK counter with 511
	lsl r1, #1									@ Multiply * 2 (16 bit SIN values)
	add r3, r1									@ Add the offset to the SIN table
	ldrsh r1, [r3]								@ Read the SIN table value (signed 16-bit value)
	lsr r1, #7									@ Right shift SIN value to make it smaller
	add r1, #160
	bl scaleSprite
	@bl rotateSprite
	
	add r4, #1									@ Add 1 to iterator
	cmp r4, #7									@ Drawn 7 sprites yet?
	bne updateLogoSpritesLoop					@ No so loop
	
	ldr r0, =vblCounter							@ Load VBLANK counter
	ldr r1, [r0]								@ Load VBLANK value
	add r1, #4									@ Add 4 to VBLANK counter
	str r1, [r0]								@ Store back
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
rotateSprite:

	stmfd sp!, {r0-r6, lr}
	
	@ r0 - ATTR1_ROTDATA(r0)
	@ r1 - angle

	ldr r4, =0x1FF								@ Load our mask to r4
	and r1, r4									@ And our mask with our angle
	lsl r1, #1									@ Multiply by 2 (16 bit data)
	ldr r4, =SIN_bin							@ Load the address of our SIN table
	ldr r5, =COS_bin							@ Load the address of our COS table
	ldrsh r2, [r4, r1]							@ Now read the SIN table
	ldrsh r3, [r5, r1]							@ Now read the COS table
	asr r2, #4									@ Right shift the SIN value 4 bits
	mov r6, r2									@ Make a copy of our SIN value (-SIN[angle & 0x1FF] >> 4)
	rsb r2, r2, #0								@ Reverse subtract to make it negative (r2=#0 - r2)
	asr r3, #4									@ Right shift the COS value 4 bits  (c = COS[angle & 0x1FF] >> 4)
	ldr r4, =OBJ_ROTATION_HDX(0)				@ This is the HDX address of the sprite
	ldr r5, =OBJ_ROTATION_HDY(0)				@ This is the HDY address of the sprite
	add r4, r0, lsl #5							@ Add r0 offset
	add r5, r0, lsl #5							@ Add r0 offset
	strh r3, [r4]								@ Write our COS value to HDX (hdx = c)
	strh r6, [r5]								@ Write our SIN value to HDY (hdy = -s)
	ldr r4, =OBJ_ROTATION_VDX(0)				@ This is the VDX address of the sprite
	ldr r5, =OBJ_ROTATION_VDY(0)				@ This is the VDY address of the sprite
	add r4, r0, lsl #5							@ Add r0 offset
	add r5, r0, lsl #5							@ Add r0 offset
	strh r2, [r4]								@ Write our SIN value to VDX (vdx = s)
	strh r3, [r5]								@ Write our COS value to VDY (vdy = c)
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
scaleSprite:

	stmfd sp!, {r0-r6, lr}
	
	@ r0 - ATTR1_ROTDATA(r0)
	@ r1 - scale

	mov r2, #0
	ldr r4, =OBJ_ROTATION_HDX(0)				@ This is the HDX address of the sprite
	ldr r5, =OBJ_ROTATION_HDY(0)				@ This is the HDY address of the sprite
	add r4, r0, lsl #5							@ Add r0 offset
	add r5, r0, lsl #5							@ Add r0 offset
	strh r1, [r4]								@ Sx
	strh r2, [r5]								@ 0
	ldr r4, =OBJ_ROTATION_VDX(0)				@ This is the VDX address of the sprite
	ldr r5, =OBJ_ROTATION_VDY(0)				@ This is the VDY address of the sprite
	add r4, r0, lsl #5							@ Add r0 offset
	add r5, r0, lsl #5							@ Add r0 offset
	strh r2, [r4]								@ 0
	strh r1, [r5]								@ Sy
	
	ldmfd sp!, {r0-r6, pc} 					@ restore registers and return
	
	@---------------------------------
	
	.data
	.align
	
vblCounter:
	.word 0
	
	.pool
	.end
