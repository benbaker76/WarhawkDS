#include "warhawk.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	.global initStandardShot

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
@ "INIT" - "Standard shots 1-6"
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
			str r6,[r2,r0]			@ paste it in out bullet y
			mov r0,#sptFireTypeOffs
			str r3,[r2,r0]			@ store r3 as our bullets type
			mov r0,#sptObjOffs		
			mov r6,#27				@ pick object 27
			str r6,[r2,r0]			@ set object to a bullet (Either 26,27,28)
			mov r6,#1				@ a 1 sets the sprite active (visible)
			str r6,[r2]				@ set ACTIVE (this will alway be r2 with no offset)
		iStandardNo:	
		
	ldmfd sp!, {r0-r10, pc}
	
@
@ "INIT" - "Tracker shot 13"
	initTrackerShot: