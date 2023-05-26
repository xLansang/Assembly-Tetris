.syntax unified

@ Function exports:
.global show_image, display_image

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
  str r10, [sp, -4]!

  @ ldr r4, =possible_move
  @ mov r5, 0
  @ str r5, [r4]

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
  @ ldr r4, =possible_move
  @ mov r5, 1
  @ str r5, [r4]

  ldr r3, [sp], 4
  ldr r10, [sp], 4
  ldr r9, [sp], 4
  ldr r8, [sp], 4
  ldr r7, [sp], 4
  ldr r6, [sp], 4
  ldr r5, [sp], 4
  ldr r4, [sp], 4
  ldr lr, [sp], 4 

  bx lr

.size show_image, .-show_image


.type display_image %function
@ takes two arguments, end address of the image, length of image
@ R0: end address of the image
@ R1: length of the image
@ R2: speed of display. Higher values >> slower and vice versa.
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
  mov r5, 1 @move values to registers that will not change after a function is called
  mov r11, r2

  display_loop:
  mov r0, r4
  mov r1, r11
  mov r2, r5
  mov r3, 0b00001  @Starting at the e
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

