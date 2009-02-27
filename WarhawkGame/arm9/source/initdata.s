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
	@ use this to init data for the start of the game
	stmfd sp!, {r0-r1, lr}

	ldr r1,=level
	mov r0,#3
	str r0,[r1]

	ldmfd sp!, {r0-r1, pc}

	.end
	
@ These below need to be inited at game start - not per level

pixelOffsetSFSub:
	.word 0
pixelOffsetSFMain:
	.word 0
pixelOffsetSBSub:
	.word 0
pixelOffsetSBMain:
	.word 0
vofsSFMain:
	.word 256
vofsSBMain:
	.word 256
vofsSFSub:
	.word 256
vofsSBSub:
	.word 256
yposSFMain:
	.word 736						@ 3200 - 192 - 64 / 4
yposSBMain:
	.word 736						@ 3200 - 192 - 64 / 4
yposSFSub:
	.word 736						@ 3200 - 192 - 64 / 4
yposSBSub:
	.word 736						@ 3200 - 192 - 64 / 4