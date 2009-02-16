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
	.global initSprites
	
initSprites:
	stmfd sp!, {r0-r6, lr} 

	@ Load the palette into the palette subscreen area and main

	ldr r0, =SpritesPal
	ldr r1, =SPRITE_PALETTE
	ldr r2, =SpritesPalLen
	bl dmaCopy
	ldr r1, =SPRITE_PALETTE_SUB
	bl dmaCopy

	@ Write the tile data to VRAM

	ldr r0, =SpritesTiles
	ldr r1, =SPRITE_GFX
	ldr r2, =SpritesTilesLen
	bl dmaCopy
	ldr r1, =SPRITE_GFX_SUB
	bl dmaCopy
	
	@ Clear the OAM (disable all 128 sprites for both screens)

	ldr r0, =ATTR0_DISABLED			@ Set OBJ_ATTRIBUTE0 to ATTR0_DISABLED
	ldr r1, =OAM
	ldr r2, =1024					@ 3 x 16bit attributes + 16 bit filler = 8 bytes x 128 entries in OAM
	bl dmaFillWords
	ldr r1, =OAM_SUB
	bl dmaFillWords
	
	@ wipe all sprite data
	ldr r0,=0
	ldr r1,=spriteX
	ldr r2,=2432
	bl dmaFillWords

	ldmfd sp!, {r0-r6, pc}

	.end
