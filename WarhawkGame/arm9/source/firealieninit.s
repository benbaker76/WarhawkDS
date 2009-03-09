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
	.global initStandardShot
	.global initTrackerShot
	.global initAccelShot
	.global initRippleShot
	.global initRippleTripleShot
	.global initMineShot
	.global initTripleShot
	.global initRippleShotPhase1
	.global initRippleShotPhase2
	.global initDirectShot
	.global initSpreadShot

@
@	Every init in this code should also have a "move" function in firealienupdate.s
@
@	Passed to any function used here are:
@
@	r1 		= Offset to our alien data		(Use sptXXXXOffs defines)
@	r2 		= Offset to our new bullet data	(generated in findAlienFire)
@	r3		= Shot type	(Do not modify r3)
@	r4/r5 	= Players x/y coord
@

@
@ "INIT" - "Standard shots 1-8"
	initStandardShot:
	stmfd sp!, {r3, lr}
	
		@ this is a simple "DEMO" code for use one other types	
		
		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iStandardNo				@ so, we cannot init a bullet :(
			@ r1= offset for alien
			@ r2= offset for bullet
			mov r0,#SPRITE_X_OFFS	@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_Y_OFFS
			ldr r6,[r1,r0]			@ copy the aliens Y
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_SPEED_OFFS
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
			
			mov r0,#SPRITE_OBJ_OFFS		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)
		iStandardNo:	
		
	ldmfd sp!, {r3, pc}
	
@
@ "INIT" - "Tracker shot 9"
	initTrackerShot:
	stmfd sp!, {r3, lr}
	
		@ This is a downward shot that tracks to your X coord	
		
		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iTrackNo				@ so, we cannot init a bullet :(
			@ r1= offset for alien
			@ r2= offset for bullet
			mov r0,#SPRITE_X_OFFS		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_Y_OFFS
			ldr r6,[r1,r0]			@ copy the aliens Y
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
			
			mov r0,#SPRITE_OBJ_OFFS		
			mov r6,#26				@ pick object 26
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)
			mov r0,#SPRITE_SPEED_X_OFFS	
			mov r6,#0				@ make sure the bullets initial X speed is 0
			str r6,[r2,r0]
			mov r0,#SPRITE_SPEED_DELAY_X_OFFS
			mov r6,#6				@ set our speed delay to an initial value
			str r6,[r2,r0]
			mov r0,#SPRITE_FIRE_SPEED_OFFS
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
			
		iTrackNo:	
		
	ldmfd sp!, {r3, pc}
	
@
@ "INIT" - "Accelleration shot 10"
	initAccelShot:
	stmfd sp!, {r3, lr}
	
		@ This is a downward shot that tracks to your X coord	
		
		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iAccellNo				@ so, we cannot init a bullet :(
			@ r1= offset for alien
			@ r2= offset for bullet
			mov r0,#SPRITE_X_OFFS		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_Y_OFFS
			ldr r6,[r1,r0]			@ copy the aliens Y
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
	
			mov r0,#SPRITE_OBJ_OFFS		
			mov r6,#28				@ pick object 28
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#SPRITE_SPEED_Y_OFFS	
			mov r6,#1				@ make sure the bullets initial y speed is 1
			str r6,[r2,r0]
			mov r0,#SPRITE_SPEED_DELAY_Y_OFFS
			mov r6,#0				@ set our speed delay to an initial value
			str r6,[r2,r0]
		iAccellNo:	
		
	ldmfd sp!, {r3, pc}
	
@
@ "INIT" - "Ripple shot 11" (this is a DUAL shot and uses 2 bullets)
	initRippleShot:
	stmfd sp!, {r3, lr}
	
		@ This is a downward shot that tracks to your X coord

		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iRippleNo				@ so, we cannot init a bullet :(
			@ r1= offset for alien
			@ r2= offset for bullet
			mov r0,#SPRITE_X_OFFS		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_SPEED_DELAY_X_OFFS	@ We will use this to store our ACUTAL X coord (modified by sine)
			str r6,[r2,r0]			@ store our backup
			mov r0,#SPRITE_Y_OFFS
			ldr r6,[r1,r0]			@ copy the aliens Y
			add r6,#10
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#SPRITE_FIRE_SPEED_OFFS
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
	
			mov r0,#SPRITE_OBJ_OFFS		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#SPRITE_SPEED_X_OFFS	
			mov r6,#0				@ we will use this for a marker of where we are in the sine
			str r6,[r2,r0]	
		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iRippleNo				@ so, we cannot init a bullet :(
			@ r1= offset for alien
			@ r2= offset for bullet
			mov r0,#SPRITE_X_OFFS		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_SPEED_DELAY_X_OFFS	@ We will use this to store our ACUTAL X coord (modified by sine)
			str r6,[r2,r0]			@ store our backup
			mov r0,#SPRITE_Y_OFFS
			ldr r6,[r1,r0]			@ copy the aliens Y
			add r6,#10
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#SPRITE_FIRE_SPEED_OFFS
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
	
			mov r0,#SPRITE_OBJ_OFFS		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#SPRITE_SPEED_X_OFFS	
			mov r6,#24				@ we will use this for a marker of where we are in the sine
			str r6,[r2,r0]	
		iRippleNo:	
		
	ldmfd sp!, {r3, pc}
	
@
@ "INIT" - "Ripple triple shot 12" (this is a DUAL ripple shot and uses 3 bullets)
	initRippleTripleShot:
	stmfd sp!, {r3, lr}
	mov r3,#11
	bl initRippleShot
	mov r3,#3
	bl initStandardShot
	ldmfd sp!, {r3, pc}
	
@
@ "INIT" - "Mine shot 13"
	initMineShot:
	stmfd sp!, {r3, lr}
	
		@ This is a downward shot that sits, waits and explodes!	
		
		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iMineNo					@ so, we cannot init a bullet :(
			@ r1= offset for alien
			@ r2= offset for bullet
			mov r0,#SPRITE_X_OFFS		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_Y_OFFS
			ldr r6,[r1,r0]			@ copy the aliens Y
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
			
			mov r0,#SPRITE_OBJ_OFFS		
			mov r6,#26				@ pick object 26 (mine)
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)
	
			mov r0,#SPRITE_SPEED_Y_OFFS	
			mov r6,#3				@ make sure the mines initial Y speed
			str r6,[r2,r0]
			mov r0,#SPRITE_SPEED_DELAY_Y_OFFS
			mov r6,#0				@ set our speed delay to an initial value (0)
			str r6,[r2,r0]
			mov r0,#SPRITE_SPEED_DELAY_X_OFFS
			mov r6,#128				@ set our Explode delay to an initial value
			str r6,[r2,r0]
		iMineNo:	
		
	ldmfd sp!, {r3, pc}

@
@ "INIT" - "Triple shot 14" (This fires a spread of 3 shots)
	initTripleShot:
	stmfd sp!, {r3, lr}
	@ we will use SPRITE_TRACK_X_OFFS and SPRITE_SPEED_DELAY_X_OFFS for X delay and backup
	@ and also SPRITE_TRACK_Y_OFFS and SPRITE_SPEED_DELAY_Y_OFFS for Y delay and backup
	@ SPRITE_SPEED_X_OFFS and SPRITE_SPEED_Y_OFFS are used for the speed of the bullet
	@ and SPRITE_FIRE_SPEED_OFFS holds the shot speed

								@ we use r3=14 for an angled shot!			
	mov r3,#3					@ 3=downward
	bl initStandardShot			@ do a central shot!
	mov r3,#14					@ set an "angled" shot
	@ ok, now lets set a shot to the left!
	bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
	cmp r2,#255					@ 255=not found
	beq iTripleNo				@ so, we cannot init a bullet :(

			@ ok, lets fire one slighlty to the left - little delay on the X update and a negative x speed
			mov r0,#SPRITE_X_OFFS	@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_Y_OFFS
			ldr r7,[r1,r0]			@ copy the aliens Y
			str r7,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#SPRITE_OBJ_OFFS		
			mov r8,#27				@ pick object 27
			str r8,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r8,#8				@ an 8 sets the sprite active (visible)
			str r8,[r2]				@ set ACTIVE (this will always be r2 with no offset)
		
			mov r0,#SPRITE_FIRE_SPEED_OFFS	@ this is a downward shot - so this is needed in Y speed
			ldr r7,[r1,r0]			@ r6 = speed			
			mov r0,#SPRITE_SPEED_Y_OFFS
			str r7,[r2,r0]
			mov r6,#1
			mov r0,#SPRITE_SPEED_X_OFFS
			str r6,[r2,r0]
			cmp r7,#1
			moveq r8,#8
			cmp r7,#2
			moveq r8,#4
			cmp r7,#3
			moveq r8,#3
			cmp r7,#4
			moveq r8,#2
			movgt r8,#1
			mov r0,#SPRITE_TRACK_X_OFFS
			str r8,[r2,r0]			@ store r8 for the y update delay
			mov r0,#SPRITE_SPEED_DELAY_X_OFFS
			str r8,[r2,r0]			@ and backup
			mov r6,#0				@ and clear the y update delay
			mov r0,#SPRITE_TRACK_Y_OFFS
			str r6,[r2,r0]
			mov r0,#SPRITE_SPEED_DELAY_Y_OFFS
			str r6,[r2,r0]
	@ ok, now lets set a shot to the left!
	bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
	cmp r2,#255					@ 255=not found
	beq iTripleNo				@ so, we cannot init a bullet :(

			@ ok, lets fire one slighlty to the left - little delay on the X update and a negative x speed
			mov r0,#SPRITE_X_OFFS	@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_Y_OFFS
			ldr r7,[r1,r0]			@ copy the aliens Y
			str r7,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#SPRITE_OBJ_OFFS		
			mov r8,#27				@ pick object 27
			str r8,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r8,#8				@ an 8 sets the sprite active (visible)
			str r8,[r2]				@ set ACTIVE (this will always be r2 with no offset)
	
			mov r0,#SPRITE_FIRE_SPEED_OFFS	@ this is a downward shot - so this is needed in Y speed
			ldr r7,[r1,r0]			@ r6 = speed			
			mov r0,#SPRITE_SPEED_Y_OFFS
			str r7,[r2,r0]
			mov r6,#-1
			mov r0,#SPRITE_SPEED_X_OFFS
			str r6,[r2,r0]
			cmp r7,#1
			moveq r8,#8
			cmp r7,#2
			moveq r8,#4
			cmp r7,#3
			moveq r8,#3
			cmp r7,#4
			moveq r8,#2
			movgt r8,#1
			mov r0,#SPRITE_TRACK_X_OFFS
			str r8,[r2,r0]			@ store r8 for the y update delay
			mov r0,#SPRITE_SPEED_DELAY_X_OFFS
			str r8,[r2,r0]			@ and backup
			mov r6,#0				@ and clear the y update delay
			mov r0,#SPRITE_TRACK_Y_OFFS
			str r6,[r2,r0]
			mov r0,#SPRITE_SPEED_DELAY_Y_OFFS
			str r6,[r2,r0]

	iTripleNo:
@	pop {r3}
	ldmfd sp!, {r3, pc}
	
@
@ "INIT" - "Ripple shot 15" (this is a Single shot, Phase 1)
	initRippleShotPhase1:
	stmfd sp!, {r3, lr}
	
		@ This is a downward shot that tracks to your X coord

		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iRippleph1No			@ so, we cannot init a bullet :(
			@ r1= offset for alien
			@ r2= offset for bullet
			mov r0,#SPRITE_X_OFFS		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_SPEED_DELAY_X_OFFS	@ We will use this to store our ACUTAL X coord (modified by sine)
			str r6,[r2,r0]			@ store our backup
			mov r0,#SPRITE_Y_OFFS
			ldr r6,[r1,r0]			@ copy the aliens Y
			add r6,#14
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			mov r4,#15
			str r4,[r2,r0]			@ store r4 as our bullets type (r3 +1)
			mov r0,#SPRITE_FIRE_SPEED_OFFS
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
	
			mov r0,#SPRITE_OBJ_OFFS		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)			@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#SPRITE_SPEED_X_OFFS	
			mov r6,#0				@ we will use this for a marker of where we are in the sine
			str r6,[r2,r0]	
		iRippleph1No:	
	ldmfd sp!, {r3, pc}

@
@ "INIT" - "Ripple shot 16" (this is a Single shot, Phase 2)
	initRippleShotPhase2:
	stmfd sp!, {r3, lr}
	
		@ This is a downward shot that tracks to your X coord

		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iRippleph2No				@ so, we cannot init a bullet :(
			@ r1= offset for alien
			@ r2= offset for bullet
			mov r0,#SPRITE_X_OFFS		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_SPEED_DELAY_X_OFFS	@ We will use this to store our ACUTAL X coord (modified by sine)
			str r6,[r2,r0]			@ store our backup
			mov r0,#SPRITE_Y_OFFS
			ldr r6,[r1,r0]			@ copy the aliens Y
			add r6,#14
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			mov r4,#15
			str r4,[r2,r0]			@ store r4 as our bullets type (r3 +1)
			mov r0,#SPRITE_FIRE_SPEED_OFFS
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
	
			mov r0,#SPRITE_OBJ_OFFS		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#SPRITE_SPEED_X_OFFS	
			mov r6,#24				@ we will use this for a marker of where we are in the sine
			str r6,[r2,r0]	
		iRippleph2No:	
	ldmfd sp!, {r3, pc}

@
@ "INIT" - "Direct Shot 17"
	initDirectShot:
	stmfd sp!, {r3, lr}

		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iDirectNo				@ so, we cannot init a bullet :(
		
			ldr r0,=spriteX
			ldr r4,[r0]
			ldr r0,=spriteY
			ldr r5,[r0]
			ldr r0,=horizDrift
			ldr r6,[r0]
			add r4,r6
		
			@ r1= offset for alien
			@ r2= offset for bullet
			mov r0,#SPRITE_X_OFFS		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_Y_OFFS
			ldr r7,[r1,r0]			@ copy the aliens Y
			str r7,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#SPRITE_FIRE_SPEED_OFFS
			ldr r12,[r1,r0]		@ copy the bullet speed
			str r12,[r2,r0]		@ paste it in our bullet speed
			mov r0,#SPRITE_OBJ_OFFS		
			mov r8,#27				@ pick object 27
			str r8,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r8,#8				@ an 8 sets the sprite active (visible)
			str r8,[r2]				@ set ACTIVE (this will always be r2 with no offset)
			
			@ ok, now to work out where to shoot???
			@ r4/r5 = player X/Y
			@ r6/r7 = Alien X/Y
			@ r12 = shot speed
			mov r10,r12						@ Store the X/Y speeds
			mov r11,r12						@ we will need r12 later
			
			cmp r5,r7
			rsble r11,r11,#0
			suble r9,r7,r5
			subgt r9,r5,r7			
				cmp r4,r6
				rsble r10,r10,#0
				suble r8,r6,r4
				subgt r8,r4,r6
				cmp r8,r9
				bmi directOddQuad
					push {r0-r2}
					mov r0,r8					@ divide this number
					add r9,r12					@ we also need to divide by the SPEED
					mov r1,r9					@ by this number
						bl divf32				@ r0=result 20.12	
					mov r9,r0					@ move the whole to r9
					mov r8,#0	
					pop {r0-r2}
				b directDone
				directOddQuad:
					push {r0-r2}
					mov r0,r9					@ divide this number
					add r8,r12					@ we also need to divide by the SPEED
					mov r1,r8					@ by this number
						bl divf32				@ r0=result 20.12	
					mov r8,r0					@ move the whole to r9
					mov r9,#0	
					pop {r0-r2}
				b directDone				
					
		directDone:
		@ We may need to divide the r8 and r9 delays by the r12 speed value?
		@
@		push {r0-r2}
@		mov r0,r8
@		mov r1,r12
@		bl divf32
@		mov r8,r0
@		mov r0,r9
@		mov r1,r12
@		bl divf32
@		mov r9,r0
@		pop {r0-r2}
		
		
		
		@	store the calculated values!
		@
		@ first backup the delay values to trackx/tracky
		mov r0,#SPRITE_TRACK_X_OFFS
		str r8,[r2,r0]				@ store X delay			@ Whole number
		mov r0,#SPRITE_SPEED_DELAY_X_OFFS
		str r8,[r2,r0]										@ whole number
		mov r0,#SPRITE_TRACK_Y_OFFS
		str r9,[r2,r0]				@ store y delay
		mov r0,#SPRITE_SPEED_DELAY_Y_OFFS
		str r9,[r2,r0]				@ store the X and Y speeds
		mov r0,#SPRITE_SPEED_X_OFFS
		str r10,[r2,r0]
		mov r0,#SPRITE_SPEED_Y_OFFS
		str r11,[r2,r0]
		
		iDirectNo:	
		
	ldmfd sp!, {r3, pc}

@
@ "INIT" - "Spread shot 18" (This fires a spread of 3 shots)
	initSpreadShot:
	stmfd sp!, {r3, lr}
	@ we will use SPRITE_TRACK_X_OFFS and SPRITE_SPEED_DELAY_X_OFFS for X delay and backup
	@ and also SPRITE_TRACK_Y_OFFS and SPRITE_SPEED_DELAY_Y_OFFS for Y delay and backup
	@ SPRITE_SPEED_X_OFFS and SPRITE_SPEED_Y_OFFS are used for the speed of the bullet
	@ and SPRITE_FIRE_SPEED_OFFS holds the shot speed

								@ we use r3=14 for an angled shot!			
	mov r3,#3					@ 3=downward
	bl initStandardShot			@ do a central shot!
	mov r3,#14
	bl initTripleShot
	mov r3,#14					@ set an "angled" shot
	@ ok, now lets set a shot to the left!
	bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
	cmp r2,#255					@ 255=not found
	beq iSpreadNo				@ so, we cannot init a bullet :(

			@ ok, lets fire one slighlty to the left - little delay on the X update and a negative x speed
			mov r0,#SPRITE_X_OFFS	@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_Y_OFFS
			ldr r7,[r1,r0]			@ copy the aliens Y
			str r7,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#SPRITE_OBJ_OFFS		
			mov r8,#27				@ pick object 27
			str r8,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r8,#8				@ an 8 sets the sprite active (visible)
			str r8,[r2]				@ set ACTIVE (this will always be r2 with no offset)
		
			mov r0,#SPRITE_FIRE_SPEED_OFFS	@ this is a downward shot - so this is needed in Y speed
			ldr r7,[r1,r0]			@ r6 = speed				
			mov r0,#SPRITE_SPEED_Y_OFFS
			str r7,[r2,r0]
			mov r6,#1
			mov r0,#SPRITE_SPEED_X_OFFS
			str r6,[r2,r0]
			cmp r7,#1
			moveq r8,#4
			cmp r7,#2
			moveq r8,#2
			cmp r7,#3
			moveq r8,#1
			cmp r7,#4
			movpl r8,#0
			mov r0,#SPRITE_TRACK_X_OFFS
			str r8,[r2,r0]			@ store r8 for the y update delay
			mov r0,#SPRITE_SPEED_DELAY_X_OFFS
			str r8,[r2,r0]			@ and backup
			mov r6,#0				@ and clear the y update delay
			mov r0,#SPRITE_TRACK_Y_OFFS
			str r6,[r2,r0]
			mov r0,#SPRITE_SPEED_DELAY_Y_OFFS
			str r6,[r2,r0]
	@ ok, now lets set a shot to the left!
	bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
	cmp r2,#255					@ 255=not found
	beq iSpreadNo				@ so, we cannot init a bullet :(

			@ ok, lets fire one slighlty to the left - little delay on the X update and a negative x speed
			mov r0,#SPRITE_X_OFFS	@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#SPRITE_Y_OFFS
			ldr r7,[r1,r0]			@ copy the aliens Y
			str r7,[r2,r0]			@ paste it in our bullet y
			mov r0,#SPRITE_FIRE_TYPE_OFFS
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#SPRITE_OBJ_OFFS		
			mov r8,#27				@ pick object 27
			str r8,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r8,#8				@ an 8 sets the sprite active (visible)
			str r8,[r2]				@ set ACTIVE (this will always be r2 with no offset)
	
			mov r0,#SPRITE_FIRE_SPEED_OFFS	@ this is a downward shot - so this is needed in Y speed
			ldr r7,[r1,r0]			@ r6 = speed			
			mov r0,#SPRITE_SPEED_Y_OFFS
			str r7,[r2,r0]
			mov r6,#-1
			mov r0,#SPRITE_SPEED_X_OFFS
			str r6,[r2,r0]
			cmp r7,#1
			moveq r8,#4
			cmp r7,#2
			moveq r8,#2
			cmp r7,#3
			moveq r8,#1
			cmp r7,#4
			movpl r8,#0
			mov r0,#SPRITE_TRACK_X_OFFS
			str r8,[r2,r0]			@ store r8 for the y update delay
			mov r0,#SPRITE_SPEED_DELAY_X_OFFS
			str r8,[r2,r0]			@ and backup
			mov r6,#0				@ and clear the y update delay
			mov r0,#SPRITE_TRACK_Y_OFFS
			str r6,[r2,r0]
			mov r0,#SPRITE_SPEED_DELAY_Y_OFFS
			str r6,[r2,r0]

	iSpreadNo:
	ldmfd sp!, {r3, pc}


	.pool
	.end
