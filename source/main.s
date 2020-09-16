// CPSC 359: Assignment #3
// Authors:
//      - Emilio Alvarez
//      - James Peralta
//      - Joshua Velasquez

//A tetris game.

.section    .init
.globl     _start

_start:
    b       main

.section .text

main:
	mov	sp, #0x8000
	bl	EnableJTAG
	bl	InitFrameBuffer		// Initialize the frame buffer
	mov     r0, #9          	// Initializes pin 9 (Latch) to output
        bl      Init_GPIO
        mov     r0, #10         	// Initializes pin 10 (Data) to input
        bl      Init_GPIO
        mov     r0, #11         	// Initializes pin 11 (Clock) to output
        bl      Init_GPIO

.globl	MenuScreen
MenuScreen:
	bl	DrawMainMenu		//Draw the main menu background

//Check which option is selected. Default to start.
StartMenuOption:
	bl	DrawStartGameSelected	//Default to start game
	bl	DrawQuitGame
	bl	ReadButtons
	cmp	r0, #4			//If up, loop back
	beq	StartMenuOption
	cmp	r0, #5			//If down, go to quit option
	beq	QuitMenuOption
	cmp	r0, #8			//If A, start game
	beq	StartGameLoop
	b	StartMenuOption		//If none/other, loop back

QuitMenuOption:
	bl	DrawQuitGameSelected
	bl	DrawStartGame
	bl	ReadButtons		//Read buttons
	cmp	r0, #4			//If up, go to start option
	beq	StartMenuOption
	cmp	r0, #5			//If down, loop back
	beq	QuitMenuOption
	cmp	r0, #8			//If A, quit game
	beq	QuitGame
	b	QuitMenuOption		//If none/other, loop back


.globl	StartGameLoop
StartGameLoop:
	bl	DrawGameBackground	//Draw the game background
	bl	resetState		//Set the state of the gameState array to empty
GameLoop:
	bl	gameLoop		//Start the game loop


//If the player wins or loses
.globl LostGame
LostGame:
	bl	DrawGameOver		//Draw the game over image
	b	EndGameLoop
.globl WonGame
WonGame:
	bl	DrawGameWon		//Draw the game won image
EndGameLoop:
	bl	ReadButtons		//Check if the user presses start
	cmp	r0, #3
	beq	MenuScreen		//Go to menu if pressed
	b	EndGameLoop


QuitGame:
	bl	clearScreen		//Clear the screen and end the program


haltLoop$:
	b	haltLoop$


