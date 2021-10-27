`include "./core/priRV32_regs.v"
`include "./core/priRV32_ifu.v"
`include "./core/priRV32_exu.v"

module priRV32(
	input clk_in,
	input rst_n
);

	reg [31:0]pc_reg;
	wire reg_wen;
	wire [31:0]reg_rdata2, reg_rdata1, reg_wdata;
	wire [4:0]reg_waddr, reg_raddr2, reg_raddr1;

	always @(negedge rst_n) begin
		pc_reg <= 32'h00000000;
	end

	priV32_Regs general_regs(
		.clk_in(clk_in),
		.rst_n(rst_n),
		.we_i(reg_wen),
		.waddr_i(reg_waddr),
		.wdata_i(reg_wdata),
		.raddr1_i(reg_raddr1),
		.raddr2_i(reg_raddr2),
		.rdata1_o(reg_rdata1),
		.rdata2_o(reg_rdata2)
	);

	priRV32_IFU ifu(
		.clk_in(clk_in),
		.rst_n(rst_n)
	);

endmodule
