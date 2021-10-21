module uart_top #(
	parameter CLK_FREQUENCY = 50,
	parameter BAUD_RATE = 115200
)
(
    input clk_in,
    input rst_n,
    input rx_pin,
    output tx_pin,
	input write_valid,
	input read_ready,
	output write_ready,
	output read_valid,
	input reg [31:0] write_data,
	output reg [31:0] read_data,
	input reg [31:0] write_address,
	input reg [31:0] read_address
);

	reg [31:0] regs[0:30];

	always @(posedge clk_in)
		if (wen)
            regs[~waddr[4:0]] <= write_data;

	assign rdata1 = regs[~raddr1[4:0]];
	assign rdata2 = regs[~raddr2[4:0]];

	uart_rx#
	(
		.CLK_FRE(CLK_FREQUENCY),
		.BAUD_RATE(BAUD_RATE)
	) uart_rx_inst
	(
		.clk                        (clk_in       ),
		.rst_n                      (rst_n        ),
		.rx_data                    (rx_data      ),
		.rx_data_valid              (rx_data_valid),
		.rx_data_ready              (rx_data_ready),
		.rx_pin                     (rx_pin       )
	);

	uart_tx#
	(
		.CLK_FRE(CLK_FREQUENCY),
		.BAUD_RATE(BAUD_RATE)
	) uart_tx_inst
	(
		.clk                        (clk_in       ),
		.rst_n                      (rst_n        ),
		.tx_data                    (tx_data      ),
		.tx_data_valid              (tx_data_valid),
		.tx_data_ready              (tx_data_ready),
		.tx_pin                     (tx_pin       )
	);

endmodule