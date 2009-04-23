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


	.arm
	.align
	.text

	.global checkBossInit
	.global bossAttack
	.global bossIsShot
	.global bossExploder
	
@----------------- BOSS INIT CODE	
checkBossInit:
	stmfd sp!, {r1-r2, lr}

	ldr r0,=playerDeath
	ldr r0,[r0]
	cmp r0,#5
	bne bossInitActive
		ldmfd sp!, {r1-r2, pc}
	bossInitActive:

	@ this uses yposSub to tell when we should display the BOSS
	@ Perhaps levelend will tell us when to move him???
	@ not sure?
	@ we will use bossMan as a flag to say that he is HERE!!!
	@ 0= no (but check scroll)
	@ 1=yes, but not ready to move (so move with scroller)
	@ 2=attack time (scroller stopped so off we go)
	@ 3=boss is DEAD = EXPLODE
	@ 4=EXPLODE done, end level!!
	
	ldr r0,=bossMan
	ldr r0,[r0]
	cmp r0,#0
	beq bossInit
	cmp r0,#1
	beq bossActiveScroll		@ Use this to scroll the Boss with the bg1
	cmp r0,#2
	bne bossDeadCheck
		bl bossAttack			@ if he is active, let "bossAttack" do the work
		b checkBossInitFail
	bossDeadCheck:
	cmp r0,#3
	bne bossDeadCheck2
		bl bossIsDead
		b checkBossInitFail
	bossDeadCheck2:
	cmp r0,#4
	bne checkBossInitFail
		ldr r0,=explodeSpriteBossCount	@ if bossMan=4 we want to use this bit of code
		ldr r0,[r0]						@ so that we can keep him moving for a bit
		cmp r0,#1						@ while he explodes and then stop him
		bge checkBossInitFail			@ and let the explosion settle :)
		bl bossAttack	
		b checkBossInitFail	
	ldmfd sp!, {r1-r2, pc}
