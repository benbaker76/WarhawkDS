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
#include "windows.h"

	.arm
	.align
	.text
	.global fxTextScrollerOn
	.global fxTextScrollerOff
	.global fxTextScrollerVBlank
	.global fxVertTextScrollerOn
	.global fxVertTextScrollerOff
	.global fxVertTextScrollerVBlank

fxTextScrollerOn:

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_TEXT_SCROLLER
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT
	ldr r1, [r0]
	orr r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
	ldr r2, =WIN_IN							@ Make bgs appear inside the window
	ldr r3, [r2]
	orr r3, #(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]
	
	ldr r2, =WIN_OUT						@ Make bgs appear inside the window
	mov r3, #(WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]
	
	ldr r2, =WIN0_Y0						@ Top pos
	ldr r3, =0
	strb r3, [r2]
	
	ldr r2, =WIN0_Y1						@ Bottom pos
	ldr r3, =192
	strb r3, [r2]
	
	ldr r2, =WIN0_X0						@ Top pos
	ldr r3, =8
	strb r3, [r2]
	
	ldr r2, =WIN0_X1						@ Bottom pos
	ldr r3, =248
	strb r3, [r2]
	
	ldr r0, =textPos
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =scrollPos
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =ofsScroll
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =REG_BG0HOFS
	mov r1, #0
	strh r1, [r0]
	
	ldmfd sp!, {r0-r3, pc}

	@ ---------------------------------------
	
fxTextScrollerOff:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	bic r1, #FX_TEXT_SCROLLER
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT
	ldr r1, [r0]
	bic r1, #DISPLAY_WIN0_ON
	str r1, [r0]
	
	ldr r0, =WIN_IN
	mov r1, #0
	strh r1, [r0]
	
	ldr r0, =REG_BG0HOFS
	mov r1, #0
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}

	@ ---------------------------------------
	
fxTextScrollerVBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =hscrollText
	ldr r1, =textPos
	ldr r2, [r1]
	add r0, r2
	ldrb r2, [r0]
	mov r3, #0
	cmp r2, #0
	streq r3, [r1]
	
	ldr r1, =scrollPos
	ldr r1, [r1]
	ldr r2, =23									@ y pos
	ldr r3, =0									@ Draw on sub screen
	ldr r4, =1									@ Maximum number of characters
	bl drawTextCount
	
	ldr r0, =ofsScroll
	ldr r1, [r0]
	ldr r2, =textPos
	ldr r3, [r2]
	ldr r4, =scrollPos
	ldr r5, [r4]
	add r1, #1
	ldr r6, =0x7
	and r6, r1
	cmp r6, #0
	addeq r3, #1
	addeq r5, #1
	and r5, #0x1F
	ldr r6, =REG_BG0HOFS
	str r3, [r2]
	str r5, [r4]
	strh r1, [r6]
	strh r1, [r0]
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
fxVertTextScrollerOn:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	orr r1, #FX_VERTTEXT_SCROLLER
	str r1, [r0]
	
	ldr r0, =textPos
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =scrollPos
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =ofsScroll
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =REG_BG0VOFS
	mov r1, #0
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}

	@ ---------------------------------------
	
fxVertTextScrollerOff:

	stmfd sp!, {r0-r1, lr}
	
	ldr r0, =fxMode
	ldr r1, [r0]
	bic r1, #FX_VERTTEXT_SCROLLER
	str r1, [r0]
	
	ldr r0, =REG_BG0VOFS
	mov r1, #0
	strh r1, [r0]
	
	ldmfd sp!, {r0-r1, pc}

	@ ---------------------------------------
	
fxVertTextScrollerVBlank:

	stmfd sp!, {r0-r6, lr}
	
	ldr r0, =vscrollText
	ldr r1, =textPos
	ldr r2, [r1]
	add r0, r2, lsl #5
	ldrb r2, [r0]
	cmp r2, #0
	streq r2, [r1]
	
	ldr r1, =ofsScroll
	ldr r1, [r1]
	tst r1, #(0xF-1)
	bne fxVertTextScrollerVBlankContinue
	
	ldr r1, =0									@ x pos
	ldr r2, =scrollPos
	ldr r2, [r2]
	add r2, #24									@ y pos
	and r2, #0x1F
	ldr r3, =0									@ Draw on sub screen
	ldr r4, =32									@ Maximum number of characters
	bl drawTextCount
	
fxVertTextScrollerVBlankContinue:
	
	ldr r0, =ofsScroll
	ldr r1, [r0]
	ldr r2, =textPos
	ldr r3, [r2]
	ldr r4, =scrollPos
	ldr r5, [r4]

	ldr r6, =ofsScrollDelay
	ldr r7,[r6]
	subs r7,#1
	movmi r7,#2
	str r7,[r6]
	bpl fxVertTextScrollerVBlankContinueNot
	add r1, #1
	
	ldr r6, =0xF
	and r6, r1
	tst r6, #0xF
	addeq r3, #1
	tst r6, #0x7
	addeq r5, #1
	ldr r6, =REG_BG0VOFS
	str r3, [r2]
	str r5, [r4]
	strh r1, [r6]
	strh r1, [r0]

fxVertTextScrollerVBlankContinueNot:
	
	ldmfd sp!, {r0-r6, pc}

	@ ---------------------------------------
	
	.data
	.align
	
textPos:
	.word 0

scrollPos:
	.word 0
	
ofsScroll:
	.word 0
	
ofsScrollDelay:
	.word 0
	
	.align
