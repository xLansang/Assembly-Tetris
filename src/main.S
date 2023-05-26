.syntax unified
.global main

.set GPIOTE_EVENTS_IN0, 0x40006100
.set GPIOTE_INTENSET, 0x40006304
.set GPIOTE_CONFIG0, 0x40006510
.set GPIOTE_CONFIG1, 0x40006514
.set GPIOTE_EVENTS_IN1, 0x40006104
.set SHPR3, 0xE000ED20
.set NVIC_IPR1, 0xE000E404

@ NVIC Constants
.set NVIC_ISER0, 0xE000E100

.type main, %function
main:
@Turning on buttons, systick timer and LEDs
  bl init_leds

  ldr r0, =ADR_SYST_CSR
  ldr r1, [r0]
  mov r2, 0b111
  orr r1, r2
  str r1, [r0]

  ldr r3, =ADR_SYST_RVR
  ldr r1, =0b111010000100100000000000
  str r1, [r3]

  ldr r0, =GPIOTE_CONFIG0
  ldr r1, =(1 | 14 << 8 | 0 << 13 | 1 << 16) @ |
  str r1, [r0]

  ldr r0, =GPIOTE_CONFIG1
  ldr r1, =(1 | 23 << 8 | 0 << 13 | 1 << 16) @ |
  str r1, [r0]

  ldr r0, =GPIOTE_INTENSET
  ldr r1, =0b11
  str r1, [r0]

  ldr r0, =SHPR3
  ldr r1, =(0 << 31 | 1 << 30 |  0 << 29 )
  str r1, [r0]


  ldr r0, =NVIC_IPR1
  ldr r1, =(0 << 23 | 0 << 22 |  1 << 21 )
  str r1, [r0]

  ldr r0, =NVIC_ISER0
  ldr r1, =(1 << 6) 
  str r1, [r0]

@ Beginning of program
  start:
  ldr r0, =lights_end
  mov r1, 5
  mov r2, 1
  bl display_image

  ldr r0, =lights_end
  mov r1, 5
  mov r2, 1
  bl display_image

  ldr r0, =lights_end
  mov r1, 5
  mov r2, 1
  bl display_image

  ldr r0, =T
  mov r1, 10
  mov r2, 5
  mov r3, 0b00001
  bl show_image

  ldr r4, =E
  mov r0, r4
  mov r1, 10
  mov r2, 5
  mov r3, 0b00001
  bl show_image

  ldr r4, =T
  mov r0, r4
  mov r1, 10
  mov r2, 5
  mov r3, 0b00001
  bl show_image

  ldr r4, =R
  mov r0, r4
  mov r1, 10
  mov r2, 5
  mov r3, 0b00001
  bl show_image

  ldr r4, =I
  mov r0, r4
  mov r1, 10
  mov r2, 5
  mov r3, 0b00001
  bl show_image

  ldr r4, =S
  mov r0, r4
  mov r1, 10
  mov r2, 5
  mov r3, 0b00001
  bl show_image

@Beginning of game
  tetris_display:
  ldr r0, =first_piece
  bl drop_piece

  ldr r0, =second_piece
  bl drop_piece

  ldr r0, =third_piece
  bl drop_piece

  ldr r0, =fourth_piece
  bl drop_piece

  ldr r0, =fifth_piece
  bl drop_piece

  ldr r0, =sixth_piece
  bl drop_piece

  end_game:
  ldr r0, =systimer @resets the button bounce checker
  mov r1, 0
  str r1, [r0]
  
  mov r5, 3
  end_gameloop:
  ldr r4, =tetris
  mov r0, r4
  mov r1, 5
  mov r2, 5
  mov r3, 0b00001
  bl show_image

  ldr r4, =empty
  mov r0, r4
  mov r1, 10
  mov r2, 5
  mov r3, 0b00001
  bl show_image

  subs r5, 1
  blt reset_game

  b end_gameloop

@Clearing boards, current piece and booleans
  reset_game:
  ldr r0, =tetris
  mov r1, 0
  str r1, [r0]
  str r1, [r0, 4] 
  str r1, [r0, 8]
  str r1, [r0, 12]
  str r1, [r0, 16]

  ldr r0, =prev_tetris
  str r1, [r0]
  str r1, [r0, 4]
  str r1, [r0, 8]
  str r1, [r0, 12]
  str r1, [r0, 16]

  ldr r0, =current_piece
  str r1, [r0]
  str r1, [r0, 4]
  str r1, [r0, 8]
  str r1, [r0, 12]
  str r1, [r0, 16]
  str r1, [r0, 20]

  ldr r0, =collision_address
  str r1, [r0]

  ldr r0, =game_over
  str r1, [r0]
  b start
  
