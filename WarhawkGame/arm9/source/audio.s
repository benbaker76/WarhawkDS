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
	.global playInGameMusic
	.global playBlasterSound
	.global playExplosionSound

playInGameMusic:
	stmfd sp!, {r0-r1, lr}

	ldr r0, =IPC_SOUND_LEN(0)		@ Get the IPC sound length address
	ldr r1, =InGameMusicLen			@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(0)		@ Get the IPC sound data address
	ldr r1, =ingame_wav				@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r1, pc} 		@ restore registers and return
	
playBlasterSound:
	stmfd sp!, {r0-r2, lr}

	ldr r0, =IPC_SOUND_LEN(1)		@ Get the IPC sound length address
	ldr r1, =BlasterSoundLen		@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)		@ Get the IPC sound data address
	ldr r1, =blaster_raw			@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 		@ restore registers and return
	
playExplosionSound:
	stmfd sp!, {r0-r2, lr}

	ldr r0, =IPC_SOUND_LEN(1)		@ Get the IPC sound length address
	ldr r1, =ExplosionSoundLen		@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)		@ Get the IPC sound data address
	ldr r1, =explosion_raw			@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 		@ restore registers and return

