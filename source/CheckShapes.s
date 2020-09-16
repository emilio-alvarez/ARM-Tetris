/*Global Methods:
	- CheckShape
	- CheckColour
*/

.section .text

//----------------------------------------------------------------------------------------       
/*
This subroutine checks the shape that is produced by 
        the random number generator and draws it onto the grid
	
	1 - Light blue 	        (I Shape)
	2 - Blue 		(J Shape)
	3 - Orange 		(L Shape)
	4 - Yellow 		(O Shape)
	5 - Green 		(S Shape)
	6 - Purple 		(T Shape)
	7 - Red 		(Z Shape)
	
Parameters:
	r2 - Colour number (0-7)
	r3 - holds the address to the ASCII colours of each shape
	r7 - holds the address to the shape grid
*/ 
.globl CheckShape       
CheckShape:     // Gets a random number and checks the shape
        push    {r4-r8,lr}
       
       
        cmp     r2, #1                          // Checks for I Shape
        beq     DrawIShape
       
        cmp     r2, #2                          // Checks for J Shape
        beq     DrawJShape
        
        cmp     r2, #3                          // Checks for L Shape
        beq     DrawLShape
        
        cmp     r2, #4                          // Checks for O Shape
        beq     DrawOShape
        
        cmp     r2, #5                          // Checks for S Shape
        beq     DrawSShape
        
        cmp     r2, #6                          // Checks for T Shape
        beq     DrawTShape
        
        cmp     r2, #7                          // Checks for Z Shape
        beq     DrawZShape   

DrawIShape:     // Assigns the grid shape and the colour to draw function
        ldr    r2, =IShapeGrid
        ldr    r3, =IShape
        bl     GetShapeI
        b      ExitCheckShape
       
DrawJShape:    
        ldr    r2, =JShapeGrid
        ldr    r3, =JShape
        bl     GetShape
        b      ExitCheckShape     
      
DrawLShape:
        ldr    r2, =LShapeGrid
        ldr    r3, =LShape        
        bl     GetShape
        b      ExitCheckShape  
        
DrawOShape:
        ldr    r2, =OShapeGrid
        ldr    r3, =OShape        
        bl     GetShape
        b      ExitCheckShape
        
DrawSShape:
        ldr    r2, =SShapeGrid
        ldr    r3, =SShape        
        bl     GetShape
        b      ExitCheckShape
        
DrawTShape:
        ldr    r2, =TShapeGrid
        ldr    r3, =TShape        
        bl     GetShape
        b      ExitCheckShape
        
DrawZShape:        
        ldr    r2, =ZShapeGrid
        ldr    r3, =ZShape        
        bl     GetShape
        b      ExitCheckShape

ExitCheckShape:
        pop     {r4-r8,lr}
        mov     pc,lr 

//---------------------------------------------------------------------------------------
/*
This subroutine draws the shape according to the shape grid then calls
        onto a function that draws each block.
        - 1 = coloured block
        - 0 = black
Parameters:
        r0 - x value
        r1 - y value
        r2 - the grid
        r3 - ASCII Colour       
Returns:
        None        
*/        
GetShape: 
        push    {r4-r11,lr}                                    
        mov     r4, r0	// Initializes the spawn of each block (14x32pixels) to get to the center x coordinate
        mov     r5, r1	 // Initializes the spawn of each block (0x32pixels) to get to the center y coordinate
        mov     r7,r2           //the grid
        mov     r9, #0          // counter
        mov     r10, #0
        mov     r11, #0
        mov     r6, r4
       
DrawShape:
        cmp     r9, #3
        beq     NextRow
        ldrb    r8, [r7, r11]
        add     r11, #1
        cmp     r8, #1
        bne     DrawBlackSquare
        beq     DrawShapeLoop

DrawBlackSquare:

        add     r4, #1
        add     r9, #1
        b       DrawShape


DrawShapeLoop:
        mov     r0, r4
        mov     r1, r5
        bl      DrawBlock
        b       NextBlock
            
NextBlock:
        add     r4, #1
        add     r9, #1
        b       DrawShape                

NextRow:   
        add     r10, #1
        cmp     r10, #3
        beq     Exit
        mov     r4, r6
        
        add     r5, #1
        mov     r9, #0
        b       DrawShape
        
Exit:
        pop     {r4-r11,lr}
        mov     pc, lr




GetShapeI: 
        push    {r4-r11,lr}                                    
        mov     r4, r0   // Initializes the spawn of each block (14x32pixels) to get to the center x coordinate
        mov     r5, r1   // Initializes the spawn of each block (0x32pixels) to get to the center y coordinate
        mov     r7,r2   //the grid        
        mov     r9, #0    // counter
        mov     r10, #0
        mov     r11, #0
        mov     r6, r4
       