.size main, .-main



.type check_collision %function
@ takes four arguments, the current columns of a piece and the position of that piece
@ if a piece has less than three, then enter the columns as 0
@ Function checks if a piece has hit another piece
@ Input:
@ R0, left column address of piece
@ R1, middle column size horizontally
@ R2, right column position
@ R3, position address
@ Output: sets the data at check collisons to 1, if there is a collision
@ 0 if there is no collision

check_collision:
  str lr, [sp, -4]!
  str r4, [sp, -4]!
  str r5, [sp, -4]!
  str r6, [sp, -4]!
  str r7, [sp, -4]!

  mov r7, r3
  ldr r6, [r7, 12] @size
  ldr r3, [r7, 20] @position

@gets the corresponding columns of the game to match the position of the piece
  ldr r4, =tetris 
  lsl r3, 2
  add r4, r3

  ldr r3, [r4] @checks if there is a collision by AND columns of piece and columns of Board
  and r0, r3
  cmp r0, 0
  bgt true
  cmp r6, 1
  beq false

  ldr r3, [r4, 4]
  and r1, r3
  cmp r1, 0
  bgt true
  cmp r6, 2
  beq false
  
  ldr r3, [r4, 8]
  and r2, r3
  cmp r2, 0
  bgt true

  false:
  ldr r1, =collision_address
  mov r2, 0
  str r2, [r1]
  b exit_check

  true:
  ldr r1, =collision_address
  mov r2, 1
  str r2, [r1]
  b exit_check

  exit_check:
  ldr r7, [sp], 4
  ldr r6, [sp], 4
  ldr r5, [sp], 4
  ldr r4, [sp], 4
  ldr lr, [sp], 4 

  bx lr

.size check_collision, .-check_collision

.type insert_piece %function
@ takes three arguments, 
@ R0: the address of a piece in data. 
@ R1: the position you would like to insert it in
@ R2: address of a game
@ inserts a piece into the game. 
@ If there is a collision. it changes the value of game over to 1
@ Input: R0, address of piece in data
@
@ Output: new tetris state, checks if game is over
insert_piece:
  str lr, [sp, -4]!
  str r4, [sp, -4]!
  str r5, [sp, -4]!
  str r6, [sp, -4]!
  str r7, [sp, -4]!
  str r8, [sp, -4]!

  mov r5, r0
  mov r8, r1
  mov r4, r2

  ldr r0, [r5]
  ldr r1, [r5, 4] 
  ldr r2, [r5, 8]
  mov r3, r5

  bl check_collision @Checks if inserting a piece will result in a collision
  ldr r0, =collision_address
  ldr r1, [r0]
  cmp r1, 1
  bne continue_insert

  ldr r0, =game_over
  mov r1, 1
  str r1, [r0]

  continue_insert: 
  lsl r8, 2
  add r4, r8 @This section inserts the piece at the correct location in the board
  mov r3, r5
  ldr r5, [r4]
  ldr r6, [r4, 4]
  ldr r7, [r4, 8]

  ldr r0, [r3]
  ldr r1, [r3, 4]
  ldr r2, [r3, 8]

  orr r5, r0
  orr r6, r1
  orr r7, r2

  str r5, [r4]
  str r6, [r4, 4]
  str r7, [r4, 8]

  ldr r8, [sp], 4
  ldr r7, [sp], 4
  ldr r6, [sp], 4
  ldr r5, [sp], 4
  ldr r4, [sp], 4
  ldr lr, [sp], 4 

  bx lr

.size insert_piece, .-insert_piece

