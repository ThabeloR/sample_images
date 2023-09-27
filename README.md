# Running the Brightness Adjustment Program
## Prerequisites
Before running the program, make sure you have the following:

## MARS Simulator: 
You will need a MIPS assembly simulator like MARS to execute the assembly code.

## Input Image: 
You should have an input PPM image file that you want to adjust the brightness of. Update the file variable in the assembly code with the correct file path to your input image insure that you use a image flie that has a CRLF end character since the code runs for windows it will give an error if it is in correct.

## Step-by-Step Instructions
Open MARS Simulator: Launch the MARS simulator on your computer.

Load the Assembly Code: In the MARS simulator, click on the "File" menu and select "Open." Locate and open the assembly code file containing your provided code.

Run the Program: To execute the code, click on the "Tools" menu and select "Assembler and Simulator." This will assemble the code and load it into the simulator.

Execute the Program: Click on the "Run" button in the MARS simulator. The program will execute, and you will see output in the simulator's console.

View Results: The program will display the average pixel value of the original image and the modified image on the console.

Save the Modified Image: If the program runs successfully, it will save the modified image to a new file specified by the newfile variable in the assembly code. You can then view this modified image using an image viewer. The dirctory of the saved file must specified. You can use the already provided bright_crlf.ppm for the increase_brightness.asm program and the greyscale_crlf.ppm for the greyscale.asm program insure that the dirctory to the file is added correctly.

Exit the Simulator: After you have finished running and testing the program, you can exit the MARS simulator.

### This is how you run either of the two programs 