DrawBShape:
        cmp     r9, #4
        beq     NextIRow
        ldrb    r8, [r7, r11]
        add     r11, #1
        cmp     r8, #1
        bne     DrawIBlackSquare
        beq     DrawIShapeLoop

DrawIBlackSquare:
        add     r4, #1
        add     r9, #1
        b       DrawBShape

DrawIShapeLoop:
        mov     r0, r4
        mov     r1, r5
        bl      DrawBlock
        b       NextIBlock
            
NextIBlock:
        add     r4, #1
        add     r9, #1
        b       DrawBShape                

NextIRow:   
        add     r10, #1
        cmp     r10, #4
        beq     ExitI
        mov     r4, r6
        
        add     r5, #1
        mov     r9, #0
        b       DrawBShape
        
ExitI:
        pop     {r4-r11,lr}
        mov     pc, lr
//---------------------------------------------------------------------------------------
/*
This subroutine draws a block according to the x and y coordinates.
        Offset to 32 pixels (x*32pixels and y*32pixels)
Parameters:
        r0 - x value
        r1 - y value
        r3 - ASCII value
Returns:
        None                
*/
.globl DrawBlock
DrawBlock:
	push {r4-r11,lr}

        mov     r6, r3                  // Makes a copy of the ASCII value

        mov     r9, #32                             //32 is the offset
        mul     r10, r0, r9                              
        mul     r11, r1, r9 

	mov	r4,r10			//Start X position of your picture
	mov	r5,r11
	mov	r7,r4
        add     r7,#32
	mov	r8,r5
        add     r8,#32
DrawBlockLoop:
	mov	r0,r4			//passing x for ro which is used by the Draw pixel function 
	mov	r1,r5			//passing y for r1 which is used by the Draw pixel formula 
	
	ldrh	r2,[r3],#2			//setting pixel color by loading it from the data section. We load hald word
	bl	DrawPixel
	add	r4,	#1			//increment x position
	cmp	r4,	r7			//compare with image with
	blt	DrawBlockLoop
	mov	r4,	r10			//reset x
	add	r5,	#1			//increment Y
	cmp	r5,	r8			//compare y with image height
	blt	DrawBlockLoop
	mov     r3, r6
	pop     {r4-r11,lr}
	mov	pc,	lr			//return

//------------------------------------------------------------------------------------------
/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */
.globl DrawPixel
DrawPixel:
	push	{r4}


	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add	offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl	offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop	{r4}
	bx	lr

//------------------------------------------------------------------------------------------
//				GAMESTATEHELPER
/*
This subroutine prints out a block correspinging to the number passed in
	
        0 - Black
	1 - Light blue 	        (I Shape)
	2 - Blue 		(J Shape)
	3 - Orange 		(L Shape)
	4 - Yellow 		(O Shape)
	5 - Green 		(S Shape)
	6 - Purple 		(T Shape)
	7 - Red 		(Z Shape)
	
Parameters:
	r0 - holds the address of the x
	r1 - holds the address of the y
        r2 - Colour number (0-7)
*/
.globl CheckColour        
CheckColour:     // Gets a random number and checks the shape
        push    {lr}

        cmp     r2, #0                          // Checks for I Shape
        beq     DrawBlackBox
             
        cmp     r2, #1                          // Checks for I Shape
        beq     DrawIShape2
       
        cmp     r2, #2                          // Checks for J Shape
        beq     DrawJShape2
        
        cmp     r2, #3                          // Checks for L Shape
        beq     DrawLShape2
        
        cmp     r2, #4                          // Checks for O Shape
        beq     DrawOShape2
        
        cmp     r2, #5                          // Checks for S Shape
        beq     DrawSShape2
        
        cmp     r2, #6                          // Checks for T Shape
        beq     DrawTShape2
        
        cmp     r2, #7                          // Checks for Z Shape
        beq     DrawZShape2  


DrawBlackBox:     // Assigns the grid shape and the colour to draw function 
      
        ldr    r3, =blackOut
        bl     DrawBlock
        b      ExitCheckColour

DrawIShape2:     // Assigns the grid shape and the colour to draw function 
      
        ldr    r3, =IShape
        bl     DrawBlock
        b      ExitCheckColour
       
DrawJShape2:    
        ldr    r3, =JShape
        bl     DrawBlock
        b      ExitCheckColour     
      
DrawLShape2:
        ldr    r3, =LShape        
        bl     DrawBlock
        b      ExitCheckColour  
        
DrawOShape2:
        ldr    r3, =OShape        
        bl     DrawBlock
        b      ExitCheckColour
        
