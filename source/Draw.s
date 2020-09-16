/*Global Methods:
	- DrawMainMenu
	- DrawGameBackground
	- DrawGameBounds
	- DrawStartGame
	- DrawStartGameSelected
	- DrawQuitGame
	- DrawQuitGameSelected
	- DrawPauseFrame
	- DrawRestartGame
	- DrawRestartGameSelected
	- DrawGameWon
	- DrawGameOver
	- drawBlock:
		> r0, X coordinate
		> r1, Y coordinate
	- eraseBlock:
		> r0, X coordinate
		> r1, Y coordinate
	- clearScreen
	- DrawScore
*/
/*Used methods:
	- DrawLoop
	- EndDraw
	- DrawPixel
*/
/*Data:
	- IShapeGrid
	- JShapeGrid
	- LShapeGrid
	- OShapeGrid
	- ZShapeGrid
	- TShapeGrid
	- SShapeGrid
*/

//---------------------------------------------------------------------------
//			DrawScore
.globl	DrawScore
DrawScore:
	push	{r0-r11,lr}
	
	x	.req	r6
	y	.req	r5
	color	.req	r4
	
	ldr	r11, =ScoreASCII	//Address of score digits	

	mov	y, #118			//Starting Y
	ldr	x, =830			//Starting X
	mov	r3, x
	ldr	r7, =862		//Ending X
	ldr	r8, =149		//Ending Y

	mov	r9, #0			//index in ScoreASCII
DrawScoreLoop:
	ldrb	r10, [r11, r9]		//Digit
	cmp	r9, #0
	beq	ContinueDrawScore	//Move on to check which number to draw
	cmp	r9, #1
	beq	InitializeXY1
	cmp	r9, #2
	beq	InitializeXY2

InitializeXY1:
	ldr	x, =870			//Initialize the values accordingly
	mov	r3, x
	ldr	y, =118
	ldr	r7, =902
	b	ContinueDrawScore
InitializeXY2:
	ldr	y, =118
	ldr	x, =910
	mov	r3, x
	ldr	r7, =942
	b	ContinueDrawScore

ContinueDrawScore:
	add	r9, #1			//Increment index
	cmp	r9, #4
	beq	EndDrawScore		//If 4, stop drawing numbers
	cmp	r10, #0			//Which number to draw
	beq	DrawScore0
	cmp	r10, #1
	beq	DrawScore1
	cmp	r10, #2
	beq	DrawScore2
	cmp	r10, #3
	beq	DrawScore3
	cmp	r10, #4
	beq	DrawScore4
	cmp	r10, #5
	beq	DrawScore5
	cmp	r10, #6
	beq	DrawScore6
	cmp	r10, #7
	beq	DrawScore7
	cmp	r10, #8
	beq	DrawScore8
	cmp	r10, #9
	beq	DrawScore9

DrawScore0:
	ldr	color, =Score0		//Load the proper ascii values
	b	ScoreDrawLoop	
DrawScore1:
	ldr	color, =Score1
	b	ScoreDrawLoop
DrawScore2:
	ldr	color, =Score2
	b	ScoreDrawLoop
DrawScore3:
	ldr	color, =Score3
	b	ScoreDrawLoop
DrawScore4:
	ldr	color, =Score4
	b	ScoreDrawLoop
DrawScore5:
	ldr	color, =Score5
	b	ScoreDrawLoop
DrawScore6:
	ldr	color, =Score6
	b	ScoreDrawLoop
DrawScore7:
	ldr	color, =Score7
	b	ScoreDrawLoop
DrawScore8:
	ldr	color, =Score8
	b	ScoreDrawLoop
DrawScore9:
	ldr	color, =Score9
	b	ScoreDrawLoop

ScoreDrawLoop:
	mov	r0, x			//Move the values for draw pixel
	mov	r1, y
	ldrh	r2, [color], #2
	bl 	DrawPixel

	add	x, #1			//Increment the x value
	cmp	x, r7			
	bne	ScoreDrawLoop		//Keep printing the same row

	cmp	y, r8
	beq	DrawScoreLoop		//Move to next digit
	
	add	y, #1			//Move to next row
	mov	x, r3			//Reset x
	b	ScoreDrawLoop

EndDrawScore:
	.unreq	x
	.unreq	y
	.unreq	color
	pop	{r0-r11,lr}
	mov	pc, lr
