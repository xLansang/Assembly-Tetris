<div style="text-align: center;">

# Mini Tetris

</div>

Mini tetris is an interactive game created on a 5x5 LED display of a microbit. The game runs 3 stages. The initial display of the TETRIS word, the play of the game, and lastly the end/reset stage. The following report describes how the game is played, how the game was implemented, and an analysis on the final design.

The play of the game involves placing 6 pieces on the board. Only one piece is placed at a time and each piece is inserted into the game at the top of the display. The player is able to control the position of the pieces by using the A button to left shift and the B button to right shift.  The pieces will automatically move downwards and players will have a limited time to conduct their shifts. The game ends when all six pieces are placed, or if there is no space at the top of the board for a piece to be inserted.

At the end of the game the board will flash three times and a score will be displayed based on the number of completely filled rows in the game.


<h2>Implementation</h2>


The game utilises a series of functions and data structures to make the implementation of the design clean and easily modifiable. The figure belows provides an image how the functions of the game work together to display the correct images.





