# Seven Segment Display Hexadecimal Counter

This verilog code describes a hexadecimal counter used to count from (0-F) in hexadecimal numbering system.
It is a standalone module which can be used to make other seven segment related projects. Such projects may include alarm clock, stopwatch, digital watch etc.

Software Used :: 
Vivado Design Suit

Hardware Used :: 
I have implemented this design on Basys-3 Artix-7 FPGA trainer board:
![image](https://user-images.githubusercontent.com/67659898/205711680-71310f0b-b884-4847-929e-b6ed756c10c8.png)

You may implement this code on any FPGA of your choice, I will be explaining its implementation via the above mentioned board.


Steps I followed are as follows :-
1) The very first step is to create an error free verilog code which would work as intended. Vivado tool has built-in text editor for verilog code editing, error detection and pre & post sythesis simulation.
![Code-Editor](https://user-images.githubusercontent.com/67659898/205713246-6641c5d1-5110-4d8e-a579-c189da52fc7f.png)

2) Now we must check the behavioural simulation of our code to ensure that our RTL code is logically correct. This is achieved by applying simulas to the module's input ports and verifying the corresponding output at its output ports.
![Behavioural-Simulation](https://user-images.githubusercontent.com/67659898/205714433-5251be8e-af1c-4ad0-a418-467bbc064e9e.png)

3) After successfull behavioural simulation, we will elaborate our design via running the RTL analysis tool of Vivado Design Suit. Sucessfull analysis may result in a schematic implementation as shown below.
![RTL-Analysis-Schematic](https://user-images.githubusercontent.com/67659898/205715182-da6bb1d6-8175-4a22-bad4-82f8c82bbb7f.png)

4) Post-Synthesis simulation is the next obvious step we need to implement. We will use the built-in post synthesis tool of Vivado design suit. Just like the behavioural simulation, we will applying simulas to the module's input ports and verifying the corresponding output at its output ports.
![Post-Synthesis-Functional-Simulation](https://user-images.githubusercontent.com/67659898/205716675-949f89ab-2c7e-4234-a613-eb2b5024dd7d.png)

5) Successfull post-synthesis simulation may result in a schematic implementation as shown below.
![Post-Synthesis-Schematic](https://user-images.githubusercontent.com/67659898/205717059-f241f259-6838-445d-9dee-413c8e35c77e.png)

![FPGA1_5](https://user-images.githubusercontent.com/67659898/205717146-b07723c0-d6d8-4985-bf58-6aad576ef76b.JPG)


