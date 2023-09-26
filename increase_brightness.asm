# program that brigtheness image pixels
# by Thabelo Tshikalange

.data
    data1: .asciiz "Average pixel value of the original image:\n"
    data2: .asciiz "\nAverage pixel value of new image:\n"
    buffer: .space 4  # Allocate space for a string buffer (adjust size as needed)
    file:    .asciiz "C:/Users/tshik/OneDrive - University of Cape Town/Documents/UCT/4th Year/CSC2002S/ASM/sample_images/tree_64_in_ascii_crlf.ppm"
    newfile:    .asciiz "C:/Users/tshik/OneDrive - University of Cape Town/Documents/UCT/4th Year/CSC2002S/ASM/sample_images/bright_crlf.ppm"
    filesize:    .space  61460 # The space given to the file that will be read 
    buffer2:	.space  61460 # The space given for the buffer that will have the new file data to be written
    zero: .double 0.0  # double to use for getting the average 
    

.text
.globl  main

main:
	la $s6, buffer # Store the address of the buffer to be printed to s6
	li $s0 , 12288 # set a counter that will count the number of lines that have pixel values as to show were the program to end
	li $s2, 0x30  # 48 the 0 referance point for string to int convertion stored in s2  
	move $s3, $zero # contains the int val that will be added by 10 stored in s3
	move $s5, $zero # contains the value of the ascii character that will be number needed for storage 
	li $s4, 10 # store 10 in s4
	li $t5, 0 # store 0 in t5
	li $t6, 0 # store the average of the main image
	li $t7 ,0 # store average of second image
	
	
   	# print out the program output 1 that is the data1 string
   	li $v0, 4
   	la $a0, data1
	syscall
 	
	# open to a file
	li $v0, 13 # open_file
	la $a0, file # get file
	li $a1, 0   # read file(0)
	syscall
	move $s1, $v0 # move the file descriptor $s1 = file 
	
	#read the file data 
	li $v0, 14
	move $a0, $s1
	la $a1, filesize # use a1 to get the string that will be changed 
	la $a2, 61460
	syscall 
	
	addi $t1, $a1, 23 # add 23 to the address a1 to t1 which will be the header and use it to find is the header has been stored 
	la $a3, buffer2 # move address to a3 used later
	move $s7, $s6 # cope the address of the buffer that will have the pixel value to s7 this will be used as a referance
	
	#store the header into the provided buffer2
computeheader: 
	lb $t2, ($a1)
	sb $t2, ($a3) 
	addi $a3, $a3, 1
	addi $a1, $a1, 1
	beq $t1, $a1, brightness # when the header is stored then jump to the brightness computation to change the pixel color
	j computeheader


    # run brightness program
brightness: 
	beq $s0, $t5, Done # when we retch the end of the file 
	lb $t0, ($a1) # load the indivitual value
	beq $t0, 0x0d, incerment # when we reach the and of the value and find  the character CR jump to incerment
    
	addi $a1, $a1, 1 # move to next byte value to read
    
	# turn string to int 
	sub $t1, $t0, $s2 # get the int value by subtacting it form the 48 that was given
	mul $s3, $s3, $s4 # multiply by 10 to move to the next 10nth place to store the next value 
	add $s3, $s3, $t1 # final value is in s3
	j brightness


incerment:
	add $t6, $t6, $s3 # add the value of the pixel to t6 
	addi $a1 , $a1, 2 # move to the next line with pixel data
	addi $t5 , $t5, 1 # add counter
	addi $s3, $s3, 10 # add 10 to the pixel value
	# check 255
	jal set
	# This method will convert the int value to its string equivalent  
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
    		
    		#store the value ascii converted value to the buffer
		end:
			addi $s6, $s6,-1 # move one byte back to were the int value is
			move $s3, $zero # set s3 to zero
			
		# this method will reverse the string value that was store in s6 to its correct oriantaion to store in buffer2
		loop:
			
    			lb   $s1, ($s6) # load string value staring from the back
    			sb   $s1, ($a3) # store it to buffer2
    			addi $a3, $a3, 1 # move to next space
    			beq  $s7, $s6, pad # if we get to the start of the space then pad 
    			addi $s6, $s6, -1 # move back to the next space
    			j    loop
    			
# This method adds the CR and LF characters that will be used to move show the end of a pixel value in the file 			
pad:
	li $s1, 0x0d # add the CR character to s1
	sb $s1, ($a3) # store it in buffer2
	addi $a3, $a3,1 #move to next space in buffer
	li $s1, 0x0a # add the LF character to s1
	sb $s1, ($a3) # store it in buffer2
	addi $a3, $a3, 1 #move to next space in buffer 
	j brightness
# see if the value is not geater then 255	
set:
	bge $s3, 225, setnow #  if not then leave as is
	add $t7, $t7, $s3 # add the pixel value plus 10 to t7
	jr $ra # go back to the brightness mothod 
setnow:
	li $s3, 255 # if it is then set it to 255
	add $t7, $t7, $s3 # add the pixel value to t7
	jr $ra # go back to the brightness mothod 
    
Done:
	
	# close the file
	li $v0, 16 # close file
	move $a0, $s0 # file descriptor to close
	syscall
	
	
	ldc1 $f6, zero # load the 0.0 double to f6
	li $t8, 3133440 # load the value used to find the average value in t8
	
	mtc1.d $t8, $f2 # move the averaging value to a floating point register f2 with double  
	cvt.d.w $f2,$f2 # convert the value to a double
	
	mtc1.d $t6, $f0 # move the total sum of the original image pixle values to a floating point register f0 with double   
	cvt.d.w $f0,$f0 # convert the value to a double
	

	div.d $f4, $f0, $f2 # divide the values and store in f4

	li $v0, 3 # call the printing float service
	add.d $f12, $f4, $f6 # move the value to f12
	syscall
	
	# print out the program output data2
   	li $v0, 4
   	la $a0, data2
	syscall
	
	mtc1.d $t7, $f0  # move the total sum of the new image pixle values to a floating point register f0 with double  
	cvt.d.w $f0,$f0 # convert the value to a double

	div.d $f4, $f0, $f2 # divide the values and store in f4

	li $v0, 3 # call the printing float service
	add.d $f12, $f4, $f6 # move the value to f12
	syscall
	
	# open to a file
	li $v0, 13 # open_file
	la $a0, newfile # get file
	li $a1, 1   # wirte file(1)
	syscall
	move $s1, $v0 # move the file descriptor $s1 = file 
	
	#write to the file 
	li $v0, 15 
	move $a0, $s1
	la $a1, buffer2 # buffer that has the values to write 
	la $a2, 61460 # size of buffer
	syscall 
	
	# close the file
	li $v0, 16 # close file
	move $a0, $s0 # file descriptor to close
	syscall 
	
	
exit:
	li $v0, 10 # close program
	syscall
