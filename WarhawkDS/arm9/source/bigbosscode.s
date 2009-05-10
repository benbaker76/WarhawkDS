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

	.global bigBossInit
	.global updateBigBoss
	.global bigBossInitExplode

	.arm
	.align
	.text
	
bigBossInit:
	stmfd sp!, {r0-r10, lr}
	@ need to init sprites starting at sprite 17 and up to 81 max
	@ use bossX and bossY for the coords (top left)
	@ use sprite image 62 throughout for now!
	@ we will use sriteActive value of 256 to signal big boss and 512 for the "hit zone"
	@ the only downside is that we can only spare 34 sprite images!!
	
	@----------------------------------
	@ SO, AND I NEED YOUR INPUT HERE!!!!
	@ the size it is now, we can also release powerups
	@ or another row of 7 and no powerup but a bigger ship! More impressive?? We could make "powerup" perminent for this
	@ boss fight, so powerup collection is not needed...
	@ also, should we give player full hitpoints at the start of the battle??
	@----------------------------------
	
	@ one good thing or 2...
	@ drawsprite and standard collision handles everything here with this
	@ also, it was so so easy to integrate!! :)
	
	@-----------------------------------
	@
	@ another thing.... when you die... we will have to do something else,
	@ there are not ANY sprites free of a higher priority to enable explosions ABOVE the ship?
	@ so, what can we do?
	@ fade the ship out and release the sprites? help!!!
	@
	@------------------------------------
	
	ldr r0,=bossX
	mov r3,#96+16			@ r3=x
	str r3,[r0]
	ldr r0,=bossY
	mov r4,#384+16			@ r4=y
	str r4,[r0]

	@ ok, init spritedata
	
	mov r0,#0				@ sprite number
	mov r1,r3				@ x count
	mov r2,r4				@ y count
	mov r7,#0
	bigBossInitLoop:
		ldr r5,=spriteActive+68
		mov r6,#256
		str r6,[r5, r0, lsl #2]			@ activate sprite
		ldr r5,=spriteX+68
		str r1,[r5, r0, lsl #2]			@ set X coord
		ldr r5,=spriteY+68
		str r2,[r5, r0, lsl #2]			@ set y coord
		ldr r5,=spriteIdent+68
		mov r6,#32
		str r6,[r5, r0, lsl #2]			@ set the ident (the code will handle this as a huge alien already)
		ldr r5,=spriteHits+68
		mov r6,#512
		str r6,[r5, r0, lsl #2]			@ number of hits
		mov r6,#62
		ldr r5,=spriteObj+68
		str r6,[r5, r0, lsl #2]			@ set the sprite image

		mov r6,#0							@ reset other data that may cock things up
		ldr r5,=spriteFireType
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteFireDelay
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteFireMax
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBloom
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteFireSpeed
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstNum
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstNumCount
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstDelay
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstDelayCount
		str r6,[r5, r0, lsl #2]		
		add r1,#32
		add r7,#1
		cmp r7,#7
		moveq r7,#0
		moveq r1,r3
		addeq r2,#32
		
		add r0,#1
		cmp r0,#56
	bne bigBossInitLoop
	
	@ set the dummy shoot areas for now!
	ldr r5,=spriteActive+276
	mov r6,#512
	str r6,[r5]
	ldr r5,=spriteActive+372	
	str r6,[r5]	
	ldr r5,=spriteActive+368	
	str r6,[r5]	
	@ from here we will have to set the shots of the boss sections
	@ or, have our own code to do it!
	
	
	@ now we need to copy the new sprites across (spritesboss1 for now)

	mov r1,#GAMEMODE_BIGBOSS					@ set gamemode to switch to bigboss battle
	ldr r0,=gameMode
	str r1,[r0]

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
@	bl scrollMain								@ Scroll Level Data			@ we will use a differet background here
@	bl scrollSub								@ Main + Sub				@ and here
	bl levelDrift								@ update level with the horizontal drift
	bl moveBullets								@ check and then moves bullets
	bl scrollStars								@ Scroll Stars (BG2,BG3)	@ just done this for effect
	bl scrollStars								@ Scroll Stars (BG2,BG3)	@ though we will need a different backgroung
	bl scrollStars								@ Scroll Stars (BG2,BG3)	@ faded in... hmmm...??
	bl scrollStars								@ Scroll Stars (BG2,BG3)	@ we do have to make this stand out! :)
	bl drawSprite								@ drawsprites and do update bloom effect
	bl checkGameOver							@ check if the game is over
	bl checkLevelControl						@ check to see if we want to change level
	bl playerDeathCheck							@ check and do DEATH stuff
	bl useCheat									@ a call to restore health if cheat is active
	bl checkGamePause							@ check if the game is paused	
@	bl checkEndOfLevel							@ Set Flag for end-of-level
@	bl drawDebugText							@ draw some numbers :)	
	bl bigBossMovement							@ move big boss
	
	@ use this to keep powerup active...
	mov r0,#1
	ldr r1,=powerUp
	str r0,[r1]
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------

bigBossDraw:

	stmfd sp!, {r0-r10, lr}
	
	@ this will update the position of all sprites based on bossX and bossY

	ldr r0,=bossX
	ldr r3,[r0]				@ r3=x
	ldr r0,=bossY
	ldr r2,[r0]				@ r4=y

	mov r0,#0				@ sprite number
	mov r4,r3				@ x pos
	mov r7,#0				@ x count
	bigBossDrawLoop:
		ldr r5,=spriteX+68
		str r4,[r5, r0, lsl #2]			@ set X coord
		ldr r5,=spriteY+68
		str r2,[r5, r0, lsl #2]			@ set y coord

		add r4,#32
		add r7,#1
		cmp r7,#7
		moveq r7,#0
		moveq r4,r3
		addeq r2,#32	
		add r0,#1
		cmp r0,#56
	bne bigBossDrawLoop

	ldmfd sp!, {r0-r10, pc}
@------------------------------------------------------
	
bigBossInitExplode:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#0				@ sprite number
	mov r6,#64
	@ for now (until we have a proper DEATH) we just nulify the boss!
	bigBossActiveKill:
		ldr r5,=spriteActive+68
		str r6,[r5, r0, lsl #2]			@ activate sprite
		add r0,#1
		cmp r0,#63
	bne bigBossActiveKill

	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------

bigBossMovement:

	stmfd sp!, {r0-r10, lr}
	@ sine/cos movement?

	bl bigBossDraw							@ update to new position
	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------

@ this is a list of the sprites assigned to the boss.
@ we may have another for level 32?
@ 7*9 = 63 sprites (is this ok?)

bigBossSpriteTable1:
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0


.end