#include "warhawk.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	.global moveStandardShot

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
@ "MOVE" - "Standard shots 1-7+"
@		1-4 	are standard directional
@		5-6 	are right/left with the addition of a move in time with scroll vertically
@		7-10	are standard directional with a speed of 4 (use r5 for speed)
@		11-12 	are right/left (speed 4) with the addition of a move in time with scroll vertically	
	moveStandardShot:
	stmfd sp!, {r0-r10, lr}	
		
		mov r5,#2
		cmp r3,#7				@ if type is >=7
		movpl r5,#4				@ make speed 4
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
@ "MOVE" - "Tracker shot 13"
	moveTrackerShot: