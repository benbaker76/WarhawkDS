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
			mov r0,#sptXOffs		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#sptYOffs
			ldr r6,[r1,r0]			@ copy the aliens Y
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#sptFireSpdOffs
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
			mov r0,#sptFireTypeOffs
			str r3,[r2,r0]			@ store r3 as our bullets type
			
			mov r0,#sptObjOffs		
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
			mov r0,#sptXOffs		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#sptYOffs
			ldr r6,[r1,r0]			@ copy the aliens Y
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#sptFireTypeOffs
			str r3,[r2,r0]			@ store r3 as our bullets type
			
			mov r0,#sptObjOffs		
			mov r6,#26				@ pick object 26
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)
			mov r0,#sptSpdXOffs	
			mov r6,#0				@ make sure the bullets initial X speed is 0
			str r6,[r2,r0]
			mov r0,#sptSpdDelayXOffs
			mov r6,#6				@ set our speed delay to an initial value
			str r6,[r2,r0]
			mov r0,#sptFireSpdOffs
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
			mov r0,#sptXOffs		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#sptYOffs
			ldr r6,[r1,r0]			@ copy the aliens Y
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#sptFireTypeOffs
			str r3,[r2,r0]			@ store r3 as our bullets type
	
			mov r0,#sptObjOffs		
			mov r6,#28				@ pick object 28
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#sptSpdYOffs	
			mov r6,#1				@ make sure the bullets initial y speed is 1
			str r6,[r2,r0]
			mov r0,#sptSpdDelayYOffs
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
			mov r0,#sptXOffs		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#sptSpdDelayXOffs@ We will use this to store our ACUTAL X coord (modified by sine)
			str r6,[r2,r0]			@ store our backup
			mov r0,#sptYOffs
			ldr r6,[r1,r0]			@ copy the aliens Y
			add r6,#10
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#sptFireTypeOffs
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#sptFireSpdOffs
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
	
			mov r0,#sptObjOffs		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#sptSpdXOffs	
			mov r6,#0				@ we will use this for a marker of where we are in the sine
			str r6,[r2,r0]	
		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iRippleNo				@ so, we cannot init a bullet :(
			@ r1= offset for alien
			@ r2= offset for bullet
			mov r0,#sptXOffs		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#sptSpdDelayXOffs@ We will use this to store our ACUTAL X coord (modified by sine)
			str r6,[r2,r0]			@ store our backup
			mov r0,#sptYOffs
			ldr r6,[r1,r0]			@ copy the aliens Y
			add r6,#10
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#sptFireTypeOffs
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#sptFireSpdOffs
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
	
			mov r0,#sptObjOffs		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#sptSpdXOffs	
			mov r6,#24				@ we will use this for a marker of where we are in the sine
			str r6,[r2,r0]	
		iRippleNo:	
		
	ldmfd sp!, {r3, pc}
	
@
@ "INIT" - "Ripple triple shot 12" (this is a DUAL ripple shot and uses 3 bullets)
	initRippleTripleShot:
	stmfd sp!, {r3, lr}
	
		@ This is a downward shot that tracks to your X coord

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
			mov r0,#sptXOffs		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#sptYOffs
			ldr r6,[r1,r0]			@ copy the aliens Y
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#sptFireTypeOffs
			str r3,[r2,r0]			@ store r3 as our bullets type
			
			mov r0,#sptObjOffs		
			mov r6,#26				@ pick object 26 (mine)
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)
	
			mov r0,#sptSpdYOffs	
			mov r6,#3				@ make sure the mines initial Y speed
			str r6,[r2,r0]
			mov r0,#sptSpdDelayYOffs
			mov r6,#0				@ set our speed delay to an initial value (0)
			str r6,[r2,r0]
			mov r0,#sptSpdDelayXOffs
			mov r6,#128				@ set our Explode delay to an initial value
			str r6,[r2,r0]
		iMineNo:	
		
	ldmfd sp!, {r3, pc}