.type drop_piece %function
@ takes one argument, R0, the address of a piece
@ this function sets the argument to the current piece
@ it then loops, decreasing the position of the piece vertically until that piece is set on the board
@ Input: R0, address of piece in data
@ Output: new tetris image
drop_piece:
  str lr, [sp, -4]!
  str r4, [sp, -4]!
  str r5, [sp, -4]!
  str r6, [sp, -4]!
  str r7, [sp, -4]!

  ldr r1, [r0]
  ldr r2, [r0, 4]
  ldr r3, [r0, 8]
  ldr r4, [r0, 12]
  ldr r5, [r0, 16]
  ldr r6, [r0, 20]

  ldr r0, =current_piece
  str r1, [r0]
  str r2, [r0, 4]
  str r3, [r0, 8]
  str r4, [r0, 12]
  str r5, [r0, 16]
  str r6, [r0, 20]

  mov r0, r1
  mov r1, r2
  mov r2, r3
  ldr r3, =current_piece

  bl check_collision
  ldr r0, =collision_address
  ldr r1, [r0]
  cmp r1, 1
  beq end_game

  ldr r0, =possible_move
  mov r1, 1
  str r1, [r0]

  ldr r0, =current_piece
  ldr r1, [r0, 20]
  ldr r2, =prev_tetris
  bl insert_piece
  
  ldr r0, =prev_tetris @show the player the current position of the piece
  mov r1, 20
  mov r2, 5
  mov r3, 0b00001
  bl show_image

  ldr r0, =current_piece
  ldr r1, [r0, 20]
  
  ldr r0, =prev_tetris @clear the board to prepare the piece's descent
  lsl r1, 2
  add r0, r1
  ldr r1, [r0]
  ldr r2, [r0, 4]
  ldr r3, [r0, 8]

  ldr r7, =current_piece
  ldr r4, [r7]
  ldr r5, [r7, 4]
  ldr r6, [r7, 8]

  bic r1, r4
  bic r2, r5
  bic r3, r6

  str r1, [r0]
  str r2, [r0, 4]
  str r3, [r0, 8]

  ldr r7, [r7, 16]
  mov r0, 5
  sub r7, r0, r7
  
 
  @ shuffle piece down
  go_down:
  ldr r4, =current_piece
  ldr r0, [r4]
  ldr r1, [r4, 4]
  ldr r2, [r4, 8]
  ldr r3, [r4, 20]
  lsl r0, 1
  lsl r1, 1
  lsl r2, 1
  mov r3, r4

  mov r4, r0
  mov r5, r1
  mov r6, r2

  bl check_collision @Check if descent causes collision
  ldr r0, =collision_address
  ldr r1, [r0]
  cmp r1, 1
  beq set_piece

  ldr r0, =current_piece
  str r4, [r0]
  str r5, [r0, 4]
  str r6, [r0, 8]

  ldr r0, =current_piece @insert piece if no collision
  ldr r1, [r0, 20]
  ldr r2, =prev_tetris
  bl insert_piece
  
  ldr r0, =prev_tetris
  mov r1, 20
  mov r2, 5
  mov r3, 0b00001
  bl show_image
  
  ldr r0, =current_piece
  ldr r1, [r0, 20]
  
  ldr r0, =prev_tetris
  lsl r1, 2
  add r0, r1
  ldr r1, [r0]
  ldr r2, [r0, 4]
  ldr r3, [r0, 8]

  bic r1, r4
  bic r2, r5
  bic r3, r6

  str r1, [r0]
  str r2, [r0, 4]
  str r3, [r0, 8]

  ldr r0, =possible_move
  mov r1, 1
  str r1, [r0]

  subs r7, 1
  beq set_piece @if it cannot move any further set the piece
  b go_down

  set_piece:
  ldr r0, =current_piece   @insert the next piece
  ldr r1, [r0, 20]
  ldr r2, =tetris
  bl insert_piece

  ldr r0, =tetris @this finalises the position of the piece into the board
  ldr r1, [r0]
  ldr r2, [r0, 4]
  ldr r3, [r0, 8]
  ldr r4, [r0, 12]
  ldr r5, [r0, 16]
   
  ldr r0, =prev_tetris
  str r1, [r0]
  str r2, [r0, 4]
  str r3, [r0, 8]
  str r4, [r0, 12]
  str r5, [r0, 16]

  display:
  ldr r4, =tetris @display the state after the piece has been set
  mov r0, r4
  mov r1, 50
  mov r2, 5
  mov r3, 0b00001
  bl show_image

  next_piece:
  ldr r7, [sp], 4
  ldr r6, [sp], 4
  ldr r5, [sp], 4
  ldr r4, [sp], 4 
  ldr lr, [sp], 4 

  bx lr

.size drop_piece, .-drop_piece

