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
	.global initLevel
	.global initLevelSprites
	.global initMainTiles
	.global initLevelScrollRegisters
	
initLevel:

	stmfd sp!, {r0-r9, lr}
	
	bl fxFadeBlackInit
	bl fxFadeMax
	bl clearSpriteData

	mov r1,#0
	ldr r0,=levelEnd
	str r1,[r0]				@ Flag is SET for end of level	
	ldr r0,=waveNumber
	str r1,[r0]				@ make sure we always start at wave 0
	ldr r0,=bossMan
	str r1,[r0]				@ turn the Boss attack Off!!
	ldr r0,=animFrame		
	str r1,[r0]				@ reset anim frames
	ldr r0,=firePress
	str r1,[r0]
	ldr r0,=basesLeft
	str r1,[r0]				@ reset the base counter (count later)
	ldr r0,=basesShot
	str r1,[r0]
	ldr r0,=deathMode
	str r1,[r0]
	ldr r0,=deathModeDelay
	str r1,[r0]
	ldr r0,=animEnergyActive
	str r1,[r0]				@ turn off the energy bar flash
	ldr r0,=powerUp
	str r1,[r0]
	ldr r0,=mineTimerCounter
	str r1,[r0]
	ldr r0,=hunterTimerCounter
	str r1,[r0]
	ldr r0,=shipAnimDelay
	str r1,[r0]
	ldr r0,=bigBossMode
	str r1,[r0]
	
	@ set scroller data
	ldr r0,=pixelOffsetSub
	str r1,[r0]
	ldr r0,=pixelOffsetMain
	str r1,[r0]	
	mov r1,#256+32
	ldr r0,=vofsMain
	str r1,[r0]
	ldr r0,=vofsSub
	str r1,[r0]
	mov r1,#3744			@ 3968 - 192 - 32
	ldr r0,=yposMain
	str r1,[r0]
	ldr r0,=yposSub
	str r1,[r0]

	mov r0,#0
	ldr r1,=pixelOffsetSFSub
	str r0,[r1]
	ldr r1,=pixelOffsetSFMain
	str r0,[r1]
	ldr r1,=pixelOffsetSBSub
	str r0,[r1]
	ldr r1,=pixelOffsetSBMain
	str r0,[r1]

	mov r0,#256
	ldr r1,=vofsSFMain
	str r0,[r1]
	ldr r1,=vofsSBMain
	str r0,[r1]
	ldr r1,=vofsSFSub
	str r0,[r1]
	ldr r1,=vofsSBSub
	str r0,[r1]

	mov r0,#736
	ldr r1,=yposSFMain
	str r0,[r1]
	ldr r1,=yposSBMain
	str r0,[r1]
	ldr r1,=yposSFSub
	str r0,[r1]
	ldr r1,=yposSBSub
	str r0,[r1]

	@ reset the BOSS stuff
	mov r0,#0
	ldr r1,=bossXDelay
	str r0,[r1]
	ldr r1,=bossYDelay
	str r0,[r1]
	ldr r1,=bossXDir
	str r0,[r1]
	ldr r1,=bossMan
	str r0,[r1]
	ldr r1,=explodeSpriteBossCount
	str r0,[r1]
	
	mov r0,#2
	ldr r1,=delaySF
	str r0,[r1]
	mov r0,#4
	ldr r1,=delaySB
	str r0,[r1]

	mov r1,#200
	ldr r0,=delayPowerUp
	str r1,[r0]

	ldr r0,=horizDrift
	mov r1,#32
	strb r1,[r0]			@ Drift on levels horizontal - centre to start level
	
	ldr r0,=energy
	mov r1,#71
