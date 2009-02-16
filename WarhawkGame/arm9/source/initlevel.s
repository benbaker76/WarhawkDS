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
	.global initLevel
	
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
	mov r1,#3744	@ 3968 - 192 - 32
	ldr r0,=yposMain
	str r1,[r0]
	ldr r0,=yposSub
	str r1,[r0]

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

	mov r1,#32
	ldr r0,=horizDrift
	strb r1,[r0]			@ Drift on levels horizontal - centre to start level
	
	
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
	
	level11:
	cmp r8,#11
	bne levelDone
							@ Set level 11
		ldr r0,=Level3Map
		ldr r1,=LevelMap
		str r0,[r1]

		ldr r0,=Level3Tiles
		ldr r1,=LevelTiles
		str r0,[r1]
		
		ldr r0,=colMap11
		ldr r1,=collideMap
		str r0,[r1]	
	levelDone:

mov r15,r14


.end

