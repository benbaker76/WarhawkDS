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
	.global drawAllEnergyBars
	.global drawEnergyBar
	
drawAllEnergyBars:

	stmfd sp!, {r0-r6, lr}
	
	mov r0, #26
	mov r1, #21
	ldr r3, =energyLevel
	mov r4, #3
	
drawAllEnergyBarsLoop1:

	ldrb r2, [r3]
	
	bl drawEnergyBar
	
	add r3, #4
	add r0, #2
	
	subs r4, r4, #1
	
	bne drawAllEnergyBarsLoop1
	
	mov r0, #26
	add r1, #1
	mov r4, #3
	
drawAllEnergyBarsLoop2:

	ldrb r2, [r3]
	
	bl drawEnergyBar
	
	add r3, #4
	add r0, #2
	
	subs r4, r4, #1
	
	bne drawAllEnergyBarsLoop2
	
	mov r0, #26
	add r1, #1
	mov r4, #3
	
drawAllEnergyBarsLoop3:

	ldrb r2, [r3]
	
	bl drawEnergyBar
	
	add r3, #4
	add r0, #2
	
	subs r4, r4, #1
	
	bne drawAllEnergyBarsLoop3
	
	ldmfd sp!, {r0-r6, pc}
	
drawEnergyBar:

	@ r0 = x pos
	@ r1 = y pos
	@ r2 = Energy Level (0 Full - 7 Empty)

	stmfd sp!, {r3-r6, lr} 
	
	ldr r3, =BG_MAP_RAM(BG0_MAP_BASE) @ make r5 a pointer to sub

	add r3, r0, lsl #1				@ Add x position multiplied by 2
	add r3, r1, lsl #6				@ Add y multiplied by 64
	
	mov r4, r2, lsl #1				@ Energy Level Offset multiplied by 2
	add r4, #148 					@ Add offset multiplied by 2

	strh r4, [r3], #2				@ Write the tile number to our 32x32 map and move along
	add r4, #1						@ Next tile
	strh r4, [r3]					@ Write the tile number to our 32x32 map and move along
	
	ldmfd sp!, {r3-r6, pc}
