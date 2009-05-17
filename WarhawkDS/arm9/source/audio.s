@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"), to deal in the Software without restriction, including
@ without limitation the rights to use, copy, modify, merge, publish,
@ distribute, sublicense, and/or sell copies of the Software, and to
@ permit persons to whom the Software is furnished to do so, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software.
@ 
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
@ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
@ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
@ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
@ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
@ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
@ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "warhawk.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "ipc.h"

	.arm
	.align
	.text
	
	.global stopSound
	.global playBlasterSound					@ Used = Normal Fire
	.global playExplosionSound					@ used = player death & base explode
	.global playAlienExplodeSound				@ used = alien explode (need better for big aliens)
	.global playAlienExplodeScreamSound			@ used = powershot, mineshot explode, player death
	.global playElecShotSound					@ used = alien fire
	.global playLaserShotSound					@ used = alien fire
	.global playShipArmourHit1Sound				@ used = boss shot, player/alien collision
	.global playShipArmourHit2Sound				@ not used (using for powerup collect for now)
	.global playClassicSound					@ not used
	.global playCrashBuzSound					@ used = alien fire
	.global playDinkDinkSound					@ used = cheatmode and level start
	.global playHitWallSound					@ not used
	.global playLowSound						@ used = alien fire
	.global playSteelSound						@ used = eol counter, alien/player collide, alien fire
	.global playBossExplodeSound				@ used = Player explode
	.global playFireworksSound					@ used = fireworks
	.global playPowerupCollect					@ for powerup collection
	.global playpowerupLostSound				@ powerup runs out
	.global playIdentShipExplode				@ for when a multi-sprite ship is destroyed
	.global playKeyboardClickSound				@ for menu navigation/options
	.global playBossExplode2Sound				@ used = Boss Explosion (not happy with it :( )
	.global playEvilLaughSound
	.global playAlertSound

stopSound:

	stmfd sp!, {r0-r1, lr}

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	mov r1, #0											@ Zero
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	mov r1, #-1											@ Stop sound value
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r1, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playBlasterSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =blaster_raw_end							@ Get the sample end
	ldr r2, =blaster_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =blaster_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playExplosionSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =explosion_raw_end							@ Get the sample end
	ldr r2, =explosion_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =explosion_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playAlienExplodeSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =alien_explode_raw_end						@ Get the sample end
	ldr r2, =alien_explode_raw							@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =alien_explode_raw							@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playAlienExplodeScreamSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =alien_explode_scream_raw_end				@ Get the sample end
	ldr r2, =alien_explode_scream_raw					@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =alien_explode_scream_raw							@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playElecShotSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =elecshot_raw_end							@ Get the sample end
	ldr r2, =elecshot_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =elecshot_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playLaserShotSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =lasershot_raw_end							@ Get the sample end
	ldr r2, =lasershot_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =lasershot_raw								@ Get the sample address
	str r1, [r0]										@ Write the value

	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playShipArmourHit1Sound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =ship_armour_hit1_raw_end					@ Get the sample end
	ldr r2, =ship_armour_hit1_raw						@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =ship_armour_hit1_raw						@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playShipArmourHit2Sound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =ship_armour_hit2_raw_end					@ Get the sample end
	ldr r2, =ship_armour_hit2_raw						@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =ship_armour_hit2_raw						@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playClassicSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =classic_raw_end							@ Get the sample end
	ldr r2, =classic_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =classic_raw								@ Get the sample address
	str r1, [r0]										@ Write the value

	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playCrashBuzSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =crashbuz_raw_end							@ Get the sample end
	ldr r2, =crashbuz_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =crashbuz_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playDinkDinkSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =dinkdink_raw_end							@ Get the sample end
	ldr r2, =dinkdink_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =dinkdink_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playHitWallSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =hitwall_raw_end							@ Get the sample end
	ldr r2, =hitwall_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =hitwall_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playLowSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =low_raw_end								@ Get the sample end
	ldr r2, =low_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =low_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playSteelSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =steel_raw_end								@ Get the sample end
	ldr r2, =steel_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =steel_raw									@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playBossExplodeSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =boss_explode_raw_end						@ Get the sample end
	ldr r2, =boss_explode_raw							@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =boss_explode_raw							@ Get the sample address
	str r1, [r0]										@ Write the value

	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playFireworksSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =fireworks_raw_end							@ Get the sample end
	ldr r2, =fireworks_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =fireworks_raw								@ Get the sample address
	str r1, [r0]										@ Write the value
	
	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

playBossExplode2Sound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =boss_explode2_raw_end							@ Get the sample end
	ldr r2, =boss_explode2_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =boss_explode2_raw								@ Get the sample address
	str r1, [r0]										@ Write the value

	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return

	@ ---------------------------------------------
	
playKeyboardClickSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =keyclick_raw_end							@ Get the sample end
	ldr r2, =keyclick_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =keyclick_raw								@ Get the sample address
	str r1, [r0]										@ Write the value

	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return

	@ ---------------------------------------------
	
playPowerupCollect:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =powerupcollect_raw_end						@ Get the sample end
	ldr r2, =powerupcollect_raw							@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =powerupcollect_raw							@ Get the sample address
	str r1, [r0]										@ Write the value

	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return

	@ ---------------------------------------------
	
playpowerupLostSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =poweruplost_raw_end						@ Get the sample end
	ldr r2, =poweruplost_raw							@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =poweruplost_raw							@ Get the sample address
	str r1, [r0]										@ Write the value

	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return

	@ ---------------------------------------------
	
playIdentShipExplode:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =bigshipexplode_raw_end						@ Get the sample end
	ldr r2, =bigshipexplode_raw							@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =bigshipexplode_raw								@ Get the sample address
	str r1, [r0]										@ Write the value

	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playEvilLaughSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =evil_laugh_raw_end							@ Get the sample end
	ldr r2, =evil_laugh_raw								@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =evil_laugh_raw								@ Get the sample address
	str r1, [r0]										@ Write the value

	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------
	
playAlertSound:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =IPC_SOUND_DATA(1)
	ldr r1, =0x10
	bl DC_FlushRange

	ldr r0, =IPC_SOUND_LEN(1)							@ Get the IPC sound length address
	ldr r1, =alert_raw_end								@ Get the sample end
	ldr r2, =alert_raw									@ Get the same start
	sub r1, r2											@ Sample end - start = size
	str r1, [r0]										@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(1)							@ Get the IPC sound data address
	ldr r1, =alert_raw									@ Get the sample address
	str r1, [r0]										@ Write the value

	ldmfd sp!, {r0-r2, pc} 							@ restore registers and return
	
	@ ---------------------------------------------

	.pool
	.end