//---------------------------------------------------------------------------
//			eraseBlock
//r0: X coordinate
//r1: Y coordinate
.globl eraseBlock
eraseBlock:
	push 	{r4-r11,lr}

        mov 	r9, #32      	//Size of each block to get an offset
        
        mul 	r10, r0, r9     //Save the starting X and Y coordinates                         
        mul 	r11, r1, r9 

	mov	r4, r10		//Starting X coordinate
	mov	r5, r11		//Starting Y coordinate
	
	mov	r7, r4		//When to end the draw
        add     r7, #32
	mov	r8, r5
        add     r8, #32
drawBlackLoop:
	mov	r0, r4		//X into r0 
	mov	r1, r5		//Y into r1 
	mov	r2, #0		//Black color
	bl	DrawPixel
	
	add	r4, #1		//Increment X
	cmp	r4, r7		//Check if max X
	blt	drawBlackLoop
	
	mov	r4, r10		//Reset x
	add	r5, #1		//Increment Y
	cmp	r5, r8		//Check if max Y
	blt	drawBlackLoop
	
	pop    	{r4-r11,lr}	//Return
	mov	pc, lr

//---------------------------------------------------------------------------
//			drawBlock
//r0: X coordinate
//r1: Y coordinate

.globl drawBlock
drawBlock:
	push	{r4-r11,lr}

        mov 	r9, #32    	//32 is the offset
        
        mul 	r10, r0, r9	//Save the starting X and Y coordinates                              
        mul 	r11, r1, r9 

	mov	r4, r10		//Starting X coordinate
	mov	r5, r11		//Starting Y coordinate
	
	ldr	r6, =ZShape	//Address of the picture
	mov	r7, r4		//End values of draw
        add     r7, #32
	mov	r8, r5
        add     r8, #32
drawPictureLoop:
	mov	r0, r4		//X into r0 
	mov	r1, r5		//Y into r1 
	ldrh	r2, [r6], #2	//Pixel color. Post increment to next color.
	bl	DrawPixel
	
	add	r4, #1		//increment x position
	cmp	r4, r7		//Check if max X
	blt	drawPictureLoop
	
	mov	r4, r10		//Reset x
	add	r5, #1		//Increment Y
	cmp	r5, r8		//Check if max Y
	blt	drawPictureLoop
	
	pop	{r4-r11,lr}	//Return
	mov	pc, lr

//---------------------------------------------------------------------------
//			DrawMainMenu
.globl	DrawMainMenu		//Draws the main menu
DrawMainMenu:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x0			//Start at x=0, y=0
	ldr	y, =0x0			//
	ldr	r7, =0x3FF		//r7 = 1023
	ldr	r8, =0x2FE		//r8 = 767
	ldr	color, =MenuBackground	//Address to the ASCII representation of picture 
MenuDrawLoop:	
	bl	DrawLoopdraw
	ldr	x, =0x0			//reset x
	b	MenuDrawLoop		//Draw next line

//---------------------------------------------------------------------------
//			DrawGameBackground
.globl DrawGameBackground	//Draws the game background
DrawGameBackground:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x0			//Start at x=0, y=0
	ldr	y, =0x0			//
	ldr	r7, =0x3FF		//r7 = 1023
	ldr	r8, =0x2FE		//r8 = 767
	ldr	color, =GameBackground	//Address to the ASCII representation of picture 
GameDrawLoop:	
	bl	DrawLoopdraw
	ldr	x, =0x0			//reset x
	b	GameDrawLoop		//Draw next line

//---------------------------------------------------------------------------
//			DrawLoop, EndDraw
DrawLoopdraw:
	push	{lr}
InnerDrawLoop:
	mov	r0, x			//r0 = current x value
	mov	r1, y			//r1 = current y value
	ldrh	r2, [color], #2		//Load the value of the color
	bl	DrawPixel

	add	x, #1			//Increase x value by 1
	cmp	x, r7			//Compare the x value to the max x value
	bne	InnerDrawLoop		//If not equal continue drawing line

	pop	{lr}			//Pop lr to return to where the function was called
	cmp	y, r8			//Compare y to max value
	beq	EndDraw			//If End draw, lr will be popped again to return properly
	
	add	y, #1			//Move to next row
	mov	pc, lr

EndDraw:
	.unreq	x			//Remove register labels
	.unreq	y
	.unreq	color
	pop	{r0-r2, r4-r8, lr}	//Pop used registers
	mov	pc, lr			//

