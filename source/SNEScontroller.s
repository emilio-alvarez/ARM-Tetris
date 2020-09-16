/*Global Methods:
	- Init_GPIO:
		> r0: Line number (9 for latch, 10 for data, 11 for clock
		> r1: Function code (1 for set (output), 7 for clear (input))
	- ReadSNES:
		> Returns: r0 = the code of the buttons
	- Wait:
		> r3: Number of microseconds to wait
	- ReadButtons:
		> Returns: r0 = index of pressed button
	- ReadGameButtons:
		> Returns: r0, r1. New X and Y coordinates
		> up, left, and right press check
*/
.globl ReadButtons
ReadButtons:                // Reads the button the user pressed
	push	{r4-r7, lr}
ButtonsRead:	
	bl      ReadSNES                        // Returns the 16 bits in r0
        cmp     r0,r10                          // Checks if the state is same as last
        beq     SameState                       // Makes it wait 
        mov     r10,r0                          // Keeps track of the state
  	mov     r6, r0                          // R6 will now contain the code after ReadSNES ex: 1111111111110 means b is pressed    
	mov     r4, #0                          // Initalize the counter   
	mov     r5, #1                          // This is the bit = 000000001
 	mvn     r5, r5                          // This reverses it to be 1111111110  

CheckPressedButtons:    // Checks the register which button is pressed
	bic     r7, r6, r5                      // Bit clears the register to check 
  	cmp     r7, #0                          // Which button is pressed      
	beq     ButtonPressed                   // If a button is pressed it jumps out of the loop
	lsr	r6, #1                          // Checks the next bit if pressed
	add	r4, #1                        
	cmp	r4, #11                         // Loops out once every bit is checked
	ble	CheckPressedButtons
	b       ButtonsRead

ButtonPressed:          // Prints out the button that was pressed by the user
	mov	r0, r4
	pop	{r4-r7, lr}
	mov	pc, lr

SameState:                                      // If it is the same state it will go into this loop
        add     r3, #28                         // Wait 28 micro seconds
        bl      Wait                            // Takes in input r3 = the time it wants to wait      
        b       ButtonsRead                     // Branches back to read the buttons

//----------------------------------------------------------------------------------------------
//				ReadGameButtons
//Returns:
//	r0 = new X
//	r1 = new Y
.globl ReadGameButtons
ReadGameButtons:         // Reads the button the user pressed
	push	{r4-r12, lr}
        mov     r8, r0           	//xCoordinate
        mov     r9, r1           	//y coordinate  

	ldr     r3, =ColourOfBlock              //address of memory address
        strb    r2, [r3]                        //stores in memory the block number

        ldr     r11, =0x3F003004        //load clock in in r11 
        ldr     r12, [r11]                                            
        ldr     r0, =150000
        add     r12, r0                 //r12 has time to wait for 
                         
ButtonsRead2:
	bl      ReadSNES                // Returns the 16 bits in r0
        cmp     r0,r10                  // Checks if the state is same as last
        beq     SameState2              // Makes it wait 
        mov     r10,r0                  // Keeps track of the state
  	mov     r6, r0                  // R6 will now contain the code after ReadSNES ex: 1111111111110 means b is pressed    
	mov     r4, #0                  // Initalize the counter   
	mov     r5, #1                  // This is the bit = 000000001
 	mvn     r5, r5                  // This reverses it to be 1111111110  

CheckPressedButtons2:    // Checks the register which button is pressed
	bic     r7, r6, r5              // Bit clears the register to check 
  	cmp     r7, #0                  // Which button is pressed      
	beq     ButtonPressed2          // If a button is pressed it jumps out of the loop
	lsr	r6, #1                  // Checks the next bit if pressed
	add	r4, #1                        
	cmp	r4, #11                 // Loops out once every bit is checked
	ble	CheckPressedButtons2

        ldr     r0, [r11]               //check clock
        cmp     r12, r0			// clock in r11
	bhi	ButtonsRead2
        b       endRead2       

ButtonPressed2:          // Prints out the button that was pressed by the user
      
        //r0 = 6 means left
        cmp 	r4 ,#6
        moveq   r0, r8                  //puts x in r0
        moveq   r1, r9                  //puts y in r1
        bleq    leftPressCheck          //checks the left side sets 0 flag if equal 
        subeq   r8,#1              
        cmp 	r4 ,#6	                //recheck        
        beq     ButtonsRead2

        //r0 = 7 means right
        cmp     r4 ,#7
        moveq   r0, r8                  //puts x in r0
        moveq   r1, r9                  //puts y in r1
        bleq    rightPressCheck
        addeq   r8, #1
        cmp     r4 ,#7
        beq     ButtonsRead2

	//r0 = 0 means B
	cmp     r4, #0                  //if user presses B
        moveq   r0, r8                  //puts x in r0
        moveq   r1, r9                  //puts y in r1
        bleq    upPressCheck
        cmp     r4 ,#7                          
        beq     ButtonsRead2

        //r0 == 3 mean start
        cmp     r4, #3
        bleq    pauseMidGame
        b       ButtonsRead2

