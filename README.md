# UART_PROJECT
## INTRODUCTION

![INTRODUCTION](docs/img1.jpg)

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