@mov r1,#2048
	str r1,[r0]				@ set energy to full
	
	ldr r0,=animDelay
	mov r1,#3
	str r1,[r0]				@ set the anim to start on first call
	
	@ we NEED to copy colmapX to a place in ram to modify it, otherwise
	@ when we come back to play the level - the bases will still be destroyed
	@ from that last time!
	
	@ so, copy from colmap (r9)
	@ we will set the colmap in r9 here
	
	ldr r8,=levelNum
	ldr r8,[r8]
	cmp r8,#LEVEL_1
	bne level2
							@ Set level 1
		ldr r0,=Level1Map
		ldr r1,=levelMap
		str r0,[r1]
		
		ldr r0,=Level1Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level1TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap1
		
		ldr r0,=Level1Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal1
		ldr r1,=starBackPal
		str r0,[r1]
		
		
	level2:
	cmp r8,#LEVEL_2
	bne level3
							@ Set level 2
		ldr r0,=Level2Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level2Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level2TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap2
		
		ldr r0,=Level2Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal2
		ldr r1,=starBackPal
		str r0,[r1]

	level3:
	cmp r8,#LEVEL_3
	bne level4
							@ Set level 3
		ldr r0,=Level3Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level3Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level3TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap3
		
		ldr r0,=Level3Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal3
		ldr r1,=starBackPal
		str r0,[r1]
	
	level4:
	cmp r8,#LEVEL_4
	bne level5
							@ Set level 4
		ldr r0,=Level4Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level4Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level4TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap4

		ldr r0,=Level4Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal1
		ldr r1,=starBackPal
		str r0,[r1]
		
	level5:
	cmp r8,#LEVEL_5
	bne level6
							@ Set level 5
		ldr r0,=Level5Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level5Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level5TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap5

		ldr r0,=Level5Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal2
		ldr r1,=starBackPal
		str r0,[r1]
		
	level6:
	cmp r8,#LEVEL_6
	bne level7
							@ Set level 6
		ldr r0,=Level6Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level6Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level6TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap6

		ldr r0,=Level6Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal3
		ldr r1,=starBackPal
		str r0,[r1]

	level7:
	cmp r8,#LEVEL_7
	bne level8
							@ Set level 7
		ldr r0,=Level7Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level7Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level7TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap7
		
		ldr r0,=Level7Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal1
		ldr r1,=starBackPal
		str r0,[r1]
	
	level8:
	cmp r8,#LEVEL_8
	bne level9
							@ Set level 8
		ldr r0,=Level8Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level8Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level8TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap8

		ldr r0,=Level8Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal2
		ldr r1,=starBackPal
		str r0,[r1]
	
	level9:
	cmp r8,#LEVEL_9
	bne level10
							@ Set level 9
		ldr r0,=Level9Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level9Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level9TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap9
	
		ldr r0,=Level9Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal3
		ldr r1,=starBackPal
		str r0,[r1]
		
	level10:
	cmp r8,#LEVEL_10
	bne level11
							@ Set level 10
		ldr r0,=Level10Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level10Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level10TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap10
	
		ldr r0,=Level10Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal1
		ldr r1,=starBackPal
		str r0,[r1]
		
	level11:
	cmp r8,#LEVEL_11
	bne level12
							@ Set level 11
		ldr r0,=Level11Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level11Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level11TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap11

		ldr r0,=Level11Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal2
		ldr r1,=starBackPal
		str r0,[r1]

	level12:
	cmp r8,#LEVEL_12
	bne level13
							@ Set level 12
		ldr r0,=Level12Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level12Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level12TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap12

		ldr r0,=Level12Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal3
		ldr r1,=starBackPal
		str r0,[r1]
	level13:
	cmp r8,#LEVEL_13
	bne level14
							@ Set level 13
		ldr r0,=Level13Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level13Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level13TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap13

		ldr r0,=Level13Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal1
		ldr r1,=starBackPal
		str r0,[r1]	
	level14:
	cmp r8,#LEVEL_14
	bne level15
							@ Set level 14
		ldr r0,=Level14Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level14Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level14TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap14

		ldr r0,=Level14Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal2
		ldr r1,=starBackPal
		str r0,[r1]
	level15:
	cmp r8,#LEVEL_15
	bne level16
							@ Set level 15
		ldr r0,=Level15Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level15Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level15TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap15

		ldr r0,=Level15Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal3
		ldr r1,=starBackPal
		str r0,[r1]		

	level16:
	cmp r8,#LEVEL_16
	bne levelDone
							@ Set level 16
		ldr r0,=Level16Map
		ldr r1,=levelMap
		str r0,[r1]

		ldr r0,=Level16Tiles
		ldr r1,=levelTiles
		str r0,[r1]
		
		ldr r0,=Level16TilesLen
		ldr r1,=levelTilesLen
		str r0,[r1]
		
		ldr r9,=colMap16

		ldr r0,=Level16Pal
		ldr r1,=levelPal
		str r0,[r1]
		
		ldr r0,=StarBackPal1
		ldr r1,=starBackPal
		str r0,[r1]
			
	levelDone:
	
	@ ok, using r9 as source, copy data to colMapStore
	@ and if we find a non-zero value, add to basesLeft
	
	mov r3,#0					@ base count
	ldr r1,=colMapStore			@ location for data
	ldr r0,=1984				@ out counter (size of colmap in bytes)
		colMapFill:
		ldrb r2,[r9,r0]
		cmp r2,#0				@ is it non-zero
		addne r3,#1				@ if so, add to base count
		strb r2,[r1,r0]

	subs r0,#1
	bpl colMapFill
	
	ldr r1,=basesLeft
	str r3,[r1]					@ store the numbers of bases on the level

		@ Load the palette into the palette subscreen area and main

		ldr r0, =levelPal
		ldr r0,[r0]
		ldr r1, =BG_PALETTE
		ldr r2, =512
		bl dmaCopy
		mov r3, #0
		strh r3, [r1]
		ldr r1, =BG_PALETTE_SUB
		bl dmaCopy
		strh r3, [r1]
		
		@ Load the star back palette

		ldr r0, =starBackPal
		ldr r0,[r0]
		ldr r1, =BG_PALETTE
		ldr r2, =32
		bl dmaCopy
		mov r3, #0
		strh r3, [r1]
		ldr r1, =BG_PALETTE_SUB
		bl dmaCopy
		strh r3, [r1]

		@ Write the tile data to VRAM Level BG1

		ldr r0,=levelTiles
		ldr r0,[r0]
		ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
		ldr r2, =levelTilesLen
		ldr r2, [r2]
		bl dmaCopy
		ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
		bl dmaCopy
	
		bl showLevelStart

	ldmfd sp!, {r0-r9, pc}

	@ ------------------------------------