SameState2:              // If it is the same state it will go into this loop
        add     r3, #0                	// Wait 28 micro seconds. Adjust according to preference
        bl      Wait                    // Takes in input r3 = the time it wants to wait  
        
        ldr     r0, [r11]              	//check clock
        cmp     r12, r0			// clock in r11
	bhi     ButtonsRead2    
        b       endRead2                // Branches back to read the buttons

endRead2:
        mov     r0,r8
        mov     r1,r9        
        pop	{r4-r12, lr}
        mov 	pc, lr

//----------------------------------------------------------------------------------------------
//			upPressCheck
//r0 will contain the posistion of X
//r1 will contain the posistion of Y
upPressCheck:
        push {r4,r5,r6,r8,lr}

        mov r4, r0              //stores x
        mov r5, r1              //stores y
	  
	ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]                        //loads the block number
	cmp	r2, #8				//checks if its the value pack
	beq	endUpValue
	
        //rotate the shape

        ldr     r8, =ColourOfBlock              //address of memory address

        ldrb    r2, [r8]                        //gets the colour         
        bl      GetGrid                         //gets the proper grid
        mov r2, r0                              //saves the grid
        ldrb r0,  [r8]                          //gets the shape
        bl CheckRotatingShape                   //rotates the grid passed in
        
        //check if the shape is allowed to be rotated        
        ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]                        //loads the block number 
        mov     r0, r4                          //sets x
        mov     r1, r5                          //sets y      
        bl potentialArray                       //returns in r0 = 0 if it is valid

                                               //returns in r0 = 1 if it is not valid
        cmp r0, #1                              //if it is not valid
        beq failUpCheck                       //fails up and unrotates the array

//if it passes unrotate the block , clear ,then rotate and print then return
//----------------------------------------------------------------------------
        ldrb    r2, [r8]                        //gets the colour         
        bl      GetGrid                         //gets the proper grid
        mov r2, r0                              //saves the grid
        ldrb r0,  [r8]                          //gets the shape
        bl UnRotateShape                        //unrotates


                                               
        mov r0 , r2
        ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]  
        bl      GetGrid
        mov r2, r0                              //saves the grid   
        mov r0, r4                              //r0 = x
        mov r1, r5                              //the Y 
        ldr     r8, =ColourOfBlock              //address of memory address 
        ldrb    r3, [r8]   
        bl ClearShape                           //clears the current shape

//----------------------------------------------------------------------------
//I will write rotating the shape
               
        ldrb    r2, [r8]                        //gets the colour         
        bl      GetGrid                         //gets the proper grid
        mov r2, r0                              //saves the grid
        ldrb r0,  [r8]                          //gets the shape
        bl CheckRotatingShape                   //rotates the grid passed in


        //now print that new rotated array and pass it back

        mov r0, r4                              //gets the X
        mov r1, r5                              //gets the y and prints it
        ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]                        //loads the block number   
        bl CheckShape 
                            
        mov r1, #0              //tell it user it can move
        cmp r1, #0              //sets the zero flag 
        b     endUpCheck 

failUpCheck:

        ldrb    r2, [r8]                        //gets the colour         
        bl      GetGrid                         //gets the proper grid
        mov r2, r0                              //saves the grid
        ldrb r0,  [r8]                          //gets the shape
        bl UnRotateShape                        //unrotates

        //unrotate the shape and sent it back
        mov r1, #1              //tell it user it cant move
        cmp r1, #0              //make sure there is no zero flag

endUpCheck:     
        pop {r4,r5,r6,r8,lr}
        mov pc, lr

endUpValue:
	mov r1, #1              //tell it user it cant move
        cmp r1, #0              //make sure there is no zero flag
	pop {r4,r5,r6,r8,lr}
	mov pc, lr

