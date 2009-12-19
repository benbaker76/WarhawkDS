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
	.global loadLevelData
	.global Level1Map
	.global Level2Map
	.global Level3Map
	.global Level4Map
	.global Level5Map
	.global Level6Map
	.global Level7Map
	.global Level8Map
	.global Level9Map
	.global Level10Map
	.global Level11Map
	.global Level12Map
	.global Level13Map
	.global Level14Map
	.global Level15Map
	.global Level16Map
	.global Level32Map
	.global Level1Tiles
	.global Level2Tiles
	.global Level3Tiles
	.global Level4Tiles
	.global Level5Tiles
	.global Level6Tiles
	.global Level7Tiles
	.global Level8Tiles
	.global Level9Tiles
	.global Level10Tiles
	.global Level11Tiles
	.global Level12Tiles
	.global Level13Tiles
	.global Level14Tiles
	.global Level15Tiles
	.global Level16Tiles
	.global Level32Tiles
	.global Level1Pal
	.global Level2Pal
	.global Level3Pal
	.global Level4Pal
	.global Level5Pal
	.global Level6Pal
	.global Level7Pal
	.global Level8Pal
	.global Level9Pal
	.global Level10Pal
	.global Level11Pal
	.global Level12Pal
	.global Level13Pal
	.global Level14Pal
	.global Level15Pal
	.global Level16Pal
	.global Level32Pal
	.global Level1TilesLen
	.global Level2TilesLen
	.global Level3TilesLen
	.global Level4TilesLen
	.global Level5TilesLen
	.global Level6TilesLen
	.global Level7TilesLen
	.global Level8TilesLen
	.global Level9TilesLen
	.global Level10TilesLen
	.global Level11TilesLen
	.global Level12TilesLen
	.global Level13TilesLen
	.global Level14TilesLen
	.global Level15TilesLen
	.global Level16TilesLen
	.global Level32TilesLen
	
loadLevelData:

	stmfd sp!, {r0-r1, lr}
	
	@ Read palette
	
	ldr r0, =levelPal
	ldr r0, [r0]
	bl readFile
	
	@ Write palette
	
	ldr r0, =pFileBuffer
	ldr r0, [r0]
	ldr r1, =BG_PALETTE
	ldr r2, =512
	bl dmaCopy
	mov r3, #0
	strh r3, [r1]
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	strh r3, [r1]
	
	@ Read tiles
	
	ldr r0, =levelTiles
	ldr r0, [r0]
	bl readFile
	ldr r1, =levelTilesLen
	str r0, [r1]
	
	@ Write tiles
	
	ldr r0, =pFileBuffer
	ldr r0, [r0]
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	bl decompressToVRAM
	ldr r0, =pFileBuffer
	ldr r0, [r0]
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	bl decompressToVRAM
	
	@ Read map
	
	ldr r0, =levelMap
	ldr r0, [r0]
	bl readFile
	
	@ Write map
	
	ldr r0, =pFileBuffer
	ldr r1, =levelMap
	ldr r0, [r0]
	str r0, [r1]
	
	bl DC_FlushAll
		
	ldmfd sp!, {r0-r1, pc}
	
	@------------------------------------
	
	.data
	
	.align
Level1Map:
	.asciz "/Data/Warhawk/Levels/Level1.map.bin"
	.align
Level2Map:
	.asciz "/Data/Warhawk/Levels/Level2.map.bin"
	.align
Level3Map:
	.asciz "/Data/Warhawk/Levels/Level3.map.bin"
	.align
Level4Map:
	.asciz "/Data/Warhawk/Levels/Level4.map.bin"
	.align
Level5Map:
	.asciz "/Data/Warhawk/Levels/Level5.map.bin"
	.align
Level6Map:
	.asciz "/Data/Warhawk/Levels/Level6.map.bin"
	.align
Level7Map:
	.asciz "/Data/Warhawk/Levels/Level7.map.bin"
	.align
Level8Map:
	.asciz "/Data/Warhawk/Levels/Level8.map.bin"
	.align
Level9Map:
	.asciz "/Data/Warhawk/Levels/Level9.map.bin"
	.align
Level10Map:
	.asciz "/Data/Warhawk/Levels/Level10.map.bin"
	.align
Level11Map:
	.asciz "/Data/Warhawk/Levels/Level11.map.bin"
	.align
Level12Map:
	.asciz "/Data/Warhawk/Levels/Level12.map.bin"
	.align
Level13Map:
	.asciz "/Data/Warhawk/Levels/Level13.map.bin"
	.align
