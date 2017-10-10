# Functions for the game of Connect Four.
# Author: Michael Rolland
# Version: 2017.10.10

.text

error_oneReturn:
	li $v0, -1
	jr $ra

error_twoReturns:
    li $v0, -1
    li $v1, -1
    jr $ra
	
##############################
##      set_slot            ##
##############################



set_slot:
    blt $a1, 0, error_oneReturn # error if num_rows < 0
    blt $a2, 0, error_oneReturn # error if num_cols < 0
    
    lw $t0, 0($sp) # $t0 = col
    
    blt $a3, 0, error_oneReturn # error if row < 0
    blt $t0, 0, error_oneReturn # error if col < 0
    addi $t1, $a1, -1 # $t1 = num_rows-1
    addi $t2, $a2, -1 # $t2 = num_cols-1
    bgt $a3, $t1, error_oneReturn # error if row > num_rows-1
    bgt $t0, $t2, error_oneReturn # error if col > num_cols-1
    
    lw $t1, 4($sp) # $t1 = c
    beq $t1, 82, continue_setSlot
    beq $t1, 89, continue_setSlot
    beq $t1, 46, continue_setSlot
    j error_oneReturn # error if c != 'R', 'Y', or '.'
    
    continue_setSlot:      
    lw $t2, 8($sp) # $t2 = turn_num
    blt $t2, 0, error_oneReturn
    bgt $t2, 255, error_oneReturn
    
    addi $sp, $sp, -4
    sw $s0, 0($sp)
    
    li $t3, 2 # size_of_obj = 2
    mult $t3, $a2 
    mflo $t3 # $t3 = num_cols * size_ob_obj = row_size
    mult $t3, $a3 
    mflo $t3 # $t3 = row_size * i
    li $s0, 2 # size_of_obj = 2
    mult $s0, $t0 
    mflo $s0 # $s0 = size_of_obj * j
    add $t3, $s0, $t3 # $t3 = (row_size * i) + (size_of_obj * j)
    add $t3, $a0, $t3 # $t3 = address of board(row, col)
    
    sb $t2, 0($t3) # store turn_num
    sb $t1, 1($t3) # store c
    
    lw $s0, 0($sp)
    addi $sp, $sp, 4 
    li $v0, 0
    jr $ra

##############################
##         get_slot        ##
##############################
    	
get_slot:
    lw $t0, 0($sp) # col
    bltz $a1, error_twoReturns # num_rows < 0
    bltz $a2, error_twoReturns # num_cols < 0
    bltz $a3, error_twoReturns # row < 0
    bltz $t0, error_twoReturns # col < 0
    
    addi $t1, $a1, -1
    addi $t2, $a2, -1
    bgt $a3, $t1, error_twoReturns # row > num_rows-1
    bgt $t0, $t2, error_twoReturns # col > num_cols-1
    
    li $t1, 2 # size_of_obj = 2
    mult $a2, $t1
    mflo $t1 # $t1 = num_cols * size_of_obj = row_size
    mult $t1, $a3 
    mflo $t3 # $t3 = row_size * i
    li $t4, 2 # size_of_obj = 2
    mult $t4, $t0 
    mflo $t4 # $t4 = size_of_obj * j
    add $t3, $t4, $t3 # $t3 = (row_size * i) + (size_of_obj * j)
    add $t3, $a0, $t3 # $t3 = address of board(row, col)
    
    lb $v0, 1($t3) # load c
    lb $v1, 0($t3) # load turn_num

    jr $ra

##############################
##       clear_board        ##
##############################

clear_board:
    bltz $a1, error_oneReturn # num_rows < 0
    bltz $a2, error_oneReturn # num_cols < 0
    
    li $t6, 0 # i
    li $t7, 0 # j
    addi $sp, $sp, -12
    sw $ra, 12($sp)
    
    ########################################
    ## set_slot uses $t0,$t1,$t2,$t3 ONLY ##
    ########################################
    
    # set_slot params: board, numrow, numcol, row, col, c, turn_num
    
    clearLoop:
    	# $a0 already contains board
    	# $a1 already contains num_rows
    	# $a2 already contains num_cols
    	move $a3, $t6 # row
    	sw $t7, 0($sp) # col
    	li $t0, 46
    	sw $t0, 4($sp) # c
    	sw $zero, 8($sp) # turn_num
    	jal set_slot
    	
    	addi $t7, $t7, 1 # increment j
    	addi $t0, $a2, -1 # $t0 = num_cols - 1
    	addi $t1, $a1, -1 # $t1 = num_rows - 1
    	bgt $t7, $t0, incrementI # if j > num_cols-1, increment i and reset j
    j clearLoop
    	
    incrementI:
    	addi $t6, $t6, 1
    	bgt $t6, $t1, breakClearLoop # if j > num_cols-1 && i > num_rows-1, break loop
    	li $t7, 0 # reset to top of row
    	j clearLoop
    
    breakClearLoop:
    lw $ra, 12($sp)	
    addi $sp, $sp, 12
    li $v0, 0
    jr $ra



