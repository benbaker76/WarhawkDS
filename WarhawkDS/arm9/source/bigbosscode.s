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
#include "sprite.h"
#include "background.h"

	.global bigBossInit
	.global updateBigBoss
	.global bigBossInitExplode
	.global bigBossMode
	
	#define	BIGBOSS_OFFSET		68

	.arm
	.align
	.text
	
bigBossInit:
	stmfd sp!, {r0-r4, lr}
	@ need to init sprites starting at sprite 17 and up to 81 max
	@ use bossX and bossY for the coords (top left)
	@ use sprite image 30 throughout for now!
	@ we will use sriteActive value of 256 to signal big boss and 512 for the "hit zone"
	@ the only downside is that we can only spare 35 sprite images!!
	
	@----------------------------------
	@ SO, AND I NEED YOUR INPUT HERE!!!!
	@ the size it is now, we can also release powerups
	@ or another row of 7 and no powerup but a bigger ship! More impressive?? We could make "powerup" perminant for this
	@ boss fight, so powerup collection is not needed...
	@ also, should we give player full hitpoints at the start of the battle??
	@ Ps - bigger works for me :)
	@ also - should we add animation to parts of it? I think it would really help to show that we are a great team... and
	@ it is easy to do, could look cool?
	@----------------------------------
	
	@ one good thing or 2...
	@ drawsprite and standard collision handles everything here with this
	@ also, it was so so easy to integrate!! :)
	@ and, I REALLY love your idea for adding this!!! :) <chuckle>
	
	@-----------------------------------
	@
	@ another thing.... when you die... we will have to do something else,
	@ there are not ANY sprites free of a higher priority to enable explosions ABOVE the ship?
	@ so, what can we do?
	@ fade the ship out and release the sprites? help!!!
	@
	@------------------------------------
	
	mov r1,#GAMEMODE_BIGBOSS					@ set gamemode to switch to bigboss battle
	ldr r0,=gameMode
	str r1,[r0]

	bl fxOff
	bl fxFadeBlackInit
	bl fxFadeMax
	bl stopSound
	bl stopAudioStream
	bl resetScrollRegisters						@ Reset the scroll registers
	bl clearBG0									@ Clear bgs
	bl clearBG1
	bl clearBG2
	bl clearBG3
	
	bl killAllSpritesBoss						@ this SHOULD kill everyother sprite except you and bullets
	bl initStarData
	
	ldr r0,=bossX								@ set initial boss X/Y (20.12 format)
	mov r3,#32								@ r3=x
	lsl r3,#12
	str r3,[r0]

	ldr r0,=bossY
	mov r4,#384+16								@ r4=y
	mov r4,#128
	lsl r4,#12
	str r4,[r0]
	
	ldr r0, =getReadyText			@ Load out text pointer
	ldr r1, =11						@ x pos
	ldr r2, =10						@ y pos
	ldr r3, =0						@ Draw on sub screen
	bl drawText
	
	ldr r0, =getReadyText			@ Load out text pointer
	ldr r1, =11						@ x pos
	ldr r2, =10						@ y pos
	ldr r3, =1						@ Draw on main screen
	bl drawText

	bl fxCopperTextOn							@ Turn on copper text fx
	
	mov r0,#256
	bl fxStarfieldDownOn						@ Turn on starfield

	ldr r0, =4000								@ 5 seconds
	ldr r1, =bigBossGo							@ Callback function address

	bl startTimer
	
	bl playAlertSound

	bl fxFadeIn
	
	ldr r0,=horizDrift
	mov r1,#32
	str r1,[r0]

	ldmfd sp!, {r0-r4, pc}

	@------------------------------------
	
bigBossGo:

	stmfd sp!, {r0-r4, lr}
	
	bl clearBG0
	
	bl fxCopperTextOff
	
	bl playEvilLaughSound

	ldr r0, =bossRawText						@ Read the path to the file
	bl playAudioStream							@ Play the audio stream
	
	@ ok, init spritedata
	
	bl bigBossInitAllSpriteData					@ set all sprite data (draw will handle possition)
	bl bigBossDraw

	ldr r0,=bigBossMode
	mov r1,#BIGBOSSMODE_SCROLL_ON
	str r1,[r0]									@ set bossmode to 1 = bring on from top
												@ 2= move phase, 3=explode init

	ldmfd sp!, {r0-r4, pc}

	@------------------------------------

