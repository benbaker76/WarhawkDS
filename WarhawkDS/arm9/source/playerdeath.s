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
	.global playerDeathCheck
	
	
playerDeathCheck:

	stmfd sp!, {r0-r6, lr}
	
	
	ldr r0,=deathMode
	ldr r1,[r0]				@ r1=deathmode
	
	cmp r1,#DEATHMODE_STILL_ACTIVE
	bne playerDeathActive
	ldmfd sp!, {r0-r6, pc}	

playerDeathActive:										@ --- PHASE 1
	cmp r1,#DEATHMODE_DEATH_INIT						@ do we need to init the DEATH?
	bne playerDeathMidExplode

	mov r1,#DEATHMODE_MID_EXPLODE
	str r1,[r0]				@ set mid explode to active (store in player death)
	ldr r1,=220				@ 220 is a good length
	ldr r0,=deathModeDelay
	str r1,[r0]				@ set duration of mid explode
	
	ldr r0,=powerUp
	mov r1,#1
	str r1,[r0]
	ldr r0,=spriteBloom
	mov r1,#0x2f
	str r1,[r0]				@ make a little "FLASH"
	
	bl playAlienExplodeScreamSound
	
	ldmfd sp!, {r0-r6, pc}			
	
playerDeathMidExplode:									@ --- PHASE 2
	cmp r1,#DEATHMODE_MID_EXPLODE
	bne playerDeathMainExplode
	@ ok, this will generate explosions around the players ship while player has control
	@ we must not allow firing, though flying over bases will explode them.
	@ aliens are still generated and moved.

	@ ok, now we need to find a space to activate an explosion... much like an ident explode

	mov r7,#111
	ldr r6,=spriteActive+68
	midDeathHuntLoop:
		ldr r3,[r6,r7,lsl #2]
		cmp r3,#0
		beq midDeathExplode
		subs r7,#1
		cmp r7,#64
	bpl midDeathHuntLoop
	b midExplodeCountdown
	
	midDeathExplode:
	@ we have a free explosion
	add r6, r7, lsl #2			@ r6= ident to explosion
	
	mov r3,#11					@ set to a player explosion
	str r3,[r6]					@ spriteActive set to 11
	mov r3,#6
	mov r0,#SPRITE_OBJ_OFFS
	str r3,[r6,r0]				@ set the frame (start at 6)
	bl getRandom
	and r8,#0xf					@ get 0-15
	lsl r8,#1					@ set the delay on explosion (randomly) (0-31)
	mov r0,#SPRITE_EXP_DELAY_OFFS
	str r8,[r6,r0]
	
	bl getRandom
	and r8,#0xF					@ r8=0-15
	subs r8,#7					@ r8= -7 to 7
	ldr r3,=spriteX				@ get player X
	ldr r3,[r3]					@ r3=players X coord
	ldr r4,=horizDrift
	ldr r4,[r4]
	add r3,r4					@ r3=players x coord, horiz adjusted
	adds r3,r8
	mov r0,#SPRITE_X_OFFS
	str r3,[r6,r0]				@ store explosion X
	
	bl getRandom
	and r8,#0xF
	subs r8,#7
	ldr r3,=spriteY				@ get player Y
	ldr r3,[r3]
	adds r3,r8
	mov r0,#SPRITE_Y_OFFS
	str r3,[r6,r0]				@ store explosion X	
	
	mov r0,#SPRITE_FIRE_TYPE_OFFS
	mov r3,#0
	str r3,[r6,r0]				@ we NEED to clear this :)
	mov r0,#SPRITE_FIRE_SPEED_OFFS
	mov r3,#0
	str r3,[r6,r0]
	
	bl getRandom
	and r8,#0x2f	
	mov r0,#SPRITE_BLOOM_OFFS
	str r8,[r6,r0]
	bl getRandom
	and r8,#0x1					@ randomly flip the explosion
	mov r0,#SPRITE_HORIZ_FLIP_OFFS
	str r8,[r6,r0]
	
	@ ok, we need sound? Hmmmm...
	bl getRandom
	and r8,#0xf
	cmp r8,#0xf					@ randomly play a sound 1 in 16!
	bleq playExplosionSound

	noMidExplodeYet:
	@ ok, now we need to use players coord to check against bases (use like a bullet)
	bl detectShipAsFire
	
	midExplodeCountdown:
	ldr r0,=deathModeDelay
	ldr r1,[r0]
	subs r1,#1
	str r1,[r0]
	bpl midExplodeCountdownNo
		ldr r2,=deathMode		@ time to init the MAIN explosion
		mov r3,#DEATHMODE_MAIN_EXPLODE
		str r3,[r2]
		mov r3,#190				@ set delay for MAIN explosion
		str r3,[r0]
		ldr r1,=spriteActive
		mov r3,#0
		str r3,[r1]			@ turn off players ship
		bl fxPaletteFadeToRed
		bl stopAudioStream	@ stop music here
		@---- PLAY BIG PLAYER EXPLODE NOISE HERE
		bl playBossExplodeSound		@ we will use this for now!!	
		ldmfd sp!, {r0-r6, pc}	
	midExplodeCountdownNo:
	
	cmp r1,#170
	blgt fxPaletteInvert			@ do that flash effect
	bleq fxPaletteRestore			@ put the palette BACK

	ldmfd sp!, {r0-r6, pc}
		
