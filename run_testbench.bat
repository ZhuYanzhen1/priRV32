@echo off
set input1=%1%
set input2=%2%
iverilog -o "priRV32_tb.vvp" .\tb\%input1% .\core\input2
vvp -n .\priRV32_tb.vvp
gtkwave.exe .\priRV32_tb.vcd