##############################
##       display_board      ##
##############################

display_board:
    bltz $a1, error_oneReturn # num_rows < 0
    bltz $a2, error_oneReturn # num_cols < 0
    
    move $t5, $a0 # save board in $t5
    
    addi $t7, $a1, -1 # $t7 = num_rows-1 (start at the top)
    li $t6, -1 # j
    
    addi $sp, $sp, -12
    sw $ra, 4($sp)
    sw $s0, 8($sp)
    
    li $s0, 0 # counter of pieces
    
    ############################################ 
    ## get_slot uses $t0,$t1,$t2,$t3,$t4 ONLY ##
    ############################################
    # get_slot args: board, num_rows, num_cols, row, col @ 0($sp) 
    # get_slot returns c and turn_num
    
    printLoop:
    	move $a0, $t5 # board
    	# $a1 already has num_rows
    	# $a2 already has num_cols
    	move $a3, $t7 # row, starts at num_rows-1
    	addi $t6, $t6, 1
    	addi $t0, $a2, -1 # $t0 = num_cols-1
    	bgt $t6, $t0, printNextRow
    	continuePrint:
    	sw $t6, 0($sp)
    	jal get_slot
    	
    	bne $v0, 46, incrementPieceCount
    	continuePrint2:
    	
    	move $a0, $v0
    	li $v0, 11 
    	syscall # print c	
    j printLoop
    
    incrementPieceCount:
    	addi $s0, $s0, 1
    	j continuePrint2
    		
    printNextRow:
    	addi $t7, $t7, -1 # go to next row down	
    	bltz $t7, returnPrint # if all rows have been printed, return
    	move $a3, $t7 # pass new row as arg
    	li $a0, 10
    	li $v0, 11
    	syscall # print newline
    	li $t6, 0 # start back at first col
    	move $a0, $t5 # board
    	j continuePrint
    	
    returnPrint:
    move $v0, $s0
    lw $s0, 8($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 12
    jr $ra

##############################
##         drop_piece       ##
##############################

drop_piece:
    bltz $a1, error_oneReturn # num_rows < 0
    bltz $a2, error_oneReturn # num_cols < 0
    lw $t5, 0($sp) # piece
    beq $t5, 82, continueDrop
    beq $t5, 89, continueDrop
    j error_oneReturn # piece != 'R' || 'Y'
    continueDrop:
    lw $t6, 4($sp) # turn_num
    bgt $t6, 255, error_oneReturn # turn_num > 255
    
    addi $sp, $sp, -12
    sw $ra, 12($sp)
    
    ############################################ 
    ## get_slot uses $t0,$t1,$t2,$t3,$t4 ONLY ##
    ############################################
    # get_slot args: board, num_rows, num_cols, row, col @ 0($sp) 
    # get_slot returns c and turn_num
    
    move $t7, $a3 # save col in $t7
    li $a3, -1 # i (row)
    findSlotLoop: 
    	# $a0 already holds board
    	# $a1 already holds num_rows
    	# $a2 already holds num_cols
    	addi $a3, $a3, 1 # increment row
   	sw $t7, 0($sp) # col
   	jal get_slot
   	beq $v0, 46, placePiece # if the slot is empty, place piece
   	beq $v0, 0, placePiece
   	beq $v0, -1, error_dropPiece
    j findSlotLoop
    
    error_dropPiece:
    	lw $ra, 12($sp)
    	addi $sp, $sp, 12
    	li $v0, -1
    	jr $ra
    	
    # set_slot args: board, num_rows, num_cols, row, col @ 0, c @ 4, turn_num @ 8
    placePiece:
    # $a0 already holds board
    # $a1 already holds num_rows
    # $a2 already holds num_cols
    # $a3 already holds row
    sw $t7, 0($sp) # col
    sw $t5, 4($sp) # c (piece)
    sw $t6, 8($sp) # turn_num
    jal set_slot
   
    lw $ra, 12($sp)
    addi $sp, $sp, 12
    li $v0, 0
    jr $ra

##############################
##      undo_piece          ##
##############################
error_undo1:
    li $v0, 46
    li $v1, -1
    jr $ra
    
error_undo2:
    li $v0, 46
    li $v1, -1
    lw $s0, 12($sp)
    lw $s1, 16($sp)
    lw $s2, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra


undo_piece:
    bltz $a1, error_undo1 # num_rows < 0
    bltz $a2, error_undo1 # num_cols < 0
    
    addi $sp, $sp, -28
    sw $s0, 12($sp)
    sw $s1, 16($sp)
    sw $s2, 20($sp)
    sw $ra, 24($sp)
       
    move $t5, $a1 # $t5 = num_rows
    li $t6, 0 # $t6 = col
    li $t7, 0 # $t7 will keep track of max turn_num
    li $s0, 0 # $s0 will keep track of piece color
    li $s1, 0 # $s1 will keep track of row of undone piece
    li $s2, 0 # $s2 will keep track of col of undone piece
    
    ############################################ 
    ## get_slot uses $t0,$t1,$t2,$t3,$t4 ONLY ##
    ############################################
    # get_slot args: board, num_rows, num_cols, row, col @ 0($sp) 
    # get_slot returns c and turn_num
    
    findTopLoop:
   	 # $a0 already contains board
   	 # $a1 already contains num_rows
   	 # $a2 already contains num_cols
   	 addi $t5, $t5, -1
   	 move $a3, $t5 # start row at num_rows-1 and decrement to find top piece
   	 sw $t6, 0($sp) # col
   	 jal get_slot
   	 
   	 beq $v0, 82, pieceFound
   	 beq $v0, 89, pieceFound
   	 beq $v0, -1, pieceFound # hit bottom
    j findTopLoop
    
    newMax:
    move $t7, $v1
    move $s0, $v0
    move $s1, $a3
    lw $s2, 0($sp)
    j continueUndo
    
    pieceFound:
    bgt $v1, $t7, newMax  
    continueUndo: 
    move $t5, $a1 # reset to top of col
    addi $t6, $t6, 1 # go to next col
    addi $t0, $a2, -1 # $t0 = num_cols-1
    bgt $t6, $t0, returnUndo # if all the columns have been searched, return
    j findTopLoop
    
    returnUndo:
    beq $t7, 0, error_undo2 # if no piece was found, return error
    
    # call set_slot
    # $a0 has board
    # $a1 has num_rows
    # $a2 has num_cols
    move $a3, $s1 # row
    sw $s2, 0($sp) # col
    li $t0, 46
    sw $t0, 4($sp) # c
    li $t0, 0
    sw $t0, 8($sp) # turn_num
    jal set_slot  
    
    move $v0, $s0
    move $v1, $t7
    lw $s0, 12($sp)
    lw $s1, 16($sp)
    lw $s2, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra
    
##############################
##       check_winner       ##
##############################
error_win:
    lw $ra, 8($sp)
    lw $s0, 12($sp)
    lw $s1, 16($sp)
    addi $sp, $sp, 16
    li $v0, 46
    jr $ra

check_winner:
    addi $sp, $sp, -16
    sw $ra, 8($sp)  
    sw $s0, 12($sp)
    sw $s1, 16($sp)
    
    ############################################ 
    ## get_slot uses $t0,$t1,$t2,$t3,$t4 ONLY ##
    ############################################
    # get_slot args: board, num_rows, num_cols, row, col @ 0($sp) 
    # get_slot returns c and turn_num
    
    li $t5, 0 # i
    li $t6, -1 # j
    li $t7, 46 # char
    checkForWinLoop:
    	# $a0 already has board
    	# $a1 alreadu has num_rows
    	# $a2 already has num_cols
    	move $a3, $t5 # row
    	addi $t6, $t6, 1
    	addi $t0, $a2, -1
    	bgt $t6, $t0, incrementI_checkWin # if j > num_cols-1, go to next row
    	sw $t6, 0($sp) # col
    	jal get_slot
    	
    	beq $v0, 82, search
    	beq $v0, 89, search
    j checkForWinLoop
    	
    incrementI_checkWin:
    addi $t5, $t5, 1 # increment i
    addi $t0, $a1, -1
    bgt $t5, $t0, error_win # if all slots have been checked, no winner
    li $t6, -1 # reset j
    j checkForWinLoop
    
    search:
    move $t7, $v0 # save 'R' or 'Y' in $t7
    move $s0, $a3 # save row in $s0
    move $s1, $t6 # save col in $s1
    
    searchAbove:
    move $a3, $s0
    
    addi $t0, $a1, -3
    bge $a3, $t0, searchBelow # if row >= num_rows-3, no space for win above
    addi $a3, $a3, 1 # check slot above
    jal get_slot
    bne $v0, $t7, searchBelow # if color doesnt match, check below
    addi $a3, $a3, 1
    jal get_slot
    bne $v0, $t7, searchBelow
    addi $a3, $a3, 1
    jal get_slot
    bne $v0, $t7, searchBelow
    j returnWin # at this point, there's a veritcal row of 4
    
    searchBelow:
    move $a3, $s0
    
    ble $a3, 2, searchLeft # if row <= 2, no space for win below
    addi $a3, $a3, -1 # check slot below
    jal get_slot
    bne $v0, $t7, searchLeft
    addi $a3, $a3, -1
    jal get_slot 
    bne $v0, $t7, searchLeft
    addi $a3, $a3, -1
    jal get_slot
    bne $v0, $t7, searchLeft
    j returnWin
    
    searchLeft:
    move $a3, $s0
    move $t6, $s1
    
    ble $t6, 2, searchRight # if col <= 2, no space for win to left
    addi $t0, $t6, -1
    sw $t0, 0($sp)
    jal get_slot
    bne $v0, $t7, searchRight
    addi $t0, $t6, -1
    sw $t0, 0($sp)
    jal get_slot
    bne $v0, $t7, searchRight
    addi $t0, $t6, -1
    sw $t0, 0($sp)
    jal get_slot
    bne $v0, $t7, searchRight
    j returnWin
    
    searchRight:
    move $a3, $s0
    move $t6, $s1
    
    addi $t0, $a2, -3
    bge $t6, $t0, checkNextSlot # if col >= num_cols-3, no space for win to right
    addi $t0, $t6, 1
    sw $t0, 0($sp)
    jal get_slot
    bne $v0, $t7, checkNextSlot
    addi $t0, $t6, 1
    sw $t0, 0($sp)
    jal get_slot
    bne $v0, $t7, checkNextSlot
    addi $t0, $t6, 1
    sw $t0, 0($sp)
    jal get_slot
    bne $v0, $t7, checkNextSlot
    j returnWin
    
checkNextSlot:
    move $a3, $s0
    move $t6, $s1
    j checkForWinLoop
    
returnWin:
    lw $ra, 8($sp)
    lw $s0, 12($sp)
    lw $s1, 16($sp)
    addi $sp, $sp, 16
    move $v0, $t7
    jr $ra

#####################################
##       check_diagonal_winner     ##
#####################################
	
error_winDiag:
    lw $ra, 8($sp)
    lw $s0, 12($sp)
    lw $s1, 16($sp)
    addi $sp, $sp, 8
    li $v0, 46
    jr $ra

check_diagonal_winner:
    addi $sp, $sp, -16
    sw $ra, 8($sp)  
    sw $s0, 12($sp)
    sw $s1, 16($sp)
    
    ############################################ 
    ## get_slot uses $t0,$t1,$t2,$t3,$t4 ONLY ##
    ############################################
    # get_slot args: board, num_rows, num_cols, row, col @ 0($sp) 
    # get_slot returns c and turn_num
    
    li $t5, 0 # i
    li $t6, -1 # j
    li $t7, 46 # char
    checkDiagLoop:
    	# $a0 already has board
    	# $a1 alreadu has num_rows
    	# $a2 already has num_cols
    	move $a3, $t5 # row
    	addi $t6, $t6, 1
    	addi $t0, $a2, -1
    	bgt $t6, $t0, incrementI_checkDiag # if j > num_cols-1, go to next row
    	sw $t6, 0($sp) # col
    	jal get_slot
    	
    	beq $v0, 82, searchDiag
    	beq $v0, 89, searchDiag
    j checkDiagLoop
    
    incrementI_checkDiag:
    addi $t5, $t5, 1 # increment i
    addi $t0, $a1, -1
    bgt $t5, $t0, error_winDiag # if all slots have been checked, no winner
    li $t6, -1 # reset j
    j checkDiagLoop
    
    searchDiag:
    move $t7, $v0 # save 'R' or 'Y' in $t7
    move $s0, $a3 # save row in $s0
    move $s1, $t6 # save col in $s1
    
    searchUpperMinor:
    move $a3, $s0
    move $t6, $s1
    
    addi $t0, $a1, -3
    bge $a3, $t0, searchLowerMinor
    addi $t0, $a2, -3
    bge $t6, $t0, searchLowerMinor
     
    addi $a3, $a3, 1 # increment i
    addi $t6, $t6, 1 # increment j
    sw $t6, 0($sp)
    jal get_slot
    bne $v0, $t7, searchLowerMinor
    addi $a3, $a3, 1
    addi $t6, $t6, 1
    sw $t6, 0($sp)
    jal get_slot
    bne $v0, $t7, searchLowerMinor
    addi $a3, $a3, 1
    addi $t6, $t6, 1
    sw $t6, 0($sp)
    jal get_slot
    bne $v0, $t7, searchLowerMinor
    j returnWinDiag
    
    searchLowerMinor:
    move $a3, $s0
    move $t6, $s1
    
    ble $a3, 2, searchUpperMajor
    ble $t6, 2, searchUpperMajor
    
    addi $a3, $a3, -1 # decrement i
    addi $t6, $t6, -1 # decrement j
    sw $t6, 0($sp)
    jal get_slot
    bne $v0, $t7, searchUpperMajor
    addi $a3, $a3, -1 # decrement i
    addi $t6, $t6, -1 # decrement j
    sw $t6, 0($sp)
    jal get_slot
    bne $v0, $t7, searchUpperMajor
    addi $a3, $a3, -1 # decrement i
    addi $t6, $t6, -1 # decrement j
    sw $t6, 0($sp)
    jal get_slot
    bne $v0, $t7, searchUpperMajor
    j returnWinDiag
    
    searchUpperMajor:
    move $a3, $s0
    move $t6, $s1
    
    ble $t6, 2, searchLowerMajor # col must be > 2
    addi $t0, $a1, -3
    bge $a3, $t0, searchLowerMajor # row must be < num_rows-3
    
    addi $a3, $a3, 1 # increment i
    addi $t6, $t6, -1 # decrement j
    sw $t0, 0($sp)
    jal get_slot
    bne $v0, $t7, searchLowerMajor
    addi $a3, $a3, 1 # increment i
    addi $t6, $t6, -1 # decrement j
    sw $t6, 0($sp)
    jal get_slot
    bne $v0, $t7, searchLowerMajor
    addi $a3, $a3, 1 # increment i
    addi $t6, $t6, -1 # decrement j
    sw $t6, 0($sp)
    jal get_slot
    bne $v0, $t7, searchLowerMajor
    j returnWinDiag
    
    searchLowerMajor:
    move $a3, $s0
    move $t6, $s1
    
    ble $a3, 2, checkNext # row must be > 2
    addi $t0, $a2, -3
    bge $t6, $t0, checkNext # col must be < num_cols-3
    
    addi $a3, $a3, -1 # decrement i
    addi $t6, $t6, 1 # increment j
    sw $t6, 0($sp) 
    jal get_slot
    bne $v0, $t7, checkNext
    addi $a3, $a3, -1 # decrement i
    addi $t6, $t6, 1 # increment j
    sw $t6, 0($sp) 
    jal get_slot
    bne $v0, $t7, checkNext
    addi $a3, $a3, -1 # decrement i
    addi $t6, $t6, 1 # increment j
    sw $t6, 0($sp) 
    jal get_slot
    bne $v0, $t7, checkNext
    j returnWinDiag
    
checkNext:
    move $a3, $s0
    move $t6, $s1   
    j checkDiagLoop
    
returnWinDiag:
    lw $ra, 8($sp)
    lw $s0, 12($sp)
    lw $s1, 16($sp)
    addi $sp, $sp, 16
    move $v0, $t7
    jr $ra
