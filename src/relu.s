.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
	# Prologue
    li t0, 1       #t0=1
    blt a1, t0 exception #length < 1
    addi sp, sp, -4
    sw s0 0(sp)
    addi s0, a0, 0 #s0 is the address of the first integer
    li t0, 0       # i = 0
    j loop_start 

loop_start:
    beq t0, a1, loop_end
    lw t1 0(s0)     # t1 = a[i]
    bge x0, t1 loop_continue #t1 is less than 0
    sw t1 0(s0)
    addi s0, s0, 4
    addi, t0, t0, 1
    j loop_start
    
loop_continue:
    sw x0, 0(s0)
    addi s0, s0, 4
    addi t0, t0, 1
    j loop_start

loop_end:
	# Epilogue
    lw s0, 0(sp)
    addi sp, sp, 4
	ret

exception:
    li a0 36
    j exit
    
