@echo off
set input1=%1%
iverilog -I .\tb -o "priRV32_tb.vvp" .\core\%input1%.v
vvp -n .\priRV32_tb.vvp
gtkwave.exe .\priRV32_tb.vcd
