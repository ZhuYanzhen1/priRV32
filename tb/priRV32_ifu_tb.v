`timescale 1ns/1ns
`include "./core/priRV32_ifu.v"

module priRV32_ifu_tb;

reg clk, rst_n, exu_result;
reg [31:0]pc_data_i, pc_addr_i;

    initial begin
        $dumpfile("priRV32_tb.vcd");
        $dumpvars(0, priRV32_ifu_tb);
    end

    priRV32_IFU ifu(.clk_i(clk),
                    .rst_n(rst_n),
                    .pc_data_i(pc_data_i),
                    .pc_addr_i(pc_addr_i),
                    .exu_branch_result_i(exu_result)
    );

    initial begin
        exu_result = 1'b0;
        rst_n = 1'b1;
        clk = 1'b0;
        pc_data_i = 32'd0;
        pc_addr_i = 32'h80000000;
        #2
        rst_n = 0;
        #3
        rst_n = 1;
        pc_data_i = 32'b0000010_00011_00101_000_10000_1100011;
        #2
        pc_data_i = 32'd0;
        #50
		$stop;
    end
    always
        #1 clk = ~clk;
endmodule
