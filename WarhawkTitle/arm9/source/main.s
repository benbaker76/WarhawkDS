@
@ Title Screen
@ v0.3 - HK
@ - Added music
@ V0.2 - Flash
@ - Added introduction graphics
@ V0.1 - Flash
@  - Added code to create 256 stars when storage can be worked out?
@ - Added random number routine
@


#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "ipc.h"

	.arm
	.align
	.global initSystem
	.global main

initSystem:
	bx lr

main:

	bl InitData

	bl Opening							@ Display the production notes

	
@ Initialise the Display
@ First draw main logo on the top screen (Sub screen)

	ldr r0, =BG_BMP_RAM_SUB(0)		@ make r0 a pointer to screen memory bg bitmap sub address 0
	ldr r1, =ToptitleBitmap			@ make r1 a pointer to your bitmap data
	mov r3, #0x6000					@ Half of 96k (2 pixels at a time)
	subPicLoop:
		ldr r2, [r1], #4				@ Loads r2 with the next two pixels from the bitmap data (pointed to by r1).
		str r2, [r0], #4				@ Write two pixels
		subs r3, r3, #1					@ Move along one
	bne subPicLoop					@ And loop back if not done

bl ClearStar						@ Zero all star data (not needed)
bl RandStar							@ Store initial random stars

bl Warhawkship						@ Draw Warhawk mothership (need re-drawing)	
bl WarhawkLogo						@ Draw Warhawk logo (may need work)
bl playTitleMusic

@ ----------------------------------
@ Main loop
@ ----------------------------------


loop:
								@ First step (strangly - erase the stars)

	bl WaitVBlank

	ldr r8,=0						@ set r8 to the colour of the star (0=erase)
	bl drawstars					@ draw the stars
	bl movestars					@ Call the subroutine to move the stars (this could be in the plot routine for speed when r8=0)
	ldr r8,=65535					@ Set the stars to white
	bl drawstars					@ Re-plot the stars in white
	bl fireplay						@ Pulse the "Fire to Play" Text


	bl ScreenSwitch					@ Run code to check for a switch of the main screens

	@ This is just a simple code to check for "A" and halt until released
	butta:
		ldr r1,=REG_KEYINPUT
		ldr r2,[r1]
		mov r3,#1
		and r2,r3
		cmp r2,#0
	beq butta

	bl WaitVBlankNo

b loop							@ lets keep doing it!

@--------------------------------------
@ Subroutines are listed below
@ "Plotstar" is a simpe star plot routine that requests and x,y passed in r6,r7 and a colour passed in r8
@ This is integrated into the two draw and move subs to avoid nestled subs (hard to manage in asm)
@--------------------------------------

ScreenSwitch:
	stmfd sp!, {r0-r6, lr}
	@ now we need some code to change the title screens!
	@ we will have 2, one with the mothership and one with the credits (and Highscore "predrawn in init" later)
	@ tscreen = screen number
	@ tscreendelay = delay till we swich screens
								
	adrl r0,[tscreendelay]
	ldr r1,[r0]
	add r1,r1,#1
	ldr r2,=600
	cmp r1,r2
	bne nochange
		mov r1,#0
		adrl r3,[tscreen]
		ldr r4,[r3]
		cmp r4,#2
		bne screen2
			mov r4,#1
			str r4,[r3]
			bl clearscreen
			bl Warhawkship
			b nochange
		screen2:
		mov r4,#2
		str r4,[r3]
		bl clearscreen
		bl creditshow

	nochange:
	str r1,[r0]
	ldmfd sp!, {r0-r6, pc}

