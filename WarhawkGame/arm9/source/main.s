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

@
@ Release V0.50
@
@ ps. you can kill trackers by swinging them off the bottom of the screen!

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
	.global initSystem
	.global main
	.global debugDigits
	.global randomNumber

initSystem:
	bx lr

main:
	bl irqInit								@ Initialize Interrupts
		
	ldr r0, =IRQ_VBLANK						@ VBLANK interrupt
	ldr r1, =gameLoop						@ Function Address
	bl irqSet								@ Set the interrupt
	
	bl initData								@ setup actual game data
	
	@ Setup the screens and the sprites	
	
bl waitforVblank	@ We need to set up a wipe here and clear it later / but for now, this will just make it CLEAN
	bl initLevel
	bl initVideo
	bl initSprites
	bl initLevelSprites
@	bl initLevel
	
	@ firstly, lets draw all the screen data ready for play
	@ and display the ship sprite
	
	bl clearBG0
	bl clearBG1
	bl clearBG2
	bl clearBG3	
	
	bl drawMapScreenMain
	bl drawMapScreenSub
	bl drawSFMapScreenMain
	bl drawSFMapScreenSub
	bl drawSBMapScreenMain
	bl drawSBMapScreenSub
	bl drawScore
	bl drawSprite
	bl drawGetReadyText
	bl drawAllEnergyBars
	@bl playInGameMusic
	
bl waitforNoblank	@ end of bit to make it clean / use wipe to game!


	bl waitforFire		@ wait for a short while to start game
	mov r1,#1			@ just for checking (though this would NEVER be active at level start)
	ldr r0,=powerUp
@	str r1,[r0]
	
	bl clearBG0
	
	@ ---------------------------------------------
	@ INTERRUPTS
	@ ---------------------------------------------
	
	@ldr r0, =(IRQ_VBLANK | IRQ_HBLANK)		@ Interrupts
	@bl irqEnable							@ Enable
	
@mainLoop:

	@b mainLoop
	
	@ ---------------------------------------------
	@ INTERRUPTS
	@ ---------------------------------------------

@----------------------------@	
@ This is the MAIN game loop @
@----------------------------@
gameLoop:

	bl waitforVblank
	@--------------------------------------------
	@ this code is executed offscreen
	@--------------------------------------------
		
		bl moveShip			@ check and move your ship
		
		bl moveBullets		@ check and then moves bullets
		bl alienFireMove	@ check and move alien bullets
		bl fireCheck		@ check for your wish to shoot!


		bl drawScore		@ update the score with any changes
		bl drawAllEnergyBars

		
		bl checkWave		@ check if time for another alien attack
		bl moveAliens		@ move the aliens and detect colisions with you

		bl initHunterMine	@ check if we should chuck another mine or hunter into the mix


		bl scrollMain		@ Scroll Level Data
		bl scrollSub		@ Main + Sub
		bl levelDrift		@ update level with the horizontal drift
		bl scrollStars		@ Scroll Stars (BG2,BG3)		
		bl checkEndOfLevel	@ Set Flag for end-of-level (use later to init BOSS)
		bl checkBossInit	@ Check if we should set the offscreen boss up??
		bl drawSprite		@ drawsprites and do update bloom effect

@		bl drawDebugText	@ draw some numbers :)


	ldr r10,=energy					@ Pointer to data
	ldr r10,[r10]					@ Read value
	cmp r10,#0
@	beq youDied
	bl waitforNoblank
	
	@---------------------------------------------
	@ this code is executed during refresh
	@ this should give us a bit more time in vblank
	@---------------------------------------------
			

	b gameLoop			@ our main loop
	
	@ we will end up with more code here for game over and death
	@ also for return to title!
	
	
	youDied:

	bl drawAllEnergyBars	

	ldr r0, =youDiedText			@ Load out text pointer
	ldr r1, =6						@ x pos
	ldr r2, =10						@ y pos
	ldr r3, =1						@ Draw on main screen
	bl drawText
	
	stopit:
	b stopit

@------------------------------------------------------------------------------

	.pool
	.end


