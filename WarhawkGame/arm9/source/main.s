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
	.global randomNumber

initSystem:
	bx lr

main:
	@ setup actual game data
	bl initData
	@ Setup the screens and the sprites	
bl waitforVblank	@ We need to set up a wipe here and clear it later / but for now, this will just make it CLEAN
	bl initLevel
	bl initVideo
	bl initSprites
	bl initLevel
	
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
	@bl playInGameMusic
	
bl waitforNoblank	@ end of bit to make it clean / use wipe to game!


	bl waitforFire		@ wait for a short while to start game
	mov r1,#1			@ just for checking (though this would NEVER be active at level start)
	ldr r0,=powerUp
	str r1,[r0]
	
	bl clearBG0
	bl drawAllEnergyBars

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

		
		bl checkWave		@ check if time for another alien attack
		bl moveAliens		@ move the aliens and detect colisions with you

		bl initHunterMine	@ check if we should chuck another mine or hunter into the mix

		bl drawSprite		@ drawsprites and do update bloom effect

		bl scrollMain		@ Scroll Level Data
		bl scrollSub		@ Main + Sub
		bl levelDrift		@ update level with the horizontal drift
		bl scrollStars		@ Scroll Stars (BG2,BG3)		
		bl checkEndOfLevel	@ Set Flag for end-of-level (use later to init BOSS)



@		bl drawDebugText	@ draw some numbers :)


	ldr r0, =energyText				@ Load out text pointer
	ldr r1, =0						@ x pos
	ldr r2, =0						@ y pos
	ldr r3, =1						@ Draw on Sub screen
	bl drawText
		
	ldr r10,=energy					@ Pointer to data
	ldr r10,[r10]					@ Read value
	mov r8,#0						@ y pos
	mov r9,#2						@ Number of digits
	mov r11,#7						@ x pos
	bl drawDigits					@ Draw

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
	
	ldr r0, =youDiedText			@ Load out text pointer
	ldr r1, =6						@ x pos
	ldr r2, =10						@ y pos
	ldr r3, =1						@ Draw on main screen
	bl drawText
	
	stopit:
	b stopit

@------------------------------------------------------------------------------



