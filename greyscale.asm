.data
    buffer: .space 4  # Allocate space for a string buffer (adjust size as needed)
    file:    .asciiz "C:/Users/tshik/OneDrive - University of Cape Town/Documents/UCT/4th Year/CSC2002S/ASM/sample_images/house_64_in_ascii_crlf.ppm"
    newfile:    .asciiz "C:/Users/tshik/OneDrive - University of Cape Town/Documents/UCT/4th Year/CSC2002S/ASM/sample_images/greyscale_crlf.ppm"
    filesize:    .space  61460
    buffer2:	.space  61460
    

.text
.globl  main

main:
	la $s6, buffer
	li $s0 , 12288 # set a counter that will cont the number of lines that have pixel values
	li $s2, 0x30  # 48 the 0 
	move $s3, $zero ## contains the int val
	move $s5, $zero ## contains the int val
	li $s4, 10
	li $t5, 0
	li $t6, 2 # get the three values to ave
	li $t7 , 0 # store avrage of second image
	li $t8, 0

	# open to a file
	li $v0, 13 # open_file
	la $a0, file # get file
	li $a1, 0   # read file(0)
	syscall
	move $s1, $v0 # move the file descriptor $s1 = file 
	
	
	li $v0, 14
	move $a0, $s1
	la $a1, filesize # use a1 to get the string that will be changed 
	la $a2, 61460
	syscall 
	
	addi $t1, $a1, 23
	la $a3, buffer2 #move address to t1 used later
	move $s7, $s6
	addi $t3, $a1, 1
computeheader: 
	lb $t2, ($a1)
	jal change_header
	sb $t2, ($a3) 
	addi $a3, $a3, 1
	addi $a1, $a1, 1
	beq $t1, $a1, greyscale # skip the header
	j computeheader

change_header:
	beq $a1, $t3, change_header_now 
	jr $ra
change_header_now:
	li $t2, 50
	jr $ra 
    # run brightness program
greyscale: 
	beq $s0, $t5, Done # when we retch the end of the file 
	lb $t0, ($a1) # load the indivitual value
	beq $t0, 0x0d, incerment
    
	addi $a1, $a1, 1
    
	# turn string to int 
	sub $t1, $t0, $s2
	mul $s3, $s3, $s4
	add $s3, $s3, $t1 # final valuue is in s3
	j greyscale


incerment:
	addi $a1 , $a1, 2 # move to the next line with pixel data
	addi $t5 , $t5, 1 # add counter
	jal set
	
	convert_loop:
    		beqz $s3, end  # If the integer is zero, terminate the loop

    		# Divide the integer by 10 and get the remainder (digit)
    		divu $t4, $s3, $s4
    		mfhi $s5            # $t5 = remainder (ASCII digit)

    		# Convert the remainder to an ASCII character ('0' + digit)
    		addi $s5, $s5, 48   # Convert digit to ASCII

    		# Store the ASCII character in the buffer
    		sb $s5, ($s6)
    		addi $s6, $s6, 1    # Move to the next character in the buffer

    		# Update the integer (divide it by 10)
    		move $s3, $t4

    		j convert_loop       # Repeat the loop
		end:
			addi $s6, $s6,-1
			move $s3, $zero

		loop:
			
    			lb   $s1, ($s6)
    			sb   $s1, ($a3)
    			addi $a3, $a3, 1
    			beq  $s7, $s6, pad
    			addi $s6, $s6, -1
    			j    loop
    			
pad:
	li $s1, 0x0d
	sb $s1, ($a3)
	addi $a3, $a3,1 
	li $s1, 0x0a
	sb $s1, ($a3)
	addi $a3, $a3, 1
	j greyscale
set:
	add $t7, $t7, $s3
	bge $t8, $t6, setnow
	addi $t8, $t8, 1 
	move $s3, $zero
	j greyscale 
setnow:
	li $t9, 3
	mtc1.d $t7, $f1
	cvt.s.w $f1,$f1
	
	mtc1.d $t9, $f2
	cvt.s.w $f2,$f2
	
	div.s $f4, $f1, $f2
	floor.w.s $f6, $f4
	
	mfc1 $s3, $f6

	
	move $t7, $zero
	move $t8, $zero
	jr $ra
    
Done:
	
	# close the file
	li $v0, 16 # close file
	move $a0, $s0 # file descriptor to close
	syscall
	
	# open to a file
	li $v0, 13 # open_file
	la $a0, newfile # get file
	li $a1, 1   # wirte file(1)
	syscall
	move $s1, $v0 # move the file descriptor $s1 = file 
	
	li $v0, 15
	move $a0, $s1
	la $a1, buffer2
	la $a2, 61460
	syscall 
	
	li $v0, 16
	move $a0, $s1
	syscall 
	
	
exit:
	li $v0, 10
	syscall