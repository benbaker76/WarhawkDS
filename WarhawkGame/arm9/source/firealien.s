#include "warhawk.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	.global alienFireInit
	.global alienFireMove


	.arm
	.align

@----------------- INITIALISE A SHOT 
alienFireInit:
	stmfd sp!, {r0-r10, lr}
	@ This initialises and aliens bullet
	@ REMEMBER, 	R1 = our aliens offset (we can use this to get coords)
	@ 				R3 = our fire type to initialise ok?
	@	For examples we will use the types 1-4
	@	these are up, down, left, right
	
	ldmfd sp!, {r0-r10, pc}
	
	
@----------------- MOVE ALIEN BULLETS AND CHECK COLLISIONS
alienFireMove:
	stmfd sp!, {r0-r10, lr}
	@ here. we need to step through all alien bullets and check type
	@ and from that we will bl to code to act on it :)
	@ and then return to the main loop!
	
	@ do stuff here
	
	@ and from here we need to check if the bullet is on our ship
	@ and if so, deplete energy, mainloop will act on a 0 and kill us!
	
	ldmfd sp!, {r0-r10, pc}
	
@----------------- BULLET TYPE CODE FROM HERE
.end
