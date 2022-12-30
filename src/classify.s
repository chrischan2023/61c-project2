.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    
    #Error Check
    addi t0, x0, 5
    bne a0, t0, command_error

    #Prologue
    ebreak
    addi sp, sp, -56
    sw ra, 52(sp)
    lw t0, 16(a1)
    sw t0, 48(sp)
    sw s11, 44(sp)
    sw s10, 40(sp)
    sw s9, 36(sp)
    sw s8, 32(sp)
    sw s7, 28(sp)
    sw s6, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)
    
    add s0, a0, x0
    add s1, a1, x0
    add s2, a2, x0
    
   
	# Read pretrained m0
    #pointer for file name
    lw s3, 4(s1)
    #poniters for two integers
    addi a0, x0, 4
    jal malloc
    beq a0, x0, malloc_error
    add s4, a0, x0 #s4 points to #rows of m0
    addi a0, x0, 4
    jal malloc
    beq a0, x0, malloc_error
    add s5, a0, x0 #s5 points to #columns of m0
    add a0, s3, x0
    add a1, s4, x0
    add a2, s5, x0
    jal read_matrix
    add s3, a0, x0 #s3 to be the pointer of m0

	# Read pretrained m1
    lw s6, 8(s1)
    #pointers for two integers
    addi a0, x0, 4
    jal malloc
    beq a0, x0, malloc_error
    add s7, a0, x0 #s7 points to #rows of m1
    addi a0, x0, 4
    jal malloc
    beq a0, x0, malloc_error
    add s8, a0, x0 #s8 points to #columns of m1
    add a0, s6, x0
    add a1, s7, x0
    add a2, s8, x0
    jal read_matrix
    add s6, a0, x0 #s6 to be the pointer of m1

	# Read input matrix
    lw s9, 12(s1)
    #poniters for two integers
    addi a0, x0, 4
    jal malloc
    beq a0, x0, malloc_error
    add s10, a0, x0 #s10 points to #rows of input
    addi a0, x0, 4
    jal malloc
    beq a0, x0, malloc_error
    add s11, a0, x0 #s11 points to #columns of input
    add a0, s9, x0
    add a1, s10, x0
    add a2, s11, x0
    jal read_matrix
    add s9, a0, x0 #s5 to be the pointer of the input matrix

	# Compute h = matmul(m0, input)
    lw t1, 0(s4)
    lw t2, 0(s11)
    mul t0, t1, t2
    add s1, t0, x0 # s1 = #elements in h
    addi t1, x0, 4
    mul t0, t0, t1
    add a0, t0, x0
    jal malloc
    beq a0, x0, malloc_error
    add s0, a0, x0 #s0 points to h
    add a0, s3, x0
    lw a1, 0(s4)
    lw a2, 0(s5)
    add a3, s9, x0
    lw a4, 0(s10)
    lw a5, 0(s11)
    add a6, s0, x0
    jal matmul

	# Compute h = relu(h)
    add a0, s0, x0
    add a1, s1, x0
    jal relu

	# Compute o = matmul(m1, h)
    lw t1, 0(s7)
    lw t2, 0(s11)
    mul t0, t1, t2
    addi t1, x0, 4
    mul t0, t1, t0
    add a0, t0, x0
    jal malloc
    beq a0, x0, malloc_error
    add s1, a0, x0 #s1 points to o
    add a0, s6, x0
    lw a1, 0(s7)
    lw a2, 0(s8)
    add a3, s0, x0
    lw t0, 0(s4)
    add a4, t0, x0
    lw t0, 0(s11)
    add a5, t0, x0
    add a6, s1, x0
    jal matmul
    

	# Write output matrix o
    lw t0, 48(sp)
    add a0, t0, x0
    add a1, s1, x0
    lw t0, 0(s7)
    add a2, t0, x0
    lw t0, 0(s11)
    add a3, t0, x0
    jal write_matrix
    
    add a0, s0, x0
    jal free

	# Compute and return argmax(o)
    add a0, s1, x0
    lw t0, 0(s7)
    lw t1, 0(s11)
    mul a1, t0, t1
    jal argmax
    add s0, a0, x0 #save argmax(o)
    
	# If enabled, print argmax(o) and newline
    ebreak
    beq x0, s2, print
    
return:
    add a0, s1, x0
    jal free
    add a0, s3, x0
    jal free
    add a0, s4, x0
    jal free
    add a0, s5, x0
    jal free
    add a0, s6, x0
    jal free
    add a0, s7, x0
    jal free
    add a0, s8, x0
    jal free
    add a0, s9, x0
    jal free
    add a0, s10, x0
    jal free
    add a0, s11, x0
    jal free
    add a0, s0, x0 #restore result
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw s11, 44(sp)
    lw ra, 52(sp)
    addi sp, sp, 56
    ebreak
	ret

print:
    ebreak
    add a0, s0, x0
    jal print_int
    li a0 '\n'
    jal print_char
    j return 
    

command_error:
    li a0 31
    j exit
    
malloc_error:
    li a0 26
    j exit