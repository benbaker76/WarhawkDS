	.arm
	.align
	.global divideNumber

divideNumber:
	@ R1 to hold number to divide, r2 hold divisor. R0 returns result (hopefully)
	@ Thought this may come in handy - perhaps not?
	
	stmfd sp!, {r4-r6, lr}
	
	mov r0,#0
	mov r3,#1	@ set bit 0 for test in shift
	divl1:
		cmp r2,r1
		movls r2,r2,lsl #1	@ shift r2 till it is same as r1
		movls r3,r3,lsl #1	@ shift r3 (this is our count flag)
	bls divl1
	divl2:
		cmp r1,r2
		subcs r1,r1,r2
		addcs r0,r0,r3
		movs r3,r3,lsr #1
		movcc r2,r2,lsr #1
	bcc divl2
	
	ldmfd sp!, {r4-r6, pc}
