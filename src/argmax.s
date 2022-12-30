.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
	# Prologue
    addi sp, sp, -8
    sw s1, 4(sp)
    sw s0, 0(sp) 
    li t0, 1       #t0=1
    blt a1, t0 exception #length < 1
    add s0, a0, x0 #s0 is the address of the first integer
    add t1, x0, x0 #t1 to be the largest element
    li t0, 0       ## i = 0
    add s1, x0, x0 #s1 to be the index of the largest element
    j loop_start


loop_start:
    beq t0, a1, loop_end
    lw t2 0(s0)
    blt t1, t2, loop_continue 
    addi s0, s0, 4
    addi t0, t0, 1 
    j loop_start


loop_continue:
    add t1, t2, x0 #t1 now be the currently largest element
    add s1, t0, x0
    addi s0, s0, 4
    addi t0, t0, 1
    j loop_start
    

loop_end:
	# Epilogue
    addi a0, s1, 0
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
	ret
    
exception:
    li a0 36
    j exit
