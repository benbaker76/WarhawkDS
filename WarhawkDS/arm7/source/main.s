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

#include "system.h"
#include "interrupts.h"
#include "audio.h"
#include "ipc.h"

	#define STOP_SOUND			-1
	#define NO_FREE_CHANNEL		-1

	.arm
	.align
	.text
	.global main
	
interruptHandlerVBlank:

	stmfd sp!, {r0-r4, lr}
	
	ldr r2, =IPC_SOUND_DATA(0)					@ Get a pointer to the sound data in IPC
	ldr r3, =IPC_SOUND_LEN(0)					@ Get a pointer to the sound data in IPC
	ldr r0, [r2]								@ Read the value
	ldr r1, [r3]								@ Read the value
	mov r4, #0									@ Value to reset
	str r4, [r2]								@ Clear the data
	cmp r0, #STOP_SOUND							@ Stop Sound value?
	beq interruptHandlerVBlankStopMusic			@ Stop Sound
	cmp r0, #0									@ Is there data there?
	bgt interruptHandlerVBlankPlayMusic			@ If so lets play the sound
	
	ldr r2, =IPC_SOUND_DATA(1)					@ Get a pointer to the sound data in IPC
	ldr r3, =IPC_SOUND_LEN(1)					@ Get a pointer to the sound data in IPC
	ldr r0, [r2]								@ Read the value
	ldr r1, [r3]								@ Read the value
	mov r4, #0									@ Value to reset
	str r4, [r2]								@ Clear the data
	cmp r0, #STOP_SOUND							@ Stop Sound value?
	beq interruptHandlerVBlankStopSound			@ Stop Sound
	cmp r0, #0									@ Is there data there?
	bgt interruptHandlerVBlankPlaySound			@ If so lets play the sound
	
	b interruptHandlerVBlankDone
	
interruptHandlerVBlankStopMusic:

	bl stopMusic
	b interruptHandlerVBlankDone
	
interruptHandlerVBlankPlayMusic:

	bl playMusic
	b interruptHandlerVBlankDone

interruptHandlerVBlankStopSound:

	bl stopSound
	b interruptHandlerVBlankDone
	
interruptHandlerVBlankPlaySound:

	bl playSound
	
interruptHandlerVBlankDone:
	
	ldmfd sp!, {r0-r4, pc} 					@ restore registers and return

	@ ------------------------------------
	
main:
	bl irqInit									@ Initialize Interrupts
	
	ldr r0, =IRQ_VBLANK							@ VBLANK interrupt
	ldr r1, =interruptHandlerVBlank				@ Function Address
	bl irqSet									@ Set the interrupt
	
	ldr r0, =(IRQ_VBLANK)						@ Interrupts
	bl irqEnable								@ Enable
	
	ldr r0, =REG_POWERCNT
	ldr r1, =POWER_SOUND						@ Turn on sound
	str r1, [r0]
	
	ldr r0, =SOUND_CR							@ This just turns on global sound and sets volume
	ldr r1, =(SOUND_ENABLE | SOUND_VOL(127))	@ Turn on sound
	strh r1, [r0]
	
mainLoop:

	bl swiWaitForVBlank
	
	bl checkSleepMode
	
	b mainLoop
	
	@ ------------------------------------
	
playMusic:

	stmfd sp!, {r0-r4, lr}
	
	@ r0 - Data
	@ r1 - Len
	
	ldr r2, =SCHANNEL_TIMER(0)
	ldr r3, =SCHANNEL_TIMER(1)
	ldr r4, =SOUND_FREQ(32000)					@ Frequency currently hard-coded to 32000 Hz
	strh r4, [r2]
	strh r4, [r3]
	
	ldr r2, =SCHANNEL_SOURCE(0)					@ Channel source
	ldr r3, =SCHANNEL_SOURCE(1)					@ Channel source
	str r0, [r2]								@ Write the value
	str r0, [r3]								@ Write the value
	
	ldr r2, =SCHANNEL_LENGTH(0)
	ldr r3, =SCHANNEL_LENGTH(1)
	lsr r1, #2									@ Right shift (LEN >> 2)
	str r1, [r2]								@ Write the value
	str r1, [r3]								@ Write the value
	
	ldr r2, =SCHANNEL_REPEAT_POINT(0)
	ldr r3, =SCHANNEL_REPEAT_POINT(1)
	mov r4, #0
	strh r4, [r2]
	strh r4, [r3]
	
	ldr r2, =SCHANNEL_CR(0)
	ldr r3, =SCHANNEL_CR(1)
	ldr r4, =(SCHANNEL_ENABLE | SOUND_REPEAT | SOUND_VOL(127) | SOUND_PAN(64) | SOUND_8BIT)
	str r4, [r2]
	str r4, [r3]

	ldmfd sp!, {r0-r4, pc} 					@ restore rgisters and return
	
	@ ------------------------------------
	
