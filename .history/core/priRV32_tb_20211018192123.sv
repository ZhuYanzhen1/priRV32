`timescale 1ns/1ns
module priRV32_tb;
reg clk, rst_n;
wire led;
priRV32 rv32(.clk(clk), .rst_n(rst_n), .led(led));
    initial begin
        rst_n           = 1;
        clk             = 0;
        #1000
		$stop;
    end
    always @() begin
        #10 clk = ~clk;
    end
endmodule
