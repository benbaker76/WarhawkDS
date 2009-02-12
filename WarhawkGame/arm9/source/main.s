@
@ Release V0.22
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
	.global initSystem
	.global main
	.global debugDigits

initSystem:
	bx lr

main:
	@ Setup the screens and the sprites	

	bl initVideo
	bl initSprites
	bl initData

	@ firstly, lets draw all the screen data ready for play
	@ and display the ship sprite
	
@	bl waitforVblank
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
	@bl playInGameMusic

	bl waitforFire
	mov r1,#1			@ just for checking (though this would NEVER be active at level start)
	ldr r0,=powerUp
	str r1,[r0]
	
	bl clearBG0
	bl drawAllEnergyBars

	@mov r1,#1
	@bl init_Alien
	@mov r1,#2
	@bl init_Alien
	@mov r1,#3
	@bl init_Alien
	@mov r1,#4
	@bl init_Alien
	@mov r1,#5
	@bl init_Alien
	@mov r1,#6
	@bl init_Alien
	@mov r1,#7
	@bl init_Alien
	@mov r1,#8
	@bl init_Alien
	@mov r1,#9
	@bl init_Alien
	@mov r1,#10
	@bl init_Alien
	@mov r1,#11
	@bl init_Alien
	@mov r1,#12
	@bl init_Alien
	@mov r1,#13
	@bl init_Alien

@

@@----------------------------@	
@ This is the MAIN game loop @
@----------------------------@
gameLoop:

	bl waitforVblank
	@--------------------------------------------
	@ this code is executed offscreen
	@--------------------------------------------
		
		bl moveShip
		
		bl scrollMain		@ Scroll Level Data
		bl scrollSub		@ Main + Sub
		bl levelDrift
		bl moveBullets		@ check and then moves bullets
		bl fireCheck

		bl moveAliens

		bl drawScore

		
		bl scrollStars		@ Scroll Stars (BG2,BG3)

		bl checkWave
		bl checkEndOfLevel	@ Set Flag for end-of-level (use later to init BOSS)

		bl drawSprite

		bl drawDebugText

	bl waitforNoblank
	
	@---------------------------------------------
	@ this code is executed during refresh
	@ this should give us a bit more time in vblank
	@---------------------------------------------
			

	b gameLoop			@ our main loop

@------------------------------------------------------------------------------

