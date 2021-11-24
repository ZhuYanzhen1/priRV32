`timescale 1ns/1ns
`include "./core/priRV32_exu.v"

module priRV32_tb;

    reg clk, rst_n, exu_result;
    reg [31:0]pc_data_i, pc_addr_i;

    priRV32_EXU exu(.clk_i(clk),
                    .rst_n(rst_n),
                    .imm_decoded(),
                    .rs1_decoded(),
                    .rs2_decoded(),
                    .pc_latched(),
                    .rd_reg(),
                    .rs1_reg(),
                    .rs2_reg(),
                    .instrset_latched()
    );

    initial begin
        $dumpfile("./priRV32_tb.vcd");
        $dumpvars(0, priRV32_tb);
        rst_n = 1'b1;
        clk = 1'b0;
        #2
        rst_n = 0;
        #3
        rst_n = 1;
        
        #50
		$stop;
    end

    always
        #1 clk = ~clk;

endmodule