DrawSShape2:
        ldr    r3, =SShape        
        bl     DrawBlock
        b      ExitCheckColour
        
DrawTShape2:
        ldr    r3, =TShape        
        bl     DrawBlock
        b      ExitCheckColour
        
DrawZShape2:        
        ldr    r3, =ZShape        
        bl     DrawBlock
        b      ExitCheckColour

ExitCheckColour:
        pop     {lr}
        mov     pc,lr 



//r2 = type of block
//r0 is the adress to the shape
.globl GetGrid       
GetGrid: 
        push {lr}       
        
        cmp     r2, #1                          // Checks for I Shape
        ldreq    r0, =IShapeGrid

        cmp     r2, #2                          // Checks for I Shape
        ldreq    r0, =JShapeGrid

        cmp     r2, #3                          // Checks for I Shape
        ldreq    r0, =LShapeGrid        

        cmp     r2, #4                          // Checks for I Shape
        ldreq    r0, =OShapeGrid        
        
        cmp     r2, #5                          // Checks for I Shape
        ldreq    r0, =SShapeGrid        

        cmp     r2, #6                          // Checks for I Shape
        ldreq    r0, =TShapeGrid        

        cmp     r2, #7                          // Checks for I Shape       
        ldreq    r0, =ZShapeGrid        

        pop {lr}

        mov pc, lr

//------------------------------------------------------------------------------------------
//				practiceSNESCONTROLLER
/*
This subroutine draws the shape according to the shape grid then calls
        onto a function that draws each block.
        - 1 = coloured block
        - 0 = black
Parameters:
        r0 - x value
        r1 - y value
        r2 - array of grid about to be deleted 
        r3 - colour      
Returns:
        None        
*/ 
.globl ClearShape       
ClearShape: 
        push    {r4-r11,lr} 

        cmp r3, #1                      //checks if its an I
        beq ClearShapeI                 //branches to clear the shape
                                   
        mov     r4, r0                                 // get x co-ordinate
        mov     r5, r1                                // get y co-ordinate
        mov     r7, r2                                  //gets the grid

        mov     r9, #0                  // x - value
        mov     r10, #0                 // y- value
        mov     r11, #0                 //index in the shape array
        mov     r6, r4                  //copy of x to reset
       
DrawShapeClear:
        cmp     r9, #3                  //3X3
        beq     NextRowClear                 //b if equal to three branch to next row
        ldrb    r8, [r7, r11]           //r7 has the grid of shape

        add     r11, #1
        cmp     r8, #1
        bne     DrawBlackSquareClear
        beq     DrawShapeClearLoop

DrawBlackSquareClear:
        add     r4, #1
        add     r9, #1
        b       DrawShapeClear

DrawShapeClearLoop:
        mov     r0, r4
        mov     r1, r5
        bl      eraseBlock
        b       NextBlockClear
            
NextBlockClear:
        add     r4, #1
        add     r9, #1
        b       DrawShapeClear                

NextRowClear:   
        add     r10, #1
        cmp     r10, #3
        beq     ExitClearShape
        mov     r4, r6
        
        add     r5, #1
        mov     r9, #0
        b       DrawShapeClear
        
ExitClearShape:
        pop     {r4-r11,lr}
        mov     pc, lr

//------------------------------------------------------------------------------------------------------------------------
ClearShapeI: 
               
        mov     r4, r0                                 // get x co-ordinate
        mov     r5, r1                                // get y co-ordinate
        mov     r7, r2                                  //gets the grid
        mov     r9, #0                  // x - value
        mov     r10, #0                 // y- value
        mov     r11, #0                 //index in the shape array
        mov     r6, r4                  //copy of x to reset
       
DrawShapeI:
        cmp     r9, #4                  //3X3
        beq     NextRowI                 //b if equal to three branch to next row
        ldrb    r8, [r7, r11]           //r7 has the grid of shape

        add     r11, #1
        cmp     r8, #1
        bne     DrawBlackSquareI
        beq     DrawShapeLoopI

DrawBlackSquareI:
        add     r4, #1
        add     r9, #1
        b       DrawShapeI

DrawShapeLoopI:
        mov     r0, r4
        mov     r1, r5
        bl      eraseBlock
        b       NextBlockI
            
NextBlockI:
        add     r4, #1
        add     r9, #1
        b       DrawShapeI                

NextRowI:   
        add     r10, #1
        cmp     r10, #4
        beq     ExitIClear
        mov     r4, r6
        
        add     r5, #1
        mov     r9, #0
        b       DrawShapeI
   
ExitIClear:
        b ExitClearShape
  