bigBossInitAllSpriteData:
	stmfd sp!, {r0-r10, lr}

	ldr r0, =optionGameModeCurrent
	mov r1,#1									@ uncomment for level 32 boss
str r1,[r0]

	ldr r10, [r0]

	ldr r0, =BossBulletsTiles				@ we need a slightly different bullet - LOBO!!! he he
	ldr r2, =BossBulletsTilesLen	
	ldr r1, =SPRITE_GFX
	add r1, #27*512
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
	add r1, #27*512
	bl dmaCopy

	ldr r1,=bigBossSpriteNumber
	cmp r10,#0
	moveq r2,#54
	movne r2,#62
	str r2,[r1]				@ set number of sprites used

	ldreq r8,=bigBossSpriteTable1			@ load the image from our table!
	ldrne r8,=bigBossSpriteTable2			@ load the image from our table!
	ldreq r9,=bigBossFlipTable1				@ set flip data
	ldrne r9,=bigBossFlipTable2				@ set flip data

	mov r0,#0				@ sprite number
	bigBossInitLoop:
		ldr r5,=spriteActive+BIGBOSS_OFFSET
		mov r6,#256
		str r6,[r5, r0, lsl #2]			@ activate sprite
		ldr r5,=spriteIdent+BIGBOSS_OFFSET
		mov r6,#32
		str r6,[r5, r0, lsl #2]			@ set the ident (the code will handle this as a huge alien already)
		ldr r5,=spriteHits+BIGBOSS_OFFSET
		mov r6,#10
		str r6,[r5, r0, lsl #2]			@ number of hits

		ldr r6,[r8, r0, lsl #2]
		ldr r5,=spriteObj+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]			@ set the sprite image
		
		ldr r6,[r9, r0, lsl #2]
		ldr r5,=spriteHFlip+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]

		mov r6,#0							@ reset other data that may cock things up
		ldr r5,=spriteFireType+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteFireDelay+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteFireMax+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBloom+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteFireSpeed+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstNum+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstNumCount+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstDelay+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstDelayCount+BIGBOSS_OFFSET
		str r6,[r5, r0, lsl #2]		
		add r0,#1
		cmp r0,r2
	bne bigBossInitLoop
	
	cmp r10,#0
	bleq bigBossInitFire1
	blne bigBossInitFire2

	cmp r10,#0
	
	@ set the "softspots", where you can shoot the big boss
	
		ldreq r5,=spriteActive+BIGBOSS_OFFSET+(52*4)
		moveq r6,#512
		streq r6,[r5]
		ldreq r5,=spriteActive+BIGBOSS_OFFSET+(53*4)
		moveq r6,#512
		streq r6,[r5]
	
		ldrne r5,=spriteActive+BIGBOSS_OFFSET+(60*4)
		movne r6,#512
		strne r6,[r5]
		ldrne r5,=spriteActive+BIGBOSS_OFFSET+(61*4)
		movne r6,#512
		strne r6,[r5]
		
	bne bigBossTiles2	
		ldr r0, =Spritesboss1Tiles
		ldr r2, =Spritesboss1TilesLen	
		ldr r1, =SPRITE_GFX
		add r1, #29*512
		bl dmaCopy
		ldr r1, =SPRITE_GFX_SUB
		add r1, #29*512
		bl dmaCopy
	ldmfd sp!, {r0-r10, pc}
	bigBossTiles2:
		ldr r0, =Spritesboss2Tiles
		ldr r2, =Spritesboss2TilesLen	
		ldr r1, =SPRITE_GFX
		add r1, #29*512
		bl dmaCopy
		ldr r1, =SPRITE_GFX_SUB
		add r1, #29*512
		bl dmaCopy
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------

killAllSpritesBoss:
	stmfd sp!, {r0-r10, lr}
	@ we need to kill all sprites that are not used!!
	@ all we "SHOULD" need to do is mark spriteActive to 0

	mov r0,#0
	mov r1,#0
	mov r5,#812
	ldr r2,=spriteActive+68						@ from sprite 17 (16)
	ldr r3,=spriteX+68
	ldr r4,=spriteY+68
	ldr r6,=spriteObj+68
	killAllSpritesBossLoop:
		str r1,[r2, r0, lsl #2]				@ active
		str r1,[r3, r0, lsl #2]				@ x
		str r5,[r4, r0, lsl #2]				@ y
		str r1,[r6, r0, lsl #2]				@ object	
		add r0,#1
		cmp r0,#48								@ 17+48=65 = end-1
	bne killAllSpritesBossLoop

	ldmfd sp!, {r0-r10, pc}
@------------------------------------------------------

updateBigBoss:
	stmfd sp!, {r0-r10, lr}
	
	bl moveShip									@ check and move your ship
	bl alienFireMove							@ check and move alien bullets
	bl fireCheck								@ check for your wish to shoot!
	bl drawScore								@ update the score with any changes
	bl drawAllEnergyBars						@ Draw the energy bars
	bl drawEnergyBarFlash						@ flash is energy low
	bl moveAliens								@ move the aliens and detect colisions with you
	bl levelDrift								@ update level with the horizontal drift
	bl moveBullets								@ check and then moves bullets

	ldr r1,=bigBossMode
	ldr r0,[r1]
	cmp r0,#BIGBOSSMODE_EXPLODE_INIT
	bge bigBossNoScroll
		bl scrollSBMain
		bl scrollSBSub
	bigBossNoScroll:

	bl drawSprite								@ drawsprites and do update bloom effect
	bl checkGameOver							@ check if the game is over
	bl checkLevelControl						@ check to see if we want to change level
	bl playerDeathCheck							@ check and do DEATH stuff
	bl useCheat									@ a call to restore health if cheat is active
	bl checkGamePause							@ check if the game is paused	
@	bl checkEndOfLevel							@ Set Flag for end-of-level
@	bl drawDebugText							@ draw some numbers :)	
	bl bigBossMovement							@ move big boss

	ldr r0, =horizDrift
	ldr r0, [r0]
	ldr r1, =REG_BG2HOFS			@ Load our horizontal scroll register for BG2 on the main screen
	ldr r2, =REG_BG2HOFS_SUB		@ Load our horizontal scroll register for BG2 on the sub screen
	strh r0,[r1]
	strh r0,[r2]	
	lsr r0,#1
	ldr r1, =REG_BG3HOFS			@ Load our horizontal scroll register for BG3 on the main screen
	ldr r2, =REG_BG3HOFS_SUB		@ Load our horizontal scroll register for BG3 on the sub screen
	strh r0,[r1]
	strh r0,[r2]
	
	mov r0,#1									@ retain powerup
	ldr r1,=powerUp
	str r0,[r1]
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------

bigBossDraw:

	stmfd sp!, {r0-r10, lr}
	
	@ this will update the position of all sprites based on bossX and bossY
	@ modify to use data tables for all offsets

	ldr r0,=bossX
	ldr r0,[r0]				@ r0 = x
	asr r0,#12				@ use asl to preserve the signed bit as X may be negetive
	ldr r1,=bossY
	ldr r1,[r1]				@ r1 = y
	lsr r1,#12
	ldr r2,=optionGameModeCurrent
	ldr r2,[r2]
	cmp r2,#0
	ldreq r8,=bigBossSpritesX1	@ x table - boss 1
	ldreq r9,=bigBossSpritesY1	@ y table
	ldrne r8,=bigBossSpritesX2	@ x table - boss 2
	ldrne r9,=bigBossSpritesY2	@ y table
	ldr r10,=spriteX+BIGBOSS_OFFSET	@ sprites X coords
	ldr r11,=spriteY+BIGBOSS_OFFSET	@ sprites Y coords	
	ldr r3,=bigBossSpriteNumber	@ number of sprites used in boss
	ldr r3,[r3]
	
	mov r2,#0					@ r2 = sprite number	
	
	ldr r7,=bigBossMode
	ldr r7,[r7]
	cmp r7,#BIGBOSSMODE_EXPLODE_INIT
	bne bigBossDrawerLoop
	
		bl getRandom				@ add a "Shake" on X for boss death
		and r8,#0xf
		subs r8,#7
		adds r0,r8
		ldr r8,=bigBossSpritesX1	@ x table
	
	bigBossDrawerLoop:
		ldr r6,[r8, r2, lsl #2]		@ r6= x offset
		adds r7,r0,r6					@ r7= actuall coord
		str r7,[r10, r2, lsl #2]		@ store coord
		ldr r6,[r9, r2, lsl #2]		@ r6= y offset
		adds r7,r1,r6					@ r7= actuall coord
		str r7,[r11, r2, lsl #2]		@ store coord		
		add r2,#1
		cmp r2,r3
	bne bigBossDrawerLoop

	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------------------------
	
bigBossInitExplode:
	stmfd sp!, {r0-r10, lr}

	ldr r8,=bossMan							@ this stops bullets and sprite detection
	mov r6,#BOSSMODE_EXPLODE
	str r6,[r8]

	ldr r0,=starDirection
	mov r1,#384
	str r1,[r0]

	ldr r0, =BossExplodeTiles				@ use our boss explosions
	ldr r2, =BossExplodeTilesLen	
	ldr r1, =SPRITE_GFX
	add r1, #6*512
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
	add r1, #6*512
	bl dmaCopy

	ldr r0,=bigBossMode
	mov r1,#BIGBOSSMODE_EXPLODE_INIT						@ set bossmode to DEAD and scroll of screen quickly
	str r1,[r0]

	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------

bigBossMovement:

	@ we use this to handle the several phases of the boss mode
	@ we also use "bossman" as in a normal boss, as this is what we used
	@ to nullify the detection code...

	stmfd sp!, {r0-r10, lr}

	ldr r0,=bigBossMode
	ldr r0,[r0]
	cmp r0,#BIGBOSSMODE_SCROLL_ON																		@ PHASE=SCROLL ON
	bne bigBossMovementPhase2
	
	@ ok, we just need to bring it on and change bigBossMode to 2 when there!
	
	ldr r0,=bossY
	ldr r1,[r0]
	lsr r1,#12
	
	ldr r3,=optionGameModeCurrent
	ldr r3,[r3]
	cmp r3,#0
	
	moveq r3,#384-16	@ distance normal
	movne r3,#384-32	@ distance mental

	cmp r1,r3
	bpl bigBossMovementPhaseChange
	
		add r1,#1
		lsl r1,#12
		str r1,[r0]
		bl bigBossDraw							@ update to new position	
		
		ldmfd sp!, {r0-r10, pc}

	bigBossMovementPhaseChange:	
	
		bl playBossExplodeSound				@ play an explosion
		ldr r0,=bigBossMode
		mov r1,#BIGBOSSMODE_MOVE
		str r1,[r0]									@ set to "ready to move"
	
	ldmfd sp!, {r0-r10, pc}
	
bigBossMovementPhase2:	
	cmp r0,#2																		@ PHASE=MOVEMENT
	bne bigBossMovementPhase3
	@ sine/cos movement?

	ldr r0,=bossX
	ldr r1,[r0]					@ r1= x coord (20.12)	
	ldr r2,=SIN_bin
	ldr r3,=bigBossXphase
	ldr r4,[r3]					@ r4= x phase
	add r4,#2
	cmp r4,#512
	movge r4,#0
	str r4,[r3]
	lsl r4,#1
	ldrsh r5,[r2,r4]
	lsl r5,#1
	adds r1,r5
	str r1,[r0]

	ldr r0,=bossY
	ldr r1,[r0]					@ r1= x coord (20.12)	
	ldr r2,=COS_bin
	ldr r3,=bigBossYphase
	ldr r4,[r3]					@ r4= x phase
	add r4,#1
	cmp r4,#512
	movge r4,#0
	str r4,[r3]
	lsl r4,#1
	ldrsh r5,[r2,r4]
@	lsl r5,#1
	adds r1,r5
	str r1,[r0]

	bl bigBossDraw							@ update to new position

	ldmfd sp!, {r0-r10, pc}

bigBossMovementPhase3:
	cmp r0,#3																		@ PHASE+SCROLL OFF
	bne bigBossMovementPhase4
	
		@ play bigboss explode init sound - firecrackers???
		ldr r0,=bossY
		ldr r1,[r0]
		mov r2,#6
		lsl r2,#12
		add r1,r2
		str r1,[r0]
		
		bl bigBossDraw							@ update to new position
		
		mov r2,#768
		lsl r2,#12
		cmp r1,r2
		
		ble bigbossDeathNo
			
			ldr r0,=bigBossMode
			mov r1,#BIGBOSSMODE_NO_DEATH
			str r1,[r0]

		bigbossDeathNo:
	
		ldmfd sp!, {r0-r10, pc}
		
bigBossMovementPhase4:
	cmp r0,#4																		@ PHASE=INIT BIG BOSS EXPLODE
	bne bigBossMovementPhase5
		@ here we need to init code to handle a special explosion!
		
		ldr r0,=bigBossExplodeCount
		mov r1,#0
		str r1,[r0]
		
		mov r1,#17
		ldr r0,=bigBossSpriteExp
		str r1,[r0]
		
		ldr r0,=bigBossExpHigh
		mov r1,#768-64
		str r1,[r0]
		
		@ play bigboss explode main explosion sound
		ldr r0,=bigBossMode
		mov r1,#BIGBOSSMODE_MAIN_EXPLODE
		str r1,[r0]
		
	ldmfd sp!, {r0-r10, pc}	
	
bigBossMovementPhase5:
	@this is our main explode thing!
	cmp r0,#5																		@ PHASE=DO THE EXPLOSION
	bne bigBossMovementPhase6
	
		mov r12,#0								@ our counter per phase
			bigBossUpExplodeLoop:

			ldr r0,=bigBossSpriteExp
			ldr r1,[r0]								@ r1=sprite to explode (number 17-127)

			@ generate a random X
			bl getRandom							@ need 64-351
			ldr r2,=0x1ff
			and r8,r2
			mov r2,#9
			mul r8,r2
			lsr r8,#4
			add r8,#64
			mov r10,r8								@ r10 holds our X
			bl getRandom
			and r8,#0x3f							@ 0-63
			ldr r2,=bigBossExpHigh
			ldr r3,[r2]
			add r11, r8,r3							@ r11 holds our Y

			ldr r6,=spriteActive
			add r6, r1, lsl #2						@ r6=offset
		
			ldr r2,[r6]
			cmp r2,#13
			beq bigBossExpSkip
		
			mov r2,#13								@ explosion type
			str r2,[r6]
			mov r2,#6								@ initial frame
			mov r8,#SPRITE_OBJ_OFFS				
			str r2,[r6,r8]
			mov r2,#8
			mov r8,#SPRITE_EXP_DELAY_OFFS
			str r2,[r6,r8]

			mov r8,#SPRITE_X_OFFS
			str r10,[r6,r8]
			mov r8,#SPRITE_Y_OFFS
			str r11,[r6,r8]

			@ do a random bloom
			bl getRandom
			and r8,#0x2F		@ i know it is out of palette range, but give a shimmer!! :) (cheating)
			mov r2,#SPRITE_BLOOM_OFFS
			str r8,[r6,r2]

		bigBossExpSkip:
		add r1,#1
		cmp r1,#128
		moveq r1,#17
		ldr r0,=bigBossSpriteExp
		str r1,[r0]
		add r12,#1
		cmp r12,#14
		bne bigBossUpExplodeLoop
	
		bl getRandom
		and r8,#0xf
		cmp r8,#2
		bllt playExplosionSound
	
ldr r0,=bigBossExpHigh
ldr r1,[r0]
sub r1,#2
str r1,[r0]

ldr r0,=bigBossMode
mov r2,#BIGBOSSMODE_ALL_DONE
cmp r1,#384
strle r2,[r0]
ldrle r0,=bigBossExpHigh
movle r2,#100
strle r2,[r0]
	
	ldmfd sp!, {r0-r10, pc}
		
bigBossMovementPhase6:
	cmp r0,#BIGBOSSMODE_ALL_DONE															@ PHASE=WAIT A MO
	bne bigBossAllDone
	
	ldr r0,=bigBossExpHigh
	ldr r1,[r0]
	subs r1,#1
	str r1,[r0]
	bpl bigBossToWait

		ldr r0,=bigBossMode
		mov r1,#BIGBOSSMODE_NO_MORE
		str r1,[r0]
	
	bigBossToWait:

	@ when r1=(around) 30, we need to init a nice fade!		**** NOTE

	ldmfd sp!, {r0-r10, pc}
	
bigBossAllDone:
	cmp r0,#BIGBOSSMODE_NO_MORE															@ PHASE=GO TO COMPLETION
	bne bigBossNoMorePhase

	@ the boss if finished with!!!
	@ all we need to do here is go to the completion code!
	
	ldr r0,=bigBossMode
	ldr r1, =BIGBOSSMODE_FADE_OUT
	str r1, [r0]

	bl fxFadeBlackInit
	
	ldr r0, =fxFadeCallbackAddress
	ldr r1, =showLevelNext
	str r1, [r0]
	
	bl fxFadeOut

bigBossNoMorePhase:

	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------

bigBossInitFire1:
	stmfd sp!, {r0-r10, lr}
@1
	mov r1,#11
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]

	mov r1,#40
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]	
	
	mov r1,#3
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]	
@2
	mov r1,#11
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]

	mov r1,#40
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]	
	
	mov r1,#3
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]	
@3
	mov r1,#23
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]

	mov r1,#120
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]

	mov r1,#2
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]

	mov r1,#4
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]	
	
	mov r1,#4
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]	

