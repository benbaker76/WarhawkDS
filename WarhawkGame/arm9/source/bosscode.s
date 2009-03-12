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

	.global checkBossInit
	.global bossAttack
	.global bossIsShot
	
@----------------- BOSS INIT CODE	
checkBossInit:
	stmfd sp!, {r1-r2, lr}
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
	bne checkBossInitFail
		bl bossIsDead
		b checkBossInitFail	
	ldmfd sp!, {r1-r2, pc}
	
	
	bossInit:
	ldr r0,=yposSub
	ldr r0,[r0]
	cmp r0,#352					@ scroll pos to init BOSS
@cmp r0,#3744					@ COMMENT OUT LINE ABOVE AND ADD THIS FOR TEST!
	bne checkBossInitFail		@ not time yet :(
		@ here we need to lay all the sprites and data out for the boss
		
		mov r1,#1
		ldr r0,=bossMan
		str r1,[r0]				@ set to "scroll mode" (So he will move with scroll only!)
	
		@ FIRST, we need to copy the sprites from "BossShipTiles" into our tiles from sprite ??
		@ set r0 to the source based on the level
		@ set r1 to the destination in our sprite tiles
		ldr r0, =BossShipsTiles
		ldr r1,=levelNum
		ldr r1,[r1]
		sub r1,#1
		mov r2,#9
		mul r1,r2				@ *9 sprites per boss (level*9)*512
		lsl r1,#9				@ multiply by 512
		add r0,r1				@ add to base
		
		ldr r1, =SPRITE_GFX
		add r1,#55*512			@ boss starts as sprite 55

		ldr r2, =512*9			@ 9 sprites to copy
		bl dmaCopy
		ldr r1, =SPRITE_GFX_SUB
		add r1,#55*512
		bl dmaCopy	
		@ OK, that is that boss sprites assigned (55-63)
		@ now we need to activate them (113-x)
		@ we will uses spriteActive of #128 for a boss
		mov r0,#55					@ r0 = sprite object
		mov r1,#113					@ r1 = sprite number
		ldr r2,=spriteActive
		bossSpriteLoop:
			mov r3,#128
			ldr r2,=spriteActive
			str r3,[r2, r1, lsl #2]	@ activate the sprite
			ldr r2,=spriteObj
			str r0,[r2, r1, lsl #2]	@ Store the sprites image
			mov r3,#128
			ldr r2,=spriteIdent
			str r3,[r2, r1, lsl #2]	@ set the ident to 128 (so the unit flashes as one)
			
			add r0,#1
			add r1,#1
			cmp r0,#64
		bne bossSpriteLoop
		ldr r1,=bossX					@ set X coord
		mov r0,#144+32
		str r0,[r1]
		ldr r1,=bossY					@ set y coord
		mov r0,#288-42
@ add r0,#150				@------------------ TESTING
		str r0,[r1]
		@ now we need to read the bossInitLev data based on the level
		@ and set the variables accordingly		
		ldr r0,=levelNum
		ldr r0,[r0]
		sub r0,#1						@ make level 0-15
		ldr r1,=bossInitLev
		add r1, r0, lsl #5				@ add level * 32 (bytes)
		ldr r0,[r1]						@ load "max X speed"
		ldr r2,=bossMaxX
		str r0,[r2]	
		add r1,#4
		ldr r0,[r1]						@ load "max y speed"
		ldr r2,=bossMaxY
		str r0,[r2]
		add r1,#4
		ldr r0,[r1]						@ load "boss turn speed"
		ldr r2,=bossTurn
		str r0,[r2]
		add r1,#4
		ldr r0,[r1]
		ldr r2,=bossHits				@ set hits to kill
		str r0,[r2]
		add r1,#4
		ldr r0,[r1]
		ldr r2,=bossFireMode			@ store mode, 0=normal/1=twin fire
		str r0,[r2]
		add r1,#4
		ldr r0,[r1]
		ldr r2,=bossSpecial				@ store "SPECIAL" no idea yet!!
		str r0,[r2]

		mov r0,#0
		ldr r1,=bossFirePhase
		str r0,[r1]						@ reset shot phase
		ldr r1,=bossFireDelay
		str r0,[r1]						@ reset fire delay
		
		
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
	stmfd sp!, {r1-r2, lr}
	ldr r6,=bossX
	ldr r6,[r6]					@ r1 =x
	ldr r2,=bossY
	ldr r2,[r2]					@ r2 =y
	
	mov r4,#113					@ r4 = sprite number to draw
	mov r5,#0					@ horizontal counter
	bossDrawLoop:
	
		ldr r3,=spriteX
		str r6,[r3, r4, lsl #2]	@ store X
		ldr r3,=spriteY
		str r2,[r3, r4, lsl #2]	@ store y
		
		@ now we need to detect against your ship using alienCollideCheck
		@ r1 must be the aliens offset
		
		ldr r1,=spriteActive
		add r1, r4, lsl #2
		bl alienCollideCheck
		
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
	
	ldmfd sp!, {r1-r2, pc}
		
@------------------ BOSS HAS TAKEN A SHOT!!!
bossIsShot:
	@ r0 = bullet offset
	@ r4 = sprite offset
	@ r7 = bullets danage value
	stmfd sp!, {r0-r8, lr}
		ldr r8,=bossMan
		ldr r8,[r8]
		cmp r8,#3
		bpl heBeDead
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
	@ when boss is FULLY exploded, set bossMan=4 (signal level over)
	
	ldr r1,=bossMan
	mov r0,#4				@ signal level END!!!!
	str r0,[r1]
	
	bl fxFadeWhiteOut			@ Just for the HELL OF IT!!
	
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
	
	mov r8,#191-48
	mov r9,#191+16

	ldr r4,=bossXDir
	ldr r0,[r4]					@ r0/r4 0=left / 1=right
	ldr r6,=bossX
	ldr r3,[r6]					@ r3/r6 boss X
	ldr r1,=bossXSpeed
	ldr r2,[r1]	

	ldr r1,=bossTurn
	ldr r5,[r1]

	ldr r1,=bossXDelay
	ldr r7,[r1]
	add r7,#1
	cmp r7,r5
	moveq r7,#0
	str r7,[r1]
	beq bossMoveLR
	b noBossUpdate
	@------ BOSS LEFT/RIGHT UPDATE
	bossMoveLR:
	cmp r0,#0
	bne bossRight
		@ move left
		ldr r5,=bossMaxX
		ldr r5,[r5]
		rsb r5,r5,#0
		ldr r1,=bossXSpeed
		ldr r2,[r1]				@ r2 = current X speed
		subs r2,#1
		cmp r2,r5
		movmi r2,r5
		str r2,[r1]
		cmp r3,r8			@ the compare should be (180-32)-maxBossXspeed*2 (ish)
		movmi r0,#1
		b noBossUpdate
	
	bossRight:
		@ move right
		ldr r5,=bossMaxX
		ldr r5,[r5]
		ldr r1,=bossXSpeed
		ldr r2,[r1]				@ r2 = current X speed
		adds r2,#1
		cmp r2,r5
		movpl r2,r5
		str r2,[r1]
		cmp r3,r9		
		movpl r0,#0
	@-------- END OF BOSS MOVE
	noBossUpdate:
	
	str r0,[r4]
	adds r3,r2
	str r3,[r6]
	
	@------------- FROM HERE WE NEED TO DO SHOTS AND ADD SOME Y CODE


	bl bossFire					@ do our fire checks, and shoot if needed
	
	bl bossDraw					@ redraw our boss
	
	ldmfd sp!, {r0-r8, pc}
	
@------------ OUR BOSSES FIRE CODE COMES IN HERE
bossFire:
	stmfd sp!, {r0-r8, lr}
	@ First, check if the fire delay is 0
	@ then grab fire type and set fire delay
	@ add to fire phase also
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
	
	ldr r5,=bossFireMode
	ldr r5,[r5]
	cmp r5,#0
	bne tryBossFire1
		@------------ SINGLE SHOT -------------
		ldr r1,=spriteActive		@ grab a bullet gen base
		add r1,#127*4				@ use the last sprite (127)
	
		ldr r4,[r2]					@ grab speed/type
		ldr r7,=0xFFFF0000			@ isolate upper 16 bits (speed)
		and r4,r7					@ r4= speed
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
		ldr r7,=0xFFFF0000			@ isolate upper 16 bits (speed)
		and r4,r7					@ r4= speed
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
	ldr r7,=0xFFFF0000			@ isolate upper 16 bits (speed)
	and r4,r7					@ r4= speed
	lsr r4,#16					@ shunt them down :)
	
	ldr r3,=spriteActive+68		@ ok, time to init a mine... We need to find a free space for it?
	mov r0,#0					@ R0 points to the sprite that will be used for the mine
		findBossHunterLoop:
		ldr r2,[r3,r0, lsl #2]
		cmp r2,#0
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

	.pool
	.end