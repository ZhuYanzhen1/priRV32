`include "./core/priRV32_regs.v"
`include "./core/priRV32_ifu.v"
`include "./core/priRV32_exu.v"

module priRV32(
	input clk_i,
	input rst_n,
	output [31:0] itcm_address,
	input [31:0] itcm_data,
	output [31:0] mem_readwrite_address,
	input [31:0] mem_read_data,
	output [31:0] mem_write_data
);

	reg [31:0]pc_reg;
	wire reg_wen, exu_branch_result, ifu_branch_result;

	wire [31:0]branch_address, exu_pc_address, ifu_pc_address;
	wire [31:0]reg_rdata2, reg_rdata1, reg_wdata, imm_latched, datafetch_latched;
	wire [4:0]reg_waddr, reg_raddr2, reg_raddr1, rd_latched;
	wire [46:0]instrset_latched;

	assign itcm_address = pc_reg;

	always @(posedge clk_i or negedge rst_n) begin
		if (rst_n == 1'b0) begin
			pc_reg <= 32'h00000000;
		end else begin
			pc_reg <= exu_branch_result == ifu_branch_result ? ifu_pc_address : exu_pc_address;
		end
	end

	priV32_Regs general_regs(
		.clk_i(clk_i),
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
		.clk_i(clk_i),
		.rst_n(rst_n),
		.branch_result_o(ifu_branch_result),
		.pc_addr_o(ifu_pc_address),
		.exu_branch_result_i(exu_branch_result),
		.pc_data_i(),
		.pc_addr_i(pc_reg),
		.imm_latched(imm_latched),
		.rs1_latched(reg_raddr1),
		.rs2_latched(reg_raddr2),
		.rd_latched(rd_latched),
		.instrset_latched(instrset_latched)
	);

	priRV32_EXU exu( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.mem_readwrite_address(mem_readwrite_address),
		.mem_read_data(mem_read_data),
		.mem_write_data(mem_write_data),
		.imm_decoded(imm_latched),
		.rs1_decoded(reg_rdata1),
		.rs2_decoded(reg_rdata2),
		.rd_reg(rd_latched),
		.instrset_latched(instrset_latched)
	);
	
endmodule
