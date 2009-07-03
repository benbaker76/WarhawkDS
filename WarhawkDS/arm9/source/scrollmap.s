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
	.global scrollMain
	.global scrollSub
	.global scrollSFMain
	.global scrollSFSub
	.global scrollSBMain
	.global scrollSBSub
	.global scrollStars
	.global scrollStarBack
	.global scrollStarsHoriz
	.global scrollStarsHorizFast
	.global levelDrift
	.global checkEndOfLevel
	
scrollMain:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =levelEnd				@ Has our scroller reached end of level?
	ldr r1, [r0]
	cmp r1, #LEVELENDMODE_NONE
	bne scrollMainDone				@ Yes then lets quit
	
	ldr r0, =pixelOffsetMain
	ldr r1, [r0]
	cmp r1, #32						@ Has our scroller moved 32 pixels?

	moveq r1,#0
	bleq drawMapMain
	
	add r1,#1
	strh r1, [r0]					@ Write it back

	ldr r0, =vofsMain
	ldrh r1, [r0]					@ Load the scroll register
	
	cmp r1, #32						@ Has the scroll regsiter reached 32 (32 is a block size)
	moveq r1, #256+32				@ Yes then set it back to 256+32 (288)
	
	sub r1, #1						@ move up a pixel

	ldr r2, =REG_BG1VOFS			@ Load the address of the scroll register (write only)
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldr r0, =yposMain				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos
	sub r1, #1						@ lets go up one block (4 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
	
scrollMainDone:
		
	ldmfd sp!, {r0-r1, pc} 		@ restore rgisters and return
	
	@---------------------------------

scrollSub:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =levelEnd				@ Has our scroller reached end of level?
	ldr r1, [r0]
	cmp r1, #LEVELENDMODE_NONE
	bne scrollSubDone				@ Yes then lets quit
	
	ldr r0, =pixelOffsetSub
	ldr r1, [r0]
	cmp r1, #32						@ Has our scroller moved 32 pixels?
	
	moveq r1,#0
	bleq drawMapSub					@ If so, time to scroll the map

	add r1, #1						@ Add one to our scroller
	strh r1, [r0]					@ Write it back
	
	ldr r0, =vofsSub
	ldrh r1, [r0]					@ Load the scroll register
	
	cmp r1, #32						@ Has the scroll regsiter reached 32 (32 is a block size)
	moveq r1, #256+32				@ Yes then set it back to 256+32
	
	sub r1, #1						@ move up a pixel

	ldr r2, =REG_BG1VOFS_SUB		@ Load the address of the scroll register (write only)
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldr r0, =yposSub				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos
	sub r1, #1						@ lets go up one block (4 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
	
scrollSubDone:
		
	ldmfd sp!, {r0-r2, pc} 		@ restore rgisters and return
	
	@---------------------------------

scrollSFMain:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =pixelOffsetSFMain
	ldr r1, [r0]
	cmp r1, #64						@ Has our scroller moved 32 pixels?
	
	moveq r1, #0
	bleq scrollSFMapMain			@ If so, time to scroll the map
	
	add r1, #1						@ Add one to our scroller
	strh r1, [r0]					@ Write it back

	ldr r0, =vofsSFMain
	ldrh r1, [r0]					@ Load r2 with the scroll register
	
	cmp r1, #0						@ has our scroll register reached zero?
	moveq r1, #256					@ yes so mov 255 into our scroll register
	
	sub r1, #1						@ move up a pixel
	
	ldr r2, =REG_BG2VOFS			@ R2 is the memory adress for the main scroll
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldmfd sp!, {r0-r2, pc} 		@ restore rgisters and return
	
	@---------------------------------

scrollSFSub:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =pixelOffsetSFSub
	ldr r1, [r0]
	cmp r1, #64						@ Has our scroller moved 32 pixels?
	
	moveq r1, #0
	bleq scrollSFMapSub				@ If so, time to scroll the map
	
	add r1, #1						@ Add one to our scroller
	strh r1, [r0]					@ Write it back

	ldr r0, =vofsSFSub
	ldrh r1, [r0]					@ Load r2 with the scroll register
	
	cmp r1, #0						@ has our scroll register reached zero?
	moveq r1, #256					@ yes so mov 255 into our scroll register
	
	sub r1, #1						@ move up a pixel
	
	ldr r2, =REG_BG2VOFS_SUB		@ R2 is the memory adress for the main scroll
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldmfd sp!, {r0-r2, pc} 		@ restore rgisters and return
	
	@---------------------------------
	
