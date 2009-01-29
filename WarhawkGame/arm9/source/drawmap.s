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
	.global drawMapMain
	.global drawMapSub
	.global drawSFMapMain
	.global drawSFMapSub
	.global drawSBMapMain
	.global drawSBMapSub

drawMapMain:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =Level1Map
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)
	ldr r3, =yposMain
	ldr r2, [r3]					@ load y2 with ypos (map reference)
	add r0, r2, lsl #6				@ ycoord * 64 added to screenbase
	ldr r2, =8192					@ 64x64x2
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return

drawMapSub:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =Level1Map
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)
	ldr r3, =yposSub
	ldr r2, [r3]					@ load y2 with ypos (map reference)
	add r0, r2, lsl #6				@ ycoord * 64 added to screenbase
	ldr r2, =8192					@ 64x64x2
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return

drawSFMapMain:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =StarFrontMap
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)
	ldr r3, =yposSFMain
	ldr r2, [r3]					@ load y2 with ypos (map reference)
	add r0, r2, lsl #5				@ ycoord * 32 added to screenbase
	ldr r2, =4096					@ 32x64x2
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return
	
drawSFMapSub:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =StarFrontMap
	ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	ldr r3, =yposSFSub
	ldr r2, [r3]					@ load y2 with ypos (map reference)
	add r0, r2, lsl #5				@ ycoord * 32 added to screenbase
	ldr r2, =4096					@ 32x64x2
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return

drawSBMapMain:
	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =StarBackMap
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)
	ldr r3, =yposSBMain
	ldr r2, [r3]					@ load y2 with ypos (map reference)
	add r0, r2, lsl #5				@ ycoord * 32 added to screenbase
	ldr r2, =4096					@ 32x64x2
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return

drawSBMapSub:
	stmfd sp!, {r0-r6, lr}

	ldr r0, =StarBackMap
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)
	ldr r3, =yposSBSub
	ldr r2, [r3]					@ load y2 with ypos (map reference)
	add r0, r2, lsl #5				@ ycoord * 32 added to screenbase
	ldr r2, =4096					@ 32x64x2
	bl dmaCopy
	
	ldmfd sp!, {r0-r6, pc} 		@ restore registers and return

	.end