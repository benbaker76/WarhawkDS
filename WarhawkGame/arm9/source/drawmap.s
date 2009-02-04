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
	.global drawCraterBlockMain
	.global drawCraterBlockSub
	.global drawMapScreenMain
	.global drawMapScreenSub
	.global drawMapMain
	.global drawMapSub
	.global drawSFMapMain
	.global drawSFMapSub
	.global drawSBMapMain
	.global drawSBMapSub
	
checkCraterBlockMain:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =colMap					@ collision map
	ldr r1, =yposMain
	ldr r2, =vofsMain

	ldr r4, [r1]
	lsr r4, #3						@ Divide by 8 to get tile offset
	
	ldr r5, [r2]
	sub r5, #32						@ One line of tiles offset (for drawing tiles offscreen)
	
	lsr r4, #2						@ divide by 4
	lsl r4, #4						@ multiply by 16
	
	mov r6, #0
	add r0, r4						@ calculate collision map offset
	
checkCraterBlockMainLoop:

	cmp r6, #16
	beq checkCraterBlockMainExit
	
	ldr r0, =colMap	
	add r0, r4
	ldrb r3, [r0, r6]				@ read the value

	mov r0, r6, lsl #2				@ multiply by 4
	mov r1, r5, lsr #3				@ divide by 8
	
	cmp r3, #2						@ is it destructable?	
	bleq drawCraterBlockMain
	
	add r6, #1
	
	bl checkCraterBlockMainLoop
	
checkCraterBlockMainExit:

	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return
	
	

	
	
	
	
	
	
	
	
drawCraterBlockMain:

	@ r0 = xpos in VRAM
	@ r1 = ypos in VRAM

	stmfd sp!, {r2-r6, lr}
	
	ldr r2, =Level1Map				@ source
	ldr r3, =BG_MAP_RAM(BG1_MAP_BASE)	@ destination
	ldr r4, =0						@ xpos (in the LevelMap)
	ldr r5, =496					@ ypos (in the LevelMap)
	
	add r3, r4, lsl #1				@ Add xpos * 2
	add r2, r5, lsl #7				@ Add ypos * (64*2)

	cmp r1,#31
	subgt r1,#32
	
	cmp r0, #31						@ If xpos > 31 then we need to jump a screen block
	addgt r1, #31					@ Yes so add 32 tiles to ypos

	
	add r3, r0, lsl #1				@ Add xpos * 2
	add r3, r1, lsl #6				@ Add ypos * 64
	
	mov r0, r2
	mov r1, r3
	ldr r2, =8						@ 4 * 2 tiles * 2
	ldr r3, =64						@ 64 tiles
	ldr r4, =3
	bl dmaCopy

drawCraterBlockMainLoop:

	add r0, r3, lsl #1				@ (64 * 2) tiles
	add r1, r3						@ 64 tiles
	bl dmaCopy
	
	subs r4, r4, #1
	bne drawCraterBlockMainLoop
	
	ldmfd sp!, {r2-r6, pc} 		@ restore registers and return
	
	
drawCraterBlockSub:

	@ r0 = xpos in VRAM
	@ r1 = ypos in VRAM

	stmfd sp!, {r2-r6, lr}
	
	ldr r2, =Level1Map				@ source
	ldr r3, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r4, =0						@ xpos (in the LevelMap)
	ldr r5, =496					@ ypos (in the LevelMap)
	
	add r3, r4, lsl #1				@ Add xpos * 2
	add r2, r5, lsl #7				@ Add ypos * (64*2)

	cmp r1,#31
	subgt r1,#32

	cmp r0, #31						@ If xpos > 31 then we need to jump a screen block
	addgt r1, #31					@ Yes so add 32 tiles to ypos
	
	add r3, r0, lsl #1				@ Add xpos * 2
	add r3, r1, lsl #6				@ Add ypos * 64
	
	mov r0, r2
	mov r1, r3
	ldr r2, =8						@ 4 * 2 tiles * 2
	ldr r3, =64						@ 64 tiles
	ldr r4, =3
	bl dmaCopy
	
drawCraterBlockSubLoop:

	add r0, r3, lsl #1				@ (64 * 2) tiles
	add r1, r3						@ 64 tiles
	bl dmaCopy
	
	subs r4, r4, #1
	bne drawCraterBlockSubLoop
	
	ldmfd sp!, {r2-r6, pc} 		@ restore registers and return
	

drawMapMain:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =Level1Map				@ source
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)	@ destination
	ldr r2, =yposMain				@
	ldr r3, =vofsMain
	
	ldr r4, [r2]					@ load y2 with ypos (map reference)
	lsr r4, #3						@ Divide by 8 to get tile offset
	
	ldr r5, [r3]
	sub r5, #32						@ One line of tiles offset (for drawing tiles offscreen)
	
	add r0, r4, lsl #7				@ yposMain * (64*2) added to Level1Map
	add r1, r5, lsl #3				@ vofsMain * 8 pixels per scroll line added to map address
	
	ldr r2, =64						@ 32x2 for a line of tiles
	mov r4, r1
	ldr r5, =2048					@ Skip block (32x32x2)
	bl dmaCopy
	
	mov r6, #1
	