//----------------------------------------------------------------------------------------------
//			leftPressCheck
//r0 will contain the posistion of X
//r1 will contain the posistion of Y
leftPressCheck:
	ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]                        //loads the block number
	cmp	r2, #8				//checks if its the value pack
	beq	leftPressValueCheck 

        push {r4,r5,r6,r8,lr}

        mov r4, r0              //stores x
        mov r5, r1              //stores y
  
        mov r1, #1                    //number to subtract by
        sub r0, r4, r1                //r0 = x - 1
        mov r1, r5                    //the Y
        ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]                        //loads the block number    
        bl potentialArray                       //returns in r0 = 0 if it is valid
                                                //returns in r0 = 1 if it is not valid
        cmp r0, #1                              //if it is not valid
        beq failLeftCheck                       //fails left
                                                
        mov r0 , r2
        ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]  

        bl      GetGrid
        mov r2, r0    
        mov r0, r4                              //r0 = x
        mov r1, r5                              //the Y 
        ldr     r8, =ColourOfBlock              //address of memory address 
        ldrb    r3, [r8]   
        bl ClearShape

  
        mov r1, #1                    //number to subtract by
        sub r0, r4, r1                //r0 = x - 1
        mov r1, r5                    //the Y
        ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]                        //loads the block number   
        bl CheckShape                                 
       
        mov r1, #0              //tell it user it can move
        cmp r1, #0              //sets the zero flag 
        b     endLeftCheck 

failLeftCheck:
        mov r1, #1              //tell it user it cant move
        cmp r1, #0              //make sure there is no zero flag

endLeftCheck:     
        pop {r4,r5,r6,r8,lr}
        mov pc, lr

//----------------------------------------------------------------------------------------------
//			rightPressCheck
//r0 will contain the posistion of X
//r1 will contain the posistion of Y
rightPressCheck:
	ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]                        //loads the block number
	cmp	r2, #8				//checks if its the value pack
	beq	rightPressValueCheck 

        push {r4,r5,r6,r8,lr}
        
        mov r4, r0              //stores x
        mov r5, r1              //stores y
        

        mov r1, #1                    //number to add by
        add r0, r4, r1                //r0 = x - 1
        mov r1, r5                    //the Y
        ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]                        //loads the block number       
        bl potentialArray                       //returns in r0 = 0 if it is valid

                                               //returns in r0 = 1 if it is not valid
        cmp r0, #1                              //if it is not valid
        beq failRightCheck                       //fails left
                                                
        mov r0 , r2
        ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]  


        bl      GetGrid
        mov r2, r0
    
        mov r0, r4                              //r0 = x
        mov r1, r5 
        ldr     r8, =ColourOfBlock              //address of memory address 
        ldrb    r3, [r8] 
        bl ClearShape

  
        mov r1, #1                    //number to add by
        add r0, r4, r1                //r0 = x + 1
        mov r1, r5                    //the Y
        ldr     r3, =ColourOfBlock              //address of memory address
        ldrb    r2, [r3]                        //loads the block number   
        bl CheckShape

        mov r1, #0              //tell it user it can move
        cmp r1, #0              //sets the zero flag
        b     endRightCheck  

failRightCheck:
        mov r1, #1              //tell it user it can move
        cmp r1, #0              //smake sure there is no zero flag

endRightCheck:
        pop {r4,r5,r6,r8,lr}
        mov pc, lr
//----------------------------------------------------------------------------------------------
//-----------------------------------------SUBROUTINES------------------------------------------
//----------------------------------------------------------------------------------------------

.globl Init_GPIO
Init_GPIO:	        // Initializes a GPIO line.
		        // Input:
		        //	r0: Line number (9 for latch, 10 for data, 11 for clock
		        //	r1: Function code (1 for set (output), 7 for clear (input))
        push    {lr}
	cmp     r0, #9
	beq     SetLatch                        // Jumps to write latch
	cmp     r0, #10
	beq     SetData                         // Jumps to read data
	cmp     r0, #11
	beq     SetClock                        // Jumps to write clock
	
SetLatch:               // Sets GPIO pin 9 (latch) to output
        ldr     r0, =0x3F200000                 // Address of GPFSEL0
        ldr     r1, [r0]                            
        mov     r2, #7                          // Bit clears (0111)
        lsl     r2, #27                             
        bic     r1, r2                          // Clearing pin 9 bits
        mov     r3 , #1                             
        lsl     r3, #27                             
        orr     r1, r3                              
        str     r1, [r0]                         // Storing value back to GPFSEL0
        b       ExitInitGPIO
        
SetData:                // Sets GPIO pin 10 (Data) to input
        ldr     r0, =0x3F200004                  // Address of GPFSEL1
        ldr     r1, [r0]                            
        mov     r2, #7                              
        bic     r1, r2                           // Bit clears (0111)
        mov     r3 , #0                             
        orr     r1, r3                             
        str     r1, [r0]                         // Stores value back to GPFSEL1
        b       ExitInitGPIO
        
SetClock:               //Sets GPIO pin 11 (Clock) to output
        ldr     r0, =0x3F200004                  // Address for GPFSEL1
        ldr     r1, [r0]                            
        mov     r2, #7                              
        lsl     r2, #3                           // Shift left by 3
        bic     r1, r2                           // Bit clears (0111)
        mov     r3 , #1                             
        lsl     r3, #3                              
        orr     r1, r3                              
        str     r1, [r0]                         // Stores value back to GPFSEL1
        b       ExitInitGPIO

