.section	.text


.globl SpawnValuePack
SpawnValuePack:
	pop {r4,r5,lr}			//pops the r4 and r5 from spawnBlock
	push {r4-r12, lr}		//push's new registers

	bl	DrawSpecial

	ldr	r0, =0x3F003004			//CLO
	ldr	r1, [r0]			//Current time
	ldr	r3, =40000000			//Add 20 seconds
	add	r1, r3				//Time to wait until
	ldr	r0, =TimeToWait			//Store the value in memory
	str	r1, [r0]

	mov r0, #15             //posistion of x nned to 15
        mov r1, #3              //position of y need to have 3
	ldr r3, =ValuePack
        bl DrawBlock		//spawns the value pack

	mov r5, #15		//stores value for x
	mov r6, #3		//stores value for y
	mov r7, #8		//stores the colour 8

droppingValueBlock:
	
	//bl debugprintState
		     
        mov r0, r5                      //passes in the x
        mov r1, r6                      //passes in the y
        mov r2, r7
        bl ReadGameButtons              //returns new x and y
        mov r5,r0                       //sets x to new x
        mov r6,r1                       //sets y to new y

	mov r8, #1			//a number 1	
	mov r0, r5			//r5 = the x
	add r1, r6, r8 			//r1 =y + 1
	bl checkABox 
	cmp r3, #1			//if it lands
	beq endDroppingValuePack
	
        cmp r6, #21                            //checks if it landed
        bge endDroppingValuePack             //if it did branch to the top

        mov r0, r5                      //gets x
        mov r1, r6                      //gets y
        bl      dropValuePackFunction            
        mov     r6, r0                  //adds new y

        b       droppingValueBlock             //keep doing this loop

endDroppingValuePack:
	pop {r4-r12, lr}

	b checkBreak 


//-----------------------------------------------------------------------------------------------------------------
//takes r0 =x and r1 = y
//returns new y in r0
dropValuePackFunction:
        push {r5,r6,lr}

        mov     r5, r0                  //stores the x
        mov     r6, r1                  //stores the y
	
	mov r0, r5			//the x
	mov r1, r6			//the y
	bl eraseBlock			//erase the proper block
	mov r0, r5              	//x to delete
        mov r1, r6              	//y to delete
        bl clearFromState


	add r6 ,#1                      //moves down by 1

        mov r0, r5                      //gets x
        mov r1, r6                      //gets y
        ldr r3, =ValuePack		//this is the value pack
	bl DrawBlock			//draws he block
        mov r0, r5              //x to delete
        mov r1, r6              //y to delete
	mov r2, #8		//8 in the state
        bl addToState
     
	mov r0, r6                      //new Y in r0

        pop {r5,r6,lr}
        mov pc, lr

//-----------------------------------------------------------------------------------------------------------------



//----------------------------------------------------------------------------------------------
//r0 will contain the posistion of X
//r1 will contain the posistion of Y
.globl leftPressValueCheck
leftPressValueCheck:
        push {r4,r5,r6,lr}

        mov r4, r0              //stores x
        mov r5, r1              //stores y

        sub r2, r4, #1              //check the left side
        cmp r2, #11             //test < 11
        blt     failLeftValueCheck
        sub r0, r4, #1              //x-1
        mov r1, r5                  //y
        bl checkABox    
        cmp r3, #1                  //if the lest side has a bit
        beq     failLeftValueCheck
        


        mov r0, r4              //x to delete
        mov r1, r5              //y to delete
        bl eraseBlock           //erase current block
        mov r0, r4              //x to delete
        mov r1, r5              //y to delete
        bl clearFromState


        sub r6,r4,#1              //move on left 
        mov r0, r6                //new X 
        mov r1, r5                //Y
 	ldr r3, =ValuePack
        bl DrawBlock		//spawns the value pack

        sub r6,r4,#1              //move on left 
        mov r0, r6              //x to delete
        mov r1, r5              //y to delete
	mov r2, #8		//8 in the state
        bl addToState

        mov r1, #0              //tell it user it can move
        cmp r1, #0              //sets the zero flag 
        b     endLeftValueCheck 

failLeftValueCheck:
        mov r1, #1              //tell it user it cant move
        cmp r1, #0              //make sure there is no zero flag

endLeftValueCheck:     
        pop {r4,r5,r6,lr}
        mov pc, lr
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
//r0 will contain the posistion of X
//r1 will contain the posistion of Y
.globl rightPressValueCheck
rightPressValueCheck:
        push {r4,r5,r6,lr}
        
        mov r4, r0              //stores x
        mov r5, r1              //stores y

        add r2, r4, #1              //check the right side
        cmp r2, #20                 //test > 20
        bgt     failRightValueCheck
        add r0, r4, #1              //x+1
        mov r1, r5                  //y
        bl checkABox    
        cmp r3, #1                  //if the right side has a block
        beq     failRightValueCheck

        mov r0, r4              //x to delete
        mov r1, r5              //y to delete
        bl eraseBlock           //erase current block
        mov r0, r4              //x to delete
        mov r1, r5              //y to delete
        bl clearFromState
        
        add r6,r4,#1              //move on left 
        mov r0, r6                //new X 
        mov r1, r5                //Y
 	ldr r3, =ValuePack
        bl DrawBlock		//spawns the value pack

        add r6,r4,#1              //move on left
        mov r0, r6              //x to delete
        mov r1, r5              //y to delete
	mov r2, #8		//the value to add to the state
        bl addToState 

        mov r1, #0              //tell it user it can move
        cmp r1, #0              //sets the zero flag
        b     endRightValueCheck  

failRightValueCheck:
        mov r1, #1              //tell it user it can move
        cmp r1, #0              //smake sure there is no zero flag

endRightValueCheck:
        pop {r4,r5,r6,lr}
        mov pc, lr
//----------------------------------------------------------------------------------------------

