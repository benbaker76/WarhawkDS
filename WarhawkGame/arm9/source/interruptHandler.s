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
	.global initInterruptHandler

onIrq:
	ldr r0, =REG_IF
	ldr r0, [r0]
	tst r1, #IRQ_VBLANK
	beq otherIrq
	
	@ do stuff
	
	ldr r0, =VBLANK_INTR_WAIT_FLAGS
	ldr r1, [r0]
	orr r1, r1, #IRQ_VBLANK
	str r1, [r0]
	ldr r0, =REG_IF
	ldr r1, [r0]
	orr r1, r1, #IRQ_VBLANK
	str r1, [r0]
	bx lr
	
otherIrq:
	ldr r0, =REG_IF
	ldr r1, [r0]
	str r1, [r0]
	bx lr
	
initInterruptHandler:
	ldr r0, =REG_IME
	mov r1, #0
	strh r1, [r0]
	ldr r0, =IRQ_HANDLER
	ldr r1, =onIrq
	str r1, [r0]
	ldr r0, =REG_IE
	ldr r1, =IRQ_VBLANK
	str r1, [r0]
	ldr r0, =REG_IF
	mov r1, #~0
	str r1, [r0]
	ldr r0, =REG_DISPSTAT
	ldr r1, =DISP_VBLANK_IRQ
	str r1, [r0]
	ldr r0, =REG_IME
	mov r1, #1
	strh r1, [r0]
	bx lr