InitData:
	ldr r0, =REG_POWERCNT
	ldr r1, =POWER_ALL_2D			@ All power on
	str r1, [r0]
 
	mov r0, #REG_DISPCNT			@ Main screen to Mode 5 with BG2 active
	ldr r1, =(MODE_5_2D | DISPLAY_BG2_ACTIVE)
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB		@ Sub screen to Mode 5 with BG2 active
	ldr r1, =(MODE_5_2D | DISPLAY_BG2_ACTIVE)
	str r1, [r0]
 
	ldr r0, =VRAM_A_CR				@ Set VRAM A to be main address 0x06000000
	ldr r1, =(VRAM_ENABLE | VRAM_A_MAIN_BG_0x06000000)
	strb r1, [r0]
	
	ldr r0, =VRAM_C_CR				@ Set VRAM C to be sub address 0x06200000
	ldr r1, =(VRAM_ENABLE | VRAM_C_SUB_BG_0x06200000)
	strb r1, [r0]
	
	ldr r0, =REG_BG2CNT				@ Set main screen BG2 format to be 256x256x16 bitmap at base address
	ldr r1, =(BG_BMP16_256x256 | BG_BMP_BASE(0))
	str r1, [r0]

	ldr r0, =REG_BG2CNT				@ Set main screen BG2 format to be 256x256x16 bitmap at base address
	ldr r1, =(BG_BMP16_256x256 | BG_BMP_BASE(0))
	str r1, [r0]
	
	ldr r0, =REG_BG2CNT_SUB			@ Set sub screen BG2 format to be 256x256x16 bitmap at base address
	ldr r1, =(BG_BMP16_256x256 | BG_BMP_BASE(0))
	str r1, [r0]
	
	ldr r0, =REG_BG2PA				@ these are rotation backgrounds so you must set the rotation attributes: 
	ldr r1, =(1 << 8)				@ these are fixed point numbers with the low 8 bits the fractional part
	strh r1, [r0]					@ this basicaly gives it a 1:1 translation in x and y so you get a nice flat bitmap
	
	ldr r0, =REG_BG2PB
	ldr r1, =0
	strh r1, [r0]
	
	ldr r0, =REG_BG2PC
	ldr r1, =0
	strh r1, [r0]
	
	ldr r0, =REG_BG2PD
	ldr r1, =(1 << 8)
	strh r1, [r0]
	
	ldr r0, =REG_BG2X				@ set scroll registers to zero
	ldr r1, =0
	strh r1, [r0]

	ldr r0, =REG_BG2Y
	ldr r1, =0
	strh r1, [r0]
	
	ldr r0, =REG_BG2PA_SUB			@ these are rotation backgrounds so you must set the rotation attributes: 
	ldr r1, =(1 << 8)				@ these are fixed point numbers with the low 8 bits the fractional part
	strh r1, [r0]					@ this basicaly gives it a 1:1 translation in x and y so you get a nice flat bitmap
	
	ldr r0, =REG_BG2PB_SUB
	ldr r1, =0
	strh r1, [r0]
	
	ldr r0, =REG_BG2PC_SUB
	ldr r1, =0
	strh r1, [r0]
	
	ldr r0, =REG_BG2PD_SUB
	ldr r1, =(1 << 8)
	strh r1, [r0]
	
	ldr r0, =REG_BG2X_SUB			@ set scroll registers to zero
	ldr r1, =0
	strh r1, [r0]

	ldr r0, =REG_BG2Y_SUB
	ldr r1, =0
	strh r1, [r0]
	mov r15,r14

@----
Opening:
	stmfd sp!, {r0-r6, lr}
	bl WaitVBlank
	
	
	ldr r0, =BG_BMP_RAM_SUB(0)		@ make r0 a pointer to screen memory bg bitmap sub address 0
	ldr r1, =WartopBitmap			@ make r1 a pointer to your bitmap data
	mov r3, #0x6000					@ Half of 96k (2 pixels at a time)
	Oloop0:
		ldr r2, [r1], #4				@ Loads r2 with the next two pixels from the bitmap data (pointed to by r1).
		str r2, [r0], #4				@ Write two pixels
		subs r3, r3, #1					@ Move along one
	bne Oloop0	

	ldr r0,=ProteusBitmap
	ldr r1,=(BG_BMP_RAM(0))
	mov r2,#0x6000
	Oloop1:
		ldr r3,[r0],#4
		str r3,[r1],#4
		subs r2,r2,#1	
	bne Oloop1
	
	ldr r0,=30000
	Oloop2:
		bl WaitVBlank
		subs r0,#1
	bne Oloop2
	
	ldr r0,=RetrobytesBitmap
	ldr r1,=(BG_BMP_RAM(0))
	mov r2,#0x6000
	Oloop4:
		ldr r3,[r0],#4
		str r3,[r1],#4
		subs r2,r2,#1	
	bne Oloop4	
	
	ldr r0,=30000
	Oloop5:
		bl WaitVBlank
		subs r0,#1
	bne Oloop5

	ldr r1,=(BG_BMP_RAM(0))
	mov r2,#49152
	mov r3,#0
	Oloop6:
		strh r3,[r1],#2
		subs r2,r2,#1
	bne Oloop6
	
	bl WaitVBlank
	
	ldmfd sp!, {r0-r6, pc}