Level14Map:
	.asciz "/Data/Warhawk/Levels/Level14.map.bin"
	.align
Level15Map:
	.asciz "/Data/Warhawk/Levels/Level15.map.bin"
	.align
Level16Map:
	.asciz "/Data/Warhawk/Levels/Level16.map.bin"
	.align
Level32Map:
	.asciz "/Data/Warhawk/Levels/Level32.map.bin"

	.align
Level1Tiles:
	.asciz "/Data/Warhawk/Levels/Level1.img.bin"
	.align
Level2Tiles:
	.asciz "/Data/Warhawk/Levels/Level2.img.bin"
	.align
Level3Tiles:
	.asciz "/Data/Warhawk/Levels/Level3.img.bin"
	.align
Level4Tiles:
	.asciz "/Data/Warhawk/Levels/Level4.img.bin"
	.align
Level5Tiles:
	.asciz "/Data/Warhawk/Levels/Level5.img.bin"
	.align
Level6Tiles:
	.asciz "/Data/Warhawk/Levels/Level6.img.bin"
	.align
Level7Tiles:
	.asciz "/Data/Warhawk/Levels/Level7.img.bin"
	.align
Level8Tiles:
	.asciz "/Data/Warhawk/Levels/Level8.img.bin"
	.align
Level9Tiles:
	.asciz "/Data/Warhawk/Levels/Level9.img.bin"
	.align
Level10Tiles:
	.asciz "/Data/Warhawk/Levels/Level10.img.bin"
	.align
Level11Tiles:
	.asciz "/Data/Warhawk/Levels/Level11.img.bin"
	.align
Level12Tiles:
	.asciz "/Data/Warhawk/Levels/Level12.img.bin"
	.align
Level13Tiles:
	.asciz "/Data/Warhawk/Levels/Level13.img.bin"
	.align
Level14Tiles:
	.asciz "/Data/Warhawk/Levels/Level14.img.bin"
	.align
Level15Tiles:
	.asciz "/Data/Warhawk/Levels/Level15.img.bin"
	.align
Level16Tiles:
	.asciz "/Data/Warhawk/Levels/Level16.img.bin"
	.align
Level32Tiles:
	.asciz "/Data/Warhawk/Levels/Level32.img.bin"
	
	.align
Level1Pal:
	.asciz "/Data/Warhawk/Levels/Level1.pal.bin"
	.align
Level2Pal:
	.asciz "/Data/Warhawk/Levels/Level2.pal.bin"
	.align
Level3Pal:
	.asciz "/Data/Warhawk/Levels/Level3.pal.bin"
	.align
Level4Pal:
	.asciz "/Data/Warhawk/Levels/Level4.pal.bin"
	.align
Level5Pal:
	.asciz "/Data/Warhawk/Levels/Level5.pal.bin"
	.align
Level6Pal:
	.asciz "/Data/Warhawk/Levels/Level6.pal.bin"
	.align
Level7Pal:
	.asciz "/Data/Warhawk/Levels/Level7.pal.bin"
	.align
Level8Pal:
	.asciz "/Data/Warhawk/Levels/Level8.pal.bin"
	.align
Level9Pal:
	.asciz "/Data/Warhawk/Levels/Level9.pal.bin"
	.align
Level10Pal:
	.asciz "/Data/Warhawk/Levels/Level10.pal.bin"
	.align
Level11Pal:
	.asciz "/Data/Warhawk/Levels/Level11.pal.bin"
	.align
Level12Pal:
	.asciz "/Data/Warhawk/Levels/Level12.pal.bin"
	.align
Level13Pal:
	.asciz "/Data/Warhawk/Levels/Level13.pal.bin"
	.align
Level14Pal:
	.asciz "/Data/Warhawk/Levels/Level14.pal.bin"
	.align
Level15Pal:
	.asciz "/Data/Warhawk/Levels/Level15.pal.bin"
	.align
Level16Pal:
	.asciz "/Data/Warhawk/Levels/Level16.pal.bin"
	.align
Level32Pal:
	.asciz "/Data/Warhawk/Levels/Level32.pal.bin"
	
	.align
Level1TilesLen:
Level2TilesLen:
Level3TilesLen:
Level4TilesLen:
Level5TilesLen:
Level6TilesLen:
Level7TilesLen:
Level8TilesLen:
Level9TilesLen:
Level10TilesLen:
Level11TilesLen:
Level12TilesLen:
Level13TilesLen:
Level14TilesLen:
Level15TilesLen:
Level16TilesLen:
Level32TilesLen:

	.pool
	.end