scrollSBMain:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =pixelOffsetSBMain
	ldr r1, [r0]
	cmp r1, #64						@ Has our scroller moved 32 pixels?
	
	moveq r1, #0
	bleq scrollSBMapMain			@ If so, time to scroll the map
	
	add r1, #1						@ Add one to our scroller
	strh r1, [r0]					@ Write it back

	ldr r0, =vofsSBMain
	ldrh r1, [r0]					@ Load r2 with the scroll register
	
	cmp r1, #0						@ has our scroll register reached zero?
	moveq r1, #256					@ yes so mov 255 into our scroll register
	
	sub r1, #1						@ move up a pixel
	
	ldr r2, =REG_BG3VOFS			@ R2 is the memory adress for the main scroll
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldmfd sp!, {r0-r2, pc} 		@ restore rgisters and return
	
	@---------------------------------
	
scrollSBSub:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =pixelOffsetSBSub
	ldr r1, [r0]
	cmp r1, #64						@ Has our scroller moved 32 pixels?
	
	moveq r1, #0
	bleq scrollSBMapSub				@ If so, time to scroll the map
	
	add r1, #1						@ Add one to our scroller
	strh r1, [r0]					@ Write it back

	ldr r0, =vofsSBSub
	ldrh r1, [r0]					@ Load r2 with the scroll register
	
	cmp r1, #0						@ has our scroll register reached zero?
	moveq r1, #256					@ yes so mov 255 into our scroll register
	
	sub r1, #1						@ move up a pixel
	
	ldr r2, =REG_BG3VOFS_SUB		@ R2 is the memory adress for the main scroll
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldmfd sp!, {r0-r2, pc} 		@ restore rgisters and return

	@---------------------------------

scrollSFMapMain:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =yposSFMain				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos
	
	cmp r1,#48						@ If we are at the top, lets go back to the
	moveq r1,#736+64				@ bottom of the map!

	sub r1, #16						@ lets go up one block (64 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
	
	bl drawSFMapMain
	
	ldmfd sp!, {r0-r1, pc} 		@ restore rgisters and return
	
	@---------------------------------

scrollSFMapSub:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =yposSFSub				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos
	
	cmp r1,#48						@ If we are at the top, lets go back to the
	moveq r1,#736+64				@ bottom of the map!
	
	sub r1, #16						@ lets go up one block (64 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
	
	bl drawSFMapSub
	
	ldmfd sp!, {r0-r1, pc} 		@ restore rgisters and return
	
	@---------------------------------
	
scrollSBMapMain:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =yposSBMain				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos

	cmp r1,#48						@ If we are at the top, lets go back to the
	moveq r1,#736+64				@ bottom of the map!

	sub r1, #16						@ lets go up one block (64 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
	
	bl drawSBMapMain
	
	ldmfd sp!, {r0-r1, pc} 		@ restore rgisters and return
	
	@---------------------------------
	
scrollSBMapSub:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =yposSBSub				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos

	cmp r1,#48						@ If we are at the top, lets go back to the
	moveq r1,#736+64				@ bottom of the map!

	sub r1, #16						@ lets go up one block (64 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
	
	bl drawSBMapSub

	ldmfd sp!, {r0-r1, pc} 		@ restore registers and return

	@---------------------------------

scrollStars:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0,=delaySF
	ldr r1,[r0]						@ Delay Starfront for every other update
	subs r1, #1
	bpl noScrollSF
	bl scrollSFMain
	bl scrollSFSub
	mov r1,#2
noScrollSF:
	ldr r0,=delaySF
	str r1,[r0]
	ldr r0,=delaySB					@ Delay Starback for every 4 updates
	ldr r1,[r0]
	subs r1,#1
	bpl noScrollSB
	bl scrollSBMain
	bl scrollSBSub
	mov r1,#4
noScrollSB:
	ldr r0,=delaySB
	str r1,[r0]
	
	ldmfd sp!, {r0-r2, pc}