stopMusic:

	stmfd sp!, {r0-r2, lr}
	
	ldr r0, =SCHANNEL_CR(0)
	ldr r1, =SCHANNEL_CR(1)
	mov r2, #0
	str r2, [r0]
	str r2, [r1]

	ldmfd sp!, {r0-r2, pc} 					@ restore rgisters and return
	
	@ ------------------------------------
	
playSound:

	stmfd sp!, {r0-r4, lr}
	
	@ r0 - Data
	@ r1 - Len
	
	mov r2, r0
	
	bl getFreeChannel
	cmp r0, #NO_FREE_CHANNEL
	beq playSoundDone

	mov r3, r0, lsl #4
	mov r0, r2
	
	ldr r2, =SCHANNEL_TIMER(0)
	ldr r4, =SOUND_FREQ(11025)					@ Frequency currently hard-coded to 11025 Hz
	strh r4, [r2, r3]
	
	ldr r2, =SCHANNEL_SOURCE(0)					@ Channel source
	str r0, [r2, r3]							@ Write the value
	
	ldr r2, =SCHANNEL_LENGTH(0)
	lsr r1, #2									@ Right shift (LEN >> 2)
	str r1, [r2, r3]							@ Write the value
	
	ldr r2, =SCHANNEL_REPEAT_POINT(0)
	mov r4, #0
	strh r4, [r2, r3]
	
	ldr r2, =SCHANNEL_CR(0)
	ldr r4, =(SCHANNEL_ENABLE | SOUND_ONE_SHOT | SOUND_VOL(127) | SOUND_PAN(64) | SOUND_8BIT)
	str r4, [r2, r3]
	
playSoundDone:				

	ldmfd sp!, {r0-r4, pc} 					@ restore registers and return
	
	@ ------------------------------------
	
stopSound:

	stmfd sp!, {r0-r2, lr}
	
	mov r0, #15									@ Reset the counter
	ldr r1, =SCHANNEL_CR(0)						@ This is the base address of the sound channel
	mov r2, #0									@ Clear
	
stopSoundLoop:
	
	str r2, [r1, r0, lsl #4]					@ Add the offset (0x04000400 + ((n)<<4))
	sub r0, #1									@ sub one from our counter
	cmp r0, #1
	bne stopSoundLoop							@ back to our loop

	ldmfd sp!, {r0-r2, pc} 					@ restore registers and return
	
	@ ------------------------------------
	
getFreeChannel:

	@ RetVal r0 = channel number (0 - 15)

	stmfd sp!, {r1-r2, lr}

	mov r0, #15									@ Reset the counter
	ldr r1, =SCHANNEL_CR(0)						@ This is the base address of the sound channel
	
getFreeChannelLoop:
	
	ldr r2, [r1, r0, lsl #4]					@ Add the offset (0x04000400 + ((n)<<4))
	tst r2, #SCHANNEL_ENABLE					@ Is the sound channel enabled?
	beq getFreeChannelFound						@ (if not equal = channel clear)
	sub r0, #1									@ sub one from our counter
	cmp r0, #1
	bne getFreeChannelLoop						@ keep looking
	
	mov r0, #NO_FREE_CHANNEL

getFreeChannelFound:

	ldmfd sp!, {r1-r2, pc}						@ restore registers and return
	
	@ ------------------------------------

	.pool
	.end