drawMapMainLoop:

	add r0, r2
	add r1, r5
	bl dmaCopy
	
	cmp r6, #4						@ Have we drawn 4 rows of tiles?
	beq drawMapMainDone				@ Yes then lets exit

	mov r1, r4						@ Draw the tiles x > 256 on second screen block
	add r0, r2
	mov r3, r2
	mul r3, r6
	add r1, r3
	bl dmaCopy
	
	add r6, #1
	b drawMapMainLoop
	
drawMapMainDone:

	bl checkCraterBlockMain

	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return

drawMapSub:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =Level1Map				@ source
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =yposSub				@
	ldr r3, =vofsSub
	
	ldr r4, [r2]					@ load y2 with ypos (map reference)
	lsr r4, #3						@ Divide by 8 to get tile offset
	
	sub r4, #24						@ 24 tiles offset
	ldr r5, [r3]
	sub r5, #32						@ One line of tiles offset (for drawing tiles offscreen)
	
	add r0, r4, lsl #7				@ yposMain * (64*2) added to Level1Map
	add r1, r5, lsl #3				@ vofsMain * 8 pixels per scroll line added to map address
	
	ldr r2, =64						@ 32x2 for a line of tiles
	mov r4, r1
	ldr r5, =2048					@ Skip block (32x32x2)
	bl dmaCopy
	
	mov r6, #1
	
drawMapSubLoop:

	add r0, r2
	add r1, r5
	bl dmaCopy
	
	cmp r6, #4						@ Have we drawn 4 rows of tiles?
	beq drawMapSubDone				@ Yes then lets exit

	mov r1, r4						@ Draw the tiles x > 256 on second screen block
	add r0, r2
	mov r3, r2
	mul r3, r6
	add r1, r3
	bl dmaCopy
	
	add r6, #1
	b drawMapSubLoop
	
drawMapSubDone:

	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	@ -----------------------------------
	
	
drawMapScreenMain:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =Level1Map				@ source
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)	@ destination
	ldr r2, =yposMain				@
	
	ldr r4, [r2]					@ load y2 with ypos (map reference)
	lsr r4, #3						@ Divide by 8 to get tile offset
	
	add r0, r4, lsl #7				@ yposMain * (64*2) added to Level1Map
	
	ldr r2, =64						@ 32x2 for a line of tiles
	mov r4, r1
	ldr r5, =2048					@ Skip block (32x32x2)
	bl dmaCopy
	
	mov r6, #1
	
drawMapScreenMainLoop:

	add r0, r2
	add r1, r5
	bl dmaCopy
	
	cmp r6, #32						@ Have we drawn 4 rows of tiles?
	beq drawMapScreenMainDone		@ Yes then lets exit

	mov r1, r4						@ Draw the tiles x > 256 on second screen block
	add r0, r2
	mov r3, r2
	mul r3, r6
	add r1, r3
	bl dmaCopy
	
	add r6, #1
	b drawMapScreenMainLoop
	
drawMapScreenMainDone:

	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return

drawMapScreenSub:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =Level1Map				@ source
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)	@ destination
	ldr r2, =yposSub				@
	
	ldr r4, [r2]					@ load y2 with ypos (map reference)
	lsr r4, #3						@ Divide by 8 to get tile offset
	sub r4, #24						@ 24 tiles offset
	
	add r0, r4, lsl #7				@ yposMain * (64*2) added to Level1Map
	
	ldr r2, =64						@ 32x2 for a line of tiles
	mov r4, r1
	ldr r5, =2048					@ Skip block (32x32x2)
	bl dmaCopy
	
	mov r6, #1
	
drawMapScreenSubLoop:

	add r0, r2
	add r1, r5
	bl dmaCopy
	
	cmp r6, #32						@ Have we drawn 4 rows of tiles?
	beq drawMapScreenSubDone				@ Yes then lets exit

	mov r1, r4						@ Draw the tiles x > 256 on second screen block
	add r0, r2
	mov r3, r2
	mul r3, r6
	add r1, r3
	bl dmaCopy
	
	add r6, #1
	b drawMapScreenSubLoop
	
drawMapScreenSubDone:

	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return
	
	@--------------------------------------------------
	
	
	
	
	
	
	
	
	

drawSFMapMain:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =StarFrontMap			@ source
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)	@ destination
	ldr r3, =yposSFMain				@ 
	ldr r2, [r3]					@ load y2 with ypos (map reference)
	add r0, r2, lsl #5				@ ycoord * 32 added to screenbase
	ldr r2, =4096					@ 32x64x2
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return
	
drawSFMapSub:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =StarFrontMap			@ source
	ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)	@ destination
	ldr r3, =yposSFSub				@ 
	ldr r2, [r3]					@ load y2 with ypos (map reference)
	add r0, r2, lsl #5				@ ycoord * 32 added to screenbase
	ldr r2, =4096					@ 32x64x2
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return

drawSBMapMain:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =StarBackMap			@ source
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)	@ destination
	ldr r3, =yposSBMain				@
	ldr r2, [r3]					@ load y2 with ypos (map reference)
	add r0, r2, lsl #5				@ ycoord * 32 added to screenbase
	ldr r2, =4096					@ 32x64x2
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return

drawSBMapSub:

	stmfd sp!, {r0-r6, lr}

	ldr r0, =StarBackMap			@ source
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)	@ destination
	ldr r3, =yposSBSub				@
	ldr r2, [r3]					@ load y2 with ypos (map reference)
	add r0, r2, lsl #5				@ ycoord * 32 added to screenbase
	ldr r2, =4096					@ 32x64x2
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return

	.pool
	.end
