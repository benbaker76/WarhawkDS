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
	.global initData
	
initData:
	@ use this to init data for the start of the game
	stmfd sp!, {r0-r10, lr}

	ldr r0,=levelNum
	mov r1,#LEVEL_1
	str r1,[r0]
	
	ldr r0,=bossSpreadAngle
	mov r1,#0
	str r1,[r0]
	
@	ldr r0,=cheatMode
@	mov r1,#1
@	str r1,[r0]
	
	ldr r0,=powerUp
	str r1,[r0]				@ set to one for autofire (on the original this carries on)
	ldr r0,=powerUpDelay
	str r1,[r0]				@ clear the fire delay

	@ NEED TO RESET SCORE HERE (see, was already noted HK :) )
	
	ldr r0,=score			@ reset (zero) score
	mov r1,#0				@ just to make sure we always get a highscore
	str r1,[r0],#4
	str r1,[r0]

	ldmfd sp!, {r0-r10, pc}
	
	.pool
	.end
