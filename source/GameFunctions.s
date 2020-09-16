/*Global Methods:
	- resetState
	- gameLoop
	- addToState
	- clearFromState
	- checkABox
	- collisionCheckLeft
	- collisionCheckRight
	- pauseMidGame
	- CheckRotatingShape
	- UnRotateShape
	- ConvertScoreToDigits
*/
/*Data:
	- gameState
	- Score
	- ScoreASCII
	- IShapeRotate
	- IShapeNormal
	- IShapePosition
*/
//New: Everything but ^
.section .text

//drawFunction draws a block
//ReadGameButtons reads an input
//clearFunction clears a block
//
//r5: contains the x
//r6: contains the y


.globl gameLoop
gameLoop:
        push {r5-r12, lr}

	ldr	r0, =Score	//Reset the score
	mov	r1, #0
	strb	r1, [r0]
	
	ldr	r0, =ScoreASCII
	strb	r1, [r0]
	strb	r1, [r0,#1]
	strb	r1, [r0,#2]

	ldr	r0, =0x3F003004			//CLO
	ldr	r1, [r0]			//Current time
	ldr	r2, =20000000			//Add 20 seconds
	add	r1, r2				//Time to wait until
	ldr	r0, =TimeToWait			//Store the value in memory
	str	r1, [r0]			

	bl	DrawGameBounds

	bl	ConvertScoreToDigits
	bl	DrawScore

        mov 	r5, #0             //starting y
        mov 	r6, #0             //starting x
        mov 	r7, #0             //starting colour
        b 	spawnBlockAtTop


.globl checkBreak
checkBreak:
        mov 	r8, #0

	ldr 	r0, =LineBreakCounter		//gets the count value
	mov 	r1, #10				//initalizes to 10
	strb 	r1, [r0]				//reset it to 10

	ldr	r0, =LineBreaks
	mov	r1, #0
	strb	r1, [r0]

checkAllLine:
        bl 	checkLineComplete            //check if a line is complete
        add 	r8, #1                      //moves onto next one
        cmp 	r8, #18                     //checks if less than 18
        blt 	checkAllLine
	ldr	r0, =LineBreaks
	ldrb	r1, [r0]
	cmp	r1, #1
	ble	spawnBlockAtTop
	
	ldr	r0, =Score
	ldrb	r1, [r0]
	add	r1, #5
	strb	r1, [r0]
	
	bl	ConvertScoreToDigits
	bl	DrawScore             

spawnBlockAtTop:
       
        bl 	spawnBlock           //spawns the block and returns its x and y
        mov 	r5, r0             //starting y
        mov 	r6, r1             //starting x
        mov 	r7, r2             //starting colour


droppingBlock:		     
        mov r0, r5                      //passes in the x
        mov r1, r6                      //passes in the y
        mov r2, r7
        bl ReadGameButtons              //returns new x and y
        mov r5,r0                       //sets x to new x
        mov r6,r1                       //sets y to new y

        mov r0, r5                      //gets x
        mov r1, r6                      //gets y
        mov r2, r7                      //the colour
        bl      dropFunction            
        mov     r6, r0                  //adds new y

        cmp r1, #1                      //checks if it landed
        beq checkBreak                  //if it did branch to the top
                                        //else keep dropping
        b       droppingBlock             //keep doing this loop



//-------------------------------------------------------------------------------------------
//			pauseMidGame
.globl pauseMidGame
pauseMidGame:
	push	{r0-r12, lr}
	bl	DrawPauseFrame		//Draw the background of the pause menu
PauseRestartOption:
	bl	DrawRestartGameSelected	//Default to restart
	bl	DrawQuitGame
	bl	ReadButtons
	cmp	r0, #4			//If up, loop back
	beq	PauseRestartOption
	cmp	r0, #5			//If down, go to quit option
	beq	PauseQuitOption
	cmp	r0, #8			//If A, start game
	beq	StartGameLoop
	cmp	r0, #3			//If start, resume
	beq	UnPauseGame
	b	PauseRestartOption	//If none/other, loop back
PauseQuitOption:
	bl	DrawQuitGameSelected
	bl	DrawRestartGame
	bl	ReadButtons
	cmp	r0, #4			//If up, go to restart option
	beq	PauseRestartOption
	cmp	r0, #5			//If down, loop back
	beq	PauseQuitOption
	cmp	r0, #8			//If A, return to main menu
	beq	MenuScreen
	cmp	r0, #3			//If start, resume
	beq	UnPauseGame
	b	PauseQuitOption		//If none/other, loop back
UnPauseGame:
	bl	printState
	pop	{r0-r12, lr}
	mov	pc, lr

endGameLoop:
        pop 	{r5-r12,lr}

        mov 	pc,lr

//-----------------------------------------------------------------------------------------------------------------
//takes r0 =x and r1 = y
//returns new y in r0
dropFunction:
        push 	{r5,r6,r7,lr}

        mov     r5, r0                  //stores the x
        mov     r6, r1                  //stores the y
        mov     r7, r2                  //stores the colour

        add 	r1, #1                  //subtract by 1
        bl      potentialArray          //y+1
        cmp 	r0, #1                  //if it is not valid
        beq 	Landed                  //fails check which means it has landed        

Continue:

        mov 	r2, r7                  //gets the colour
        bl 	GetGrid
        mov 	r2, r0                  //gets the array to clear
        mov 	r0, r5                  //loads the X
        mov 	r1, r6                  //loads the y
        mov   	r3,r7      	        //address of memory address  
        bl 	ClearShape 	        //prints the shape

        add 	r6 ,#1                  //moves down by 1

        mov 	r0, r5                  //loads the X
        mov 	r1, r6                  //loads the y
        mov 	r2, r7                  //gets the colour
        bl 	CheckShape              //prints the shape
        mov 	r0, r6                  //returns the new Y in r0
        mov 	r1, #0               	//not branched

endDropFunction:

        mov 	r0, r6                  //returns the new Y in r0

        pop 	{r5,r6,r7,lr}
        mov 	pc, lr

Landed:
        cmp 	r6, #3                  //if it lands and the top left is at 3 its game over
        ble 	LostGame
        mov 	r0, r5                  //loads the X
        mov 	r1, r6                  //loads the y
        mov 	r2, r7                  //gets the colour
        bl      arrayToState

	ldr	r0, =Score		//gets the score
	ldrb	r1, [r0]		//loads the score to r1
	add	r1, #1
	strb	r1, [r0]

	bl	ConvertScoreToDigits
	bl	DrawScore

	cmp	r1, #150
	bge	WonGame

        mov 	r1, #1                  //tells it the it landed        
        b 	endDropFunction



//-----------------------------------------------------------------------------------------------------------------
//pass in x in r0 and y in r1
//pass into r2 the colour
.globl addToState
addToState:
        push 	{r4,r5,lr}

        mov 	r3, r2                      //stores the colour 
        mov 	r5, #10 

        sub 	r0, #11                     //subtract 11 from x to get to 0
        sub 	r1, #3                      //subtract three from y to get 0
        ldr 	r2, =gameState              //get the array

        mul 	r4, r1, r5                  //multiply the y by 10
        add 	r4, r0                      //add x

     
        strb 	r3, [r2, r4]               //store into the array

        add 	r0, #11     		//subtract 11 from x to get to 0
        add 	r1, #3     		//subtract three from y to get 0
   
        pop 	{r4,r5,lr}
        mov 	pc, lr

//-----------------------------------------------------------------------------------------------------------------
//pass in x in r0 and y in r1
.globl clearFromState
clearFromState:
        push 	{r4,r5,lr}
                
        mov 	r5, #10        
        
        sub 	r0, #11     //subtract 11 from x to get to 0
        sub 	r1, #3      //subtract three from y to get 0

        ldr 	r2, =gameState      //get the array

        mul 	r4, r1, r5             //multiply the y by 10
        add 	r4, r0              //add x


        mov 	r3, #0                  //add 0
        strb 	r3, [r2, r4]           //store into the array

        add 	r0, #11     //subtract 11 from x to get to 0
        add 	r1, #3      //subtract three from y to get 0

        pop 	{r4,r5,lr}
        mov 	pc, lr
//-----------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------
//pass in x in r0 and y in r1
//r3 contains a 1 if there is a bit
.globl checkABox
checkABox:
        push 	{r4,r5,lr}
                
        mov 	r5, #10        
        
        sub 	r0, #11     //subtract 11 from x to get to 0
        sub 	r1, #3      //subtract three from y to get 0

        ldr 	r2, =gameState      //get the array

        mul 	r4, r1, r5             //multiply the y by 10
        add 	r4, r0              //add x


        ldrb 	r2, [r2, r4]           //gets the box colour
	cmp 	r2, #0	            //if its a 0
	moveq 	r3, #0		    //loads 0 into r3
	movne 	r3, #1	             //loads the 1 into r3


        add 	r0, #11     //subtract 11 from x to get to 0
        add 	r1, #3      //subtract three from y to get 0

        pop 	{r4,r5,lr}
        mov 	pc, lr
//-----------------------------------------------------------------------------------------------------------------


//r0 = x               
//r1 = y
//return r3 with 1 for if there is a collision
//return in r0, #1 if the game ends
collisionCheck:
        push 	{r4,r5,lr}
        
        mov 	r6, r1                      //stores the y in r6
               
        mov 	r5, #10        

        sub 	r0, #11                     //subtract 11 from x to get to 0
        sub 	r1, #3                      //subtract three from y to get 0
        ldr 	r2, =gameState               //get the array
        add 	r1, #1                      //check the next y
        mul 	r4, r1, r5                  //multiply the y by 10
        add 	r4, r0                      //add x

        ldrb 	r3, [r2,r4]                //r3 now has the number 

        cmp     r3, #0                      //compare if 1 if there is collison
        bne     endCollisionCheck           //branch is there is no collsion
        mov     r3,#1                      //tells it there is a collision
        cmp     r6, #3                     //checks if it collides at the top
        beq     LostGame
        
endCollisionCheck:

        add 	r0, #11     //subtract 11 from x to get to 0
        add 	r1, #3      //subtract three from y to get 0

        pop 	{r4,r5,lr}
        mov 	pc , lr

//---------------------------------------------------------------------------------------------------
//r0 = x value of Top Left
//r1 = y value of top left
//r2 = block type
//returns 1 in r0 if it is not a valid move
//this the function for blocks 2-7
arrayToState:
        push 	{r4-r12, lr}

        cmp 	r2, #1       //checks if it is an I
        beq 	arrayToStateI  //branches to I check

        mov 	r4, r0      //stores the x value
        mov 	r5, r1      //stores the y value
        mov 	r6, r2      //stores shape
        mov 	r7, #0      //the counter
        bl 	GetGrid              //returns the grid in r7
        mov 	r8, r0      //stores the grid
        mov 	r9, r4      //the x value
        add 	r9, #2      //x value boundary

addingLoop:
        ldrb 	r10, [r8,r7]       //checks for a number in there
        cmp 	r10, #0             //if there isnt
        beq     nextAddSpot        //just jump to check next spot

                                //if there is a number to be added
        mov 	r0, r4              //gets the x
        mov 	r1, r5              //gets the Y
        mov 	r2, r6              //gets the colour
        bl 	addToState

nextAddSpot:
        add 	r7, #1              //increment the counter 
        add 	r4, #1              //moves onto the next x
        cmp 	r4, r9              //checks it it is past x
        ble 	addingLoop         //keep checking if it isnt
 
       
        sub 	r4, #3              //moves back to normal x
        add 	r5, #1              //moves onto the next y
        cmp 	r7, #8             //checks if end of the array

        ble 	addingLoop         //if not yet done move to next element

endAddArray:
        pop 	{r4-r12, lr}
        mov 	pc, lr
//----------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------
//r0 = x value of Top Left
//r1 = y value of top left
//r2 = block type
//returns 1 in r0 if it is not a valid move
//this the function for blocks 2-7
arrayToStateI:
      
        mov 	r4, r0      //stores the x value
        mov 	r5, r1      //stores the y value
        mov 	r6, r2      //stores shape
        mov 	r7, #0      //the counter
        bl 	GetGrid              //returns the grid in r7
        mov 	r8, r0      //stores the grid
        mov 	r9, r4      //the x value
        add 	r9, #3      //x value boundary

addingLoopI:
        ldrb 	r10, [r8,r7]       //checks for a number in there
        cmp 	r10, #0             //if there isnt
        beq     nextAddSpotI        //just jump to check next spot

                                //if there is a number to be added
        mov 	r0, r4              //gets the x
        mov 	r1, r5              //gets the Y
        mov 	r2, r6              //gets the colour
        bl 	addToState

nextAddSpotI:
        add 	r7, #1              //increment the counter 
        add 	r4, #1              //moves onto the next x
        cmp 	r4, r9              //checks it it is past x
        ble 	addingLoopI         //keep checking if it isnt
 
       
        sub 	r4, #4              //moves back to normal x
        add 	r5, #1              //moves onto the next y
        cmp 	r7, #15             //checks if end of the array

        ble 	addingLoopI         //if not yet done move to next element

endAddArrayI:
        b 	endAddArray
//----------------------------------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------------------
//r0 = x value of Top Left
//r1 = y value of top left
//r2 = block type
//returns 1 in r0 if it is not a valid move
//this the function for blocks 2-7
.globl potentialArray
potentialArray:
        push 	{r4-r12, lr}


        cmp 	r2, #1      //checks if it is an I
        beq 	potentialArrayI     //branches to a potential array
     
        mov	 r4, r0      //stores the x value
        mov 	r5, r1      //stores the y value
        mov 	r6, r2      //stores shape
        mov 	r7, #0      //the counter
        bl 	GetGrid              //returns the grid in r7
        mov 	r8, r0      //stores the grid
        mov 	r9, r4      //the x value
        add 	r9, #2      //x value boundary


CompareLoop:
        ldrb 	r10, [r8,r7]       //checks for a number in there
        cmp 	r10, #0             //if there isnt
        beq     nextSpot        //just jump to check next spot

        cmp 	r4, #11              //checks if it is out of bounds on left
        blt 	InvalidMove          //branches if not legal
        cmp 	r4, #20              //checks if it is out of bounds on right
        bgt 	InvalidMove         //branches if not legal
        cmp 	r5, #22             //checks if y is 21
        beq 	InvalidMove         //it has hit the bottom       
     
        mov 	r0, r4              //gets the x
        mov 	r1, r5              //gets the Y
        mov 	r2, r6              //gets the colour
        bl 	checkABox            //checks the state if there is also a number
        cmp 	r2, #0              //if there isnt
        beq 	nextSpot            //continues

        b 	InvalidMove           //else its invalid

nextSpot:
        add 	r7, #1              //increment the counter 
        add 	r4, #1              //moves onto the next x
        cmp 	r4, r9              //checks it it is past x
        ble 	CompareLoop         //keep checking if it isnt
 
       
        sub	r4, #3              //moves back to normal x
        add 	r5, #1              //moves onto the next y
        cmp 	r7, #8             //checks if end of the array

        ble 	CompareLoop         //if not yet done move to next element

        mov 	r0, #0              //if its end

        b 	endPotentialArray
InvalidMove:
        mov 	r0, #1

endPotentialArray:
        pop 	{r4-r12, lr}
        mov 	pc, lr

//----------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------
//r0 = x value of Top Left
//r1 = y value of top left
//r2 = block type
//returns 1 in r0 if it is not a valid move
//this the function for block 1
potentialArrayI:
        mov 	r4, r0      //stores the x value
        mov 	r5, r1      //stores the y value
        mov 	r6, r2      //stores shape
        mov 	r7, #0      //the counter
        bl 	GetGrid              //returns the grid in r7
        mov 	r8, r0      //stores the grid
        mov 	r9, r4      //the x value
        add 	r9, #3      //x value boundary

CompareLoopI:
        ldrb 	r10, [r8,r7]       //checks for a number in there
        cmp 	r10, #0             //if there isnt
        beq     nextSpotI        //just jump to check next spot

        cmp 	r4, #11              //checks if it is out of bounds on left
        blt 	InvalidMoveI          //branches if not legal
        cmp 	r4, #20              //checks if it is out of bounds on right
        bgt 	InvalidMoveI         //branches if not legal
        cmp 	r5, #22             //checks if y is 21
        beq 	InvalidMoveI         //it has hit the bottom 
      
        mov 	r0, r4              //gets the x
        mov 	r1, r5              //gets the Y
        mov	r2, r6              //gets the colour
        bl 	checkABox            //checks the state if there is also a number
        cmp	 r2, #0              //if there isnt
        beq 	nextSpotI            //continues
        
        b 	InvalidMoveI

nextSpotI:
        add 	r7, #1              //increment the counter 
        add 	r4, #1              //moves onto the next x
        cmp 	r4, r9              //checks it it is past x
        ble 	CompareLoopI         //keep checking if it isnt
        
        sub 	r4, #4              //moves back to normal x
        add 	r5, #1              //moves onto the next y
        cmp 	r7, #15             //checks if end of the array

        ble 	CompareLoopI         //if not yet done move to next element


        mov 	r0, #0              //if its end
        b 	endPotentialArrayI
InvalidMoveI:
        mov 	r0, #1

endPotentialArrayI:
        b 	endPotentialArray

//----------------------------------------------------------------------------------------------------------------
checkLineComplete:
        push 	{r4-r12, lr}
        mov 	r4, #0              // x-coordinate
        mov 	r5, #0              // y- coordinate
        mov 	r6, #0              //counter for array index
        ldr 	r7, =gameState      //gets the game state
        mov 	r8, #0              //counter for line in row

checkLine:
        ldrb 	r9, [r7,r6]        //gets the current state of that block
        cmp 	r9, #0              //if it is empty
        addne 	r8,#1             //add 1 if it not empty
        add 	r6, #1              //move to next index
        add 	r4, #1              //adds to x

        cmp 	r8, #10             //if there it added up the row
        beq 	foundLine           //tell it there is a line found
        cmp 	r4, #9              //row width is 10
        ble 	checkLine         //stays on x while less than 9
        mov 	r8, #0
        mov 	r4, #0              //resets x
        add 	r5, #1              //adds to y
        cmp 	r5, #18             //pass the y
        ble 	checkLine         //branches back

endCheckLine:
        pop 	{r4-r12, lr}
        mov 	pc,lr

foundLine:
        mov 	r0, r5              //r5 now has the proper column
        bl 	clearRow
        sub 	r5, #1              //move one column up
        cmp 	r5, #0              //compares it to 0
        blt 	dropState           //jumps to end if not
        mov 	r0, r5              //passes new column as parameter
        bl 	moveDown             //calls movedown
        b 	foundLine

dropState:   
	ldr	r0, =Score			//gets the score
	ldrb	r1, [r0]			//loads the score to r1
	ldr	r2, =LineBreakCounter		//gets the count
	ldrb 	r3, [r2]			//loads the count to r3
	add	r1, r3				//score = score + count
	strb	r1, [r0]			//stores it back into the score

	mov r4, #15				//gets 15 
	strb r4, [r2]				//stores 15	

	ldr	r0, =LineBreaks
	ldrb	r1, [r0]
	add	r1, #1
	strb	r1, [r0]

	ldr	r0, =Score			//gets the score
	ldrb	r1, [r0]			//loads the score to r1

	bl	ConvertScoreToDigits
	bl	DrawScore

	cmp	r1, #150
	bge	WonGame

        bl printState
        b endCheckLine

//------------------------------------------------------------------------------------------------------------------------------
printState:
        push {r4-r10,lr}
        
        mov r4, #0              // x-coordinate
        mov r5, #0              // y- coordinate
        mov r6, #0              //counter for array index
        ldr r7, =gameState      //gets the game state
        mov r9, #11             //offset of x
        mov r10, #3             //offset of y
printXState:
        ldrb r8, [r7,r6]        //gets the current state of that block
        add r0,r4,r9             //sets the X
        add r1,r5,r10            //sets the y
        mov r2, r8              //sets the colour
        bl CheckColour          //erases a block
        add r6, #1              //move to next index
        add r4, #1              //adds to x
        cmp r4, #9              //row width is 10
        ble printXState         //stays on x while less than 9
        mov r4, #0              //resets x
        add r5, #1              //adds to y
        cmp r5, #18             //pass the y
        ble printXState         //branches back

        pop {r4-r10,lr}
        mov pc, lr
//-----------------------------------------------------------------------------------------------------------------
//r0 = column to get row
moveDown:
        push {r4-r9, lr}
   
        ldr r4, =gameState              //gets the game state
        mov r5, #10                     //multiplier
        mul r0,r5                       //col *10 for offset
        mov r6, #0                      //the clear bit
        mov r7, #0                      //the x counter
        mov r8, #9                      //the extra x
        add r9, r0, r8                  //number to compare to

moveDownRow:
        ldrb r6, [r4,r0]                //gets the bit
        add r0, #10                     //looks right unfer
        strb r6, [r4, r0]               //gets the bit
        sub r0, #10                     //goes back up a y
        add r0, #1                      //moves to next spot
        cmp r0, r9                      //if it is less than 9
        ble moveDownRow                      //keep brancgin while less than               

        pop {r4-r9, lr}
        mov pc, lr


//------------------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------
//r0 = column to get row
clearRow:
        push {r4-r9, lr}
   

        ldr r4, =gameState              //gets the game state
        mov r5, #10                     //multiplier
        mul r0,r5                       //col *10 for offset
        mov r6, #0                      //the clear bit
        mov r7, #0                      //the x counter
        mov r8, #9                      //the extra x
        add r9, r0, r8                  //number to compare to

forRow:

	ldrb r1, [r4, r0]               //gets the bit
	cmp r1, #8			//if it is an bomb
	beq bombFound			//bombFound

        strb r6, [r4, r0]               //gets the bit
        add r0, #1                      //moves to next spot
        cmp r0, r9                      //if it is less than 9
        ble forRow                      //keep brancgin while less than               

        pop {r4-r9, lr}
        mov pc, lr


bombFound:

	bl resetState
	bl printState	
	
	ldr	r0, =Score			//gets the score
	ldrb	r1, [r0]			//loads the score to r1
	add	r1, #40
	strb	r1, [r0]

	bl	ConvertScoreToDigits
	bl	DrawScore
	
	pop {r4-r9, lr}
	mov pc, lr

//-----------------------------------------------------------------------------------------------------------------

//r0 = x               
//r1 = y
//return r3 with 1 for if there is a collision
.globl collisionCheckLeft
collisionCheckLeft:
        push {r4,r5,lr}
                
        mov r5, #10        

        sub r0, #11             //subtract 11 from x to get to 0
        sub r1, #3              //subtract three from y to get 0
        ldr r2, =gameState      //get the array
        sub r4, #1              //check beside left
        mul r4, r1, r5          //multiply the y by 10
        add r4, r0              //add x

        ldrb r3, [r2,r4]           //r3 now has the number 

        cmp r3, #1              //compare if 1 if there is collison
        moveq r3,#1             //tells it there is a collision
        
        add r0, #11     //subtract 11 from x to get to 0
        add r1, #3      //subtract three from y to get 0

        pop {r4,r5,lr}
        mov pc , lr

//------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------
//r0 = x               
//r1 = y
//return r3 with 1 for if there is a collision
.globl collisionCheckRight
collisionCheckRight:
        push {r4,r5,lr}
                
        mov r5, #10        

        sub r0, #11             //subtract 11 from x to get to 0
        sub r1, #3              //subtract three from y to get 0
        ldr r2, =gameState      //get the array
        add r4, #1              //check beside left
        mul r4, r1, r5          //multiply the y by 10
        add r4, r0              //add x

        ldrb r3, [r2,r4]           //r3 now has the number 

        cmp r3, #1              //compare if 1 if there is collison
        moveq r3,#1             //tells it there is a collision
        
        add r0, #11     //subtract 11 from x to get to 0
        add r1, #3      //subtract three from y to get 0

        pop {r4,r5,lr}
        mov pc , lr


//------------------------------------------------------------------------------------------------------------------------------
//returns a 1 in r0 if game is over
//passes in r0 which is the current x value
checkGameOver:
        push {r5-r7,lr}

        add r5, r0, #10                     //gets the index
        ldr r6, =gameState              //gets the game state
checkFirstRow:
        ldrb r7, [r6, r5]               //loads the byte onto array
        cmp r7, #1                      //if theres a byte on the top row
        beq gameIsOver                  //player loses
        

        mov r0, #0
        b endCheckGameOver

gameIsOver:
        mov r0, #1        
                
endCheckGameOver:
        pop {r5-r7,lr}

        mov pc, lr

//------------------------------------------------------------------------------------------------------------------------------
//Draws the block and returns its x and y in r0 and r1
spawnBlock:
        push {r4,r5,lr}

checkAgain:  


	ldr	r0, =0x3F003004			//CLO
	ldr	r1, [r0]			//Current time
	ldr	r2, =TimeToWait			//Time to wait
	ldr	r3, [r2]
	cmp	r1, r3				//If CLO is greater than time to wait
	bge	SpawnValuePack

        mov r4, #14                     //the x
        mov r5, #3                      //the y
        mov r6, #0                      //the colour

        bl      RNG
        cmp r0, #0             //checks if its a black box
        beq checkAgain          //pick new block
        mov r6, r0             //stores the colour


        mov r0, r4             //posistion of x need to 15
        mov r1, r5              //position of y need to have 3
        mov r2, r6              //the colour
        bl CheckShape  
      


        mov r0, #14
        mov r1, #3
        mov r2, r6              //returns colour

endSpawnBlock:
        pop {r4,r5,lr}

        mov pc, lr

//------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------
clearFunction:
        push {r5,r6,lr}
        mov r5, r0              //stores the x to clear
        mov r6, r1              //stores the y to clear

        mov r0, r5              //gets x
        mov r1, r6              //gets y
        bl      eraseBlock

        mov r0, r5              //gets x
        mov r1, r6              //gets y
        bl      clearFromState

        pop {r5,r6,lr}

        mov pc, lr

//------------------------------------------------------------------------------------------------------------------------------
//takes r0 = x and r0 = y
drawFunction:
        push {r5-r7,lr}

        mov r5, r0              //stores the x to clear
        mov r6, r1              //stores the y to clear
        mov r7, r2              //stores the colour

        mov r0, r5              //gets x
        mov r1, r6              //gets y
        bl     CheckColour

        mov r0, r5              //gets x
        mov r1, r6              //gets y
        mov r2, r7              //gets the colour
        bl      addToState

        pop  {r5-r7,lr}

        mov pc,lr

//------------------------------------------------------------------------------------------
//			ROTATE FUNCTIONS
/*
This subroutine checks which shape to rotate and rotates that shape.
        Updates the 3 by 3 grid of each shape and a 4x4 for the special
        case I shape.

        0 - Rotates the I shape (special case)
        3 - No rotation needed (0 shape)
        The rest is rotated to the right everytime this function is called.

Parameters:
        r0 - which shape to rotate
        r2 - address of the grid to rotate
FunctionsUsed:
        None        
*/
.globl CheckRotatingShape      
CheckRotatingShape:
        push     {r4-r12,lr}    
        cmp      r0, #1
        beq      RotateIShape

        cmp      r0, #4
        beq      ExitRotateShape
        bne      RotateCorners
     
RotateIShape: 
      
        mov r11, #0                             //changes the posistion
        mov r12, #1                             //changes the posistion
        ldr r0, =IShapePosistion                 //loads the posistion for the i shape
        ldrb r1, [r0]                           //checks the posistion
        cmp r1, #0                              //if its not rotated yet   
        ldreq r3,=IShapeRotate                   //loads the rotated version to store
        streqb r12, [r0]                        //turn it into a 1 
        ldrne r3,=IShapeNormal                               //loads the unrotated 
        strneb r11, [r0]                        //turn it into a 0        

        ldr     r2, =IShapeGrid
        mov     r4, #0          // counter for index

RotateIShapeLoop:     	// Rotates the special shape I
        cmp     r4, #16
        bge     ExitRotateShape
                                           
        ldrb    r0, [r3, r4]	// Overwrites the value of the I shapes with the rotated shape
        
        strb    r0, [r2, r4]
        add     r4, #1
        b       RotateIShapeLoop   
             
RotateCorners:			// Rotates the corners of the shape (3x3 grids)
        mov     r3, #0
        mov     r4, #2
        mov     r5, #6
        mov     r6, #8
        
        ldrb    r7, [r2,r3]		// Loads the corners and shifts them to the right corners
        ldrb    r8, [r2,r4]
        ldrb    r9, [r2,r5]
        ldrb    r10, [r2,r6]
        
        strb    r7, [r2,r4]		// Storing the right corners to the shifted corners
        strb    r8,[r2,r6]
        strb    r9,[r2,r3]
        strb    r10,[r2,r5]
    
RotateMiddle:			// Rotates the middle part of the shapes appropriately (3x3 grids)
        mov     r3, #1
        mov     r4, #3
        mov     r5, #5
        mov     r6, #7
        
        ldrb    r7, [r2,r3]	// Loads the middle parts and shifts them
        ldrb    r8, [r2,r4]
        ldrb    r9, [r2,r5]
        ldrb    r10, [r2,r6]
        
        strb    r7, [r2,r5]	// Stores the middle parts of the shape to the appropriate part
        strb    r8,[r2,r3]
        strb    r10,[r2,r4]
        strb    r9,[r2,r6]
        b       ExitRotateShape
       
ExitRotateShape:        
        pop     {r4-r12,lr}
        mov     pc, lr

//-----------------------------------------------------------------------------
/*
This subroutine will undo a rotation in case the user is unable to rotate
        0 - UnRotates the I shape (special case)
        3 - No rotation needed (0 shape)
        The rest is rotated to the LEFT everytime this function is called.

Parameters:
        r0 - which shape to rotate
        r2 - address of the grid to rotate
FunctionsUsed:
        None   
*/
.globl  UnRotateShape
UnRotateShape:		// Unrotates a shape if its not allowed to rotate
        push     {r4-r12,lr}    
        cmp      r0, #1		// Checks to see which shape should be rotated
        beq      UnRotateIShape
        cmp      r0, #4
        beq      ExitUnRotateShape
        bne      UnRotateCorners
     
UnRotateIShape: 

        mov r11, #0                             //changes the posistion
        mov r12, #1                             //changes the posistion
        ldr r0, =IShapePosistion                 //loads the posistion for the i shape
        ldrb r1, [r0]                           //checks the posistion
        cmp r1, #0                              //if its not rotated yet   
        ldreq r3,=IShapeRotate                   //loads the rotated version to store
        streqb r12, [r0]                        //turn it into a 1 
        ldrne r3,=IShapeNormal                               //loads the unrotated 
        strneb r11, [r0]                        //turn it into a 0        

    
        ldr     r2, =IShapeGrid
        mov     r4, #0                           // counter for index

UnRotateIShapeLoop: 		// Special case (rotates the I shape)
        cmp     r4, #16
        bge     ExitUnRotateShape                                          
        ldrb    r0, [r3, r4]		// Loads the address of the I shape
        
        strb    r0, [r2, r4]		// Stores the new value onto the I shape grid
        add     r4, #1

        b       UnRotateIShapeLoop   
             
UnRotateCorners:		// Unrotates the corners of each shape
        mov     r3, #0
        mov     r4, #2
        mov     r5, #6
        mov     r6, #8
        
        ldrb    r7, [r2,r3]		// Loads the corner values and moves them around
        ldrb    r8, [r2,r4]
        ldrb    r9, [r2,r5]
        ldrb    r10, [r2,r6]
        
        strb    r7, [r2,r5]		// Stores the new values onto the grid with the right corners
        strb    r8,[r2,r3]
        strb    r9,[r2,r6]
        strb    r10,[r2,r4]
    
UnRotateMiddle:			// Rotates the middle part of the shape
        mov     r3, #1
        mov     r4, #3
        mov     r5, #5
        mov     r6, #7
        
        ldrb    r7, [r2,r3]	// Loads the middle part of the shape and shifts them
        ldrb    r8, [r2,r4]
        ldrb    r9, [r2,r5]
        ldrb    r10, [r2,r6]
        
        strb    r7, [r2,r4]	// Stores the middle part of the shape to its unrotated version
        strb    r8,[r2,r6]
        strb    r10,[r2,r5]
        strb    r9,[r2,r3]
        b       ExitUnRotateShape
       	
ExitUnRotateShape:        	// Exits the unrotate shape
        pop     {r4-r12,lr}
        mov     pc, lr  


//------------------------------------------------------------------------------------------
//			resetState
.globl resetState		//Resets the array of the game state
resetState:
	ldr	r0, =gameState	//Address of array
	mov	r1, #0		//Counter
	mov	r2, #0		//Value to store
resetLoop:
	strb	r2, [r0], #1	//Store 0 into array. Increment
	add	r1, #1		//Add 1 to counter
	cmp	r1, #190	//Stop when end of list is reached
	beq	endResetLoop
	b	resetLoop
endResetLoop:
	mov	pc, lr		//Return

//------------------------------------------------------------------------------------------
//			ConvertScoreToDigits
/*
This subroutine converts the integer scores into separate digits so it can be
        printed onto the screen
Parameters:
        None
Returns:
        Stores the ASCII converted score onto ScoreASCII
Registers used:
        r4 - contains the address to the score (byte)
        r5 - contains the address to the ASCII score                      
        
*/
.globl  ConvertScoreToDigits
ConvertScoreToDigits:
        push    {r4-r10,lr}
        ldr     r4, =Score 	// Loads the address of score to r4
        ldr     r5, =ScoreASCII // Loads the address of ASCII to r5
        ldrb    r6, [r4]

ConvertingToASCII:
	cmp     r6, #9		//Compares if the score is one digit, two digit or one digit
        ble     OneDigit
        cmp     r6, #99
        ble     TwoDigit
        
ThreeDigit:                     // If a three digit score
        mov     r7, #1
        strb    r7, [r5]
        mov     r7, r6          // Always stores the value 1         
        sub     r7, #100        // Subtracts the 3 digit with 100 (to get the two digits after)
        sub     r6, #100        // Subtracts the 3 digit with 100 (copy of the score)
        mov     r8, #0                                  // Counter for the loop

SubtractTenLoopThreeDigit:      // Gets the remainder (third digit)
        cmp     r7, #10
        blo     EndSubtractThreeDigit
        sub     r7, #10
        add     r8, #1
        b       SubtractTenLoopThreeDigit
        
EndSubtractThreeDigit:          // Stores the second and third digit
        mov     r9, r8
        mov     r10, #10
        mul     r8, r10
        sub     r6, r8
        
        strb    r9, [r5,#1]
        strb    r6, [r5, #2]
        b       ExitConvertScoreToASCII

OneDigit:                       // One digit score
        strb    r6, [r5,#2]
        b       ExitConvertScoreToASCII
        
TwoDigit:                       // Two digit score
        mov     r7, r6
        mov     r8, #0
        
SubtractTenLoop:                // Gets the remainder (second digit)
        cmp     r7, #10
        blo     EndSubtract
        sub     r7, #10
        add     r8, #1
        b       SubtractTenLoop
EndSubtract:
        mov     r9, r8          // Converts to ASCII
        mov     r10, #10
        mul     r8, r10
        sub     r6, r8
        
        strb    r9, [r5, #1]        // Stores the ASCII back to the ASCII buffer
        strb     r6, [r5, #2]
        b       ExitConvertScoreToASCII
        
ExitConvertScoreToASCII:        // Exits the function
        pop     {r4-r10,lr}
        mov     pc, lr

//-----------------------------------------------------------------------------------
//			Increment Score
/*
This subroutine increments the score according to how many 
        lines the user has cleared
Parameters:
        None
Returns:
        The incremented score according to how many lines 
                cleared
Registers Used:
        r4 - address to how many lines cleared
        r6 - address to the current score                                       
*/
.globl  IncrementScore
IncrementScore:                         // Increments the score
        push    {r4-r9,lr}
        ldr     r4, =LineBreakCounter
        ldrb    r5, [r4]
        cmp     r5, #1
        beq     OneLineScore
	bne	MultipleLineScore
OneLineScore:                            // Increments the score by 10 (one line)
        ldr     r6, =Score
        ldrb    r7, [r6]
        add     r7, #10
        strb    r7, [r6]
        b       ExitIncrementScore
TwoLineScore:
	ldr	r6, =Score
	ldrb	r7, [r6]
	add	r7, #20
	strb	r7,[r6]
	b	ExitIncrementScore
MultipleLineScore:                        // Increments the score by 15 (line x 15)
        ldr     r6, =Score
        ldrb    r7, [r6]
	add	r7, #15
	mov     r8, #15
        mul     r9, r5, r8
	add     r7, r9
        strb    r7, [r6]                  // Stores the score back to the buffer
        b       ExitIncrementScore
ExitIncrementScore:                       // Exits increment score
        pop     {r4-r9,lr}
        mov     pc,lr                

.section .data

.align
gameState:	//An array representing the game state
	.rept	190
	.byte	0
	.endr

IShapeRotate:
        .byte   1,0,0,0
        .byte   1,0,0,0
        .byte   1,0,0,0
        .byte   1,0,0,0    

IShapeNormal:
        .byte   1,1,1,1
        .byte   0,0,0,0
        .byte   0,0,0,0
        .byte   0,0,0,0  

IShapePosistion:
        .byte 0 

Score:
	.byte 0

.globl ScoreASCII
ScoreASCII:
        .byte   0,0,0
LineBreakCounter:
	.byte	10
LineBreaks:
	.byte	0

.align 4
.globl	TimeToWait
TimeToWait:
	.int	0
