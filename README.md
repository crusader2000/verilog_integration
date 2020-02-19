# Verilog Integration with FPGA using Xillibus

Use mkHardware.v as the top module of your code and replace Cpu.v with your processor/top_module code. Make sure your top_module.v has ready/valid handshake protocol properly established. To test your integration, a testbench is also provided. 

## Ready/Valid handshake
Go through the ready/valid handshake pdf in the repo to understand its working.

## Given code overview
Cpu.v implements a simple three state fsm where it first <strong>accumulates</strong> six 32 bit number, then it does some basic <strong>computation</strong> (adding 10 to each input) and in the third state it <strong>flushes</strong> all the six output values. This is similar to a processor design where all the instrutions will be first accumulated then computations will be done and in the last state data memory and regfile will be read.
