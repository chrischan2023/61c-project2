.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

	# Prologue
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)
    add s0, a0, x0
    add s1, a1, x0
    add s2, a2, x0
    add a1, x0, x0 #read-only
    jal fopen
    addi t0, x0, -1
    beq a0, t0, fopen_error
    add s0, a0, x0 #save the file descriptor
    addi a2, x0, 4
    add a1, s1, x0
    jal fread #read #rows
    addi t0, x0, 4
    bne t0, a0, fread_error
    add a1, s2, x0
    add a0, s0, x0
    addi a2, x0, 4
    jal fread #read #columns
    addi t0, x0, 4
    bne t0, a0, fread_error
    lw t0, 0(s1)
    lw t1, 0(s2)
    mul s3, t0, t1
    slli s3, s3, 2
    add a0, s3, x0
    jal malloc
    beq a0, x0, malloc_error
    add s1, a0, x0 #save the pointer
    add a1, a0, x0 #pointer to the allocated memory
    add a0, s0, x0 #restore file descriptor
    add a2, s3, x0
    jal fread
    bne a0, s3, fread_error
    add a0, s0, x0 #restore file descriptor
    jal fclose
    addi t0, x0, -1
    beq a0, t0, fclose_error
    add a0, s1, x0

	# Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
	ret
    
malloc_error:
    li a0 26
    j exit
    
fopen_error:
    li a0 27
    j exit
    
fclose_error:
    li a0 28
    j exit
    
fread_error:
    li a0 29
    j exit