.global GPIOTE_IRQHandler
.type GPIOTE_IRQHandler, %function
GPIOTE_IRQHandler:
  @ setup a breakpoint here to check when the interrupt occurs.
  @ interrupt code goes here
  str lr, [sp, -4]!
  str r4, [sp, -4]!

  ldr r0, =systimer @Check if a button has bounced
  ldr r1, [r0]
  ldr r2, [r0, 4]
  str r1, [r0, 4]
  sub r1, 1
  cmp r1, r2
  ble clear_event

  ldr r0, =possible_move @Check if button is timed correctly
  ldr r1, [r0]
  cmp r1, 1
  bne clear_event

  ldr r0, =GPIOTE_EVENTS_IN0 @Check whether button a or button b was pressed
  ldr r1, [r0]
  cmp r1, 1
  bne button_b

  ldr r0, =current_piece @check if the move is out of bounds
  ldr r1, [r0, 20]
  ldr r2, [r0, 12]
  cmp r1, 0
  beq clear_event

  sub r1, 1
  str r1, [r0, 20] @shift left

  ldr r4, =current_piece
  ldr r0, [r4]
  ldr r1, [r4, 4]
  ldr r2, [r4, 8]
  mov r3, r4

  bl check_collision @ensure moving does not cause collision
  ldr r0, =collision_address
  ldr r1, [r0]
  cmp r1, 1
  bne clear_event

  ldr r1, [r4, 20] @if shift is invalid, revert the position to orignal and do nothing
  add r1, 1
  str r1, [r4, 20]
  
  b clear_event

  button_b:
  ldr r0, =current_piece @check if the move is out of bounds
  ldr r1, [r0, 20]
  ldr r2, [r0, 12]
  mov r3, 5
  sub r3, r2
  cmp r1, r3
  beq clear_event

  add r1, 1
  str r1, [r0, 20] @shift right

  ldr r4, =current_piece
  ldr r0, [r4]
  ldr r1, [r4, 4]
  ldr r2, [r4, 8]
  mov r3, r4

  bl check_collision
  ldr r0, =collision_address
  ldr r1, [r0]
  cmp r1, 1
  bne clear_event

  ldr r1, [r4, 20] @if shift is invalid, revert the position to orignal and do nothing
  sub r1, 1
  str r1, [r4, 20]

  
  clear_event:
  ldr r0, =GPIOTE_EVENTS_IN0 @Clear buttons
  ldr r1, =0
  str r1, [r0]

  ldr r0, =GPIOTE_EVENTS_IN1
  ldr r1, =0
  str r1, [r0]

  ldr r4, [sp], 4
  ldr lr, [sp], 4
  bx lr
.size GPIOTE_IRQHandler, .-GPIOTE_IRQHandler

.global SysTick_Handler
.type SysTick_Handler, %function
SysTick_Handler:
  ldr r0,=systimer @increments to keep in track how long it has been since previous button pressed
  ldr r1,[r0]
  add r1, 1
  str r1, [r0]
  bx lr
.size SysTick_Handler, .-SysTick_Handler


.data
systimer:
.word 0
.word 0

lights:
 .word 0b10001
 .word 0b10001
 .word 0b10001
 .word 0b10001 
 .word 0b10001
lights_end:

T:
 .word 0b00000
 .word 0b00001
 .word 0b11111 
 .word 0b00001 
 .word 0b00000
E:
 .word 0b00000
 .word 0b11111
 .word 0b10101
 .word 0b10101 
 .word 0b00000
R:
 .word 0b00000
 .word 0b11111
 .word 0b00101
 .word 0b11010
 .word 0b00000
I:
 .word 0b00000
 .word 0b10001
 .word 0b11111 
 .word 0b10001 
 .word 0b00000
S:
 .word 0b00000
 .word 0b10111
 .word 0b10101 
 .word 0b11101 
 .word 0b00000

tetris:
  .word 0b00000 @Final state of the board
  .word 0b00000
  .word 0b00000 
  .word 0b00000
  .word 0b00000 

prev_tetris:
  .word 0b00000 @State of the board used as the gamestate shifts
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 

empty:
  .word 0b00000 @used in endgame to flash boarrd
  .word 0b00000 
  .word 0b00000
  .word 0b00000
  .word 0b00000 

current_piece:
  .word 0b00000 @Each piece is inserted to this data structure
  .word 0b00000 @to allow changes without have to ruin original
  .word 0b00000 
  .word 0b00000
  .word 0b00000
  .word 0b00000
@Pieces of the board! Adjust these if the game is too hard.
first_piece:
  .word 0b00010
  .word 0b00011
  .word 0b00010
  .word 3 @ size horizontally
  .word 2 @ size vertically
  .word 0 @ position (changes depending on buttons)

second_piece:
  .word 0b00011
  .word 0b00001
  .word 0b00000
  .word 2 
  .word 2 
  .word 1 

third_piece:
  .word 0b00001
  .word 0b00011
  .word 0b00000
  .word 2 
  .word 2
  .word 2

fourth_piece:
  .word 0b00001
  .word 0b00001
  .word 0b00000
  .word 2 
  .word 1 
  .word 1 

fifth_piece:
  .word 0b00001
  .word 0b00001
  .word 0b00000
  .word 2 
  .word 1 
  .word 3 

sixth_piece:
  .word 0b00001
  .word 0b00000
  .word 0b00000
  .word 1 
  .word 1 
  .word 3

collision_address: 
.word 0 @ if this is 0, there is no collision, if this is 1, there is one

game_over:
.word 0 @ If this is 0, the game is still on!, if this is 1, the game is over

possible_move: 
.word 0 @ a button will only work if this value is 1

