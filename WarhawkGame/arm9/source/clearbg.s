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
	.global clearBG0

clearBG0:
	stmfd sp!, {r0-r6, lr} 

	mov r0, #0
	ldr r1, =BG_MAP_RAM(15)
	ldr r2, =1024
	bl dmaFillWords
	ldr r1, =BG_MAP_RAM_SUB(17)
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}

	.end