@----
WaitVBlank:
	stmfd sp!, {r0-r6, lr}
	ldr r0, =REG_VCOUNT
	waitVB:
		ldrh r1, [r0]
		cmp r1, #193
	bne waitVB
	ldmfd sp!, {r0-r6, pc}
@----
WaitVBlankNo:
	stmfd sp!, {r0-r6, lr}
	ldr r0, =REG_VCOUNT
	waitVBNO:
		ldrh r1, [r0]					
		cmp r1, #255					
	bne waitVBNO	
	ldmfd sp!, {r0-r6, pc}
@----	
drawstars:
	stmfd sp!, {r0-r6, lr}
	mov r0,#1024				@ Set numstars-1
	loop1:
		adrl r1,[StarX]				@ Find the memory address of the X coord list
		ldrb r6,[r1,r0]			@ make r6 the xcoord + current star (r0)
		adrl r1,[StarY]				@ do the same for Y coord and stor in r7
		ldrb r7,[r1,r0]
		
		lsl r6,#1					@ 2 bytes per pixel
		lsl r7,#1					@ 512 bytes=new linw
		add r3,r6,r7,lsl #8		@ add x + (y *256) store in r0
		add r3,#BG_BMP_RAM(0)		@ add screen location to result
		@ Simple Background Check (*)
		ldrh r4,[r3]				@ Load r4 with screen contents
		ldr r1,=65535
		cmp r4,r1					@ If we have full on b, this is a star - you can redraw
		beq ok	
		ldr r4,[r3]	
		cmp r4,#0					@ If it is between white and black - dont draw
		bne nonono					@ Anything in the images onscreen that are black or white will be drawn over
			ok:							@ In the code here, this does not mater!
			strh r8,[r3]				@ store r8 at screen location
		nonono:
		subs r0,#1					@ go to next star (in reverse)
	bpl loop1					@ have we done star 0 yet? if not go back to loop1
	ldmfd sp!, {r0-r6, pc}
@----
movestars:
	stmfd sp!, {r0-r6, lr}
		mov r3,#1024					@ Set numstars
	loop2:
		adrl r4,[StarS]
		ldr r5,[r4,r3]				@ R2 now holds the speed (subs) of the star
		adrl r4,[StarX]
		ldrb r6,[r4,r3]			@ r3 now holds the x coord of the star
		subs r6,r6,r5				@ take r2 away from r3 using signed bit
		bpl onscreen				@ if the value is still positive - move on
		
			@ The code here needs to call a RND sub to generate a new Y coord (0-191) and speed (1-6)
			@ and then store this in the required location
			@ But for now we will just replace the stars taking the speed into account
		
			mov r5,#255					@ make sure if moving more than 1 pixel that
			adds r5,r5,r6				@ we take the negative off the resulting start position
			mov r6,r5
		
		onscreen:
		strb r6,[r4,r3]			@ r1 still holds the mem adrless of the x registers
		
		subs r3,#1					@ count down the number of stars
	bpl loop2
	ldmfd sp!, {r0-r6, pc}		@ restore the registers (Is it quicker just to restore the ones you have used?)
@----

WarhawkLogo:
	stmfd sp!, {r0-r6, lr}
	mov r5, #21						@ Y resolution of image
	ldr r2,=WarlogoBitmap			@ Source image (180x21)
	ldr r1, =(BG_BMP_RAM(0) + 76)	@ Load R1 with memory of bitmap + offset to centre image
	add r1,r1,#512*2				@ move down the screen (10 lines down)
	doy1:
		mov r4, #180				@ X resolution of image
		dox1:
			ldr r3,[r2],#2			@ Read 2 bytes from original image
			cmp r3,#0				@ Is the pixel black (we are using this for transparency)
			bne drawlogo			@ If false, draw as usual
			add r1,r1,#2			@ We still need to move the write position forward 1
			b didntdraw
			drawlogo:
			strh r3,[r1],#2			@ Write 2 bytes to the screen
			didntdraw:
			subs r4,r4,#1			@ Count off 1 from the x counter
		bne dox1					@ Have we done that line yet?
		add r1,r1,#76*2				@ Add the difference to start next line
		subs r5,r5,#1				@ Count off Y
	bne doy1						@ Are we dont yet???
	ldmfd sp!, {r0-r6, pc}

	
	@ This is a lazy cop-out.. I have used the same code twice to do the same thing with different dimensions.
	@ It would be better to create a routine that is supplied :-
	@ Image address, x-y top left plot coord, and x and y dimension.
	@ This would be slighly slower, but better overal.
	
