Folder contains both the Qsys generated system and the Software(found in the software folder) related to the system.

As the GPIO Header is on the FPGA side of the board, the signals sent from the sensor has to be transmitted to the NIOS side so it can be manipulated.

For this, we use the Platform Designer(Qsys) found in Quartus, to create the system that relays the FPGA side with the NIOS (Avalon Bus).

To use this, use Intel FPGA Monitor Program to upload both the system and the codes to the board.