//---------------------------------------------------------------------------
//			DrawGameBounds, DrawPixel
.globl	DrawGameBounds		//Draws the play area
DrawGameBounds:	
	push	{r0-r2,r4-r8,lr}
	x	.req	r5		//Label registers
	y	.req	r6
	color	.req	r4
	
	ldr		x, =352		// Starting X
	ldr		y, =96		// Starting Y
	ldr		color, =0x0	// Black colour
	ldr		r7, =671	// Ending X
	ldr		r8, =703	// Ending Y
DrawBlack:
	cmp		x, r7		//If less, continue on same row
	bls		DrawBlackLoop
	
	add		y, #1		//Move to next line
	ldr		x, =352		// Resets the value of x (starts from the beginning)
	cmp		y, r8		//If last row, will end draw	
	bls		DrawBlackLoop
	b		EndDraw
DrawBlackLoop:
	mov		r0, x		//x, y, and color
	mov		r1, y
	mov		r2, color
	bl		DrawPixel
	add		x, #1		//Draws black until the end of the row
	b		DrawBlack


//-----------------------------------------------------------------------------------------
//				clearScreen
.globl clearScreen
clearScreen:
	mov	r4,	#0		//x value
	mov	r5,	#0		//Y value
	mov	r6,	#0		//black color
	ldr	r7,	=1024		//Width of screen
	ldr	r8,	=768		//Height of the screen
	
Looping:
	mov	r0,	r4		//Setting x 
	mov	r1,	r5		//Setting y
	mov	r2,	r6		//setting pixel color
	push {lr}
	bl	DrawPixel
	pop {lr}
	add	r4,	#1		//increment x by 1
	cmp	r4,	r7		//compare with width
	blt	Looping
	mov	r4,	#0		//reset x
	add	r5,	#1		//increment Y by 1
	cmp	r5,	r8		//compare with height
	blt	Looping
	
	mov	pc,	lr		//return

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

//Draw Menu Options

//---------------------------------------------------------------------------
//			DrawGameOver
.globl	DrawGameOver		//Draw the game lost picture
DrawGameOver:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x85		//Start at x=133, y=156
	ldr	y, =0x9C		//
	ldr	r7, =0x37A		//r7 = x + 757 = 890
	ldr	r8, =0x262		//r8 = y + 455 = 611
	ldr	color, =GameOver	//Address to the ASCII representation of picture 
LostDrawLoop:
	bl	DrawLoopdraw	
	ldr	x, =0x85		//reset x
	b	LostDrawLoop		//Draw next line

//---------------------------------------------------------------------------
//			DrawGameWon
.globl	DrawGameWon		//Draw the game won picture
DrawGameWon:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x85		//Start at x=133, y=156
	ldr	y, =0x9C		//
	ldr	r7, =0x37A		//r7 = x + 757 = 890
	ldr	r8, =0x262		//r8 = y + 455 = 611
	ldr	color, =GameWon		//Address to the ASCII representation of picture 
WonDrawLoop:
	bl	DrawLoopdraw	
	ldr	x, =0x85		//reset x
	b	WonDrawLoop		//Draw next line

//---------------------------------------------------------------------------
//			DrawRestartGame
.globl	DrawRestartGame		//Draw restart game options
DrawRestartGame:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x1BF		//Start at x=447, y=404
	ldr	y, =404			//
	ldr	r7, =0x241		//r7 = x + 130 = 577
	ldr	r8, =443		//r8 = y + 40 = 443
	ldr	color, =RestartGame	//Address to the ASCII representation of picture 
RestartDrawLoop:
	bl	DrawLoopdraw	
	ldr	x, =0x1BF		//reset x
	b	RestartDrawLoop		//Draw next line

//---------------------------------------------------------------------------
//			DrawRestartGameSelected
.globl	DrawRestartGameSelected
DrawRestartGameSelected:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x1BF		//Start at x=447, y=404
	ldr	y, =404			//
	ldr	r7, =0x241		//r7 = x + 130 = 577
	ldr	r8, =443		//r8 = y + 40 = 443
	ldr	color, =RestartGameSelected	//Address to the ASCII representation of picture 
RestartSelectDrawLoop:	
	bl	DrawLoopdraw
	ldr	x, =0x1BF		//reset x
	b	RestartSelectDrawLoop	//Draw next line

//---------------------------------------------------------------------------
//			DrawPauseFrame
.globl DrawPauseFrame		//Draw frame for pause menu
DrawPauseFrame:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x182		//Start at x=386, y=370
	ldr	y, =0x172		//
	ldr	r7, =0x279		//r7 = x + 247 = 633
	ldr	r8, =0x225		//r8 = y + 180 = 550
	ldr	color, =PauseFrame	//Address to the ASCII representation of picture 
