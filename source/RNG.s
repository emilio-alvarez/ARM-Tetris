/*Global Methods:
	- Random number generator
*/

//Returns: r0 - contains the random number between 0-6    	
.globl	RNG
RNG:
	push	{r1-r9}
	
	ldr	r1, =w  		//Store in r5
	ldr	r2, =x  		//Store in r6
	ldr	r3, =y  		//Store in r7
	ldr	r4, =z  		//Store in r8
	
	ldrb    r5, [r1]        	//w
	ldrb    r6, [r2]        	//x
	ldrb    r7, [r3]        	//y
	ldrb    r8, [r4]        	//z
	
	mov	r9, r6			// mov x to t
	eor	r9,r9,r9,lsl #11	// xor t shift by 11
	eor	r9,r9,r9,lsl #8		// xor t shift by 8
	mov	r6, r7			// mov y to x
	mov	r7, r8			// mov z to y
	mov     r8, r5          	// mov w to z
	eor 	r5,r5,r5,lsl #19	// xor w shift by 19
	eor 	r5, r9			// xor w with t
	
	mov     r0, r5			//Number in r0
	strb    r5, [r1]		//Store back w
	strb    r6, [r2]		//Store back x
	strb    r7, [r3]		//Store back y
	strb    r8, [r4]		//Store back z
		
	and     r0, #7			//And the random number with 7
					//Returns a number between 0 and 6
	pop     {r1-r9}			
	bx lr
//------------------------------------------------------------------------------------------	
.section .data
.align
//The starting numbers the RNG uses
w:
	.byte	147
x:
	.byte   2
y:
	.byte   55
z:
	.byte   249
