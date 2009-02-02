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
	.global clearBG0
	.global clearBG1
	.global clearBG2
	.global clearBG3

clearBG0:
	stmfd sp!, {r0-r6, lr} 

	mov r0, #0
	ldr r1, =BG_MAP_RAM(BG0_MAP_BASE)
	ldr r2, =1024
	bl dmaFillWords
	ldr r1, =BG_MAP_RAM_SUB(BG0_MAP_BASE_SUB)
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}
	
clearBG1:
	stmfd sp!, {r0-r6, lr} 

	mov r0, #0
	ldr r1, =BG_MAP_RAM(BG1_MAP_BASE)
	ldr r2, =4096
	bl dmaFillWords
	ldr r1, =BG_MAP_RAM_SUB(BG1_MAP_BASE_SUB)
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}
	
clearBG2:
	stmfd sp!, {r0-r6, lr} 

	mov r0, #0
	ldr r1, =BG_MAP_RAM(BG2_MAP_BASE)
	ldr r2, =2048
	bl dmaFillWords
	ldr r1, =BG_MAP_RAM_SUB(BG2_MAP_BASE_SUB)
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}
	
clearBG3:
	stmfd sp!, {r0-r6, lr} 

	mov r0, #0
	ldr r1, =BG_MAP_RAM(BG3_MAP_BASE)
	ldr r2, =2048
	bl dmaFillWords
	ldr r1, =BG_MAP_RAM_SUB(BG3_MAP_BASE_SUB)
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}

	.end