PauseDrawLoop:	
	bl	DrawLoopdraw
	ldr	x, =0x182		//reset x
	b	PauseDrawLoop		//Draw next line

//---------------------------------------------------------------------------
//			DrawStartGameSelected
.globl	DrawStartGameSelected	//Draw start game options
DrawStartGameSelected:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x1BF		//Start at x=447, y=384
	ldr	y, =0x180		//
	ldr	r7, =0x241		//r7 = x + 130 = 577
	ldr	r8, =0x1A7		//r8 = y + 40 = 423
	ldr	color, =StartGameSelected	//Address to the ASCII representation of picture 

StartSelectDrawLoop:
	bl	DrawLoopdraw	
	ldr	x, =0x1BF		//reset x
	b	StartSelectDrawLoop	//Draw next line
//---------------------------------------------------------------------------
//			DrawStartGame
.globl	DrawStartGame
DrawStartGame:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x1BF		//Start at x=447, y=384
	ldr	y, =0x180		//
	ldr	r7, =0x241		//r7 = x + 130 = 577
	ldr	r8, =0x1A7		//r8 = y + 40 = 423
	ldr	color, =StartGame	//Address to the ASCII representation of picture 
StartDrawLoop:	
	bl	DrawLoopdraw
	ldr	x, =0x1BF		//reset x
	b	StartDrawLoop		//Draw next line

//---------------------------------------------------------------------------
//			DrawQuitGame
.globl	DrawQuitGame		//Draw Quit game options
DrawQuitGame:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x1BF		//Start at x=447, y=464
	ldr	y, =0x1D0		//
	ldr	r7, =0x241		//r7 = x + 130 = 577
	ldr	r8, =0x1F7		//r8 = y + 40 = 503
	ldr	color, =QuitGame	//Address to the ASCII representation of picture 
QuitDrawLoop:	
	bl	DrawLoopdraw
	ldr	x, =0x1BF		//reset x
	b	QuitDrawLoop		//Draw next line

//---------------------------------------------------------------------------
//			DrawQuitGameSelected
.globl	DrawQuitGameSelected
DrawQuitGameSelected:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =0x1BF		//Start at x=447, y=464
	ldr	y, =0x1D0		//
	ldr	r7, =0x241		//r7 = x + 130 = 577
	ldr	r8, =0x1F7		//r8 = y + 40 = 503
	ldr	color, =QuitGameSelected	//Address to the ASCII representation of picture 
QuitSelectDrawLoop:	
	bl	DrawLoopdraw
	ldr	x, =0x1BF		//reset x
	b	QuitSelectDrawLoop	//Draw next line

//-----------------------------------------------------------------------------------------
//---------------------------------------------------------------------------
//			DrawGameBackground
.globl DrawSpecial	//Draws the game background
DrawSpecial:
	push	{r0-r2, r4-r8, lr}
	x	.req	r5		//Label registers
	y	.req	r6		//
	color	.req	r4		//

	ldr	x, =800			//Start at x=0, y=0
	ldr	y, =600			//
	ldr	r7, =930		//r7 = 1023
	ldr	r8, =729		//r8 = 767
	ldr	color, =special	//Address to the ASCII representation of picture 
SpecialDrawLoop:	
	bl	DrawLoopdraw
	ldr	x, =800			//reset x
	b	SpecialDrawLoop		//Draw next line


//------------------------------------------------------------------------------------------
.section .data
.align

//The grids for the shapes
.globl IShapeGrid	
IShapeGrid:
        .byte   1,1,1,1
        .byte   0,0,0,0
        .byte   0,0,0,0
        .byte   0,0,0,0
      
.globl JShapeGrid
JShapeGrid:        
        .byte   1,0,0
        .byte   1,1,1
        .byte   0,0,0
        
.globl LShapeGrid       
LShapeGrid:
        .byte   0,0,1
        .byte   1,1,1
        .byte   0,0,0

.globl OShapeGrid
OShapeGrid:
        .byte   1,1,0
        .byte   1,1,0
        .byte   0,0,0

.globl ZShapeGrid
ZShapeGrid:
        .byte   1,1,0
        .byte   0,1,1
        .byte   0,0,0

.globl TShapeGrid       
TShapeGrid:
        .byte   0,1,0
        .byte   1,1,1
        .byte   0,0,0

.globl SShapeGrid      
SShapeGrid:
        .byte   0,1,1
        .byte   1,1,0
        .byte   0,0,0  

.align 4
font:
	.incbin "font.bin"





