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
	
@ ---------- Calculate energy bar levels -----------------
	
drawAllEnergyBars:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =energy					@ Read energy address
	ldr r0, [r0]					@ Read energy value
	cmp r0,#24
	bleq playCrashBuzSound
	cmp r0,#16
	bleq playCrashBuzSound
	cmp r0,#8
	bleq playCrashBuzSound
	mov r2, #0						@ Our energy offset
	mov r4, #64						@ Our energy level check for each energy bar
	
drawAllEnergyBarsLoop:
	
	ldr r1, =energyLevel			@ Read the address of the energyLevel
	add r1, r2, lsl #2				@ Get the current address of the energy bar
	
	mov r3, #0						@ Energy value will be zero
	cmp r0, r4						@ Compare with our level check
	subgt r3, r0, r4				@ Energy level greater than our level check?
	cmp r3, #7						@ Is our Energy value greater than 7?
	movgt r3, #7					@ Then make it 7

	str r3, [r1]					@ Write our energy level for this bar
	
	sub r4, #8						@ Subtract 8 from our energy level check
	add r2, #1						@ Add one to our energy level offset
	cmp r2, #9						@ Have we drawn all bars?
	
	bne drawAllEnergyBarsLoop		@ No, so loop until done
	
@ ---------- Start energy bar drawing code -----------------
	
	
	mov r0, #26						@ x pos
	ldr r3, =energyLevel			@ energyLevel address
	mov r4, #3						@ x loop count
	
drawAllEnergyBarsLoopX:
	
	mov r5, #3						@ y loop count
	mov r1, #21						@ y pos
	
drawAllEnergyBarsLoopY:

	ldr r2, [r3], #4				@ Read energyLevel value, add 4
	
	bl drawEnergyBar				@ Draw energy bar
	
	add r1, #1						@ Add 1 to y pos	
	subs r5, #1						@ sub 1 from y count
	
	bne drawAllEnergyBarsLoopY
	
	add r0, #2						@ Add 1 to x pos
	subs r4, #1						@ sub 1 from x count
	
	bne drawAllEnergyBarsLoopX
	
	ldmfd sp!, {r0-r6, pc}
	
@ ---------- Draw a single energy bar ----------------
	
drawEnergyBar:

	@ r0 = x pos
	@ r1 = y pos
	@ r2 = Energy Level (0 Empty - 7 Full)

	stmfd sp!, {r3-r6, lr}
	
	mov r3, #7						@ Reverse the value
	sub r2, r3, r2
	
	ldr r3, =BG_MAP_RAM(BG0_MAP_BASE) @ make r5 a pointer to sub

	add r3, r0, lsl #1				@ Add x position multiplied by 2
	add r3, r1, lsl #6				@ Add y multiplied by 64
	
	mov r4, r2, lsl #1				@ Energy Level Offset multiplied by 2
	add r4, #148 					@ Add offset multiplied by 2

	strh r4, [r3], #2				@ Write the tile number to our 32x32 map and move along
	add r4, #1						@ Next tile
	strh r4, [r3]					@ Write the tile number to our 32x32 map and move along
	
	ldmfd sp!, {r3-r6, pc}
