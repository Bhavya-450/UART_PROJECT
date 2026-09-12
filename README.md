# UART_PROJECT
## INTRODUCTION

![INTRODUCTION](doc/img1.jpg)

Verilog implementation of a UART transmitter and receiver with independent testbenches for simulation

UART stands for Universal Asynchronous Receiver/Transmitter. It’s not a communication protocol like SPI and I2C, but a physical circuit in a microcontroller, or a stand-alone IC.

A UART’s main purpose is to transmit and receive serial data. In UART communication, two UARTs communicate directly with each other. The transmitting UART converts parallel data from a controlling device like a CPU into serial form, and transmits it in serial to the receiving UART, which then converts the serial data back into parallel data for the receiving device.

Only two wires are needed to transmit data between two UARTs. Data flows from the transmitting UART's Tx pin to the receiving UART's Rx pin.

## BAUDRATE GENREATOR UNIT :

**Baud Rate:** is the rate at which the number of signal elements or changes to the signal occurs per second when it passes through a transmission medium. The higher the baud rate, the faster the data is sent/received.

This unit supports four possible baud rates:

- Baud rate of 2400 bps

- Baud rate of 4800 bps
  
- Baud rate of 9600 bps
  
- Baud rate of 19200 bps

## UART PROTOCOL DATA FLOW :

![UART PROTOCOL DATA FLOW](doc/img2.jpg)

These special bits are: Start bit, Priority bit, Stop bit.

**START BIT:** When a word is given to UART for asynchronous transmission, a bit called “START BIT” is added to the beginning of each word that is to be transmitted. 
The start bit is used to alert the receiver that a word of data is about to sent, and to force the clock in the receiver into synchronization with the clock in the transmitter.

**DATA BIT OR DATA FRAME:** After the start bit, the individual bits of data are sent, with the least significant Bit(LSB) being sent first. Each bit in the transmission is transmitted for exactly the same amount of time as all of the other bits. And the receiver looks at the wire at approximately halfway through the period assigned to each bit to determine if the bit is 1 or 0. For example, if it takes 2 second to send each bit, the receiver will track the signal after 1 second has passed.

**PARITY BIT:** remove the problem of loss of some bits during the transmission of a signal, error correction mechanism must be added to the transmitted data. Parity bit error checking mechanism is one of the simplest methods to detect any error in received data. In asynchronous serial communication, a parity bit is added at the end of data bits to check the number of 1’s.

**STOP BIT:** At the end of each data packet, stop bit i.e. 1 is added to indicate the end of one data packet. At the receiver end, this stop bit is used to stop the reception of Data.





















