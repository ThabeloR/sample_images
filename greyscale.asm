#Program that greyscales an image
#by Thabelo Tshikalange

.data
    buffer: .space 4  # Allocate space for a string buffer (adjust size as needed)
    file:    .asciiz "C:/Users/tshik/OneDrive - University of Cape Town/Documents/UCT/4th Year/CSC2002S/ASM/sample_images/house_64_in_ascii_crlf.ppm"
    newfile:    .asciiz "C:/Users/tshik/OneDrive - University of Cape Town/Documents/UCT/4th Year/CSC2002S/ASM/sample_images/greyscale_crlf.ppm"
    filesize:    .space  61460 # The space given to the file that will be read 
    buffer2:	.space  61460 # The space given for the buffer that will have the new file data to be written
    

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
	li $t6, 2 # store 2 in t6 this will be used to see if all the RGB pixles are added before divition
	li $t7 ,0 # store the sum of RGB  pixels
	li $t8, 0 # store 0 in t8

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
	addi $t3, $a1, 1 # add 1 to address and store it in t3 this will be usd to change the 3 to a 2 in the header
computeheader: 
	lb $t2, ($a1)
	jal change_header 
	sb $t2, ($a3) 
	addi $a3, $a3, 1
	addi $a1, $a1, 1
	beq $t1, $a1, greyscale # when the header is stored then jump to the brightness computation to change the pixel color
	j computeheader
#find the second byte in header
change_header:
	beq $a1, $t3, change_header_now #if not move on
	jr $ra # go back to computeheader
#if it finds the 2nd byte
change_header_now:
	li $t2, 50 # change it to a 2
	jr $ra # go back to computeheader
    # run greyscale program
    
greyscale: 
	beq $s0, $t5, Done # when we retch the end of the file 
	lb $t0, ($a1) # load the indivitual value
	beq $t0, 0x0d, incerment # when we reach the and of the value and find  the character CR jump to incerment
    
	addi $a1, $a1, 1 # move to next byte value to read
    
	# turn string to int 
	sub $t1, $t0, $s2 # get the int value by subtacting it form the 48 that was given
	mul $s3, $s3, $s4 # multiply by 10 to move to the next 10nth place to store the next value 
	add $s3, $s3, $t1 # final value is in s3
	j greyscale


incerment:
	addi $a1 , $a1, 2 # move to the next line with pixel data
	addi $t5 , $t5, 1 # add counter
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
	j greyscale
# This method will avrage the RGB pixels giving the grey scale pixel	
set:
	add $t7, $t7, $s3 # add the pixel value to t7
	bge $t8, $t6, setnow #  if the three pixels are not set set do not get average
	addi $t8, $t8, 1 # increment
	move $s3, $zero # reset the s3 int to 0
	j greyscale # go back to greyscale method
	
# if the three RGB values are added the average	
setnow:
	li $t9, 3 # load the division value in t9
	mtc1.d $t7, $f1 # move the sum of RGB pixle values to a floating point register f1 
	cvt.s.w $f1,$f1 # convert the value to a float
	
	mtc1.d $t9, $f2 # move the averaging value to a floating point register f2 with double 
	cvt.s.w $f2,$f2 # convert the value to a double
	
	div.s $f4, $f1, $f2 # divide the values and store in f4
	floor.w.s $f6, $f4 # roun down value 
	
	mfc1 $s3, $f6 # change back value to int and store in s3

	
	move $t7, $zero # rest t7
	move $t8, $zero #rest t8
	jr $ra # go back to breaking point
    
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
