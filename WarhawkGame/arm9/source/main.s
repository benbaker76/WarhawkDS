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
	.global initSystem
	.global main
	.global debugDigits
	.global randomNumber

initSystem:
	bx lr

main:
	bl gameStop
	bl initData								@ setup actual game data
	
	@ Setup the screens and the sprites	
	
bl waitforVblank	@ We need to set up a wipe here and clear it later / but for now, this will just make it CLEAN
	bl initVideo
	bl initLevel
	bl initInterruptHandler					@ initialize the interrupt handler
	bl initSprites
	bl initLevelSprites
	
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
	
	@ Fade in
	
	@bl fxSpotlightIn
	bl fxFadeBlackIn
	bl fxMosaicIn
	@bl fxScanline
	@bl fxWipeInLeft
	@bl fxCrossWipe
	@bl fxSineWobbleOn

	bl waitforFire		@ wait for a short while to start game
	mov r1,#1			@ just for checking (though this would NEVER be active at level start)
	ldr r0,=powerUp
@	str r1,[r0]
	
	bl clearBG0
	
	bl gameStart
	
gameLoop:


	bl swiWaitForVBlank

	b gameLoop			@ our main loop
	
@------------------------------------------------------------------------------

	.pool
	.end
