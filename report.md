<div style="text-align: center;">

# Mini Tetris

</div>

Mini tetris is an interactive game created on a 5x5 LED display of a microbit. The following report describes how the game is played, how the game was implemented, and an analysis on the final design.

The play of the game involves placing 6 pieces on the board where only one piece is placed at a time. The player is able to control the position of the pieces by using the A button to left shift and the B button to right shift. The pieces will move downwards and players will have a limited time to conduct their shifts. The game ends when all six pieces are placed, or if there is no space left on the board. In the endgame, the board will flash three times and will be reset. A loop will keep the game endlessly re-running.

Note: The A and B buttons must be timed on the descent of the piece in order for a shift to happen. Explanation of this is discussed in the analysis section of the report.


<h2>Implementation</h2>


The game utilises a series of functions and data structures. The figure below provides a diagram of how the main functions of the game work together to display the correct images.

![Tetris Diagram!](assets/Tetris_Diagram.png)


<h3>Back End Functions</h3>


The drop piece function is an integral part of the back end of the game. It utilises a series of small helper functions to insert, descend and set a piece. The function begins by copying the argument's values into the 'current_piece' data structure of the game. Creating this copy allows changes to be made to the piece's position and only having to overwrite this copy as the game moves along. 

 Afterwards, it checks if inserting the piece into the game is valid by calling the 'check_collision' function on the piece. A collision returns true if ANDing the values of TETRIS data and the values of the piece data returns a value greater than 0. If a piece insertion is invalid, the game_over boolean is set to true and the game ends. If it is valid, the piece is inserted and starts descending to the bottom.

 A single piece's data consists of the three main aspects. The column values of the piece, the size of the piece and the position of the piece. The vertical size dictates how many times a piece is able to descend, the horizontal size dictages how far a piece can shift. A piece can descend 'vertical size mod 5' number of times. Once a piece has descended to the bottom or hits the top of another piece, the drop_piece function sets the piece by inserting it's final position to the board.

 A piece's position can only be a maximum of 5 - horizontal size. When a button is pressed, the function either adds or subtracts 1 the position to conduct a shift. If the position is at it's max or 0, the button will do nothing.


<h3>Front End Functions</h3>


There are two key functions used to display an image on the board, Display_image and Show_image. Show_image displays a still image on the board for a given time. It starts by turning on the row pins for each value in the data. It then turns on the corresponding column for that row, delays for a while, turns the column off, and then delays again before repeating the loop. This scans the image and allows us to display any sort of image we want on the 5x5 board.

display_image uses a loop to show a moving version of an image going from left to right. This function follows the same logic as the show_image function but instead of looping through individual columns, it loops through sections of a full image. It does this by utilising the show_image function to show parts of a display, then extending the sections after each loop.

<h2>Analysis</h2>


The game was implemented using this design to achieve four main features. Scanning, good use of memory, modifiable displays and player interaction. With the use of the show_image and display_image functions, alongside memory, the first three features were achieved. The program can easily be changed to display any sort of image, still or moving, by simply making changes to memory and calling these functions.  More importantly, this allows  pieces of different shapes and sizes to be added to the game with ease! The piece shapes are not limited because the functions are not hard coded to a specific piece, it can work with any shape given it fits onto the board.

This is why I created the piece data structure to include the piece's horizontal and vertical size, as well as position. So that the functions can depend on these values to determine if a piece has collided or reached the bottom or side boundaries. Another design feature that is particularly important is seperating a piece in memory from the game. Since the piece's position is constantly changing, it would be easier to modify only the piece's value instead of the whole game. 


<h3>Flaws</h3>

A flaw in the game's design is being unable to control when a button interrupt should perform a shift. In the game, when a piece is shifted, some of the led's from the previous position remain on. This is worsened when buttons are mashed or bounces. The issue does not affect the actual play of the game, just the visual. It happens because interrupts can occur while an image is already being displayed. A work around this was to have the lights turn off for a short amount of time to indicate to the player that they are allowed to make a move. However, this makes the display unappealing. Another mitigation to this problem was utilising the systick timer to remove button mashing and bounces entirely. By having an address in data check when the button was last presssed, we can ignore presses that occured too fast. The tradeoff is that players will have to time their moves on the descent of the piece and not mash the buttons. An improvement would be to have two seperate states for the board, one solely for display and another for the backend. This way the program can wait till the display finishes before the next state is displayed on the board.

Overall, despite some flaws, the solid foundation of the game provides an excellent base to expand the program's capabilities further. Most importantly, the game allows players to enjoy a byte-sized version (haha get it!) of tetris.







