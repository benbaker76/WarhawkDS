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
	.global playAlienExplodeSound
	.global playAlienExplodeScreamSound
	.global playElecShotSound
	.global playShipArmourHit1Sound
	.global playShipArmourHit2Sound

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
	ldr r1, =BlasterLen				@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)		@ Get the IPC sound data address
	ldr r1, =blaster_raw			@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 		@ restore registers and return
	
playExplosionSound:
	stmfd sp!, {r0-r2, lr}

	ldr r0, =IPC_SOUND_LEN(1)		@ Get the IPC sound length address
	ldr r1, =ExplosionLen			@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)		@ Get the IPC sound data address
	ldr r1, =explosion_raw			@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 		@ restore registers and return
	
playAlienExplodeSound:
	stmfd sp!, {r0-r2, lr}

	ldr r0, =IPC_SOUND_LEN(1)		@ Get the IPC sound length address
	ldr r1, =AlienExplodeLen		@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)		@ Get the IPC sound data address
	ldr r1, =alien_explode_raw		@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 		@ restore registers and return

playAlienExplodeScreamSound:
	stmfd sp!, {r0-r2, lr}

	ldr r0, =IPC_SOUND_LEN(1)		@ Get the IPC sound length address
	ldr r1, =AlienExplodeScreamLen	@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)		@ Get the IPC sound data address
	ldr r1, =alien_explode_scream_raw		@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 		@ restore registers and return

playElecShotSound:
	stmfd sp!, {r0-r2, lr}

	ldr r0, =IPC_SOUND_LEN(1)		@ Get the IPC sound length address
	ldr r1, =ElecShotLen			@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)		@ Get the IPC sound data address
	ldr r1, =elecshot_raw			@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 		@ restore registers and return

playShipArmourHit1Sound:
	stmfd sp!, {r0-r2, lr}

	ldr r0, =IPC_SOUND_LEN(1)		@ Get the IPC sound length address
	ldr r1, =ShipArmourHit1Len		@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)		@ Get the IPC sound data address
	ldr r1, =ship_armour_hit1_raw			@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 		@ restore registers and return
	
playShipArmourHit2Sound:
	stmfd sp!, {r0-r2, lr}

	ldr r0, =IPC_SOUND_LEN(1)		@ Get the IPC sound length address
	ldr r1, =ShipArmourHit2Len		@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)		@ Get the IPC sound data address
	ldr r1, =ship_armour_hit2_raw	@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 		@ restore registers and return
	