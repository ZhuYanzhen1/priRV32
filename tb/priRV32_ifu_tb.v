`timescale 10ns/10ns
module priRV32_tb;

reg clk, rst_n;
reg [32:0]pc_data_i, pc_addr_i;

priRV32_IFU ifu(.clk_i(clk),
                .rst_n(rst_n),
                .pc_data_i(pc_data_i),
                .pc_addr_i(pc_addr_i)
);
    initial begin
        $dumpfile("priRV32_tb.vcd");
        $dumpvars(0, priRV32_tb);
        rst_n           = 1;
        clk             = 0;
        pc_data_i = 32'd0;
        pc_addr_i = 32'd0;
        #2
        rst_n = 0;
        #2
        rst_n = 1;
        #50
		$stop;
    end
    always
        #1 clk = ~clk;
endmodule