@4
	mov r1,#23
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]

	mov r1,#120
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]

	mov r1,#2
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]

	mov r1,#4
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]	
	
	mov r1,#4
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]	
	
@5
	mov r1,#10
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]

	mov r1,#70
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]

	mov r1,#2
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]

	mov r1,#0
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]	
	
	mov r1,#0
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]	

@6
	mov r1,#10
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]

	mov r1,#70
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]

	mov r1,#2
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]

	mov r1,#0
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]	
	
	mov r1,#0
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------
	
bigBossInitFire2:
	stmfd sp!, {r0-r10, lr}
@1
	mov r1,#11
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]

	mov r1,#40
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]	
	
	mov r1,#3
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(42*4)
	str r1,[r0]	
@2
	mov r1,#11
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]

	mov r1,#40
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]	
	
	mov r1,#3
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(47*4)
	str r1,[r0]	
@3
	mov r1,#23
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]

	mov r1,#120
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]

	mov r1,#2
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]

	mov r1,#4
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]	
	
	mov r1,#4
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(52*4)
	str r1,[r0]	

@4
	mov r1,#23
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]

	mov r1,#120
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]

	mov r1,#2
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]

	mov r1,#4
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]	
	
	mov r1,#4
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(53*4)
	str r1,[r0]	
	
