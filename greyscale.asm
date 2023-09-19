 .data
    data1: .asciiz "Average pixel value of the original image:\n"
    data2: .asciiz "Average pixel value of new image:\n"
    file:    .asciiz "C:/Users/tshik/OneDrive - University of Cape Town/Documents/UCT/4th Year/CSC2002S/ASM/sample_images/house_64_in_ascii_crlf.ppm"
    filesize:    .space  12292

.text
.globl  main

main:
    # read to a file
    li $v0, 13 # open_file
    la $a0, file # get file
    li $a1, 0   # read file(0)
    syscall
    move $s0, $v0 # move the file descriptor $a0 = file 


    # read the file
    li  $v0, 14 # read file 
    move $a0, $s0 # file descriptor
    la $a1, filesize # buffer that holds the string of the whole file
    la $a2, 122922
    syscall

    # run grayscale program
    

    # print whats in the file
    li $v0, 4
    la $a0, filesize
    syscall

     # close the file
     li $v0, 16 # close file
     move $a0, $s0 # file descriptor to close
     syscall


exit:
    li $v0, 10
    syscall
