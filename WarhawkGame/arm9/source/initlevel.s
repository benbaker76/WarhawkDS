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
	
initLevel:

	mov r1,#0
	ldr r0,=levelEnd
	str r1,[r0]				@ Flag is SET for end of level	
	ldr r0,=powerUp
	str r1,[r0]				@ set to one for autofire
	ldr r0,=powerUpDelay
	str r1,[r0]				@ clear the fire delay
	ldr r0,=waveNumber
	str r1,[r0]				@ make sure we always start at wave 0
	ldr r0,=bossMan
	str r1,[r0]				@ turn the Boss attack Off!!
	ldr r0,=animFrame		
	str r1,[r0]				@ reset anim frames

	ldr r0,=firePress
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



	ldr r0,=horizDrift
	mov r1,#32
	strb r1,[r0]			@ Drift on levels horizontal - centre to start level
	
	ldr r0,=energy
	mov r1,#71
	str r1,[r0]				@ set energy to full
	
	ldr r0,=animDelay
	mov r1,#3
	str r1,[r0]				@ set the anim to start on first call
	
	
	ldr r0,=levelEnd
	mov r1,#0				@ make 1 for TEST
	str r1,[r0]
	ldr r0,=bossMan
	str r1,[r0]				@ comment out for boss test!!!!
	
	
	
	ldr r8,=level
	ldr r8,[r8]
	cmp r8,#1
	bne level2
							@ Set level 1
		ldr r0,=Level1Map
		ldr r1,=LevelMap
		str r0,[r1]
		
		ldr r0,=Level1Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap1
		ldr r1,=collideMap
		str r0,[r1]
		
		ldr r0,=Level1Pal
		ldr r1,=StarBack
		str r0,[r1]
		
		
	level2:
	cmp r8,#2
	bne level3
							@ Set level 2
		ldr r0,=Level2Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level2Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap2
		ldr r1,=collideMap
		str r0,[r1]
		
		ldr r0,=Level2Pal
		ldr r1,=StarBack
		str r0,[r1]

	level3:
	cmp r8,#3
	bne level4
							@ Set level 3
		ldr r0,=Level3Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level3Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap3
		ldr r1,=collideMap
		str r0,[r1]
		
		ldr r0,=Level3Pal
		ldr r1,=StarBack
		str r0,[r1]
	
	level4:
	cmp r8,#4
	bne level5
							@ Set level 4
		ldr r0,=Level4Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level4Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap4
		ldr r1,=collideMap
		str r0,[r1]

		ldr r0,=Level4Pal
		ldr r1,=StarBack
		str r0,[r1]	
		
	level5:
	cmp r8,#5
	bne level6
							@ Set level 5
		ldr r0,=Level5Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level5Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap5
		ldr r1,=collideMap
		str r0,[r1]

		ldr r0,=Level5Pal
		ldr r1,=StarBack
		str r0,[r1]
		
	level6:
	cmp r8,#6
	bne level7
							@ Set level 6
		ldr r0,=Level6Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level6Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap6
		ldr r1,=collideMap
		str r0,[r1]

		ldr r0,=Level6Pal
		ldr r1,=StarBack
		str r0,[r1]

	level7:
	cmp r8,#7
	bne level8
							@ Set level 7
		ldr r0,=Level7Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level7Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap7
		ldr r1,=collideMap
		str r0,[r1]
		
		ldr r0,=Level7Pal
		ldr r1,=StarBack
		str r0,[r1]
	
	level8:
	cmp r8,#8
	bne level9
							@ Set level 8
		ldr r0,=Level8Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level8Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap8
		ldr r1,=collideMap
		str r0,[r1]

		ldr r0,=Level8Pal
		ldr r1,=StarBack
		str r0,[r1]	
	
	level9:
	cmp r8,#9
	bne level10
							@ Set level 9
		ldr r0,=Level9Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level9Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap9
		ldr r1,=collideMap
		str r0,[r1]
	
		ldr r0,=Level9Pal
		ldr r1,=StarBack
		str r0,[r1]
		
	level10:
	cmp r8,#10
	bne level11
							@ Set level 10
		ldr r0,=Level10Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level10Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap10
		ldr r1,=collideMap
		str r0,[r1]
	
		ldr r0,=Level10Pal
		ldr r1,=StarBack
		str r0,[r1]
		
	level11:
	cmp r8,#11
	bne level12
							@ Set level 11
		ldr r0,=Level11Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level11Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap11
		ldr r1,=collideMap
		str r0,[r1]	

		ldr r0,=Level11Pal
		ldr r1,=StarBack
		str r0,[r1]

	level12:
	cmp r8,#12
	bne levelDone
							@ Set level 11
		ldr r0,=Level12Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level12Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap12
		ldr r1,=collideMap
		str r0,[r1]	

		ldr r0,=Level12Pal
		ldr r1,=StarBack
		str r0,[r1]

	levelDone:

mov r15,r14

initLevelSprites:
	stmfd sp!, {r0-r6, lr}
	mov r1, #1
	ldr r0,=firePress
	str r1,[r0]				@ Set fire press so fire to start does not fire a bullet
	ldr r0,=spriteActive
	str r1,[r0]				@ make sure our ship is visible

	mov r1,#176
	ldr r0,=spriteX
	str r1,[r0]				@ our ships initial X coord
	mov r1,#716
	ldr r0,=spriteY
	str r1,[r0]				@ our ships initial Y coord
	
	bl initLevelSpecialSprites
	
	ldmfd sp!, {r0-r6, pc}

initLevelSpecialSprites:
	stmfd sp!, {r0-r6, lr}
	ldr r8,=level
	ldr r8,[r8]
	cmp r8,#1
	ldreq r0, =SpritesLev1Tiles
	cmp r8,#2
	ldreq r0, =SpritesLev2Tiles
	cmp r8,#3
	ldreq r0, =SpritesLev3Tiles
	cmp r8,#4
	ldreq r0, =SpritesLev4Tiles
	cmp r8,#5
	ldreq r0, =SpritesLev5Tiles
	cmp r8,#6
	ldreq r0, =SpritesLev6Tiles
	cmp r8,#7
	ldreq r0, =SpritesLev7Tiles
	cmp r8,#8
	ldreq r0, =SpritesLev8Tiles
	cmp r8,#9
	ldreq r0, =SpritesLev9Tiles
	cmp r8,#10
	ldreq r0, =SpritesLev10Tiles
	cmp r8,#11
	ldreq r0, =SpritesLev11Tiles	
	
	ldr r1, =SPRITE_GFX
	add r1,#21504
	ldr r2, =11264
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
	add r1,#21504
	bl dmaCopy
	
	bl playDinkDinkSound
	
	ldmfd sp!, {r0-r6, pc}
	
	.pool
	.end