Warhawkship:
	stmfd sp!, {r0-r6, lr}
	mov r5, #150					@ Y resolution of image
	ldr r2,=WarshipBitmap			@ Source image (114x150)
	ldr r1, =(BG_BMP_RAM(0) + 142)	@ Load R1 with memory of bitmap + offset to centre image
	add r1,r1,#512*26				@ move down the screen (10 lines down)
	doy2:
		mov r4, #114				@ X resolution of image
		dox2:
			ldr r3,[r2],#2			@ Read 2 bytes from original image
			cmp r3,#0				@ Is the pixel black (we are using this for transparency)
			bne drawlogo1			@ If false, draw as usual
			add r1,r1,#2			@ We still need to move the write position forward 1
			b didntdraw1
			drawlogo1:
			strh r3,[r1],#2			@ Write 2 bytes to the screen
			didntdraw1:
			subs r4,r4,#1			@ Count off 1 from the x counter
		bne dox2					@ Have we done that line yet?
		add r1,r1,#284				@ Add the difference to start next line
		subs r5,r5,#1				@ Count off Y
	bne doy2						@ Are we dont yet???
	ldmfd sp!, {r0-r6, pc}
	
fireplay:
	stmfd sp!, {r0-r6, lr}	
	adrl r7,[pulse]					@ find the pulse value address
	ldrb r9,[r7]					@ store the pulse in r9
	add r9,#1						@ Add 1 to the red element (makes it realy easy)
	cmp r9,#32						@ check if we are over the 32 boundy (yes we could use OR)
	bne pulseok
	mov r9,#5						@ Reset low (we dont want black)
	pulseok:
	strb r9,[r7]					@ put it back in the pulse
	add r9,#32768					@ set bit 15 the cheeky way	
	mov r5, #14						@ Y resolution of image
	ldr r2,=FireBitmap				@ Source image (60x14)
	ldr r1, =(BG_BMP_RAM(0) + 196)	@ Load R1 with memory of bitmap + offset to centre image
	add r1,r1,#512*178				@ move down the screen (10 lines down)
	fdoy2:
		mov r4, #60					@ X resolution of image
		fdox2:
			ldrh r3,[r2],#2			@ Read 2 bytes from original image
			cmp r3,#32768			@ Is the pixel black (we are using this for transparency)
			beq space
				strh r9,[r1],#2		@ r9=colour of new pixels
				b nospace			@ Write 2 bytes to the screen
			space:
			adds r1,r1,#2
			nospace:
			subs r4,r4,#1			@ Count off 1 from the x counter
		bne fdox2					@ Have we done that line yet?
		add r1,r1,#196+196			@ Add the difference to start next line
		subs r5,r5,#1				@ Count off Y
	bne fdoy2						@ Are we dont yet???
	ldmfd sp!, {r0-r6, pc}
	
creditshow:
	stmfd sp!, {r0-r6, lr}
	mov r5, #130					@ Y resolution of image
	ldr r2,=creditsBitmap			@ Source image (220x130)
	ldr r1, =(BG_BMP_RAM(0) + 36)	@ Load R1 with memory of bitmap + offset to centre image
	add r1,r1,#512*38				@ move down the screen (10 lines down)
	doy4:
		mov r4, #220				@ X resolution of image
		dox4:
			ldr r3,[r2],#2			@ Read 2 bytes from original image
			cmp r3,#0				@ Is the pixel black (we are using this for transparency)
			bne drawlogo4			@ If false, draw as usual
			add r1,r1,#2			@ We still need to move the write position forward 1
			b didntdraw4
			drawlogo4:
			strh r3,[r1],#2			@ Write 2 bytes to the screen
			didntdraw4:
			subs r4,r4,#1			@ Count off 1 from the x counter
		bne dox4					@ Have we done that line yet?
		add r1,r1,#72				@ Add the difference to start next line
		subs r5,r5,#1				@ Count off Y
	bne doy4						@ Are we dont yet???
	ldmfd sp!, {r0-r6, pc}
	