initLevelSprites:

	stmfd sp!, {r0-r1, lr}
	
	mov r1, #1
	ldr r0,=spriteActive
	str r1,[r0]				@ make sure our ship is visible
	ldr r0,=fireTrap
	str r1,[r0]
	mov r1, #0
	ldr r0,=firePress
	str r1,[r0]				@ Set fire press so fire to start does not fire a bullet

	mov r1,#176
	ldr r0,=spriteX
	str r1,[r0]				@ our ships initial X coord
	mov r1,#716
	ldr r0,=spriteY
	str r1,[r0]				@ our ships initial Y coord
	
	bl initLevelSpecialSprites
	
	@ now we need to add special explosions!	
	
	ldmfd sp!, {r0-r1, pc}
	
	@ ------------------------------------

initLevelSpecialSprites:

	stmfd sp!, {r0-r8, lr}
	
	@ Restore original Explosions
	ldr r0, =ExplodeOriginalTiles
	ldr r2, =ExplodeOriginalTilesLen	
	ldr r1, =SPRITE_GFX
	add r1, #6*512
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
	add r1, #6*512
	bl dmaCopy	

	ldr r8,=levelNum
	ldr r8,[r8]
	cmp r8,#1
	ldreq r0, =SpritesLev1Tiles
	ldreq r2, =SpritesLev1TilesLen
	cmp r8,#2
	ldreq r0, =SpritesLev2Tiles
	ldreq r2, =SpritesLev2TilesLen
	cmp r8,#3
	ldreq r0, =SpritesLev3Tiles
	ldreq r2, =SpritesLev3TilesLen
	cmp r8,#4
	ldreq r0, =SpritesLev4Tiles
	ldreq r2, =SpritesLev4TilesLen
	cmp r8,#5
	ldreq r0, =SpritesLev5Tiles
	ldreq r2, =SpritesLev5TilesLen
	cmp r8,#6
	ldreq r0, =SpritesLev6Tiles
	ldreq r2, =SpritesLev6TilesLen
	cmp r8,#7
	ldreq r0, =SpritesLev7Tiles
	ldreq r2, =SpritesLev7TilesLen
	cmp r8,#8
	ldreq r0, =SpritesLev8Tiles
	ldreq r2, =SpritesLev8TilesLen
	cmp r8,#9
	ldreq r0, =SpritesLev9Tiles
	ldreq r2, =SpritesLev9TilesLen
	cmp r8,#10
	ldreq r0, =SpritesLev10Tiles
	ldreq r2, =SpritesLev10TilesLen
	cmp r8,#11
	ldreq r0, =SpritesLev11Tiles
	ldreq r2, =SpritesLev11TilesLen
	cmp r8,#12
	ldreq r0, =SpritesLev12Tiles
	ldreq r2, =SpritesLev12TilesLen
	cmp r8,#13
	ldreq r0, =SpritesLev13Tiles
	ldreq r2, =SpritesLev13TilesLen
	cmp r8,#14
	ldreq r0, =SpritesLev14Tiles
	ldreq r2, =SpritesLev14TilesLen	
	cmp r8,#15
	ldreq r0, =SpritesLev15Tiles
	ldreq r2, =SpritesLev15TilesLen
	cmp r8,#16
	ldreq r0, =SpritesLev16Tiles
	ldreq r2, =SpritesLev16TilesLen	
	ldr r1, =SPRITE_GFX
	add r1, #21504
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
	add r1, #21504
	bl dmaCopy
	
	
	cmp r8,#14
	bne noSkulls
		ldr r0, =ExplodeSkullTiles
		ldr r2, =ExplodeSkullTilesLen	
		ldr r1, =SPRITE_GFX
		add r1, #6*512
		bl dmaCopy
		ldr r1, =SPRITE_GFX_SUB
		add r1, #6*512
		bl dmaCopy
	noSkulls:
	cmp r8,#16
	bne noRings
		ldr r0, =ExplodeRingTiles
		ldr r2, =ExplodeRingTilesLen	
		ldr r1, =SPRITE_GFX
		add r1, #6*512
		bl dmaCopy
		ldr r1, =SPRITE_GFX_SUB
		add r1, #6*512
		bl dmaCopy
	noRings:	
	bl playDinkDinkSound
	
	ldmfd sp!, {r0-r8, pc}
	
	@ ------------------------------------

