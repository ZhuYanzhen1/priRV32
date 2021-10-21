`timescale 1ns/1ns
module counter_tb; 
reg clk, enable, reset; 
wire [7:0] out; 
priRV32 rv32(.clk(clk), .rst_n(rst_n), .led(led));
    initial begin
        enable = 1;
    end
    initial begin
        clk             = 0;
        forever #10 clk = ~clk;
    end
    initial begin
        reset = 1;
        #15 reset = 0;
        #1000 $finish;
    end
    initial
    begin            
        $dumpfile("priRV32_tb.vcd");
        $dumpvars(0, priRV32_tb);
    end 
endmodule
