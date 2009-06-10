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
	
bossInitLev:
	@ This consists of 8 words (32 bytes) that describe things that the boss may do
	@ max X speed 	= maximum X speed allowed			bossMaxX
	@ max Y speed 	= maximum Y speed allowed			bossMaxY
	@ turning spd 	= Speed of turning (> is slower)	bossTurn
	@ hits			= hits to kill the boss
	@ fire mode		= 0=single, 1=double, ??			bossFireMode
	@ special		= 0=normal, 1= homing boss, 2=Lurcher, 3=Crane, 4=sine1, 5=sine2
	@ X left		= Min X move coord
	@ X right		= Max X move coord
	@1
	.word 4,2,8,70,0,0,143,207			@ Standard
	@2
	.word 4,0,7,90,1,0,123,227			@ standard
	@3
	.word 4,4,7,70,0,1,143,207			@ homing
	@4
	.word 4,5,8,80,0,2,143,207			@ Lurcher
	@5
	.word 8,2,4,140,0,0,183,167			@ I like this one :) standard + ripple + Hunters
	@6
	.word 2,2,14,120,0,1,143,207		@ homing 2 fire types
	@7
	.word 6,8,6,100,0,2,163,187			@ Lurcher, no fire, attack waves :)
	@8
	.word 3,3,8,110,0,3,140,210			@ Crane
	@9
	.word 6,5,3,110,1,0,133,217			@ Standard but fast, twin fire
	@10
	.word 5,5,3,100,0,4,113,237			@ Sine 1, laying mines :)
	@11
	.word 4,2,8,35,0,0,143,207			@ Lurcher, with attack waves *TO DO
	@12
	.word 4,2,8,35,0,0,143,207			@
	@13
	.word 4,2,8,35,1,0,143,207			@
	@14
	.word 4,2,8,60,0,0,143,207			@
	@15
	.word 3,10,2,35,0,2,73,277			@ 
	@16
	.word 2,2,8,75,1,0,143,207			@ fairly easy on PURPOSE (DONE)

	.align
bossFireLev:
	@ this consists of 64 words that describe the bosses firing pattern
	@ form [speed/type], delay
	@ speed and type are shared 16 bit values across a single word
	@ if type is 0, the pattern repeats
	@ we need to think of a way to add aliens into the mix??
	@ - Lets start with a hunter released? We can use a value of 16384 again to set a hunter
	@ - and the "Speed" setting to control the X coord to launch from (they always have speed 2)
	@ - set speed to 16384 to set a random release on the X coord for the Hunter.
	@ now for Attack Waves, we need to supply the wave number
	@ set "type" to 32768 and speed to the number of the wave to use
	@1
	.word 0x00020003,2,0x00020003,2,0x00020003,2,0x00020003,2,0x00020003,2,0x00020003,2,0x00020003,2,0x00020003,2
	.word 0x00020003,2,0x00020003,2,0x00020003,30,0x00020009,30,0x00020009,30,0x00020009,30,0x00020009,50,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@2
	.word 0x0004000e,10,0x0004000e,10,0x0004000e,10,0x0004000e,10
	.word 0x0004000e,50,0x0004000e,3,0x0004000e,3,0x0004000e,3,0x0004000e,3,0x0004000e,60,0x000400a,10,0x0004000a,10
	.word 0x0004000a,10,0x0004000a,60,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@3
	.word 0x00040012,4,0x00040012,4,0x00040012,4,0x00040012,4,0x0002000E,4,0x0002000E,50,0x0002000E,10,0x0002000E,20
	.word 0x00050003,4,0x00050003,4,0x00050003,4,0x00050003,4,0x00050003,4,0x00050003,4,0x00050003,4,0x00050003,50
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@4
	.word 0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4
	.word 0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,4,0x00040011,40,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@5
	.word 0x0003000B,4,0x0003000B,4,0x0003000B,4,0x0003000B,4,0x0003000B,4,0x0003000B,4,0x0003000B,4,0x0003000B,20
	.word 0x40004000,50,0x40004000,50,0x0004000c,10,0x0004000c,10,0x40004000,40,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@6
	.word 0x00030013,5,0x00030013,5,0x00030013,5,0x00030013,5,0x00030013,5,0x00030013,5,0x00030013,5,0x00030013,5
	.word 0x00030013,5,0x00030013,5,0x00030013,5,0x00030013,5,0x00030013,5,0x00030013,40,0x00050011,2,0x00050011,2
	.word 0x00050011,2,0x00050011,2,0x00050011,45,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@7
	.word 0x00fc8000,5,0x00fc8000,5,0x00fc8000,5,0x00fc8000,5,0x00fc8000,5,0x00fc8000,5,0x00fc8000,200
	.word 0x00fd8000,5,0x00fd8000,5,0x00fd8000,5,0x00fd8000,5,0x00fd8000,5,0x00fd8000,5,0x00fd8000,200,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0
	@8
	.word 0x00040016,10,0x00040016,10,0x00040016,10,0x00040016,111,0x00050011,1,0x00050011,1,0x00050011,1,0x00050011,1
	.word 0x00050011,1,0x00050011,1,0x00050011,1,0x00050011,1,0x00050011,1,0x00050011,1,0x00050011,1,0x00050011,1,0x00050011,1,0x00050011,1
	.word 0x00050011,1,0x00050011,66,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0
	@9
	.word 0x0004000f,2,0x0004000f,2,0x0004000f,2,0x0004000f,2,0x0004000f,2,0x0004000f,2,0x0004000f,2,0x0004000f,60
	.word 0x0004000b,1,0x0004000b,1,0x0004000b,1,0x0004000b,1,0x0004000b,40,0x40004000,10,0x40004000,10,0x40004000,10
	.word 0x00030015,6,0x00030015,6,0x00030015,6,0x00030015,80,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@10
	.word 0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3
	.word 0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3
	.word 0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,3,0x0000000d,30
	.word 0x00030009,30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@11
	.word 0x00020013,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@12
	.word 0x00020013,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@13
	.word 0x00020013,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@14
	.word 0x00020013,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@15
	.word 0x00020013,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	@16
	.word 0x00020013,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0							@ Simple fire for last boss :)
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
