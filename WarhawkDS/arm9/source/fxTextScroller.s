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
	
	ldr r2, =WIN_IN							@ Make bg's appear inside the window
	ldr r3, [r2]
	orr r3, #(WIN0_BG0 | WIN0_BG1 | WIN0_BG2 | WIN0_BG3 | WIN0_SPRITES | WIN0_BLENDS)
	strh r3, [r2]
	
	ldr r2, =WIN_OUT						@ Make bg's appear inside the window
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
	movmi r7,#1
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
	.asciz "WELCOME TO WARHAWK DS... THIS GAME IS THE FIRST OF SEVERAL (HOPEFULLY) GAMES TO BE RELEASED BY THE HEADSOFT/PROTEUS DEVELOPMENTS COLLABIRATION, WE HAVE A COUPLE OF PROJECTS LINED UP AND PERHAPS ALSO SOME MOBILE PHONE GAMES TO WORK ON... wHO KNOWS!:)   wHEN IT COMES TO 'WARHAWK' WELL, WHERE DO WE START,?? THIS IS A REMAKE OF AN OLD COMMODORE 64 GAME FROM WAY BACK IN THE YEAR OF 1986. THE ORIGINAL GAM WAS CREATED BY FLASH, BADTOAD, AND BETTS. BETTS IS BEST LEFT OUT OF THE EQUATION AS HE GOT THE CONTRACT SIGNED WITH FIREBIRD BEHIND OUR BACKS AND WITHOUT NOTIFICATION. AND SOMEWHERE ALONG THE LINE, HE ALSO FORGOT ME AND BADTOAD WHEN IT CAME TO ROYALTIES. WE RECIEVED NOTHING OTHERE THAN THE ORIGINAL ROYALTY PAYMENT. NOTHING!! SO, POOT BADTOAD AND I HAD 6 MONTHS OF WORK STOLEN FROM US! BETTS, IF YOU EVER READ THIS AND GET THE HUMP 'YOU THEIVING BASTARD' WE ARE HAPPY TO GO TO COURT, SO - YOU ARE WELCOME.. I CAN AFFORD IT :)... ANYWAY, THIS IS A PROJECT THAT WAS STARTED BY MYSELF AND HK OVER 4 MONTHS AGO, AND HAS PRESENTED US WITH SEVERAL PROBLEMS. APART FROM THE EMBEDDED FILE SYSTEM, THE ENTIRE GAME IS WITTEN IN OLD SCHOOL ASSEMBLER - QUITE AND ACIVEMENT ON THE DS.... SO, HERE IT IS AND WE HOPE IT GIVES YOU AS MUCH PLEASURE AS IT HAS DONE US TO CREATE IT!              "
	
	.align
vscrollText:
	.ascii "         - WARHAWK DS -         "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "       -ASM  PROGRAMMING-       "
	.ascii "                                "
	.ascii "             FLASH!             "
	.ascii "            HEADKAZE            "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "           -GRAPHICS-           "
	.ascii "                                "
	.ascii "              LOBO              "
	.ascii "          BIG  BADTOAD          "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "            -MUSIC-             "
	.ascii "                                "
	.ascii "       PRESS PLAY ON TAPE       "
	.ascii "         SPACE  FRACTAL         "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "-DEVELOPMENT ENVIRONMENT TWEAKS-"
	.ascii "                                "
	.ascii "            HEADKAZE            "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "         -WINE TASTING-         "
	.ascii "                                "
	.ascii "             FLASH!             "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "         -PLAY TESTING-         "
	.ascii "                                "
	.ascii "  LOBO, SPACEFRACTAL, SOKURAH,  "
	.ascii "BAZ, JACK, ?????????????????????"
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
	.ascii "WE WOULD LIKE TO PASS THANKS TO "
	.ascii " A FEW PEOPLE THAT HAVE HELPED  "
	.ascii "        US ALONG THE WAY        "
	.ascii "                                "
	.ascii "    WINTERMUTE FOR DEVKITARM    "
	.ascii "        CHISHM FOR LIBFAT       "
	.ascii "                                "
	.ascii "BLASTY, CEARN, DEKUTREE, ELHOBBS"
	.ascii "RUBEN, SIMONB                   "
	.ascii "... AND EVERYONE ON GBADEV.ORG  "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "          -GREETINGS-           "
	.ascii "                                "
	.ascii "  LIRANUNA, CHISHM, NATRIUM42,  "
	.ascii "  BLASTY, GPF, STRAGER, LYNX,   "
	.ascii "   OMEGAS, NIKOLAS, CREDIAR,    "
	.ascii "       DYNASTAB, OXTOB...       "
	.ascii " ... AND ALL ON #TOD @ EFNET    "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "                                "
	.ascii "\0"
	
	.pool
	.end
