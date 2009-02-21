#include "warhawk.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	.global initStandardShot
	.global initTrackerShot
	.global initAccelShot
	.global initRippleShot
	.global initRippleTripleShot
	.global initMineShot

	.arm
	.align

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
@ "INIT" - "Standard shots 1-18"
	initStandardShot:
	stmfd sp!, {r0-r10, lr}
	
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
			mov r0,#sptFireTypeOffs
			str r3,[r2,r0]			@ store r3 as our bullets type
			
			mov r0,#sptObjOffs		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#1				@ a 1 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)
		iStandardNo:	
		
	ldmfd sp!, {r0-r10, pc}
	
@
@ "INIT" - "Tracker shot 19"
	initTrackerShot:
	stmfd sp!, {r0-r10, lr}
	
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
			mov r6,#26				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#1				@ a 1 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)
			mov r0,#sptSpdXOffs	
			mov r6,#0				@ make sure the bullets initial X speed is 0
			str r6,[r2,r0]
			mov r0,#sptSpdDelayXOffs
			mov r6,#6				@ set our speed delay to an initial value
			str r6,[r2,r0]
		iTrackNo:	
		
	ldmfd sp!, {r0-r10, pc}
	
@
@ "INIT" - "Accelleration shot 20"
	initAccelShot:
	stmfd sp!, {r0-r10, lr}
	
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
			mov r6,#1				@ a 1 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#sptSpdYOffs	
			mov r6,#1				@ make sure the bullets initial y speed is 1
			str r6,[r2,r0]
			mov r0,#sptSpdDelayYOffs
			mov r6,#0				@ set our speed delay to an initial value
			str r6,[r2,r0]
		iAccellNo:	
		
	ldmfd sp!, {r0-r10, pc}
	
@
@ "INIT" - "Ripple shot 21" (this is a DUAL shot and uses 2 bullets)
	initRippleShot:
	stmfd sp!, {r0-r10, lr}
	
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
	
			mov r0,#sptObjOffs		
			mov r6,#27				@ pick object 26
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#1				@ a 1 sets the sprite active (visible)
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
	
			mov r0,#sptObjOffs		
			mov r6,#27				@ pick object 26
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#1				@ a 1 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will always be r2 with no offset)

			mov r0,#sptSpdXOffs	
			mov r6,#24				@ we will use this for a marker of where we are in the sine
			str r6,[r2,r0]	
		iRippleNo:	
	ldmfd sp!, {r0-r10, pc}
	
@
@ "INIT" - "Ripple triple shot 22" (this is a DUAL ripple shot and uses 3 bullets)
	initRippleTripleShot:
	stmfd sp!, {r0-r10, lr}
	
		@ This is a downward shot that tracks to your X coord
	push {r3}
	mov r3,#3
	bl initStandardShot
	mov r3,#21
	bl initRippleShot
	pop {r3}

	ldmfd sp!, {r0-r10, pc}
	
@
@ "INIT" - "Mine shot 23"
	initMineShot:
	stmfd sp!, {r0-r10, lr}
	
		@ This is a downward shot that sits, waits and explodes!	
		
		bl findAlienFire			@ look for a "BLANK" bullet, this "needs" to be called for each init!
		cmp r2,#255					@ 255=not found
		beq iMineNo				@ so, we cannot init a bullet :(
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
			mov r6,#1				@ a 1 sets the sprite active (visible)
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
		
	ldmfd sp!, {r0-r10, pc}