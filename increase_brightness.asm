.data
    data1: .asciiz "Average pixel value of the original image:\n"
    data2: .asciiz "Average pixel value of new image:\n"
    file:    .asciiz "C:/Users/tshik/OneDrive - University of Cape Town/Documents/UCT/4th Year/CSC2002S/ASM/sample_images/test.ppm"
    filesize:    .space  61460
    num: .space 10

.text
.globl  main

main:
	li $s1 , 0 # set a counter that will cont the number of lines that have pixel values
    # print out the program output
    li $v0, 4
    la $a0, data1
    syscall
    move $t1, $a0

    # read to a file
    li $v0, 13 # open_file
    la $a0, file # get file
    li $a1, 0   # wirte file(1)
    syscall
    move $s0, $v0 # move the file descriptor $a0 = file 
    
    # read file
    li $v0, 14
    move $a0, $s0
    la $a1, filesize
    la $a2, 61460   
    syscall  
    
	addi $a1, $a1, 23 # skip the header
	li $s2, 0x30 
	move $s3, $zero ## contains the int val
	move $s5, $zero ## contains the int val
	li $s4, 10

    # run brightness program
brightness:   
    lb $t0, ($a1) # load the indivitual value
    beq $t0, 0x0d, incerment
    
    addi $a1, $a1, 1
    
    # turn string to int 
    sub $t1, $t0, $s2
    mul $s3, $s3, $s4
    add $s3, $s3, $t1 
    j brightness


incerment:
	
	addi $a1 , $a1, 2 # move to the next line with pixel data
	addi $s1 , $s1, 1 # add counter
	addi $s3, $s3, 10
	# check 255
	jal set
	#write to 
	add $s5, $s5, $s3
	move $t1, $s3
	div $s5, $s1
	addi $t1, $t1, 1
	move $s3, $zero 
	j brightness
set:
	bge $s3, 225, setnow
	jr $ra 
setnow:
	li $s3, 255
	jr	$ra
    
Done:
	
    # print whats in the file
    li $v0, 4
    la $a0, data1
    syscall

     # close the file
     li $v0, 16 # close file
     move $a0, $s0 # file descriptor to close
     syscall


exit:
    li $v0, 10
    syscall
