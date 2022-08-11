This folder contains 4 different files:

- the ADC.vhd is the Top-Level of the IP; note that it contains some code related to the 7-segments display, if you don't need it, you just got to comment it.

- the div.vhd is used to divise the clock frequency, as the DE1-SoC uses a clock of 50MHz by default, and the ADC needs a frequency of less than 20MHz, a frequency divisor is needed.

- ADCVHDL.vhd contans the SPI communication and bit-banging, uses a shift register and an index to decide what and when to send the bits.
- 
- bindechex.vhd is used for the manipulation of the 7-segments display.
