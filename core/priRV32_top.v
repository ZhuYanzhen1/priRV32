`include "./core/priRV32_regs.v"
`include "./core/priRV32_ifu.v"

module PowerOn_RST#(
	parameter CNT = 20'd500_000	// 50k / 50MHz = 10ms
)(
    input clk_in,
    input rst_in,
    output rst_n
);
    wire buf_rst_n;
    reg [26:0] cnt = 27'd0;
    assign buf_rst_n = (cnt == CNT - 1'b1) ? 1'b1 : 1'b0;
    assign rst_n = buf_rst_n || rst_in;
    always @ (posedge clk_in)begin
        if (cnt < CNT - 1'b1)
            cnt <= cnt + 1'b1;
        else
            cnt <= cnt;
    end
endmodule

module priRV32(
	input clk_in,
	input rst_in
);

	reg [31:0]pc_reg;
	wire rst_n, reg_wen;
	wire [31:0]reg_rdata2, reg_rdata1, reg_wdata;
	wire [4:0]reg_waddr, reg_raddr2, reg_raddr1;

	PowerOn_RST po_rst(
		.clk_in(clk_in),
		.rst_in(rst_in),
		.rst_n(rst_n)
	);

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