clearscreen:

	@ This needs cleaning up... A simple dma would be miles better
	stmfd sp!, {r0-r6, lr}
	mov r5, #200					@ Y resolution of image
	mov r2,#32768					@ Source image (200x160)
	ldr r1, =(BG_BMP_RAM(0))		@ Load R1 with memory of bitmap + offset to centre image
	add r1,r1,#512*23				@ move down the screen (10 lines down)
	doy5:
		mov r4, #200				@ X resolution of image
		dox5:
			mov r3,#0				@ Read 2 bytes from original image
			strh r3,[r1],#2			@ Write 2 bytes to the screen
			subs r4,r4,#1			@ Count off 1 from the x counter
		bne dox5					@ Have we done that line yet?
		add r1,r1,#0				@ Add the difference to start next line
		subs r5,r5,#1				@ Count off Y
	bne doy5						@ Are we dont yet???
	ldmfd sp!, {r0-r6, pc}
RandStar:		
	mov r3,#1024
	adrl r4,[StarX]
	adrl r5,[StarY]
	adrl r6,[StarS]
	starloop:

		ldr     ip, seedpointer
        ldmia   ip, {r0, r1}
        tst     r1, r1, lsr #1			@ to bit into carry
        movs    r2, r0, rrx				@ 33-bit rotate right
        adc     r1, r1, r1				@ carry into LSB of r2
        eor     r2, r2, r0, lsl #12	@ (involved!)
        eor     r0, r2, r2, lsr #20	@ (similarly involved!)
		stmia   ip, {r0, r1} 

	strb r0,[r4,r3] @ Store X

		ldr     ip, seedpointer
        ldmia   ip, {r0, r1}
        tst     r1, r1, lsr #1			@ to bit into carry
        movs    r2, r0, rrx				@ 33-bit rotate right
        adc     r1, r1, r1				@ carry into LSB of r2
        eor     r2, r2, r0, lsl #12	@ (involved!)
        eor     r0, r2, r2, lsr #20	@ (similarly involved!)
		stmia   ip, {r0, r1}
		

	mov r7,r0
	and r0,#127
	and r7,#63
	add r0,r7
	strb r0,[r5,r3] @ Store Y

		ldr     ip, seedpointer
        ldmia   ip, {r0, r1}
        tst     r1, r1, lsr #1			@ to bit into carry
        movs    r2, r0, rrx				@ 33-bit rotate right
        adc     r1, r1, r1				@ carry into LSB of r2
        eor     r2, r2, r0, lsl #12	@ (involved!)
        eor     r0, r2, r2, lsr #20	@ (similarly involved!)
		stmia   ip, {r0, r1}
	and r0,r0,#3
	strb r0,[r6,r3] @ Store Speed
	
	subs r3,#1	
	bne starloop
	mov r15,r14

	.align

seedpointer: 
        .long    seed  
seed: 
        .long    0x55555555 
        .long    0x55555555

ClearStar:
	mov r3,#1024
	mov r0,#20
	adrl r4,[StarX]
	adrl r5,[StarY]
	adrl r6,[StarS]

	clrme:
	strb r0,[r4,r3]
	strb r0,[r5,r3]
	strb r0,[r6,r3]

	subs r3,#1
	bne clrme
	mov     pc, lr

randomnumber:
@ HK - I cannot get this to work as a BL - WTF!
@
@
@ on exit:
@       r0 = low 32-bits of pseudo-random number
@       r1 = high bit (if you want to know it)
@	stmfd sp!, {r2-r6, lr}
        ldr     ip, seedpointer
        ldmia   ip, {r0, r1}
        tst     r1, r1, lsr #1				@ to bit into carry
        movs    r2, r0, rrx					@ 33-bit rotate right
        adc     r1, r1, r1					@ carry into LSB of r2
        eor     r2, r2, r0, lsl #12		@ (involved!)
        eor     r0, r2, r2, lsr #20		@ (similarly involved!)

		stmia   ip, {r0, r1} 
@	ldmfd sp!, {r2-r6, lr}
		mov r15,r14
		
playTitleMusic:
	stmfd sp!, {r0-r1, lr}

	ldr r0, =IPC_SOUND_LEN(0)		@ Get the IPC sound length address
	ldr r1, =1480305				@ Get the sample size
	str r1, [r0]					@ Write the sample size
	
	ldr r0, =IPC_SOUND_DATA(0)		@ Get the IPC sound data address
	ldr r1, =title_wav				@ Get the sample address
	str r1, [r0]					@ Write the value
	
	ldmfd sp!, {r0-r1, pc} 		@ restore rgisters and return
	
.pool
.align

pulse:
	.word 5
tscreendelay:
	.word 0
tscreen:
	.word 0
	
StarX:
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
StarY:
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
StarS:
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.end