ExitInitGPIO:           // Exits the GPIO
        pop     {lr}
	mov	pc, lr

//----------------------------------------------------------------------------------------------
// Returns r0 = 0 for button pressed, 1 for button not pressed
ReadData:              // Reads a bit for the GPIO data line. Pin 10
	push 	{lr}
	mov 	r0, #10			         // Sets r0 to data line
	ldr 	r1, =0x3F200000			 // Address to base GPIO
	ldr 	r2, [r1,#52]			 // GPLEV0
	mov 	r3, #1
	lsl 	r3, r0				 
	and 	r2, r3
	teq 	r2, #0
	moveq   r0, #0				 // return 0
	movne   r0, #1				 // return 1
	pop 	{lr}
	mov     pc, lr

//----------------------------------------------------------------------------------------------
// Returns: r0 = the code of the buttons
.globl	ReadSNES	
ReadSNES:	        // Main SNES subroutine. Reads input from SNES controller.
	push 	{r4,r5,r8,lr}
        mov     r8, #0                           //buttons is empty 
	mov 	r0, #1				 // Write 1 to CLO
	bl      WriteClock
	mov 	r0, #1	 			 // Write 1 to Latch
	bl	WriteLatch                
        mov     r3, #12                          // Add 12 microseconds
	bl 	Wait                             // Waits for 12 microseconds
	mov 	r0, #0				 // Write 0 to Latch
	bl	WriteLatch
	mov 	r5, #0 			         // Counter for PulseLoop

PulseLoop:              // Pulse to read from SNES (12 microseconds and 6 microseconds)  
                          
        add     r3, #6                          // Add 6 microseconds
        bl      Wait                            // Waits the 6 microseconds
        mov     r0, #0			        // Write 0 to CLO
        bl      WriteClock
        mov     r3, #6                          // Waits for 6 microseconds
        bl      Wait                            // Waits 6 microseconds
        bl      ReadData
        cmp     r0, #1				// Check if bit is a 1 or 0
        bne     CheckNextBit
        mov     r2, #1                          // If it is not pressed				
        lsl     r2, r5	                        // LSL to the proper index			
        orr     r8, r2                          // Add 1 to that index to indicate it is not pressed				

CheckNextBit:                                   // Checks the next bit if not equal to 1
	mov     r0 ,#1			        // Writes 1 to clock
	bl      WriteClock
	add     r5, #1				
	cmp     r5, #16
	blt     PulseLoop                       // Loops back to the PulseLoop to check next bit

ReturnBits:                                     // Returns the final 16 bit string that contains all the buttons that's beeen pressed
        mov     r0, r8				// Return 16 bit string
        pop     {r4, r5,r8, lr}
        mov 	pc, lr

//----------------------------------------------------------------------------------------------
// Takes in input r3 = the time it wants to wait
.globl	Wait
Wait:
        push    {lr}
        ldr     r0, =0x3F003004                  // Addess of CLO
        ldr     r1, [r0] 
        add     r1, r3                           

WaitLoop:               // Waits for a time interval
        ldr     r2, [r0]
        cmp     r1, r2				// Stops when CLO = r1
        bhi     WaitLoop
        pop     {lr}
        mov     pc, lr

//----------------------------------------------------------------------------------------------
// R0 = number to write
WriteClock:	        // Writes to the GPIO clock line. Pin 11
        push    {lr}
        mov     r1,r0
        mov     r0, #11                     
        ldr     r2, =0x3F200000                 // Address to base GPIO register
        mov     r3, #1
        lsl     r3, r0                          
        teq     r1, #0                          
        streq   r3, [r2, #40]                   // If 0 then clear GPCLR0
        Strne   r3, [r2, #28]                   // If 1 then set GPSET0
        pop     {lr}
        mov	pc, lr                  

//----------------------------------------------------------------------------------------------
// R0 = number to write
WriteLatch:             // Write a bit to the GPIO latch line. Pin 9
        push    {lr}
        mov     r1,r0
        mov     r0, #9                          
        ldr     r2, =0x3F200000                 // Address to base GPIO register
        mov     r3, #1
        lsl     r3, r0                      
        teq     r1, #0                      
        streq   r3, [r2, #40]                   // If 0 then clear GPCLR0
        strne   r3, [r2, #28]                   // If 1 then set GPSET0
        pop     {lr}
        mov	pc, lr

//----------------------------------------------------------------------------------------------

.section .data
.align
ColourOfBlock:
        .byte   0    