hscrollText:
	.ascii "WELCOME TO WARHAWK DS... THIS GAME IS THE FIRST OF SEVERAL (HOPEFULLY) GAMES TO BE RELEASED BY THE HEADSOFT/PROTEUS DEVELOPMENTS COLLABORATION.    "
	.ascii "THIS IS A REMAKE OF AN OLD COMMODORE 64 GAME FROM WAY BACK IN THE YEAR OF 1986. THE ORIGINAL GAME WAS CREATED BY FLASH (MYSELF), BADTOAD, AND ANDREW BETTS. "
	.ascii "ANDREW BETTS IS NO LONGER PART OF PROTEUS DEVELOPMENTS AND IS BEST NOT MENTIONED, OTHER THAN TO SAY THAT HE GOT A CONTRACT SIGNED IN HIS OWN NAME FOR "
	.ascii "WARHAWK AND APART FROM SHARING THE FIRST ROYALTY PAYMENT, FLIPPED BADTOAD AND MYSELF THE FINGER AND SODDED OFF WITH THE MONEY... GIT! (WHERE IS HE NOW ? ? ? ? ?)           "
	.ascii "THIS IS A PROJECT THAT WAS STARTED BY MYSELF AND HK, AND HAD PRESENTED US WITH SEVERAL PROBLEMS. APART FROM THE EMBEDDED FILE SYSTEM, THE ENTIRE GAME IS WRITTEN "
	.ascii "IN OLD SCHOOL ASSEMBLY LANGUAGE - QUITE AN ACHIEVEMENT ON THE DS.... SO, HERE IT IS AND WE HOPE IT GIVES YOU AS MUCH PLEASURE AS IT HAS DONE US TO CREATE IT!          "
	.ascii "I WILL HAND THE KEYBOARD OVER TO HK, TAKE IT AWAY MR HK.....        "
	.ascii "THANKS FLASH.. HEADKAZE HERE... WELL AFTER SEVERAL MONTHS OF DEVELOPMENT HERE IS THE RESULT AND WE HOPE YOU ENJOY PLAYING THIS RETRO SHMUP CALLED WARHAWK. IT'S BEEN FUN "
	.ascii "CODING THIS IN ARM ASM AND WORKING WITH FLASH, LOBO AND SPACE FRACTAL. WE PLAN ON (RE)MAKING A COUPLE MORE GAMES IN THE NEAR FUTURE AND THEN HOPE TO MOVE INTO MOBILE DEV... "
	.ascii "JUST A FEW GREETZ TO SOME OLD FRIENDS IN THE SCENE ... LIRANUNA, CHISHM, BLASTY, GPF, NATRIUM42, STRAGER, LYNX, OMEGAS, NIKOLAS, CREDIAR, ANDREW67, DYNASTAB, OXTOB ... "
	.ascii "AND ALL ON #TOD2 / EFNET ... STAY TUNED FOR OUR NEXT RELEASE! ......     NOW OVER TO LOBO........               "
	.ascii "LOOKS LIKE IT IS MY TURN...   IT WAS A PLEASURE WORKING WITH HK AND THE GRANDPA WHO MADE THE ORIGINAL BACK IN THE DAY, WHEN I WAS 12. HOPEFULLY WHEN I AM 64, LIKE THEM, "
	.ascii "I'LL ALSO GET TO WORK WITH YOUNG BLOOD TOO, AND DRINK THEIR BLOOD JUST LIKE THESE GUYS DID TO ME...   HELLO TO SMEALUM, MY FRIEND, I DIDN'T FORGET YA ;)                              "
	.asciz ""

	.align
vscrollText:
	.ascii "          -WARHAWK DS-          "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "        -ASM PROGRAMMING-       "
	.ascii "                                "
	.ascii "              FLASH             "
	.ascii "            HEADKAZE            "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "           -GRAPHICS-           "
	.ascii "                                "
	.ascii "              LOBO              "
	.ascii "             BADTOAD            "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "            -MUSIC-             "
	.ascii "                                "
	.ascii "   PRESS PLAY ON TAPE (TITLE)   "
	.ascii "     SPACE FRACTAL (IN GAME)    "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "         -PLAY TESTING-         "
	.ascii "                                "
	.ascii "  LOBO, SPACEFRACTAL, SOKURAH,  "
	.ascii "    BAZ, JACK, MARTYN CARROL    "
	.ascii "     BADTOAD, MARK NICHOLLS     "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "     -ORIGINAL C64 VERSION-     "
	.ascii "                                "
	.ascii "FLASH, BADTOAD, AND ANDREW BETTS"
	.ascii " (THE ORDER IS VERY ACCIDENTAL) "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "WE WOULD LIKE TO PASS THANKS TO "
	.ascii " A FEW PEOPLE THAT HAVE HELPED  "
	.ascii "        US ALONG THE WAY        "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "    WINTERMUTE FOR DEVKITARM    "
	.ascii "        CHISHM FOR LIBFAT       "
	.ascii " MARTIN KOTH FOR DSTEK & NO$GBA "
	.ascii " ERIS & NODA FOR EFS / NITROFS  "
	.ascii "      DARKFADER FOR NDSTOOL     "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "LIRANUNA, BLASTY, CEARN, DOVOTO,"
	.ascii "JOAT, DEKUTREE, ELHOBBS, RUBEN, "
	.ascii "SIMONB, DARKCLOUD...            "
	.ascii "                                "
	.ascii "                                "
	.ascii " ... AND EVERYONE ON GBADEV.ORG "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii " GREETS TO ALL ON #TOD2 / EFNET "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "\0"
	
	.pool
	.end