initMainTiles:

	stmfd sp!, {r0-r2, lr}
	
	bl DC_FlushAll
	
	@ Write the tile data to VRAM FrontStar BG2

	ldr r0, =StarFrontTiles
	ldr r1, =BG_TILE_RAM(BG2_TILE_BASE)
	ldr r2, =StarFrontTilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(BG2_TILE_BASE_SUB)
	bl dmaCopy

	@ Write the tile data to VRAM BackStar BG3

	ldr r0, =StarBackTiles
	ldr r1, =BG_TILE_RAM(BG3_TILE_BASE)
	add r1, #StarFrontTilesLen
	ldr r2, =StarBackTilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
	add r1, #StarFrontTilesLen
	bl dmaCopy

	ldr r0, =ScoreTiles
	ldr r1, =BG_TILE_RAM(BG0_TILE_BASE)
	ldr r2, =ScoreTilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	bl dmaCopy
	
	ldr r0, =FontTiles
	ldr r1, =BG_TILE_RAM(BG0_TILE_BASE)
	add r1, #ScoreTilesLen
	ldr r2, =FontTilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	add r1, #ScoreTilesLen
	bl dmaCopy
	
	ldr r0, =EnergyTiles
	ldr r1, =BG_TILE_RAM(BG0_TILE_BASE)
	add r1, #(ScoreTilesLen + FontTilesLen)
	ldr r2, =EnergyTilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(BG0_TILE_BASE_SUB)
	add r1, #(ScoreTilesLen + FontTilesLen)
	bl dmaCopy
	
	ldmfd sp!, {r0-r2, pc}
	
	@ ------------------------------------
	