@
@ "INIT" - "Triple shot 14" (This fires a spread of 3 shots)
	initTripleShot:
	stmfd sp!, {r3, lr}
	
		@ This is a downward shot that tracks to your X coord
	push {r3}
	mov r3,#3
	bl initStandardShot
	mov r3,#21
	bl initRippleShot
	pop {r3}

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
			mov r0,#sptXOffs		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#sptSpdDelayXOffs@ We will use this to store our ACUTAL X coord (modified by sine)
			str r6,[r2,r0]			@ store our backup
			mov r0,#sptYOffs
			ldr r6,[r1,r0]			@ copy the aliens Y
			add r6,#14
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#sptFireTypeOffs
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#sptFireSpdOffs
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
	
			mov r0,#sptObjOffs		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#sptSpdXOffs	
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
			mov r0,#sptXOffs		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#sptSpdDelayXOffs@ We will use this to store our ACUTAL X coord (modified by sine)
			str r6,[r2,r0]			@ store our backup
			mov r0,#sptYOffs
			ldr r6,[r1,r0]			@ copy the aliens Y
			add r6,#14
			str r6,[r2,r0]			@ paste it in our bullet y
			mov r0,#sptFireTypeOffs
			mov r4,#15
			str r4,[r2,r0]			@ store r4 as our bullets type (r3 +1)
			mov r0,#sptFireSpdOffs
			ldr r6,[r1,r0]			@ copy the bullet speed
			str r6,[r2,r0]			@ paste it in our bullet speed
	
			mov r0,#sptObjOffs		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#8				@ an 8 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#sptSpdXOffs	
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
			mov r0,#sptXOffs		@ use our x offset
			ldr r6,[r1,r0]			@ copy the aliens X
			str r6,[r2,r0]			@ paste it in our bullet X
			mov r0,#sptYOffs
			ldr r7,[r1,r0]			@ copy the aliens Y
			str r7,[r2,r0]			@ paste it in our bullet y
			mov r0,#sptFireTypeOffs
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#sptFireSpdOffs
			ldr r12,[r1,r0]		@ copy the bullet speed
			str r12,[r2,r0]		@ paste it in our bullet speed
			mov r0,#sptObjOffs		
			mov r8,#27				@ pick object 27
			str r8,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r8,#8				@ an 8 sets the sprite active (visible)
			str r8,[r2]				@ set ACTIVE (this will always be r2 with no offset)
			
			@ ok, now to work out where to shoot???
			@ r4/r5 = player X/Y
			@ r6/r7 = Alien X/Y
			@ r12 = shot speed
			
			cmp r5,r7
			ble directUP					@ if py<ay shoot upwards
				cmp r4,r6
				ble directDL				@ if px<ax shooting Left
					@ We are directing bullet to down/right
					
					sub r8,r4,r6
					sub r9,r5,r7
					@ have problem with angles near the diagonal!!! :(
					cmp r8,r9
					bmi testnext
						push {r0-r2}
						mov r1,r8
						mov r2,r9
						bl divideNumber
						mov r9,r0
						mov r8,#0	
							push {r0-r10}	
							mov r10,r2					@ Read value
							mov r8,#8						@ y pos
							mov r9,#8						@ Number of digits
							mov r11, #9						@ x pos
							bl drawDigits					@ Draw	
							pop {r0-r10}			
						pop {r0-r2}
					b directDone
					testnext:
					mov r8,#0
					mov r9,#0
				directDL:
				
			directUP:		
					
		mov r8,#0
		str r8,[r2]
		mov r9,#0
		b iDirectNo
		directDone:
		@
		@	store the calculated values!
		@
		@ first backup the delay values to trackx/tracky
		mov r0,#sptTrackXOffs
		str r8,[r2,r0]				@ store X delay
		mov r0,#sptSpdDelayXOffs
		str r8,[r2,r0]
		mov r0,#sptTrackYOffs
		str r9,[r2,r0]				@ store y delay
		mov r0,#sptSpdDelayYOffs
		str r9,[r2,r0]
		
	mov r10,#1
	mov r11,#1
		
		mov r0,#sptSpdXOffs
		str r10,[r2,r0]
		mov r0,#sptSpdYOffs
		str r11,[r2,r0]
	push {r8,r9}	
	mov r10,r8					@ Read value
	mov r8,#0						@ y pos
	mov r9,#8						@ Number of digits
	mov r11, #9						@ x pos
	bl drawDigits					@ Draw	
	pop {r8,r9}
	mov r10,r9					@ Read value
	mov r8,#2						@ y pos
	mov r9,#8						@ Number of digits
	mov r11, #9						@ x pos
	bl drawDigits					@ Draw			
		
		
		
		iDirectNo:	
		
	ldmfd sp!, {r3, pc}


	.pool
	.end
