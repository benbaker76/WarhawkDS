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

	.global checkBossInit
	.global bossAttack
	
@----------------- BOSS INIT CODE	
checkBossInit:
	@ this uses yposSub to tell when we should display the BOSS
	@ Perhaps levelend will tell us when to move him???
	@ not sure?
	@ we will use bossMan as a flag to say that he is HERE!!!
	@ 0= no, 1=yes, but not ready to move, 2=attack time
	ldr r0,=bossMan
	ldr r0,[r0]
	cmp r0,#1
	beq bossActiveScroll		@ Use this to scroll the Boss with the bg1
	cmp r0,#2
	beq checkBossInitFail		@ if he is active, let "bossAttack" do the work
	ldr r0,=yposSub
	ldr r0,[r0]
	cmp r0,#352
	bne checkBossInitFail		@ not time yet :(
		@ here we need to lay all the sprites and data out for the boss
		mov r1,#1
		ldr r0,=bossMan
		str r1,[r0]				@ set to "scroll mode"
	
	
	
	mov r15,r14
	bossActiveScroll:
		@ here we need to update all 9 sprites by 1 Y pos.
		@ and check when time to "LAUNCH", set bossman to 2

checkBossInitFail:
	mov r15,r14

@------------------ BOSS ATTACK CODE	
bossAttack:

	ldr r0,=bossMan
	ldr r0,[r0]
	cmp r0,#2
	movne r15,r14

	@ Boss attack code goes in here - somehow!!
	@ BUGGER ME!! Here we need to move the boss and take care of its firing needs
	@ What joy, what fun, what?
	
	mov r15,r14