@------------------ INIT THE BOSS DATA	
	bossInit:
	
	ldr r0,=yposSub
	ldr r0,[r0]
	cmp r0,#352					@ scroll pos to init BOSS
	bne checkBossInitFail		@ not time yet :(
		@ here we need to lay all the sprites and data out for the boss
	
		mov r1,#1
		ldr r0,=bossMan
		str r1,[r0]				@ set to "scroll mode" (So he will move with scroll only!)
	
		@ FIRST, we need to copy the sprites from "BossShipTiles" into our tiles from sprite ??
		@ set r0 to the source based on the level
		@ set r1 to the destination in our sprite tiles
		ldr r0, =BossShipsTiles
		ldr r1,=levelNum		@ 1-16
		ldr r1,[r1]
		sub r1,#1				@ now 0-15
		mov r2,#9
		mul r1,r2				@ *9 sprites per boss (level*9)*512
		lsl r1,#9				@ multiply by 512
		add r0,r1				@ add to base, r0=source of boss tiles!
		push {r0}
		ldr r1, =SPRITE_GFX
		add r1,#55*512			@ boss starts as sprite 55

		ldr r2, =512*9			@ 9 sprites to copy
		bl dmaCopy
		pop {r0}
		ldr r1, =SPRITE_GFX_SUB
		add r1,#55*512
		ldr r2, =512*9			@ 9 sprites to copy (duplicted in case or error here?)
		bl dmaCopy	
		
		@ OK, that is that boss sprites assigned (55-63)
		@ now we need to activate them (113-x)
		@ we will uses spriteActive of #128 for a boss
		mov r0,#55					@ r0 = sprite object
		mov r1,#113					@ r1 = sprite number
		ldr r2,=spriteActive
		mov r3,#128					@ spriteActive Value
		bossSpriteLoop:
			ldr r2,=spriteActive
			str r3,[r2, r1, lsl #2]	@ activate the sprite
			ldr r2,=spriteObj
			str r0,[r2, r1, lsl #2]	@ Store the sprites image
			ldr r2,=spriteIdent
			str r3,[r2, r1, lsl #2]	@ set the ident to 128 (so the unit flashes as one)
			
			add r0,#1
			add r1,#1
			cmp r0,#64
		bne bossSpriteLoop
		
		@---------- FROM HERE WE SET THE DATA
		
		ldr r1,=bossX					@ set X coord
		mov r0,#144+32
		str r0,[r1]
		ldr r1,=bossY					@ set y coord
		mov r0,#288-42
		str r0,[r1]
		@ now we need to read the bossInitLev data based on the level
		@ and set the variables accordingly		
		ldr r0,=levelNum
		ldr r0,[r0]						@ level 1-16
		sub r0,#1						@ make level 0-15
		ldr r1,=bossInitLev				@ start of the 8 words that define a boss
		add r1, r0, lsl #5				@ add level * 32 (bytes) (8 words)
										@ r1=pointer to start of bossinitLev for the boss number

		mov r2,#20						@ special is the 6th word value
		ldr r2,[r1,r2]					@ grab "SPECIAL VALUE"
		cmp r2,#0
			bleq bossInitStandard		@ used on level 1
		cmp r2,#1
			bleq bossInitTracker
		cmp r2,#2
			bleq bossInitLurcher
		cmp r2,#3
			bleq bossInitCrane
		cmp r2,#4
			bleq bossInitSine
		cmp r2,#5
			bleq bossInitSine		
		
		bl bossDraw
		ldmfd sp!, {r1-r2, pc}
		
	bossActiveScroll:
		@ here we need to update all 9 sprites by 1 Y pos.
		@ and check when time to "LAUNCH", set bossman to 2
		@ So, take y coord, add 1, call bossDraw!
		ldr r0,=levelEnd
		ldr r0,[r0]
		cmp r0,#1
		bne bossStillScroll
			ldr r0,=bossMan
			mov r1,#2
			str r1,[r0]
			bl fxFadeWhiteIn				@ need a FLASH to WHITE and back to NORMAL
		bossStillScroll:
		ldr r0,=bossY
		ldr r1,[r0]
		add r1,#1
		str r1,[r0]
		bl bossDraw

checkBossInitFail:
	ldmfd sp!, {r1-r2, pc}

@------------------ ALL THIS DOES IS DRAW THE BOSS BASED ON TOP LEFT X/Y	
bossDraw:
	stmfd sp!, {r1-r6, lr}
	ldr r6,=bossX
	ldr r6,[r6]					@ r6 =x (top left of boss)
	ldr r2,=bossY
	ldr r2,[r2]					@ r2 =y
	
	mov r4,#113					@ r4 = sprite number to draw
	mov r5,#0					@ horizontal counter
	bossDrawLoop:
	
		ldr r3,=spriteActive	@ we need to make sure if the boss in exploding
		add r3, r4, lsl #2		@ that we leave it alone
		ldr r3,[r3]
		cmp r3,#4				@ value of boss explode
		beq noBossCollide
	
		ldr r3,=spriteX
		str r6,[r3, r4, lsl #2]	@ store X
		ldr r3,=spriteY
		str r2,[r3, r4, lsl #2]	@ store y
		
		@ now we need to detect against your ship using alienCollideCheck
		@ r1 must be the aliens offset
		
			ldr r1,=spriteActive
			add r1, r4, lsl #2
			bl alienCollideCheck
		
		noBossCollide:
		
		add r5,#1
		cmp r5,#3
		addne r6,#32
		bne bossDrawNotX
			mov r5,#0
			add r2,#32
			sub r6,#64
		bossDrawNotX:
		add r4,#1
		cmp r4,#122
	bne bossDrawLoop	
	
	ldmfd sp!, {r1-r6, pc}
		
@------------------ BOSS HAS TAKEN A SHOT!!!
bossIsShot:
	@ r0 = bullet offset
	@ r4 = sprite offset
	@ r7 = bullets danage value
	stmfd sp!, {r0-r8, lr}
		ldr r8,=levelEnd
		ldr r8,[r8]
		cmp r8,#2
		beq heBeDead
		
		ldr r8,=playerDeath
		ldr r8,[r8]				@ if player is dying, boss CANNOT die.. else a stray bullet
		cmp r8,#0				@ could kill the boss and you would clear the level - DEAD ??
		bne heBeDead
		
				@ ok, now we need to see how many hits to kill
		ldr r8,=bossHits
		ldr r6,[r8]
		subs r6,r7
		str r6,[r8]
		cmp r6,#0
		bpl bossIsOK
			ldr r8,=bossMan
			mov r6,#3
			str r6,[r8]
			ldmfd sp!, {r0-r8, pc}
		bossIsOK:
			@ make the boss "FLASH"
			mov r7,#113
			bossBloomLoop:
				ldr r5,=spriteBloom
				mov r3,#16
				str r3,[r5, r7, lsl #2]
				add r7,#1
				cmp r7,#123
			bne bossBloomLoop
		
			@ ok, alien not dead yet!!, so, play "Hit" sound
			@ and perhaps a "shard" (mini explosion) activated under BaseExplosion?
			mov r8,#SPRITE_X_OFFS
			ldr r6,[r4,r8]
			mov r6,r1			@ just test with bullet x (comment out to use alien x)
			mov r8,#SPRITE_Y_OFFS
			ldr r7,[r4,r8]
			bl drawShard
					
			@ add score
			ldr r8,=adder+7				@ add 5 to the score
			mov r6,#5
			strb r6,[r8]
			sub r8,#1
			mov r6,#1
			strb r6,[r8]
			bl addScore	
			bl playShipArmourHit1Sound
		heBeDead:
	ldmfd sp!, {r0-r8, pc}

@------------------ KILL THE BOSS
bossIsDead:
	stmfd sp!, {r0-r8, lr}

	ldr r1,=levelEnd
	mov r0,#2
	str r0,[r1]
	
	ldr r1,=bossMan
	mov r0,#4
	str r0,[r1]

	ldmfd sp!, {r0-r8, pc}

@------------------ BOSS ATTACK CODE	
bossAttack:
	stmfd sp!, {r0-r8, lr}

	@ Boss attack code goes in here - somehow!!
	@ BUGGER ME!! Here we need to move the boss and take care of its firing needs
	@ What joy, what fun, what?
	@ whatever data we need to use must be set in bossInit

	@ we need to calulate limits based on max X speed?
	@ amd use r8 = left limit. r9 = right limit
	
	@ must look into a way to calculate this???
	ldr r8,=bossSpecial
	ldr r8,[r8]
	cmp r8,#0
		bleq bossAttackLR
	cmp r8,#1
		bleq bossHunterMovement
	cmp r8,#2
		bleq bossLurcherMovement
	cmp r8,#3
		bleq bossCraneMovement
	cmp r8,#4
		bleq bossSine1Movement
	cmp r8,#5
		bleq bossSine2Movement

	ldr r5,=bossMan
	ldr r5,[r5]					@ if boss is exploding, do not fire!
	cmp r5,#3
	bllt bossFire				@ do our fire checks, and shoot if needed
	
	bl bossDraw					@ redraw our boss
	
	ldmfd sp!, {r0-r8, pc}

@------------ OUR BOSSES FIRE CODE COMES IN HERE
bossFire:
	stmfd sp!, {r0-r8, lr}
	@ First, check if the fire delay is 0
	@ then grab fire type and set fire delay
	@ add to fire phase also
	ldr r1,=levelEnd
	ldr r1,[r1]
	cmp r1,#2
	beq bossNoNeedReset
	
	ldr r1,=bossFireDelay
	ldr r0,[r1]					@ grab fire delay
	subs r0,#1					@ take 1 off
	bmi boss2Fire				@ if <0, time to fire
		str r0,[r1]
		ldmfd sp!, {r0-r8, pc}
	boss2Fire:					@ init a new bullet and reset delay
	@ we will use 2 pieces of code here for speed!!
	@ one for single shot and one for twin

		ldr r1,=levelNum
		ldr r1,[r1]					@ r1 = level number
		sub r1,#1					@ level is 1-16, we need 0-15
		ldr r2,=bossFireLev			@ r2 = location base of fire pattern data
		add r2,r1, lsl #8			@ add level*256 bytes
		ldr r1,=bossFirePhase
		ldr r1,[r1]					@ r1 = shot phase (0-31)
		lsl r1,#3					@ phase * 8 (data in 2 word pairs = 8 bytes)
		add r2,r1					@ r2 now points to speed/type
		ldr r4,[r2]					@ r4 = speed and type	
		ldr r7,=0xFFFF				@ isolate lower 16 bits (type)
		and r3,r4,r7				@ r3 = type
		cmp r3,#0
		beq bossNotFired
		cmp r3,#SPRITE_TYPE_HUNTER
		beq initBossHunter
		cmp r3,#SPRITE_TYPE_ALIENWAVE
		beq initBossWave
	
	ldr r5,=bossFireMode
	ldr r5,[r5]
	cmp r5,#0
	bne tryBossFire1
		@------------ SINGLE SHOT -------------
		ldr r1,=spriteActive		@ grab a bullet gen base
		add r1,#127*4				@ use the last sprite (127)
	
		ldr r4,[r2]					@ grab speed/type
		lsr r4,#16					@ shunt them down :)
		
		ldr r5,=SPRITE_FIRE_SPEED_OFFS		@ load Speed offset
		str r4,[r1,r5]				@ and store it in the bullet define

		mov r5,#0
		str r5,[r1]  				@ clear "sprite active" value
		ldr r5,=bossX
		ldr r5,[r5]
		add r5,#32
		mov r4,#SPRITE_X_OFFS
		str r5,[r1,r4]				@ store bullets X
		ldr r5,=bossY
		ldr r5,[r5]
		add r5,#66
		mov r4,#SPRITE_Y_OFFS		@ store bullets y
		str r5,[r1,r4]	
		bl alienFireInit			@ init bullet (there is something else we need?)
		mov r5,#788
		mov r4,#SPRITE_X_OFFS
		str r5,[r1,r4]
		mov r4,#SPRITE_Y_OFFS
		str r5,[r1,r4]
		b bossFireDone
	tryBossFire1:
		@ ---------------- TWIN FIRE ---------------------
		ldr r1,=spriteActive		@ grab a bullet gen base
		add r1,#127*4				@ use the last sprite (127)

		ldr r4,[r2]					@ grab speed/type
		lsr r4,#16					@ shunt them down :)
		ldr r5,=SPRITE_FIRE_SPEED_OFFS		@ load Speed offset
		str r4,[r1,r5]				@ and store it in the bullet define

		mov r5,#0
		str r5,[r1]  				@ clear "sprite active" value
		ldr r5,=bossX
		ldr r5,[r5]
		add r5,#12					@ left bullet
		mov r4,#SPRITE_X_OFFS
		str r5,[r1,r4]				@ store bullets X
		ldr r5,=bossY
		ldr r5,[r5]
		add r5,#66
		mov r4,#SPRITE_Y_OFFS		@ store bullets y
		str r5,[r1,r4]	
		bl alienFireInit			@ init bullet (there is something else we need?)

		@ for second bullet, if the type is "phased", then make the right alternate
		cmp r3,#15
		moveq r3,#16

		ldr r5,=bossX
		ldr r5,[r5]
		add r5,#12+32				@ left bullet
		mov r4,#SPRITE_X_OFFS
		str r5,[r1,r4]				@ store bullets X
		ldr r5,=bossY
		ldr r5,[r5]
		add r5,#66
		mov r4,#SPRITE_Y_OFFS		@ store bullets y
		str r5,[r1,r4]	
		bl alienFireInit			@ init bullet (there is something else we need?)
		
		mov r5,#788
		mov r4,#SPRITE_X_OFFS
		str r5,[r1,r4]
		mov r4,#SPRITE_Y_OFFS
		str r5,[r1,r4]

	bossFireDone:
	@ now we need to grab and store the bullets delay value
	add r2,#4					@ move to next word pointed to by r2
	ldr r3,[r2]					@ r1 = delay value
	ldr r0,=bossFireDelay
	str r3,[r0]
	
	bossNotFired:
	@ add to the phase (if past 31, reset to 0)
	ldr r3,=bossFirePhase
	ldr r0,[r3]
	add r0,#1
	cmp r0,#32
	moveq r0,#0
	str r0,[r3]

	ldr r1,=levelNum
	ldr r1,[r1]					@ r1 = level number
	sub r1,#1					@ level is 1-16, we need 0-15
	ldr r2,=bossFireLev			@ r2 = location base of fire pattern data
	add r2,r1, lsl #8			@ add level*256 bytes
	ldr r1,=bossFirePhase
	ldr r1,[r1]					@ r1 = shot phase (0-31)
	lsl r1,#3					@ phase * 8 (data in 2 word pairs = 8 bytes)
	add r2,r1					@ r2 now points to speed/type
	ldr r4,[r2]					@ r4 = speed and type
								@ we need to split these up and store!	
	cmp r4,#0
	bne bossNoNeedReset
		ldr r1,=bossFirePhase
		mov r0,#0
		str r0,[r1]
	bossNoNeedReset:
	
	ldmfd sp!, {r0-r8, pc}
	
@---------------- HERE WE NEED TO "FIRE" A HUNTER!
initBossHunter:
	ldr r4,[r2]					@ grab speed/type
	lsr r4,#16					@ shunt them down :)
	
	cmp r4,#SPRITE_TYPE_HUNTER	@ if speed is set also, we need to randomly grab a number
	bne bossHunterFixed
	
		bl getRandom
		ldr r4,=0x1ff
		and r8,r4
		mov r4,#9
		mul r8,r4
		lsr r8,#4
		add r4,r8,#64
		@ this should make it 64-351 ( from 0-288)
	
	bossHunterFixed:
		
	ldr r3,=spriteActive+68		@ ok, time to init a mine... We need to find a free space for it?
	mov r0,#0					@ R0 points to the sprite that will be used for the mine
		findBossHunterLoop:
		ldr r4,[r3,r0, lsl #2]
		cmp r4,#0
		beq foundBossHunter
			adds r0,#1
			cmp r0,#64
		bne findBossHunterLoop
		b bossFireDone
		foundBossHunter:
			add r3,r0, lsl #2		@ r3 is now offset to mine sprite
			mov r1,#3
			str r1,[r3]				@ activate as activeSprite 3
			mov r0,#SPRITE_X_OFFS
			
			str r4,[r3,r0]			@ set x coord
			mov r0,#SPRITE_Y_OFFS
			mov r1,#SCREEN_SUB_TOP-32			@ set y coord
			str r1,[r3,r0]
			mov r0,#SPRITE_SPEED_Y_OFFS
			mov r1,#2				@ set y speed (change based on LEVEL) (2 is good for early levels)
			str r1,[r3,r0]
			mov r0,#SPRITE_OBJ_OFFS
			mov r1,#30
			str r1,[r3,r0]			@ set sprite to display
			mov r0,#SPRITE_HIT_OFFS
			mov r1,#0				@ set number of hits a single shot (for now)
			str r1,[r3,r0]
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			mov r1,#0				@ set it to never fire (for now)
			str r1,[r3,r0]
			mov r0,#SPRITE_IDENT_OFFS
			str r1,[r3,r0]

	b bossFireDone

@--------------- HERE WE NEED TO 'FIRE' AND ATTACK WAVE
initBossWave:
		ldr r4,[r2]					@ grab speed/type
		lsr r4,#16					@ shunt them down :)
		@ now we need to make r2 the index to the start of attack wave r4
		ldr r5,=alienWave
		add r5, r4, lsl #7				@ add r2=r7*128 (each wave is 32 words)
		mov r3,#0						@ counter to get the data an init them
		initBossAliens:					@ we need to pass r1 to initAliens to start them
			ldr r1,[r5,r3, lsl #2]		@ r1+alien number*4 (one word each)
			cmp r1,#0
				beq initBossAliensDone	@ if the alien descript is 0, that is it!
				mov r6,#0				@ make sure aliens have no ident
				bl initAlien
			add r3,#1
			cmp r3,#32
		bne initBossAliens
	initBossAliensDone:
	
	b bossFireDone
	
@----------------- THIS IS OUR RATHER FUN EXPLODE CODE
bossExploder:
	stmfd sp!, {lr}
	@ sprites 17-127 can be used
	@ if active is not 0 or 128, take the x,y from it and explode it anyway!!

	ldr r2,=levelEnd
	ldr r2,[r2]
	cmp r2,#3
	beq stillExplodingBoss

	beloop:
	ldr r0,=explodeSpriteBoss
	ldr r1,[r0]						@ r1=number of sprite to explode! (USED LATER ****)
	beloop2:
	ldr r2,=spriteActive
	add r2, r1, lsl #2				@ r2=offs to sprite
	ldr r3,[r2]						@ r3=spriteActive
	cmp r3,#0
	moveq r7,#0
	beq useForBossExplode
	cmp r3,#128
	moveq r7,r3
	beq useForBossExplode
		@	ok, this is an active alien, or bullet!! (but if it is an explosion, ignore it)
		cmp r3,#4					@ if >=4, let it do its stuff! (drawsprite.s will handle it)
		bge notFreeForBoss
		@ ok, lets blow this bugger up :)
			mov r6,#4
			str r6,[r2]
			mov r6,#6
			mov r8,#SPRITE_OBJ_OFFS
			str r6,[r2,r8]
			mov r6,#4
			mov r8,#SPRITE_EXP_DELAY_OFFS
			str r6,[r2,r8]
			mov r10,#0
			b notFreeForBoss
	
	useForBossExplode:
		@ ok, we need to get a random number for X coord (0-95)
		bl getRandom
		and r8,#127
		mov r3,#3
		mul r8,r3
		push {r0,r1}
		mov r0,r8
		mov r1,#6
		bl divf32
		mov r8,r0, lsr #12			
		ldr r6,=bossX
		ldr r6,[r6]
		add r9,r8,r6			@ r9 = X coord

		bl getRandom
		and r8,#127
		mov r3,#3
		mul r8,r3
		mov r0,r8
		mov r1,#6
		bl divf32
 		mov r8,r0, lsr #12
		ldr r6,=bossY
		ldr r6,[r6]	
		add r10,r8,r6			@ r10 = Y coord
		pop {r0,r1}

		@ r2= offset to the sprite, so lets use that to explode it!!!
			mov r6,#4
			str r6,[r2]
			mov r6,#6
			mov r8,#SPRITE_OBJ_OFFS
			str r6,[r2,r8]
			mov r6,#8
			mov r8,#SPRITE_EXP_DELAY_OFFS
			str r6,[r2,r8]
			mov r8,#SPRITE_X_OFFS
			str r9,[r2,r8]
			mov r8,#SPRITE_Y_OFFS
			str r10,[r2,r8]
			mov r10,#0
			mov r8,#SPRITE_SPEED_X_OFFS
			str r10,[r2,r8]
			mov r8,#SPRITE_SPEED_Y_OFFS
			str r10,[r2,r8]
			mov r8,#SPRITE_SPEED_DELAY_X_OFFS
			str r10,[r2,r8]
			mov r8,#SPRITE_SPEED_DELAY_Y_OFFS
			str r10,[r2,r8]
			mov r8,#SPRITE_FIRE_SPEED_OFFS
			str r10,[r2,r8]
			mov r8,#SPRITE_FIRE_TYPE_OFFS
			str r10,[r2,r8]
			@ do a random bloom
			bl getRandom
			and r8,#0x2F		@ i know it is out of palette range, but give a shimmer!! :) (cheating)
			mov r6,#SPRITE_BLOOM_OFFS
			str r8,[r2,r6]
			cmp r7,#128
			bne notFreeForBoss
			add r1,#1
			@str r1,[r2]
			b beloop2
	notFreeForBoss:

	add r1,#1
	cmp r1,#127					@ PUT CHECKS INTO THE DETECTION
	bne noBossExplodeWrap
		mov r1,#17
		ldr r5,=explodeSpriteBossCount
		ldr r6,[r5]
		add r6,#1
		str r6,[r5]
	noBossExplodeWrap:
	str r1,[r0]						@ put new sprite number back ****
	
	ldr r5,=explodeSpriteBossCount
	ldr r6,[r5]
	cmp r6,#1						@ this is "HOW LONG FOR IT????" (tie this to Explosion sound)
	ble stillExplodingBoss
		ldr r6,=levelEnd
		mov r8,#3
		str r8,[r6]
	stillExplodingBoss:

	ldmfd sp!, {pc}
	.pool
	.end