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

	.arm
	.text
	.align
	.global bossInitLev
	.global bossFireLev
	.global bossMoveLev
	
bossInitLev:
	@ This consists of 8 words (32 bytes) that describe things that the boss may do
	@ max X speed 	= maximum X speed allowed			bossMaxX
	@ max Y speed 	= maximum Y speed allowed			bossMaxY
	@ turning spd 	= Speed of turning (> is slower)	bossTurn
	@ hits			= hits to kill the boss
	@ fire mode		= 0=single, 1=double, ??			bossFireMode
	@ special		= 0=normal, 1= homing boss, 2
	@ unused
	@ unused
	@1
	.word 4,2,8,35,0,0,0,0
	@2
	.word 4,2,6,35,1,0,0,0
	@3
	.word 4,2,6,35,0,0,0,0
	@4
	.space 32
	@5
	.space 32
	.space 32
	@7
	.space 32
	.space 32
	.space 32
	.space 32
	.space 32
	.space 32
	@13
	.word 4,2,8,35,1,0,0,0
	@14
	.word 4,2,8,35,0,0,0,0
	@15
	.word 4,2,8,35,1,0,0,0
	@16
	.word 4,2,8,35,1,0,0,0

bossFireLev:
	@ this consists of 64 words that describe the bosses firing pattern
	@ form [speed/type], delay
	@ speed and type are shared 16 bit values across a single word
	@ if type is 0, the pattern repeats
	@ we need to think of a way to add an alien into the mix?? Giving 
	@ Lets start with a hunter released? We can use a value of 8192 again to set a hunter
	@ and the "Speed" setting to control the X coord to launch from (they always have speed 2)
	@1
	.word 0x00020003,4,0x00020003,4,0x00020003,4,0x00020003,4,0x00020003,4,0x00020003,50,0x00020009,50,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@2
	.word 0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4
	.word 0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,40,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@3
	.word 0x00040012,4,0x00040012,4,0x00040012,4,0x00040012,4,0x0002000E,4,0x0002000E,50,0x0002000E,10,0x0002000E,20
	.word 0x00050003,4,0x00050003,4,0x00050003,4,0x00050003,4,0x00050003,4,0x00050003,4,0x00050003,4,0x00050003,50
	.word 0x00004000,1,0x01804000,1,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@4
	.word 0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4
	.word 0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,40,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@5
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	@13
	.word 0x00030011,4,0x00030011,4,0x00030011,4,0x00030011,4,0x00030011,4,0x00030011,4,0x00030011,4,0x00030011,4
	.word 0x00030011,40,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@14
	.word 0x0005000F,4,0x0005000F,4,0x0005000F,4,0x0003000F,4,0x0003000F,4,0x0003000F,50,0x0001000A,50,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.space 256
	.space 256
	
.bossMoveLev:
	@ No idea with this at the moment?
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256
	.space 256	
	.space 256
	.space 256	
	