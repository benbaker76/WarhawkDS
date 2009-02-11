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
	.global initData
	
initData:
	stmfd sp!, {r0-r1, lr}

	mov r1,#0	
	ldr r0,=levelEnd
	str r1,[r0]				@ Flag is SET for end of level	
	ldr r0,=powerUp
	str r1,[r0]				@ set to one for autofire
	ldr r0,=powerUpDelay
	str r1,[r0]				@ clear the fire delay
	ldr r0,=waveNumber
	str r1,[r0]				@ make sure we always start at wave 0

	mov r1, #1
	ldr r0,=firePress
	str r1,[r0]				@ Set fire press so fire to start does not fire a bullet
	ldr r0,=spriteActive
	str r1,[r0]				@ make sure our ship is visible

	mov r1,#176
	ldr r0,=spriteX
	str r1,[r0]				@ our ships initial X coord
	mov r1,#716
	ldr r0,=spriteY
	str r1,[r0]				@ our ships initial Y coord

	mov r1,#32
	ldr r0,=horizDrift
	strb r1,[r0]			@ Drift on levels horizontal - centre to start level
	
	ldmfd sp!, {r0-r1, pc}

	.end