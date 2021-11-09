@echo off
set input1=%1%
set input2=%2%
iverilog -o "priRV32_tb.vvp" .\tb\%input1%_tb.v .\core\%input1%.v
vvp -n .\priRV32_tb.vvp
gtkwave.exe .\priRV32_tb.vcd
