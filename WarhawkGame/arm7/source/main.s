#include "system.h"
#include "audio.h"
#include "ipc.h"

	.arm
	.text
	.global main

main:
	ldr r0, =REG_POWERCNT
	ldr r1, =POWER_SOUND			@ Turn on sound
	str r1, [r0]
	
	ldr r0, =SOUND_CR				@ This just turns on global sound and sets volume
	ldr r1, =(SOUND_ENABLE | SOUND_VOL(127))	@ Turn on sound
	strh r1, [r0]
	
mainLoop:
	ldr r0, =REG_VCOUNT
	
waitVBlank:									
	ldrh r2, [r0]					@ read REG_VCOUNT into r2
	cmp r2, #193					@ 193 is, of course, the first scanline of vblank
	bne waitVBlank					@ loop if r2 is not equal to (NE condition) 193
	
	ldr r0, =IPC_SOUND_DATA(0)		@ Get a pointer to the sound data in IPC
	ldr r1, [r0]					@ Read the value
	cmp r1, #0						@ Is there data there?
	blne playADPCM					@ If so lets play the sound

	ldr r0, =IPC_SOUND_DATA(1)		@ Get a pointer to the sound data in IPC
	ldr r1, [r0]					@ Read the value
	cmp r1, #0						@ Is there data there?
	blne playSound					@ If so lets play the sound
	
	b mainLoop
	
playADPCM:
	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =SCHANNEL_TIMER(0)
	ldr r1, =SCHANNEL_TIMER(1)
	ldr r2, =SOUND_FREQ(11025)		@ Frequency currently hard-coded to 11025 Hz
	strh r2, [r0]
	strh r2, [r1]
	
	ldr r0, =SCHANNEL_SOURCE(0)		@ Channel source
	ldr r1, =SCHANNEL_SOURCE(1)		@ Channel source
	ldr r2, =IPC_SOUND_DATA(0)		@ Lets get first sound in IPC
	ldr r3, [r2]					@ Read the value
	str r3, [r0]					@ Write the value
	str r3, [r1]					@ Write the value
	
	ldr r0, =SCHANNEL_LENGTH(0)
	ldr r1, =SCHANNEL_LENGTH(1)
	ldr r2, =IPC_SOUND_LEN(0)		@ Get the location of the sound length
	ldr r3, [r2]					@ Read the value
	and r3, #(~7)					@ Multiple of 4 bytes
	add r3, #4						@ Add 4 bytes
	and r3, #0x7FFFFFFF				@ And with 0x7FFFFFFF
	lsr r3, #2						@ Right shift (LEN >> 2)
	str r3, [r0]					@ Write the value
	str r3, [r1]					@ Write the value
	
	ldr r0, =SCHANNEL_REPEAT_POINT(0)
	ldr r1, =SCHANNEL_REPEAT_POINT(1)
	mov r2, #0
	strh r2, [r0]
	strh r2, [r1]
	
	ldr r0, =SCHANNEL_CR(0)
	ldr r1, =SCHANNEL_CR(1)
	ldr r2, =(SCHANNEL_ENABLE | SOUND_REPEAT | SOUND_VOL(127) | SOUND_PAN(64) | SOUND_FORMAT_ADPCM)
	str r2, [r0]
	str r2, [r1]

	ldr r0, =IPC_SOUND_DATA(0)		@ Get a pointer to the sound data in IPC
	mov r1, #0
	str r1, [r0]					@ Clear the value so it wont play again

	ldmfd sp!, {r0-r3, pc} 		@ restore rgisters and return
	
playSound:
	stmfd sp!, {r0-r3, lr}
	
	bl getFreeChannel
	
	mov r3, r0, lsl #4
	
	ldr r0, =SCHANNEL_TIMER(0)
	add r0, r3
	ldr r1, =SOUND_FREQ(11025)		@ Frequency currently hard-coded to 11025 Hz
	strh r1, [r0]
	
	ldr r0, =SCHANNEL_SOURCE(0)		@ Channel source
	add r0, r3
	ldr r1, =IPC_SOUND_DATA(1)		@ Lets get first sound in IPC
	ldr r2, [r1]					@ Read the value
	str r2, [r0]					@ Write the value
	
	ldr r0, =SCHANNEL_LENGTH(0)
	add r0, r3
	ldr r1, =IPC_SOUND_LEN(1)		@ Get the location of the sound length
	ldr r2, [r1]					@ Read the value
	and r2, #(~7)					@ Multiple of 4 bytes
	and r2, #0x7FFFFFFF				@ And with 0x7FFFFFFF
	lsr r2, #2						@ Right shift (LEN >> 2)
	str r2, [r0]					@ Write the value
	
	ldr r0, =SCHANNEL_REPEAT_POINT(0)
	add r0, r3
	mov r1, #0
	strh r1, [r0]
	
	ldr r0, =SCHANNEL_CR(0)
	add r0, r3
	ldr r1, =(SCHANNEL_ENABLE | SOUND_ONE_SHOT | SOUND_VOL(127) | SOUND_PAN(64) | SOUND_8BIT)
	str r1, [r0]

	ldr r0, =IPC_SOUND_DATA(1)		@ Get a pointer to the sound data in IPC
	mov r1, #0
	str r1, [r0]					@ Clear the value so it wont play again

playSoundDone:

	ldmfd sp!, {r0-r3, pc} 		@ restore rgisters and return
	
getFreeChannel:

	@ RetVal r0 = channel number (0 - 15)

	stmfd sp!, {r1-r3, lr}

	mov r0, #15						@ Reset the counter
	ldr r1, =SCHANNEL_CR(0)			@ This is the base address of the sound channel

freeChannelLoop:

	ldr r2, [r1, r0, lsl #4]		@ Add the offset (0x04000400 + ((n)<<4))
	tst r2, #SCHANNEL_ENABLE		@ Is the sound channel enabled?
	bne freeChannelFound			@ (if not equal = channel clear?)
	subs r0, #1						@ sub one from our counter
	bpl freeChannelLoop				@ keep looking
	
freeChannelFound:
									
	ldmfd sp!, {r1-r3, pc}			@ restore rgisters and return

.pool
.end
