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
	.data

	.global gameMode
	.global fxMode
	.global basesLeft
	.global basesShot
	.global bossMan
	.global bossX
	.global bossY
	.global bossHits
	.global pixelOffsetMain
	.global pixelOffsetSub
	.global pixelOffsetSFMain
	.global pixelOffsetSFSub
	.global pixelOffsetSBMain
	.global pixelOffsetSBSub
	.global pixelOffsetText
	.global pressMe
	.global firePress
	.global fireTrap
	.global horizDrift
	.global powerUp
	.global powerUpDelay
	.global delaySF
	.global delaySB
	.global score
	.global adder
	.global hofsSF
	.global hofsSB
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
	.global spriteDataStart
	.global spriteDataEnd
	.global spriteX
	.global spriteY
	.global spriteObj
	.global spriteActive
	.global spriteHits
	.global spriteAngle
	.global spriteSpeedX
	.global spriteSpeedY
	.global spriteSpeedDelay
	.global spriteSpeedDelayX
	.global spriteMaxSpeed
	.global spriteTrackX
	.global spriteTrackY
	.global spritePhase
	.global spriteExplodeDelay
	.global spriteBloom
	.global getReadyText
	.global levelText
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
	.global levelNum
	.global levelEnd
	.global levelMap
	.global levelPal
	.global levelTiles
	.global levelTilesLen
	.global colMap
	.global starBackPal
	.global craterFrame
	.global waveNumber
	.global energy
	.global energyText
	.global gameOverText
	.global inGameRawText
	.global titleRawText
	.global ppotRawText
	.global gameOverRawText
	.global hiScoreRawText
	.global endOfGameRawText
	.global mineDelay
	.global hunterDelay
	.global mineTimerCounter
	.global hunterTimerCounter
	.global spriteIdent
	.global spriteFireSpeed
	.global animFrame
	.global meteorFrame
	.global animDelay
	.global bossXSpeed
	.global bossYSpeed
	.global bossXDelay
	.global bossYDelay
	.global bossXDir
	.global bossYDir
	.global bossFirePhase
	.global bossFireDelay
	.global bossMaxX
	.global bossMaxY
	.global bossTurn
	.global bossFireMode
	.global bossSpecial
	.global delayPowerUp
	.global powerupLives
	.global bossLeftMin
	.global bossRightMax
	.global bossSpreadAngle
	.global explodeSpriteBoss
	.global explodeSpriteBossCount
	.global spriteBurstNum
	.global spriteBurstNumCount
	.global spriteBurstDelay
	.global spriteBurstDelayCount
	.global spriteSpeedDelay
	.global playerDeath
	.global playerDeathDelay
	.global playerMidDelay
	.global animEnergyPhase
	.global animEnergyActive
	.global animEnergyDelay
	.global cheatMode
	
cheatMode:
	.word 0
	
explodeSpriteBossCount:
	.word 0
explodeSpriteBoss:
	.word 0
	
animEnergyPhase:
	.word 0
animEnergyActive:
	.word 0
animEnergyDelay:
	.word 0
	
powerupLives:
	.word 0
delayPowerUp:
	.word 0
basesLeft:
	.word 0
basesShot:
	.word 0
gameMode:
	.word 0
fxMode:
	.word 0

bossSpreadAngle:
	.word 0
bossLeftMin:
	.word 0
bossRightMax:
	.word 0
bossSpecial:
	.word 0
bossFireMode:
	.word 0
bossTurn:
	.word 0
bossMaxX:
	.word 0
bossMaxY:
	.word 0
bossFireDelay:
	.word 0
bossFirePhase:
	.word 0
bossXSpeed:
	.word 0
bossYSpeed:
	.word 0
bossXDelay:
	.word 0
bossYDelay:
	.word 0
bossXDir:
	.word 0
bossYDir:
	.word 0
bossX:
	.word 0
bossY:
	.word 0
bossHits:
	.word 0

animFrame:
	.word 0
animDelay:
	.word 0
meteorFrame:
	.word 0
	
mineDelay:
	.word 0
mineTimerCounter:
	.word 0
hunterDelay:
	.word 0
hunterTimerCounter:
	.word 0
bossMan:
	.word 0
	
levelNum:
	.word 0
levelEnd:
	.word 0
levelMap:
	.word 0
levelPal:
	.word 0
levelTiles:
	.word 0
levelTilesLen:
	.word 0
colMap:
	.word 0
starBackPal:
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
fireTrap:
	.word 0
horizDrift:
	.word 0
powerUp:
	.word 0
powerUpDelay:
	.word 0
delaySF:
	.word 2
delaySB:
	.word 4
score:
	.word 0,0
adder:
	.word 0,0
	
hofsSF:
	.word 0
hofsSB:
	.word 0

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
	
	.align
getReadyText:
	.asciz "GET READY!"
	
	.align
levelText:
	.asciz "LEVEL"
	
	.align
spriteXText:
	.asciz "spritex:"
	
	.align
spriteYText:
	.asciz "spritey:"
	
	.align
vofsSubText:
	.asciz "vofssub:"
	
	.align
yposSubText:
	.asciz "ypossub:"
	
	.align
blockXText:
	.asciz "blockx:"
	
	.align
blockYText:
	.asciz "blocky:"
	
	.align
tileNumText:
	.asciz "tilenum:"
	
	.align
scrollPixelText:
	.asciz "scroll pix:"
	
	.align
pixelOffsetText:
	.asciz "pixeloff:"
	
	.align
energyText:
	.asciz "energy:"
	
	.align
gameOverText:
	.asciz "GAME OVER!"
	
	.align
inGameRawText:
	.asciz "/InGame.raw"
	
	.align
titleRawText:
	.asciz "/Title.raw"
	
	.align
gameOverRawText:
	.asciz "/GameOver.raw"
	
	.align
hiScoreRawText:
	.asciz "/HiScore.raw"
	
	.align
endOfGameRawText:
	.asciz "/EndOfGame.raw"
	
	.align
ppotRawText:
	.asciz "/PPOT.raw"

	.align 4

spriteDataStart:								@ Start of sprite data

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
spriteIdent:
	.space 512
spriteFireSpeed:
	.space 512
spriteBurstNum:
	.space 512
spriteBurstNumCount:
	.space 512
spriteBurstDelay:
	.space 512
spriteBurstDelayCount:
	.space 512
spriteSpeedDelay:
	.space 512
	
spriteInstruct:
	.space 32768
	
spriteDataEnd:									@ End of sprite data

digits:
	.space 32
	
waveNumber:
	.word 0
playerDeath:
	.word 0
playerDeathDelay:
	.word 0
playerMidDelay:
	.word 0
	
	.pool
	.end