levelDrift:
	stmfd sp!, {r0-r2, lr}
	ldr r0, =horizDrift
	ldr r0, [r0]
	ldr r1, =REG_BG1HOFS			@ Load our horizontal scroll register for BG1 on the main screen
	ldr r2, =REG_BG1HOFS_SUB		@ Load our horizontal scroll register for BG1 on the sub screen
	strh r0,[r1]
	strh r0,[r2]
	
	lsr r0,#1
	ldr r1, =REG_BG2HOFS			@ Load our horizontal scroll register for BG2 on the main screen
	ldr r2, =REG_BG2HOFS_SUB		@ Load our horizontal scroll register for BG2 on the sub screen
	strh r0,[r1]
	strh r0,[r2]
	lsr r0,#1
	ldr r1, =REG_BG3HOFS			@ Load our horizontal scroll register for BG3 on the main screen
	ldr r2, =REG_BG3HOFS_SUB		@ Load our horizontal scroll register for BG3 on the sub screen
	strh r0,[r1]
	strh r0,[r2]
	ldmfd sp!, {r0-r2, pc}
	
checkEndOfLevel:
	stmfd sp!, {r0-r2, lr}
	
	ldr r0,=levelEnd
	ldr r1,[r0]
	cmp r1,#LEVELENDMODE_NONE
	bne levelPlay
		ldr r0,=yposSub						@ Ypos is the Y position in the map data
		ldr r0, [r0]
		cmp r0, #192 - 32					@ are we at 192 - 32 - top of the map?
		bne levelPlay						@ If so, and scroll is 0 also - Stop Main Scroll!
			ldr r0, =levelEnd
			mov r1, #LEVELENDMODE_BOSSATTACK
			str r1, [r0]
			
			@bl stopAudioStream
			
			@ldr r0, =bossRawText						@ Read the path to the file
			@bl playAudioStream							@ Play the audio stream
			
			@bl fxSineWobbleOn				@ Start our wobble effect (not any more :( SNIFF )
	levelPlay:
	
	ldmfd sp!, {r0-r2, pc}

	@---------------------------------

scrollStarBack:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =delaySB						@ Delay Starback for every 2 updates
	ldr r1, [r0]
	subs r1, #1
	bpl noScrollStarBack
	bl scrollSBMain
	bl scrollSBSub
	mov r1, #2

noScrollStarBack:

@	ldr r0, =delaySB
	str r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}

	@---------------------------------

scrollStarsHoriz:

	stmfd sp!, {r0-r5, lr}
	
@	ldr r0, =delaySF
@	ldr r1, [r0]							@ Delay Starfront for every other update
@	subs r1, #1
@	bne noScrollSFHoriz
	
	ldr r2, =hofsSF
	ldrb r3, [r2]
	add r3, #3
	ldr r4, =REG_BG2HOFS					@ Load our horizontal scroll register for BG1 on the main screen
	ldr r5, =REG_BG2HOFS_SUB				@ Load our horizontal scroll register for BG1 on the sub screen
	strb r3, [r2]
	strb r3, [r4]
	strb r3, [r5]
@	mov r1, #1

noScrollSFHoriz:

@	ldr r0, =delaySF
@	str r1, [r0]
	
	ldr r0, =delaySB						@ Delay Starback for every 4 updates
	ldr r1, [r0]
	subs r1, #1
	bpl noScrollSBHoriz
	
	ldr r2, =hofsSB
	ldr r3, [r2]
	add r3, #1
	ldr r4, =REG_BG3HOFS					@ Load our horizontal scroll register for BG1 on the main screen
	ldr r5, =REG_BG3HOFS_SUB				@ Load our horizontal scroll register for BG1 on the sub screen
	strb r3, [r2]
	strb r3, [r4]
	strb r3, [r5]
	mov r1, #32

noScrollSBHoriz:

	str r1, [r0]
	
	ldmfd sp!, {r0-r5, pc}
	
	@---------------------------------
scrollStarsHorizFast:

	stmfd sp!, {r0-r5, lr}
	
	ldr r0, =delaySB						@ Delay Starback for every 4 updates
	ldr r1, [r0]
	subs r1, #1
	bpl noScrollSBHorizFast
	
	ldr r2, =hofsSB
	ldr r3, [r2]
	add r3, #1
	ldr r4, =REG_BG3HOFS					@ Load our horizontal scroll register for BG1 on the main screen
	ldr r5, =REG_BG3HOFS_SUB				@ Load our horizontal scroll register for BG1 on the sub screen
	strb r3, [r2]
	strb r3, [r4]
	strb r3, [r5]
	bl scrollSBSub
	bl scrollSBMain
	mov r1,#8
noScrollSBHorizFast:

	str r1, [r0]
	
	ldmfd sp!, {r0-r5, pc}
	
	
	.pool
	.end

