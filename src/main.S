.syntax unified
.global main

.set GPIOTE_EVENTS_IN0, 0x40006100
.set GPIOTE_INTENSET, 0x40006304
.set GPIOTE_CONFIG0, 0x40006510
.set GPIOTE_CONFIG1, 0x40006514
.set GPIOTE_EVENTS_IN1, 0x40006104
.set SHPR3, 0xE000ED20
.set NVIC_IPR1, 0xE000E404

@Have a game state function that loops on a single piece
@At the play of each piece, insert the columns of the piece into r0, r1, r2.
@Change the data structure of the current piece to the piece at r0, r1, r2
@Have a data structure called position that contains the number 0
@if the button B button is pressed, add 1 to this data structure and shift the position of piece in the current state to the right
@if the button A is pressed, substract 1 to this data structure and shift the position of a piece in the current state to the right
@if the position is 0, A does nothing
@if the the position is 5 - size of the piece, B does nothing

@ NVIC Constants
.set NVIC_ISER0, 0xE000E100

.type main, %function
main:
  bl init_leds

  ldr r0, =GPIOTE_CONFIG0
  ldr r1, =(1 | 14 << 8 | 0 << 13 | 1 << 16) @ |
  str r1, [r0]

  @ 1: Configure GPIOTE_CONFIG[0]
  @   Need to setup: mode, pin, port, polarity in the configuration 
  @   register for GPIOTE[0]
  @ Section 6.9.4.8 in nRF52833 reference manual
  @   mode = 1 (event), pin = 14 and port = 0 (P0.14 = Button A), 
  @   polarity = 1 (LoToHi)
  ldr r0, =GPIOTE_CONFIG1
  ldr r1, =(1 | 23 << 8 | 0 << 13 | 1 << 16) @ |
  str r1, [r0]

@ 2: Enable Interrupt for GPIOTE[0] (id = 6)
  @ S6.9.4.6 in nRF52833 reference manual
  ldr r0, =GPIOTE_INTENSET
  ldr r1, =0b11
  str r1, [r0]

  ldr r0, =SHPR3
  ldr r1, =(0 << 31 | 1 << 30 |  0 << 29 )
  str r1, [r0]


  ldr r0, =NVIC_IPR1
  ldr r1, =(0 << 23 | 0 << 22 |  1 << 21 )
  str r1, [r0]

