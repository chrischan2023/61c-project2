.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

	# Prologue
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)
    add s1, a1, x0
    add s2, a2, x0
    add s3, a3, x0
    addi a1, x0, 1 #write-only
    jal fopen
    addi t0, x0, -1
    beq t0, a0, fopen_error
    add s0, a0, x0 #save the file descriptor
    addi a0, x0, 4
    jal malloc
    add s4, a0, x0
    addi a0, x0, 4
    jal malloc
    add s5, a0, x0
    sw s2, 0(s4) # #rows
    sw s3, 0(s5) # #columns
    
    #write #row and #column
    addi a2, x0, 1
    addi a3, x0, 4
    add a0, s0, x0 #restore the file descriptor
    add a1, s4, x0
    jal fwrite
    addi t0, x0, 1
    bne t0, a0, fwrite_error
    
    addi a2, x0, 1
    addi a3, x0, 4
    add a0, s0, x0
    add a1, s5, x0
    jal fwrite
    addi t0, x0, 1
    bne t0, a0, fwrite_error
    
    mul a2, s2, s3
    add a0, s0, x0
    add a1, s1, x0
    addi a3, x0, 4
    jal fwrite
    mul t0, s2, s3
    bne t0, a0, fwrite_error
    
    add a0, s0, x0
    jal fclose
    bne a0, x0, fclose_error

	# Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28
	ret
    
 fopen_error:
     li a0 27
     j exit
     
fwrite_error:
    li a0 30
    j exit
    
fclose_error:
    li a0 28
    j exit
