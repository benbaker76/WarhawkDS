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

	.arm
	.align
	.text
	
	.global bossInitStandard
	.global bossInitTracker
	.global bossInitLurcher
	.global bossInitCrane
	.global bossInitSine
	
	@ r1= Pointer to start of bosses level based data (8 words)
	@ 1 - max X speed 	= maximum X speed allowed			bossMaxX
	@ 2 - max Y speed 	= maximum Y speed allowed			bossMaxY
	@ 3 - turning spd 	= Speed of turning (> is slower)	bossTurn
	@ 4 - hits			= hits to kill the boss
	@ 5 - fire mode		= 0=single, 1=double, ??			bossFireMode
	@ 6 - special		= 0=normal, 1= homing boss, 2
	@ 7 - X left		= Min X move coord
	@ 8 - X right		= Max X move coord
	
@------------------ INIT FOR TYPE 0 (NORMAL)
bossInitStandard:
	stmfd sp!, {r0-r8, lr}
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
	
	bl DrawEnergyShifter

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossFireMode			@ store mode, 0=normal/1=twin fire
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossSpecial				@ store "SPECIAL"
	str r0,[r2]
	
	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossLeftMin				@ store Min x Coord
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossRightMax			@ store Max X Coord
	str r0,[r2]

	mov r0,#0
	ldr r1,=bossFirePhase
	str r0,[r1]						@ reset shot phase
	ldr r1,=bossFireDelay
	str r0,[r1]						@ reset fire delay
	
	ldmfd sp!, {r0-r8, pc}

@-------------------- INIT FOR TYPE 1 (Tracker/hunter)	
bossInitTracker:
	stmfd sp!, {r0-r8, lr}
	ldr r0,[r1]						@ load "max X speed"
	ldr r2,=bossMaxX
	str r0,[r2]	

	ldr r2,=bossXSpeed
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]						@ load "max y speed"
	ldr r2,=bossMaxY
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]						@ load "boss turn speed"
	ldr r2,=bossTurn
	str r0,[r2]
	ldr r2,=bossXDelay
	str r0,[r2]
	ldr r2,=bossYDelay
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossHits				@ set hits to kill
	str r0,[r2]

	bl DrawEnergyShifter

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
	ldr r1,=bossXSpeed				
	str r0,[r1]						@ reset X speed
	ldr r1,=bossYSpeed
	str r0,[r1]						@ reset Y speed
	ldr r1,=bossXDelay
	str r0,[r1]						@ reset the turn counter
	ldr r1,=bossYDelay
	str r0,[r1]						@ reset the turn counter	
	
	ldmfd sp!, {r0-r8, pc}
	
@------------------ INIT FOR TYPE 2 (LURCHER)
bossInitLurcher:
	stmfd sp!, {r0-r8, lr}
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
	ldr r2,=bossYDelay
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossHits				@ set hits to kill
	str r0,[r2]

	bl DrawEnergyShifter

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossFireMode			@ store mode, 0=normal/1=twin fire
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossSpecial				@ store "SPECIAL"
	str r0,[r2]
	
	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossLeftMin				@ store Min x Coord
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossRightMax			@ store Max X Coord
	str r0,[r2]

	mov r0,#0
	ldr r1,=bossFirePhase
	str r0,[r1]						@ reset shot phase
	ldr r1,=bossFireDelay
	str r0,[r1]						@ reset fire delay
	
	ldr r1,=bossYSpeed
	str r0,[r1]
	ldr r1,=bossYDir
	str r0,[r1]
	ldr r1,=bossYDelay
	str r0,[r1]
			
	ldmfd sp!, {r0-r8, pc}
	
@------------------ INIT FOR TYPE 3 (CRANE)
bossInitCrane:
	stmfd sp!, {r0-r8, lr}

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
	ldr r2,=bossYDelay
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossHits				@ set hits to kill
	str r0,[r2]

	bl DrawEnergyShifter

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossFireMode			@ store mode, 0=normal/1=twin fire
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossSpecial				@ store "SPECIAL"
	str r0,[r2]
	
	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossLeftMin				@ store Min x Coord
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossRightMax				@ store Max X Coord
	str r0,[r2]

	mov r0,#0
	ldr r1,=bossFirePhase
	str r0,[r1]						@ reset shot phase
	ldr r1,=bossFireDelay
	str r0,[r1]						@ reset fire delay
	ldr r1,=bossYSpeed
	str r0,[r1]						@ reset Y speed
	ldr r1,=bossYDelay
	str r0,[r1]						@ reset the turn counter	

	ldmfd sp!, {r0-r8, pc}
	
@------------------ INIT FOR TYPE 4 & 5 (SINE1 & 2)
bossInitSine:
	stmfd sp!, {r0-r8, lr}

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
	ldr r2,=bossYDelay
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossHits				@ set hits to kill
	str r0,[r2]

	bl DrawEnergyShifter

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossFireMode			@ store mode, 0=normal/1=twin fire
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossSpecial				@ store "SPECIAL"
	str r0,[r2]
	
	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossLeftMin				@ store Min x Coord
	str r0,[r2]

	add r1,#4
	ldr r0,[r1]
	ldr r2,=bossRightMax			@ store Max X Coord
	str r0,[r2]

	mov r0,#0
	ldr r1,=bossFirePhase
	str r0,[r1]						@ reset shot phase
	ldr r1,=bossFireDelay
	str r0,[r1]						@ reset fire delay
	ldr r1,=bossYSpeed
	str r0,[r1]						@ reset Y speed = use this for the possision in the sine

	ldmfd sp!, {r0-r8, pc}