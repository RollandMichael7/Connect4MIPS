
.data
	board: .space 50
	
.text

main:

# arbitrary numbers to ensure reserved registers are untouched by functions
li $s0, 21
li $s1, 69
li $s2, 223
li $s3, 420
li $s4, 62
li $s5, 321

# move stack pointer to make room for function calls
addi $sp, $sp, -12

la $a0, board
li $a1, 5
li $a2, 5
# clear the board
jal clear_board

la $a0, board # board
li $a1, 5 # num_rows
li $a2, 5 # num_cols
li $a3, 0 # col
li $t0, 82
sw $t0, 0($sp) # c
li $t0, 15
sw $t0, 4($sp) # turn_num
# drop a RED piece in column 0
jal drop_piece

la $a0, board
li $a3, 1 # col
li $t0, 89
sw $t0, 0($sp) # c
li $t0, 16
sw $t0, 4($sp) # turn_num
# drop a YELLOW piece in column 1
jal drop_piece

la $a0, board
li $a3, 1 # col
li $t0, 82
sw $t0, 0($sp) # c
li $t0, 32
sw $t0, 4($sp) # turn_num
# drop a RED piece in column 1
jal drop_piece

la $a0, board
li $a3, 2
li $t0, 89
sw $t0, 0($sp) # c
li $t0, 32
sw $t0, 4($sp) # turn_num
# drop a YELLOW piece in column 2
jal drop_piece

la $a0, board
li $a3, 2
li $t0, 89
sw $t0, 0($sp) # c
li $t0, 32
sw $t0, 4($sp) # turn_num
# drop a YELLOW piece in column 2
jal drop_piece

la $a0, board
li $a3, 2
li $t0, 82
sw $t0, 0($sp) # c
li $t0, 32
sw $t0, 4($sp) # turn_num
# drop a RED piece in column 2
jal drop_piece

la $a0, board
li $a3, 3
li $t0, 89
sw $t0, 0($sp) # c
li $t0, 32
sw $t0, 4($sp) # turn_num
# drop a YELLOW piece in column 3
jal drop_piece

la $a0, board
li $a3, 3
li $t0, 89
sw $t0, 0($sp) # c
li $t0, 32
sw $t0, 4($sp) # turn_num
# drop a YELLOW piece in column 3
jal drop_piece

la $a0, board
li $a3, 3
li $t0, 89
sw $t0, 0($sp) # c
li $t0, 32
sw $t0, 4($sp) # turn_num
# drop a YELLOW piece in column 3
jal drop_piece

la $a0, board
li $a3, 3
li $t0, 82
sw $t0, 0($sp) # c
li $t0, 32
sw $t0, 4($sp) # turn_num
# drop a RED piece in column 3
jal drop_piece

la $a0, board
li $a1, 5
li $a2, 5
# display the board
jal display_board

la $a0, board
li $a1, 5
li $a2, 5
# check for a win by diagonal (puts ASCII value of winning color in $v0)
jal check_diagonal_winner

addi $sp, $sp, 12

# Store result of check_diagonal_winner in $s0
move $s0, $v0

# Print newline twice
li $a0, 10
li $v0, 11
syscall
syscall

# Print result of check_diagonal_winner (should be 'R')
move $a0, $s0
li $v0, 11
syscall

# Terminate program
li $v0, 10
syscall

.include "connectFour.asm"
