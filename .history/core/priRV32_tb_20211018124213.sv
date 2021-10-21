`timescale 1ns/1ns
module counter_tb; 
reg clk, enable, reset; 
wire [7:0] out; 
counter c1(.out(out), .clk(clk), .enable(enable), .reset(reset));
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