@5
	mov r1,#10
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]

	mov r1,#70
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]

	mov r1,#2
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]

	mov r1,#0
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]	
	
	mov r1,#0
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(40*4)
	str r1,[r0]	

@6
	mov r1,#10
	ldr r0,=spriteFireType+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]

	mov r1,#70
	ldr r0,=spriteFireDelay+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]

	mov r1,#2
	ldr r0,=spriteFireSpeed+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]

	mov r1,#0
	ldr r0,=spriteBurstNum+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]	
	
	mov r1,#0
	ldr r0,=spriteBurstDelay+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+BIGBOSS_OFFSET+(49*4)
	str r1,[r0]	
	
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------


@ this is a list of the sprites assigned to the boss.
@ 7*9 = 63 sprites (is this ok?)
.pool
	.align

bigBossSpriteTable1:				@ sprite images used in order 0-63 
.word 29,30,30,29
.word 31,31
.word 32,33,34,35,36,36,35,34,33,32
.word 37,38,39,40,41,42,42,41,40,39,38,37
.word 43,44,45,46,47,48,48,47,46,45,44,43
.word 49,50,51,52,53,53,52,51,50,49
.word 54,54
.word 55,55
bigBossSpriteTable2:				@ sprite images used in order 0-63 
.word 29,30,30,29
.word 31,32,33,34,34,33,32,31
.word 35,36,37,37,36,35
.word 38,39,40,41,42,43,43,42,41,40,39,38
.word 44,45,46,47,48,49,49,48,47,46,45,44
.word 50,51,52,53,54,54,53,52,51,50
.word 55,56,56,55
.word 57,58,58,57
.word 59,59
bigBossFlipTable1:
.word 0,0,1,1
.word 0,1
.word 0,0,0,0,0,1,1,1,1,1
.word 0,0,0,0,0,0,1,1,1,1,1,1
.word 0,0,0,0,0,0,1,1,1,1,1,1
.word 0,0,0,0,0,1,1,1,1,1
.word 0,1
.word 0,1
bigBossFlipTable2:
.word 0,0,1,1
.word 0,0,0,0,1,1,1,1
.word 0,0,0,1,1,1
.word 0,0,0,0,0,0,1,1,1,1,1,1
.word 0,0,0,0,0,0,1,1,1,1,1,1
.word 0,0,0,0,0,1,1,1,1,1
.word 0,0,1,1
.word 0,0,1,1
.word 0,1
bigBossSpritesX1:					@ x offsets for sprites 0-63
.word 128,160,192,224,160,192,0,32,64,96
.word 160,192,256,288,320,352,0,32,64,96
.word 128,160,192,224,256,288,320,352,0,32
.word 64,96,128,160,192,224,256,288,320,252
.word 32,64,96,128,160,192,224,256,288,320
.word 160,192,160,192,0,0,0,0,0,0
.word 0,0,0,0
bigBossSpritesY1:					@ y offsets for sprites 0-63
.word 0,0,0,0,32,32,64,64,64,64
.word 64,64,64,64,64,64,96,96,96,96
.word 96,96,96,96,96,96,96,96,128,128
.word 128,128,128,128,128,128,128,128,128,128
.word 160,160,160,160,160,160,160,160,160,160
.word 192,192,224,224,0,0,0,0,0,0
.word 0,0,0,0
bigBossSpritesX2:					@ x offsets for sprites 0-63
.word 64,160,192,288
.word 64,96,128,160,192,224,256,288
.word 96,128,160,192,224,256
.word 0,32,64,96,128,160,192,224,256,288,320,352
.word 0,32,64,96,128,160,192,224,256,288,320,352
.word 0,32,64,128,160,192,225,288,320,352
.word 0,128,224,352
.word 0,128,224,352
.word 0,352
bigBossSpritesY2:					@ y offsets for sprites 0-63
.word 0,0,0,0
.word 32,32,32,32,32,32,32,32
.word 64,64,64,64,64,64
.word 96,96,96,96,96,96,96,96,96,96,96,96
.word 128,128,128,128,128,128,128,128,128,128,128,128
.word 160,160,160,160,160,160,160,160,160,160
.word 192,192,192,192
.word 224,224,224,224
.word 256,256

bigBossMode:
.word 0
bigBossXphase:
.word 128
bigBossYphase:
.word 48
bigBossExplodeCount:
.word 0
bigBossSpriteExp:
.word 0
bigBossExpHigh:
.word 0
bigBossSpriteNumber:
.word 0

.pool
.end