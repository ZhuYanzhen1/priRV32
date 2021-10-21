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
        $dumpfile("priRV32_tb.vcd");        //生成的vcd文件名称
        $dumpvars(0, priRV32_tb);    //tb模块名称
    end 
endmodule
