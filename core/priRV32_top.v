module priRV32
#(
	parameter CLK_FREQUENCY = 50,
	parameter BAUD_RATE = 115200
)
(
	input clk_in,
	input rst_n
);

	reg [31:0]pc_reg;
	
	cpu_regs general_regs(
		.clk_in(clk_in),
		.rst_n(rst_n)
	);

endmodule
