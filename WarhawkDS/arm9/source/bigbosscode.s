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
	
	#define	bbOffset		68
	#define bbSpriteNum		54

	.arm
	.align
	.text
	
bigBossInit:
	stmfd sp!, {r0-r10, lr}
	@ need to init sprites starting at sprite 17 and up to 81 max
	@ use bossX and bossY for the coords (top left)
	@ use sprite image 30 throughout for now!
	@ we will use sriteActive value of 256 to signal big boss and 512 for the "hit zone"
	@ the only downside is that we can only spare 34 sprite images!!
	
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
	
	bl resetScrollRegisters						@ Reset the scroll registers
	bl clearBG0									@ Clear bgs
	bl clearBG1
	bl clearBG2
	bl clearBG3
	
	bl initStarData
	
	ldr r0,=bossX			@ set initial boss X/Y (20.12 format)
	mov r3,#32				@ r3=x
	lsl r3,#12
	str r3,[r0]
	ldr r0,=bossY
	mov r4,#384+16			@ r4=y
	lsl r4,#12
	str r4,[r0]

	@ ok, init spritedata
	
	mov r0,#0				@ sprite number
	bigBossInitLoop:
		ldr r5,=spriteActive+bbOffset
		mov r6,#256
		str r6,[r5, r0, lsl #2]			@ activate sprite
		ldr r5,=spriteIdent+bbOffset
		mov r6,#32
		str r6,[r5, r0, lsl #2]			@ set the ident (the code will handle this as a huge alien already)
		ldr r5,=spriteHits+bbOffset
		mov r6,#32
		str r6,[r5, r0, lsl #2]			@ number of hits
		mov r6,#30
		ldr r5,=spriteObj+bbOffset
		str r6,[r5, r0, lsl #2]			@ set the sprite image

		mov r6,#0							@ reset other data that may cock things up
		ldr r5,=spriteFireType+bbOffset
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteFireDelay+bbOffset
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteFireMax+bbOffset
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBloom+bbOffset
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteFireSpeed+bbOffset
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstNum+bbOffset
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstNumCount+bbOffset
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstDelay+bbOffset
		str r6,[r5, r0, lsl #2]
		ldr r5,=spriteBurstDelayCount+bbOffset
		str r6,[r5, r0, lsl #2]		
		add r0,#1
		cmp r0,#bbSpriteNum
	bne bigBossInitLoop
	
	bl bigBossInitFire
	bl bigBossDraw
	
	@ set the dummy shoot area for now!
	ldr r5,=spriteActive+276
	mov r6,#512
	str r6,[r5]
	ldr r5,=spriteActive+280
	mov r6,#512
	str r6,[r5]

	@ from here we will have to set the shots of the boss sections
	@ or, have our own code to do it!
	@ the existing code should work if we set any sprite to firing and set the burst,speed,type etc... the code should just handle it!
	
	@ now we need to copy the new sprites across (spritesboss1 for now)
	@ this replaces animated alien and hunters, metoers, etc!
	@ so sprites for the big boss are 30-63 - We could get a few more if needed from repacing the base explosions giving another 9 sprites = 43
	@ this may be worth doing to make it even more varied and SPECIAL - up to you mate??
	
		ldr r0, =Spritesboss1Tiles
		ldr r2, =Spritesboss1TilesLen	
		ldr r1, =SPRITE_GFX
		add r1, #30*512
		bl dmaCopy
		ldr r1, =SPRITE_GFX_SUB
		add r1, #30*512
		bl dmaCopy	
	
	bl fxStarfieldDownOn
	
	ldr r0,=bigBossMode
	mov r1,#2
	str r1,[r0]									@ set bossmode to 1 = bring on from top
												@ 2= move phase, 3=explode init
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
	bl scrollSBMain
	bl scrollSBSub
	bl drawSprite								@ drawsprites and do update bloom effect
	bl checkGameOver							@ check if the game is over
	bl checkLevelControl						@ check to see if we want to change level
	bl playerDeathCheck							@ check and do DEATH stuff
	bl useCheat									@ a call to restore health if cheat is active
	bl checkGamePause							@ check if the game is paused	
@	bl checkEndOfLevel							@ Set Flag for end-of-level
@	bl drawDebugText							@ draw some numbers :)	
	bl bigBossMovement							@ move big boss

	ldr r10,=horizDrift				@ Pointer to data
	ldr r10,[r10]					@ Read value
	mov r8,#0						@ y pos
	mov r9,#3						@ Number of digits
	mov r11, #9						@ x pos
	bl drawDigits					@ Draw

	ldr r0, =horizDrift
	ldr r0, [r0]
	ldr r1, =REG_BG2HOFS			@ Load our horizontal scroll register for BG1 on the main screen
	ldr r2, =REG_BG2HOFS_SUB		@ Load our horizontal scroll register for BG1 on the sub screen
	strh r0,[r1]
	strh r0,[r2]	
	lsr r0,#1
	ldr r1, =REG_BG3HOFS			@ Load our horizontal scroll register for BG1 on the main screen
	ldr r2, =REG_BG3HOFS_SUB		@ Load our horizontal scroll register for BG1 on the sub screen
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
	ldr r8,=bigBossSpritesX1	@ x table
	ldr r9,=bigBossSpritesY1	@ y table
	ldr r10,=spriteX+bbOffset	@ sprites X coords
	ldr r11,=spriteY+bbOffset	@ sprites Y coords	
	mov r2,#0				@ r2 = sprite number
	
	bigBossDrawerLoop:
		ldr r6,[r8, r2, lsl #2]		@ r6= x offset
		adds r7,r0,r6					@ r7= actuall coord
		str r7,[r10, r2, lsl #2]		@ store coord
		ldr r6,[r9, r2, lsl #2]		@ r6= y offset
		adds r7,r1,r6					@ r7= actuall coord
		str r7,[r11, r2, lsl #2]		@ store coord		
		add r2,#1
		cmp r2,#bbSpriteNum
	bne bigBossDrawerLoop

	ldmfd sp!, {r0-r10, pc}
	
@------------------------------------------------------
	
bigBossInitExplode:
	stmfd sp!, {r0-r10, lr}
	
	mov r0,#0				@ sprite number
	mov r6,#64
	@ for now (until we have a proper DEATH) we just nulify the boss!
	bigBossActiveKill:
		ldr r5,=spriteActive+bbOffset
		str r6,[r5, r0, lsl #2]			@ make it something that has no detection value
		add r0,#1
		cmp r0,#63
	bne bigBossActiveKill

	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------

bigBossMovement:

	stmfd sp!, {r0-r10, lr}
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

@------------------------------------------------------
	
bigBossInitFire:
	stmfd sp!, {r0-r10, lr}
@1
	mov r1,#11
	ldr r0,=spriteFireType+bbOffset+(42*4)
	str r1,[r0]

	mov r1,#40
	ldr r0,=spriteFireDelay+bbOffset+(42*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+bbOffset+(42*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteFireSpeed+bbOffset+(42*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteBurstNum+bbOffset+(42*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+bbOffset+(42*4)
	str r1,[r0]	
	
	mov r1,#3
	ldr r0,=spriteBurstDelay+bbOffset+(42*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+bbOffset+(42*4)
	str r1,[r0]	
@2
	mov r1,#11
	ldr r0,=spriteFireType+bbOffset+(47*4)
	str r1,[r0]

	mov r1,#40
	ldr r0,=spriteFireDelay+bbOffset+(47*4)
	str r1,[r0]
	ldr r0,=spriteFireMax+bbOffset+(47*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteFireSpeed+bbOffset+(47*4)
	str r1,[r0]

	mov r1,#3
	ldr r0,=spriteBurstNum+bbOffset+(47*4)
	str r1,[r0]
	ldr r0,=spriteBurstNumCount+bbOffset+(47*4)
	str r1,[r0]	
	
	mov r1,#3
	ldr r0,=spriteBurstDelay+bbOffset+(47*4)
	str r1,[r0]
	ldr r0,=spriteBurstDelayCount+bbOffset+(47*4)
	str r1,[r0]	

	ldmfd sp!, {r0-r10, pc}

@------------------------------------------------------


@ this is a list of the sprites assigned to the boss.
@ we may have another for level 32?
@ 7*9 = 63 sprites (is this ok?)

bigBossSpriteTable1:				@ sprite images used in order 0-63 
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0
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
bigBossMode:
.word 0
bigBossXphase:
.word 128
bigBossYphase:
.word 48
.end