initLevelScrollRegisters:

	stmfd sp!, {r0-r6, lr}

	@ Our horizontal centre routine
	
	ldr r0, =REG_BG1HOFS			@ Load our horizontal scroll register for BG1 on the main screen
	ldr r1, =REG_BG1HOFS_SUB		@ Load our horizontal scroll register for BG1 on the sub screen
	ldr r2, =REG_BG2HOFS			@ Load our horizontal scroll register for BG2 on the main screen
	ldr r3, =REG_BG2HOFS_SUB		@ Load our horizontal scroll register for BG2 on the sub screen
	ldr r4, =REG_BG3HOFS			@ Load our horizontal scroll register for BG3 on the main screen
	ldr r5, =REG_BG3HOFS_SUB		@ Load our horizontal scroll register for BG3 on the sub screen
	mov r6, #32						@ Offset the horizontal scroll register by 32 pixels to centre the map
	strh r6, [r0]					@ Write our offset value to REG_BG1HOFS
	strh r6, [r1]					@ Write our offset value to REG_BG1HOFS_SUB
	mov r6, #0
	strh r6, [r2]					@ Write our offset value to REG_BG2HOFS
	strh r6, [r3]					@ Write our offset value to REG_BG2HOFS_SUB
	strh r6, [r4]					@ Write our offset value to REG_BG3HOFS
	strh r6, [r5]					@ Write our offset value to REG_BG3HOFS_SUB
		
	@ Our vertical scrolling routine

	ldr r0, =REG_BG1VOFS			@ Load our vertical scroll register for BG1 on the main screen
	ldr r2, =vofsMain				@ Set our scroll counter to start main screen
	ldrh r2, [r2]
	strh r2, [r0]					@ Load the value into the scroll register

	ldr r0, =REG_BG1VOFS_SUB		@ Load our vertical scroll register for BG1 on the sub screen
	ldr r2, =vofsSub				@ Set our scroll counter to start sub screen
	ldrh r2, [r2]
	strh r2, [r0]					@ Load the value into the scroll register
	
	ldr r0, =REG_BG2VOFS			@ Load our vertical scroll register for BG2 on the main screen
	ldr r2, =vofsSFMain				@ Set our scroll counter to start main screen
	ldrh r2, [r2]
	strh r2, [r0]					@ Load the value into the scroll register

	ldr r0, =REG_BG2VOFS_SUB		@ Load our vertical scroll register for BG2 on the sub screen
	ldr r2, =vofsSFSub				@ Set our scroll counter to start sub screen
	ldrh r2, [r2]
	strh r2, [r0]					@ Load the value into the scroll register

	ldr r0, =REG_BG3VOFS			@ Load our vertical scroll register for BG3 on the main screen
	ldr r2, =vofsSBMain				@ Set our scroll counter to start main screen
	ldrh r2, [r2]
	strh r2, [r0]					@ Load the value into the scroll register

	ldr r0, =REG_BG3VOFS_SUB		@ Load our vertical scroll register for BG3 on the sub screen
	ldr r2, =vofsSBSub				@ Set our scroll counter to start sub screen
	ldrh r2, [r2]
	strh r2, [r0]
	
	ldmfd sp!, {r0-r6, pc}
	
	@ ------------------------------------

clearSpriteData:

	stmfd sp!, {r0-r3, lr}
	
	ldr r0, =spriteDataStart
	ldr r1, =spriteDataEnd								@ Get the sprite data end
	ldr r2, =spriteDataStart							@ Get the sprite data start
	sub r1, r2											@ sprite end - start = size
	bl DC_FlushRange
	
	mov r0, #0
	ldr r1, =spriteDataStart
	ldr r2, =spriteDataEnd								@ Get the sprite data end
	ldr r3, =spriteDataStart							@ Get the sprite data start
	sub r2, r3											@ sprite end - start = size
	bl dmaFillWords	

	ldmfd sp!, {r0-r3, pc}
	
	@ ------------------------------------

	.pool
	.end