@ 3: enable GPIOTE (interrupt #6 = NVIC_GPIOTE_ID) in NVIC_ISER0
  @ NVIC_ISER0: B3.4.4 in ARMv7-M Reference Manual
  ldr r0, =NVIC_ISER0
  ldr r1, =(1 << 6) @ set the 6th bit since NVIC_GPIOTE_ID = 6
  str r1, [r0]
 
  @ ldr r0, =image_end
  @ sub r0, 4
  @ mov r1, 5
  @ mov r2, 2
  @ bl display_image

  tetris_display:
  ldr r4, =tetris
  mov r5, 4

  tetris_loop:
  mov r0, r4
  mov r1, 10
  mov r2, 5
  mov r3, 0b00001
  bl show_image

  subs r5, 1
  beq here

  ldr r1, [r4]
  ldr r2, [r4, 4]
  ldr r3, [r4, 8]

  lsl r1, 1
  lsl r2, 1
  lsl r3, 1
  
  str r1, [r4]
  str r2, [r4, 4]
  str r3, [r4, 8]

  b tetris_loop

  here:
  ldr r0, =tetris_pieces
  bl drop_piece

  inf_loop:
  nop
  b inf_loop
  b main
.size main, .-main

.type display_image %function
@ takes two arguments, base address of the image, length of image
@ R0: base address
@ R1: length
@ R2: speed of display
@ loads the value at the base address
@ scans the image at the base address

display_image:
  str lr, [sp, -4]!
  str r4, [sp, -4]!
  str r5, [sp, -4]!
  str r6, [sp, -4]!
  str r7, [sp, -4]!
  str r8, [sp, -4]!
  str r9, [sp, -4]!
  str r10, [sp, -4]!
  str r11, [sp, -4]!

  mov r6, 5
  mov r4, r0
  mov r5, 1
  mov r11, r2

  display_loop:
  mov r0, r4
  mov r1, r11
  mov r2, r5
  mov r3, 0b00001
  bl show_image

  cmp r5, 5
  beq forward

  sub r4, 4
  add r5, 1

  b display_loop

  forward:
  mov r5, 4
  mov r3, 0b00010
  
  forward_loop:
  mov r0, r4
  mov r1, r11
  mov r2, r5
  bl show_image

  subs r5, 1
  beq leave

  lsl r3, 1
  b forward_loop
  
  leave:
  ldr r11, [sp], 4
  ldr r10, [sp], 4
  ldr r9, [sp], 4
  ldr r8, [sp], 4
  ldr r7, [sp], 4
  ldr r6, [sp], 4
  ldr r5, [sp], 4
  ldr r4, [sp], 4
  ldr lr, [sp], 4 

  bx lr

.size display_image, .-display_image


.type show_image %function
@ input:
@ R0: base address
@ R1: number of iterations
@ R2: the number of columns to run through
@ R3: the starting column
@ loads the value at the base address
@ Output:
@ scans the image at the base address

show_image:
  str lr, [sp, -4]!
  str r4, [sp, -4]!
  str r5, [sp, -4]! @store registers on to stack
  str r6, [sp, -4]!
  str r7, [sp, -4]!
  str r8, [sp, -4]!
  str r9, [sp, -4]!

  str r3, [sp, -4]!

  mov r9, r2 @number of columns to go through
  mov r10, r3 @ starting column

  mov r4, r0 @r4 register is used to iterate through the addresses of each column
  mov r8, r0 @r8 register is used to remember the base address of the image to return to

  mov r7, r1 @remember the number of times to display image
  mov r6, 0
  bl init_leds
  ldr r5, [sp]

  show_loop:
  ldr r0, [r4], 4
  bl write_row_pins

  mov r0, r5
  bl write_column_pins

  mov r0, 0x10000
  bl delay
  mov r0, 0x1000
  bl delay

  mov r0, 0b00000
  bl write_column_pins

  mov r0, 0x1000
  bl delay
  
  lsl r5, 1
  add r6, 1

  cmp r6, r9 @check if you've finished the full image
  bne show_loop 

  mov r6, 0
  ldr r5, [sp]
  mov r4, r8

  subs r7, 1 @check if you've shown the image n amount of times
  blt leave_show

  b show_loop
  
  leave_show:
  ldr r3, [sp], 4
  ldr r9, [sp], 4
  ldr r8, [sp], 4
  ldr r7, [sp], 4
  ldr r6, [sp], 4
  ldr r5, [sp], 4
  ldr r4, [sp], 4
  ldr lr, [sp], 4 

  bx lr

.size show_image, .-show_image

.type check_collision %function
@ takes four arguments, the current columns of a piece and the position of that piece
@ if a piece has less than three, then enter the columns as 0
@ Function checks if a piece has the the bottom or another piece
@ Input:
@ R0, left column
@ R1, middle column
@ R2, right column
@ R3, position
@ Output: sets the data at check collisons to 1, if there is a collision
@ 0 if there is no collision

check_collision:
  str lr, [sp, -4]!
  str r4, [sp, -4]!
  str r5, [sp, -4]!
  str r6, [sp, -4]!

  ldr r4, =prev_tetris
  lsl r3, 2
  add r4, r3
  
  ldr r3, [r4]
  and r0, r3
  cmp r0, 0
  bgt true

  ldr r3, [r4, 4]
  and r1, r3
  cmp r1, 0
  bgt true
  
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
  ldr r6, [sp], 4
  ldr r5, [sp], 4
  ldr r4, [sp], 4
  ldr lr, [sp], 4 

  bx lr

.size check_collision, .-check_collision

.type check_columns %function
@ takes one argument, R0
@ Input: R0, column we want to check for collision
@ Output: R1 is 1 if its true, 0 if its false.
check_columns:
  str lr, [sp, -4]!
  str r4, [sp, -4]!
  str r5, [sp, -4]!
  str r6, [sp, -4]!

  ldr r4, =prev_tetris
  mov r5, 4
  mov r6, 0
  column_loop:
  mul r5, r6
  ldr r3, [r4, r5]
  and r3, r0
  cmp r3, 0
  bgt set_true

  cmp r6, 4
  beq set_false
  mov r5, 4
  add r6, 1
  b column_loop

  set_true:
  mov r1, 1
  b exit_column

  set_false:
  mov r1, 0
  b exit_column

  exit_column:
  ldr r6, [sp], 4
  ldr r5, [sp], 4
  ldr r4, [sp], 4
  ldr lr, [sp], 4 

  bx lr

.size check_columns, .-check_columns

.type insert_piece %function
@ takes three arguments, 
@ R0: the address of a piece in data. 
@ R1: the position you would like to insert it in
@ R2: address of a game
@ inserts a piece into the game. 
@ If there is a collision. i.e it overlaps an existing piece on the game. it changes the value of game over to 1
@ Input: R0, address of piece in data
@
@ Output: new tetris image state, checks if game is over
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
  ldr r3, [r5, 20]

  bl check_collision
  ldr r0, =collision_address
  ldr r1, [r0]
  cmp r1, 1
  bne continue_insert

  ldr r0, =game_over
  mov r1, 1
  str r1, [r0]

  continue_insert:
  lsl r8, 2
  add r4, r8
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
  mov r3, r6

  bl check_collision
  ldr r0, =collision_address
  ldr r1, [r0]
  cmp r1, 1
  beq next_piece @change to end_game afterwards

  ldr r0, =current_piece
  ldr r1, [r0, 20]
  ldr r2, =prev_tetris
  bl insert_piece
  
  ldr r0, =prev_tetris
  mov r1, 10
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

  @ ldr r0, =current_piece   @insert the next piece
  @ ldr r1, [r0, 20]
  @ ldr r2, =tetris
  @ bl insert_piece

  @ ldr r4, =tetris
  @ mov r0, r4
  @ mov r1, 10
  @ mov r2, 5
  @ mov r3, 0b00001
  @ bl show_image

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

  mov r4, r0
  mov r5, r1
  mov r6, r2

  bl check_collision
  ldr r0, =collision_address
  ldr r1, [r0]
  cmp r1, 1
  beq set_piece

  ldr r0, =current_piece
  str r4, [r0]
  str r5, [r0, 4]
  str r6, [r0, 8]

  ldr r0, =current_piece
  ldr r1, [r0, 20]
  ldr r2, =prev_tetris
  bl insert_piece
  
  ldr r0, =prev_tetris
  mov r1, 10
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

  @ ldr r0, =prev_tetris
  @ mov r1, 10
  @ mov r2, 5
  @ mov r3, 0b00001
  @ bl show_image

  b go_down

  set_piece:
  ldr r0, =current_piece   @insert the next piece
  ldr r1, [r0, 20]
  ldr r2, =tetris
  bl insert_piece

  ldr r0, =tetris
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
  ldr r4, =tetris
  mov r0, r4
  mov r1, 10
  mov r2, 11
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
  @ interrupt code goes here'
  str lr, [sp, -4]!
  str r0, [sp, -4]!
  str r1, [sp, -4]!
  str r2, [sp, -4]!
  str r3, [sp, -4]!

  ldr r0, =image_end
  sub r0, 4
  mov r1, 5
  bl display_image
  
  @ clear event
  ldr r0, =GPIOTE_EVENTS_IN0
  ldr r1, =0
  str r1, [r0]

  ldr r0, =GPIOTE_EVENTS_IN1
  ldr r1, =0
  str r1, [r0]

  ldr r3, [sp], 4
  ldr r2, [sp], 4
  ldr r1, [sp], 4
  ldr r0, [sp], 4
  ldr lr, [sp], 4
  bx lr
.size GPIOTE_IRQHandler, .-GPIOTE_IRQHandler


.data
image:
  .word 0b10001 @ Column 1
  .word 0b10001 @ Column 2
  .word 0b10101 @ Column 3
  .word 0b10001 @ Column 4
  .word 0b10001 @ Column 5
image_end:
tetris:
  .word 0b00010 @ Column 1
  .word 0b00011 @ Column 2
  .word 0b00010 @ Column 3
  .word 0b00000 @ Column 4
  .word 0b00000 @ Column 5

prev_tetris:
  .word 0b10000 @ Column 1
  .word 0b11000 @ Column 2
  .word 0b10000 @ Column 3
  .word 0b00000 @ Column 4
  .word 0b00000 @ Column 5

current_piece:
  .word 0b00000 @ Column 1
  .word 0b00000 @ Column 2
  .word 0b00000 @ Column 3
  .word 0b00000
  .word 0b00000
  .word 0b00000

tetris_pieces:
  .word 0b00001
  .word 0b00011
  .word 0b00000
  .word 2 @ size horizontally
  .word 2 @ size vertically
  .word 2 @ position (changes depending on buttons)

collision_address: 
.word 0 @if this is 0, there is no collision, if this is 1, there is one

game_over:
.word 0 @If this is 0, the game is still on!, if this is 1, the game is over

