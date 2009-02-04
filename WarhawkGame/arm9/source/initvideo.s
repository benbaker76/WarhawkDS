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
	.global initVideo
	
initVideo:
	stmfd sp!, {r0-r6, lr}
	ldr r0, =REG_POWERCNT
	ldr r1, =POWER_ALL_2D			@ All power on
	str r1, [r0]
 
	mov r0, #REG_DISPCNT			@ Main screen to Mode 0 with BG2 active
	ldr r1, =(MODE_0_2D | DISPLAY_SPR_ACTIVE | DISPLAY_SPR_1D_LAYOUT | DISPLAY_BG0_ACTIVE | DISPLAY_BG1_ACTIVE | DISPLAY_BG2_ACTIVE | DISPLAY_BG3_ACTIVE)
	str r1, [r0]
	
	ldr r0, =REG_DISPCNT_SUB		@ Sub screen to Mode 0 with BG0 active
	ldr r1, =(MODE_0_2D | DISPLAY_SPR_ACTIVE | DISPLAY_SPR_1D_LAYOUT | DISPLAY_BG0_ACTIVE | DISPLAY_BG1_ACTIVE | DISPLAY_BG2_ACTIVE | DISPLAY_BG3_ACTIVE)
	str r1, [r0]
 
	ldr r0, =VRAM_A_CR				@ Set VRAM A to be main bg address 0x06000000
	ldr r1, =(VRAM_ENABLE | VRAM_A_MAIN_BG_0x06000000)
	strb r1, [r0]

	ldr r0, =VRAM_B_CR				@ Use this for sprite data
	ldr r1, =(VRAM_ENABLE | VRAM_A_MAIN_SPRITE)
	strb r1, [r0]
	
	ldr r0, =VRAM_C_CR				@ Set VRAM C to be sub bg address 0x06200000
	ldr r1, =(VRAM_ENABLE | VRAM_C_SUB_BG_0x06200000)
	strb r1, [r0]
	
	ldr r0, =VRAM_D_CR				@ Use this for sprite data
	ldr r1, =(VRAM_ENABLE | VRAM_D_SUB_SPRITE)
	strb r1, [r0]

	ldr r0, =REG_BG0CNT				@ Set main screen BG0 format to be 64x64 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE) | BG_TILE_BASE(BG0_TILE_BASE) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG0CNT_SUB			@ Set sub screen BG0 format to be 64x64 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_32x32 | BG_MAP_BASE(BG0_MAP_BASE_SUB) | BG_TILE_BASE(BG0_TILE_BASE_SUB) | BG_PRIORITY(BG0_PRIORITY))
	strh r1, [r0]
	
	ldr r0, =REG_BG1CNT				@ Set main screen BG0 format to be 64x64 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_64x32 | BG_MAP_BASE(BG1_MAP_BASE) | BG_TILE_BASE(BG1_TILE_BASE) | BG_PRIORITY(BG1_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG1CNT_SUB			@ Set sub screen BG0 format to be 64x64 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_64x32 | BG_MAP_BASE(BG1_MAP_BASE_SUB) | BG_TILE_BASE(BG1_TILE_BASE_SUB) | BG_PRIORITY(BG1_PRIORITY))
	strh r1, [r0]
	
	ldr r0, =REG_BG2CNT				@ Set main screen BG0 format to be 64x64 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_32x64 | BG_MAP_BASE(BG2_MAP_BASE) | BG_TILE_BASE(BG2_TILE_BASE) | BG_PRIORITY(BG2_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG2CNT_SUB			@ Set sub screen BG0 format to be 64x64 tiles at base address
	ldr r1, =(BG_COLOR_16 | BG_32x64 | BG_MAP_BASE(BG2_MAP_BASE_SUB) | BG_TILE_BASE(BG2_TILE_BASE_SUB) | BG_PRIORITY(BG2_PRIORITY))
	strh r1, [r0]

	ldr r0, =REG_BG3CNT				@ Set main screen BG3 format to be 64x64 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x64 | BG_MAP_BASE(BG3_MAP_BASE) | BG_TILE_BASE(BG3_TILE_BASE) | BG_PRIORITY(BG3_PRIORITY))
	strh r1, [r0]
	ldr r0, =REG_BG3CNT_SUB			@ Set sub screen BG3 format to be 64x64 tiles at base address
	ldr r1, =(BG_COLOR_256 | BG_32x64 | BG_MAP_BASE(BG3_MAP_BASE_SUB) | BG_TILE_BASE(BG3_TILE_BASE_SUB) | BG_PRIORITY(BG3_PRIORITY))
	strh r1, [r0]
	
	@ Load the palette into the palette subscreen area and main

	ldr r0, =StarBackPal
	ldr r1, =BG_PALETTE
	ldr r2, =StarBackPalLen
	bl dmaCopy
	ldr r1, =BG_PALETTE_SUB
	bl dmaCopy
	
	@ Write the tile data to VRAM Level BG1

	ldr r0, =Level1Tiles
	ldr r1, =BG_TILE_RAM(BG1_TILE_BASE)
	ldr r2, =Level1TilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(BG1_TILE_BASE_SUB)
	bl dmaCopy
	
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
	ldr r2, =StarBackTilesLen
	bl dmaCopy
	ldr r1, =BG_TILE_RAM_SUB(BG3_TILE_BASE_SUB)
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
	mov r6,#0
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
	
	.end