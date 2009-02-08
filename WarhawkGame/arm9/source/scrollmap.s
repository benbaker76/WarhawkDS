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
	.global scrollMain
	.global scrollSub
	.global scrollSFMain
	.global scrollSFSub
	.global scrollSBMain
	.global scrollSBSub
	.global scrollStars
	.global levelDrift
	.global checkEndOfLevel

@------------------------------------
	
scrollMain:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =levelEnd				@ Has our scroller reached end of level?
	ldrb r1, [r0]
	cmp r1, #0
	bne scrollDone					@ Yes then lets quit
	
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
	moveq r1, #288					@ Yes then set it back to 256+32 (288)
	
	sub r1, #1						@ move up a pixel

	ldr r2, =REG_BG1VOFS			@ Load the address of the scroll register (write only)
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldr r0, =yposMain				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos
	sub r1, #1						@ lets go up one block (4 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
		
	ldmfd sp!, {r0-r6, pc} 		@ restore rgisters and return
	
@---------------------------------

scrollSub:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =levelEnd				@ Has our scroller reached end of level?
	ldrb r1, [r0]
	cmp r1, #0
	bne scrollDone					@ Yes then lets quit
	
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
		
	ldmfd sp!, {r0-r6, pc} 		@ restore rgisters and return
	
@---------------------------------





scrollSFMain:
	stmfd sp!, {r0-r6, lr} 

	ldr r0, =vofsSFMain
	ldrh r1, [r0]					@ Load r2 with the scroll register
	
	cmp r1, #0						@ has our scroll register reached zero?
	bleq scrollSFMapMain			@ yes so we need to write the next chunk of map to VRAM
	ldr r2, =255					@ load 255
	cmp r1, #0						@ has our scroll register reached zero?
	moveq r1, r2					@ yes so mov 255 into our scroll register
	
	subs r1, r1, #1					@ move up a pixel
	ldr r2, =REG_BG2VOFS			@ R2 is the memory adress for the main scroll
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldmfd sp!, {r0-r6, pc} 		@ restore rgisters and return

scrollSFSub:
	stmfd sp!, {r0-r6, lr}	

	ldr r0, =vofsSFSub
	ldrh r1, [r0]					@ Load r2 with the scroll register
	
	cmp r1, #0						@ has our scroll register reached zero?
	bleq scrollSFMapSub				@ yes so we need to write the next chunk of map to VRAM
	ldr r2, =255					@ load 255
	cmp r1, #0						@ has our scroll register reached zero?
	moveq r1, r2					@ yes so mov 255 into our scroll register
	
	subs r1, r1, #1					@ move up a pixel
	ldr r2, =REG_BG2VOFS_SUB		@ R2 is the memory adress for the main scroll
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldmfd sp!, {r0-r6, pc} 		@ restore rgisters and return
	
scrollSBMain:
	stmfd sp!, {r0-r6, lr} 	

	ldr r0, =vofsSBMain
	ldrh r1, [r0]					@ Load r2 with the scroll register
	
	cmp r1, #0						@ has our scroll register reached zero?
	bleq scrollSBMapMain			@ yes so we need to write the next chunk of map to VRAM
	ldr r2, =255					@ load 255
	cmp r1, #0						@ has our scroll register reached zero?
	moveq r1, r2					@ yes so mov 255 into our scroll register
	
	subs r1, r1, #1					@ move up a pixel
	ldr r2, =REG_BG3VOFS			@ R2 is the memory adress for the main scroll
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldmfd sp!, {r0-r6, pc} 		@ restore rgisters and return
	
scrollSBSub:
	stmfd sp!, {r0-r6, lr}	

	ldr r0, =vofsSBSub
	ldrh r1, [r0]					@ Load r2 with the scroll register
	
	cmp r1, #0						@ has our scroll register reached zero?
	bleq scrollSBMapSub				@ yes so we need to write the next chunk of map to VRAM
	ldr r2, =255					@ load 255
	cmp r1, #0						@ has our scroll register reached zero?
	moveq r1, r2					@ yes so mov 255 into our scroll register
	
	subs r1, r1, #1					@ move up a pixel
	ldr r2, =REG_BG3VOFS_SUB		@ R2 is the memory adress for the main scroll
	strh r1, [r0]
	strh r1, [r2]					@ write our scroll counter into REG_BG0VOFS main screen
	
	ldmfd sp!, {r0-r6, pc} 		@ restore rgisters and return
	
scrollSFMapMain:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =yposSFMain				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos
	
	cmp r1,#0						@ If we are at the top, lets go back to the
	moveq r1,#832					@ bottom of the map!

	sub r1, #64						@ lets go up one block (64 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
	bl drawSFMapMain
	
	ldmfd sp!, {r0-r6, pc} 		@ restore rgisters and return

scrollSFMapSub:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =yposSFSub				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos
	
	cmp r1,#0						@ If we are at the top, lets go back to the
	moveq r1,#832					@ bottom of the map!
	
	sub r1, #64						@ lets go up one block (64 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
	bl drawSFMapSub
	
	ldmfd sp!, {r0-r6, pc} 		@ restore rgisters and return
	
scrollSBMapMain:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =yposSBMain				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos

	cmp r1,#0						@ If we are at the top, lets go back to the
	moveq r1,#832					@ bottom of the map!

	sub r1, #64						@ lets go up one block (64 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
	bl drawSBMapMain
	
	ldmfd sp!, {r0-r6, pc} 		@ restore rgisters and return
	
scrollSBMapSub:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =yposSBSub				@ grab ypos memory adress
	ldr r1, [r0]					@ r3 = ypos

	cmp r1,#0						@ If we are at the top, lets go back to the
	moveq r1,#832					@ bottom of the map!

	sub r1, #64						@ lets go up one block (64 tiles) on the map
	strh r1, [r0]					@ and put the value back for later
	bl drawSBMapSub
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return
	
scrollDone:
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return
	
scrollStars:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0,=delaySF
	ldr r1,[r0]						@ Delay Starfront for every other update
	subs r1, #1
	bne noScrollSF
	bl scrollSFMain
	bl scrollSFSub
	mov r1,#2
noScrollSF:
	ldr r0,=delaySF
	str r1,[r0]
	ldr r0,=delaySB					@ Delay Starback for every 4 updates
	ldr r1,[r0]
	subs r1,#1
	bne noScrollSB
	bl scrollSBMain
	bl scrollSBSub
	mov r1,#4
noScrollSB:
	ldr r0,=delaySB
	str r1,[r0]
	
	ldmfd sp!, {r0-r6, pc}

levelDrift:
	ldr r0, =horizDrift
	ldr r0, [r0]
	ldr r1, =REG_BG1HOFS			@ Load our horizontal scroll register for BG1 on the main screen
	ldr r2, =REG_BG1HOFS_SUB		@ Load our horizontal scroll register for BG1 on the sub screen
	strh r0,[r1]
	strh r0,[r2]
	mov r15,r14
	
checkEndOfLevel:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0,=levelEnd
	ldrb r1,[r0]
	cmp r1,#0
	bne levelPlay
		ldr r0,=yposSub						@ Ypos is the Y position in the map data
		ldr r0, [r0]
		cmp r0, #192 - 32					@ are we at 192 - 32 - top of the map?
		bne levelPlay						@ If so, and scroll is 0 also - Stop Main Scroll!
			ldr r0, =levelEnd
			mov r1, #1
			strb r1, [r0]
	levelPlay:
	
	ldmfd sp!, {r0-r6, pc}

	.end