playerDeathMainExplode:									@ --- PHASE 3
	@ no aliens are moved and the scrolling must also stop?
	@ no boss can be generated, or moved
	@ ok, now we want lots of explosions from spritex,y
	@ some need to shoot outwards?? hnmm... can i use fire code??
	@ ie used directional fire to a random x,y coord? hmmmm....
	@ this is pretty much the boss explode code.. with a few mods
	cmp r1,#DEATHMODE_MAIN_EXPLODE
	bne playerDeathMainExplodeWait	
	
	mov r7,#126
	ldr r6,=spriteActive+4
	mainDeathHuntLoop:
		ldr r3,[r6,r7,lsl #2]
		cmp r3,#0
		beq mainDeathExplode
		subs r7,#1
		cmp r7,#48
	bpl mainDeathHuntLoop
	b mainExplodeCountdown
	
	mainDeathExplode:
	
	add r6, r7, lsl #2				@ r6= ident to explosion
	
	mov r3,#12					@ set to a normal (slower) explosion
	str r3,[r6]
	mov r3,#6
	mov r0,#SPRITE_OBJ_OFFS
	str r3,[r6,r0]				@ set the frame
	bl getRandom
	and r8,#0xf
	lsl r8,#1					@ set the delay on explosion (randomly)
	mov r0,#SPRITE_EXP_DELAY_OFFS
	str r8,[r6,r0]
	
	bl getRandom
	and r8,#0x3F
	subs r8,#31
	ldr r3,=spriteX				@ get player X
	ldr r3,[r3]
	ldr r4,=horizDrift
	ldr r4,[r4]
	add r3,r4
	adds r3,r8
	mov r0,#SPRITE_X_OFFS
	str r3,[r6,r0]				@ store explosion X
	
	bl getRandom
	and r8,#0x3F
	subs r8,#31
	ldr r3,=spriteY				@ get player Y
	ldr r3,[r3]
	adds r3,r8
	mov r0,#SPRITE_Y_OFFS
	str r3,[r6,r0]				@ store explosion X	
	
	mov r0,#SPRITE_FIRE_TYPE_OFFS
	bl getRandom				@ set a random direction
	and r8,#0x7
	add r8,#1
	mov r3,#1
	str r8,[r6,r0]				
	mov r0,#SPRITE_FIRE_SPEED_OFFS
	mov r3,#1					@ set the speed
	str r3,[r6,r0]
	
	bl getRandom
	and r8,#0x2f	
	mov r0,#SPRITE_BLOOM_OFFS
	str r8,[r6,r0]
	
	mainExplodeCountdown:
	ldr r0,=deathModeDelay
	ldr r1,[r0]
	subs r1,#1
	str r1,[r0]
	bpl mainExplodeCountdownNo
		ldr r2,=deathMode		@ time to init the MAIN explosion
		mov r3,#DEATHMODE_DELAY
		str r3,[r2]
		mov r3,#150				@ set delay for explode WAIT
		str r3,[r0]
	mainExplodeCountdownNo:

											@ This is still causing the occational sound corruption!
											@ Commenting out for now
	@cmp r1,#170							@ overlap the explosion sounds slightly
		@bleq playBossExplodeSound		@ we will use this for now!!
	ldmfd sp!, {r0-r6, pc}
	
playerDeathMainExplodeWait:								@ --- PHASE 4
	@ this is a little delay to wait for the explosions to all finish
	cmp r1,#DEATHMODE_DELAY
	bne playerIsAllDead

	ldr r0,=deathModeDelay
	ldr r1,[r0]
	subs r1,#1
	str r1,[r0]
	bpl mainExplodeCountWait
		mov r3,#180
		str r3,[r0]

		ldr r0,=deathMode		@ set to TOTALLY finished
		mov r3,#DEATHMODE_ALL_DONE
		str r3,[r0]
		
		bl clearOAM
		bl fxCopperTextOn
		
		ldr r0, =gameOverText						@ Load out text pointer
		ldr r1, =11									@ x pos
		ldr r2, =12									@ y pos
		ldr r3, =1									@ Draw on sub screen
		bl drawText
		
		ldr r0, =gameOverText						@ Load out text pointer
		ldr r1, =11									@ x pos
		ldr r2, =12									@ y pos
		ldr r3, =0									@ Draw on main screen
		bl drawText

	mainExplodeCountWait:	
	
	ldmfd sp!, {r0-r6, pc}
	
playerIsAllDead:										@ --- PHASE 5
	@ ok, now we need to do whatever to stop the game and go to game over???
	
	cmp r1,#DEATHMODE_FADE_OUT
	bge playerDeathDone

	ldr r0,=deathModeDelay
	ldr r3,[r0]
	cmp r3,#0
	beq playerIsToast
		sub r3,#1
		str r3,[r0]
		ldmfd sp!, {r0-r6, pc}
	playerIsToast:
	
	ldr r0, =deathMode
	ldr r1, =DEATHMODE_FADE_OUT
	str r1, [r0]
	
	bl fxFadeBlackInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =showHiScoreEntry
	str r1, [r0]
	
	bl fxFadeOut
	
playerDeathDone:

	ldmfd sp!, {r0-r6, pc}

	@---------------------------------

	.data
	.align

gameOverText:
	.asciz "GAME OVER!"

	.pool
	.end