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
	stmfd sp!, {r0-r1, lr}

	ldr r0,=level
	mov r1,#12
	str r1,[r0]

	ldmfd sp!, {r0-r1, pc}
	
	.align
	.data

@ These below need to be inited at game start - not per level

pixelOffsetSFSub:
	.word 0
pixelOffsetSFMain:
	.word 0
pixelOffsetSBSub:
	.word 0
pixelOffsetSBMain:
	.word 0
vofsSFMain:
	.word 256
vofsSBMain:
	.word 256
vofsSFSub:
	.word 256
vofsSBSub:
	.word 256
yposSFMain:
	.word 736						@ 3200 - 192 - 64 / 4
yposSBMain:
	.word 736						@ 3200 - 192 - 64 / 4
yposSFSub:
	.word 736						@ 3200 - 192 - 64 / 4
yposSBSub:
	.word 736						@ 3200 - 192 - 64 / 4
	
	.pool
	.end
