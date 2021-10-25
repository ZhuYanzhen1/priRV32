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
    always @ (posedge clk)begin
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
	wire rst_n;

	PowerOn_RST po_rst(
		.clk_in(clk_in),
		.rst_in(rst_in),
		.rst_n(rst_n)
	);

	cpu_regs general_regs(
		.clk_in(clk_in),
		.rst_n(rst_n)
	);

	cpu_regs csr_regs(
		.clk_in(clk_in),
		.rst_n(rst_n)
	);

endmodule
