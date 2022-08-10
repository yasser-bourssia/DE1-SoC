# DE1-SoC
This repository contains different codes for different DE1-SoC components; mainly sensors and their respective systems created using Quartus' Platform Designer(in VHDL).



Tools used in the making of the different codes/systems:
- ModelSIM for VHDL Simulation.
- Intel FPGA Monitor Program to upload codes into the board.
- Quartus and its Platform Designer for VHDL/System creation respectively.
- VS Code for C Code writing.

The first is a code to configure, intiliaze and recover data from the Accelerometer ADXL345 already contained within the DE1-SoC Board. As the sensor is already internally wired within the board, no system is needed to be uploaded to the board. Use Intel FPGA Monitor Program to upload the code to the board. 

Second is a VHDL code for the ADC(AD7928) contained within the board, as the ADC is wired through an SPI Bus, I wrote a VHDL code to communicate with the said ADC to configure, initiliaze and recover the data from the ADC. Use Quartus to upload the code to the board.

Third is a code for an external temperature sensor, the MCP(9808), for this one, a whole system was created, there will be communication between the FPGA and the NIOS Processor contained within the board, using the Avalon Intel bus, to exchange the different signlas/data.

As the GPIO Header is wired on the FPGA side, we had to communicate the signals inbetween the board and the sensor, from the FPGA to the NIOS and viceversa so it can process and use the said signals. 


Use Intel FPGA Monitor Program to upload both the software code and the hardware system to the board.
