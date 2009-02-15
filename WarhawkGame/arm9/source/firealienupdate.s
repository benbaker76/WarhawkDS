#include "warhawk.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	.global moveStandardShot
	.global moveTrackerShot

	.arm
	.align

@
@	Every move in this code should also have a "init" function in firealieninit.s
@
@	Passed to any function used here are:
@
@	r2 		= Offset to our bullet data	(use sptXXXXOffs)
@	r3		= Shot type (this will be needed if several types of shots are combined)
@	r0/r1 	= Players x/y coord
@
@

@
@ "MOVE" - "Standard shots 1-18"
@		1-4 	are standard directional
@		5-6 	are right/left with the addition of a move in time with scroll vertically
@		7-10	are standard directional with a speed of 4 (use r5 for speed)
@		11-12 	are right/left (speed 4) with the addition of a move in time with scroll vertically	
@		13-16	are standard directional with a speed of 6 (use r5 for speed)
@		17-18	are right/left (speed 6) with the addition of a move in time with scroll vertically
	moveStandardShot:
	stmfd sp!, {r0-r10, lr}	
		
		mov r5,#2
		cmp r3,#7				@ if type is >=7
		movpl r5,#4				@ make speed 4
		subpl r3,#6				@ make type 1-6
		cmp r3,#7				@ if type is >=7
		movpl r5,#6				@ make speed 4
		subpl r3,#6				@ make type 1-6
		
			
		cmp r3,#1				@ Standard UP
		bne standard1
			mov r4,#sptYOffs
			ldr r1,[r2,r4]
			sub r1,r5
			str r1,[r2,r4]
			cmp r1,#352
			bpl standard1
				mov r1,#0
				str r1,[r2]
		standard1:
		cmp r3,#2				@ Standard RIGHT
		bne standard2
			mov r4,#sptXOffs
			ldr r1,[r2,r4]
			add r1,r5
			str r1,[r2,r4]
			cmp r1,#384
			bmi standard2
				mov r1,#0
				str r1,[r2]
		standard2:
		cmp r3,#3				@ Standard DOWN
		bne standard3
			mov r4,#sptYOffs
			ldr r1,[r2,r4]
			add r1,r5
			str r1,[r2,r4]
			cmp r1,#768
			bmi standard3
				mov r1,#0
				str r1,[r2]
		standard3:
		cmp r3,#4				@ Standard LEFT
		bne standard4
			mov r4,#sptXOffs
			ldr r1,[r2,r4]
			subs r1,r5
			str r1,[r2,r4]
			bpl standard4
				mov r1,#0
				str r1,[r2]
		standard4:
		cmp r3,#5				@ Standard RIGHT with Scroll Drift
		bne standard5
			mov r4,#sptYOffs
			ldr r1,[r2,r4]
			add r1,#1
			str r1,[r2,r4]
			cmp r1,#768
			bpl scrollDrift1
			mov r4,#sptXOffs
			ldr r1,[r2,r4]
			add r1,r5
			str r1,[r2,r4]
			cmp r1,#384
			bmi standard5
				scrollDrift1:
				mov r1,#0
				str r1,[r2]
		standard5:			
		cmp r3,#6				@ Standard LEFT with Scroll Drift
		bne standard6
			mov r4,#sptYOffs
			ldr r1,[r2,r4]
			add r1,#1
			str r1,[r2,r4]
			cmp r1,#768
			bpl scrollDrift2
			mov r4,#sptXOffs
			ldr r1,[r2,r4]
			subs r1,r5
			str r1,[r2,r4]
			cmp r1,#0
			bpl standard6
				scrollDrift2:
				mov r1,#0
				str r1,[r2]
		standard6:

	ldmfd sp!, {r0-r10, pc}
	
@
@ "MOVE" - "Tracker shot 19"			@ slightly more complex but still.....
	moveTrackerShot:
	stmfd sp!, {r0-r10, lr}
	@ first, sheck the bullets coord in relation to your x (r0)

		mov r6,#sptSpdXOffs				@ r6 is index to bullex x speed
		ldr r7,[r2,r6]					@ r7 is the bullets current speed
	
		mov r4,#sptSpdDelayXOffs		@ Update the speed delay
		ldr r5,[r2,r4]					@ r5 = speed delay x
		subs r5,#1						@ take 1 off
		str r5,[r2,r4]					@ put it back
		cmp r5,#0						@ if <> 0
		bpl tShotDone					@ carry on
		mov r5,#12						@ else reset counter
		str r5,[r2,r4]					@ store it and allow update of speed
	
		mov r4,#sptXOffs
		ldr r4,[r2,r4]					@ r4 = bullet X coord

		cmp r4,r0						@ is bullet left or right of players x (r0)
		beq tShotDone					@ it is the same, we will not do anything
		bpl tShotLeft					@ if right, go left - else, go right
	
		tShotRight:		
			add r7,#1					@ add 1 to the speed
			cmp r7,#2					@ compare with current speed
			movgt r7,#2					@ if greater - max maximum
			str r7,[r2,r6]				@ store r7 to speed x
			b tShotDone

		tShotLeft:
			subs r7,#1					@ sub 1 from the speed			
			cmp r7,#-2					@ compre with current speed
			movlt r7,#-2				@ if it is less than, reset to maximum negative!
			str r7,[r2,r6]				@ store r7 to speed x

		tShotDone:

		mov r4,#sptXOffs			
		ldr r5,[r2,r4]					@ load our bullet x pos
		adds r5,r7						@ add/sub our speed
		str r5,[r2,r4]					@ store it back

		mov r4,#sptYOffs
		ldr r5,[r2,r4]
		add r5,#2						@ add 2 to bullet Y
		cmp r5,#768
		str r5,[r2,r4]					@ put it back
		bmi tShotActive
			mov r1,#0
			str r1,[r2]					@ kill bullet if off screen
		tShotActive:

	ldmfd sp!, {r0-r10, pc}
	
	
	
	
	