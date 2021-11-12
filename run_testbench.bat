@echo off
set input1=%1%
iverilog -o ".\priRV32_tb.vvp" .\tb\%input1%_tb.v
vvp -n .\priRV32_tb.vvp
gtkwave.exe .\priRV32_tb.vcd
