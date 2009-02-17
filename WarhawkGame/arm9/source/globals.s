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
	.data
	
	.global pixelOffsetMain
	.global pixelOffsetSub
	.global pixelOffsetSFMain
	.global pixelOffsetSFSub
	.global pixelOffsetSBMain
	.global pixelOffsetSBSub
	.global pixelOffsetText
	.global LevelMap
	.global pressMe
	.global firePress
	.global horizDrift
	.global powerUp
	.global powerUpDelay
	.global levelEnd
	.global delaySF
	.global delaySB
	.global score
	.global adder
	.global vofsMain
	.global vofsSFMain
	.global vofsSBMain
	.global vofsSub
	.global vofsSFSub
	.global vofsSBSub
	.global yposMain
	.global yposSFMain
	.global yposSBMain
	.global yposSub
	.global yposSFSub
	.global yposSBSub
	.global xpos
	.global shipX
	.global shipY
	.global shipXspeed
	.global blockCraterOffset
	.global blockCraterIndex
	.global blockCraterCount
	.global energyLevel
	.global spriteX
	.global spriteY
	.global spriteObj
	.global spriteActive
	.global spriteHits
	.global spriteAngle
	.global spriteSpeedX
	.global spriteSpeedY
	.global spriteSpeedDelay
	.global spriteMaxSpeed
	.global spriteTrackX
	.global spriteTrackY
	.global spritePhase
	.global spriteExplodeDelay
	.global spriteBloom
	.global getReadyText
	.global spriteXText
	.global spriteYText
	.global spriteInstruct
	.global vofsSubText
	.global yposSubText
	.global blockXText
	.global blockYText
	.global tileNumText
	.global irqTable
	.global digits
	.global moveBaseExplosion
	.global level
	.global LevelMap
	.global LevelTiles
	.global StarBack
	.global craterFrame
	.global waveNumber
	.global collideMap
	.global energy
	.global energyText
	.global youDiedText
	
level:
	.word 0
LevelMap:
	.word 0
collideMap:
	.word 0
LevelTiles:
	.word 0
StarBack:
	.word 0
energy:
	.word 0
pixelOffsetSub:
	.word 0
pixelOffsetMain:
	.word 0
pixelOffsetSFSub:
	.word 0
pixelOffsetSFMain:
	.word 0
pixelOffsetSBSub:
	.word 0
pixelOffsetSBMain:
	.word 0
craterFrame:
	.word 2
pressMe:
	.word 0
firePress:
	.word 0
horizDrift:
	.word 0
powerUp:
	.word 0
powerUpDelay:
	.word 0
levelEnd:
	.word 0
delaySF:
	.word 2
delaySB:
	.word 4
score:
	.word 0,0
adder:
	.word 0,0

vofsMain:
	.word 256+32
vofsSFMain:
	.word 256
vofsSBMain:
	.word 256

vofsSub:
	.word 256+32
vofsSFSub:
	.word 256
vofsSBSub:
	.word 256

yposMain:
	.word 3744						@ 3968 - 192 - 32
yposSFMain:
	.word 736						@ 3200 - 192 - 64 / 4
yposSBMain:
	.word 736						@ 3200 - 192 - 64 / 4
	
yposSub:
	.word 3744						@ 3968 - 192 - 32
yposSFSub:
	.word 736						@ 3200 - 192 - 64 / 4
yposSBSub:
	.word 736						@ 3200 - 192 - 64 / 4

xpos:
	.word 0

shipXspeed:
	.word 0

blockCraterOffset:
	.word 0
blockCraterIndex:
	.word 0
blockCraterCount:
	.word 4
	
energyLevel:
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0
	
getReadyText:
	.string "GET READY!\0"
spriteXText:
	.string "spritex:\0"
spriteYText:
	.string "spritey:\0"
vofsSubText:
	.string "vofssub:\0"
yposSubText:
	.string "ypossub:\0"
blockXText:
	.string "blockx:\0"
blockYText:
	.string "blocky:\0"
tileNumText:
	.string "tilenum:\0"
scrollPixelText:
	.string "scroll pix:\0"
pixelOffsetText:
	.string "pixeloff:\0"
energyText:
	.string "energy:\0"
youDiedText:
	.string "you have died,  tit!\0"
	.section .bss

spriteActive:
	.space 512
spriteX:
	.space 512
spriteY:
	.space 512
spriteSpeedX:
	.space 512
spriteSpeedY:
	.space 512
spriteSpeedDelayX:
	.space 512
spriteSpeedDelayY:
	.space 512
spriteMaxSpeed:
	.space 512
spritePhase:
	.space 512
spriteTrackX:
	.space 512
spriteTrackY:
	.space 512
spriteObj:
	.space 512
spriteHits:
	.space 512
spriteAngle:
	.space 512
spriteExplodeDelay:
	.space 512

spriteFireType:
	.space 512
spriteFireDelay:
	.space 512
spriteFireMax:
	.space 512

spriteBloom:
	.space 512
	
spriteInstruct:
	.space 32768
	
irqTable:
	.space 1024					@ 32 entries
digits:
	.space 32
	
waveNumber:
	.word 0

	.end
