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
	input read_valid,
	input [31:0] write_data,
	output reg [31:0] read_data,
	input [31:0] write_address,
	input [31:0] read_address
);

	reg [31:0] uart_regs[0:4];
	wire [7:0]tx_data, rx_data;
	reg tx_data_valid;
	wire tx_data_ready, rx_data_valid, rx_data_ready;

	always @(posedge clk_in or negedge rst_n)
	begin
		if (rst_n == 1'b0) begin
			uart_regs[0] <= 32'h00000000;
			uart_regs[1] <= 32'h00000000;
			uart_regs[2] <= 32'h00000000;
			uart_regs[3] <= 32'h00000000;
			tx_data_valid <= 1'b0;
		end else begin
			if (uart_regs[2][1:0] == 1'b1 && tx_data_ready == 1'b1) begin
				tx_data_valid <= 1'b1;
			end else if (tx_data_ready == 1'b1 && tx_data_valid == 1'b1) begin
				uart_regs[2][1:0] <= 1'b0;
				tx_data_valid <= 1'b0;
			end
			if (rx_data_valid == 1'b1) begin
				uart_regs[1][7:0] <= rx_data;
				uart_regs[2][2:1] <= 1'b1;
			end
			if (write_address[31:4] == 28'h1000000) begin
				if (write_valid == 1'b1) begin
					uart_regs[write_address[1:0]] <= write_data;
				end
			end
			if (read_address[31:4] == 28'h1000000) begin
				if (read_valid == 1'b1) begin
					read_data <= uart_regs[read_address[1:0]];
				end
			end
		end
	end

	assign tx_data = uart_regs[0][7:0];
	assign rx_data_ready = 1'b1;

	uart_rx#
	(
		.CLK_FREQUENCY(CLK_FREQUENCY),
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
		.CLK_FREQUENCY(CLK_FREQUENCY),
		.BAUD_RATE(BAUD_RATE)
	) uart_tx_inst
	(
		.clk                        (clk_in       ),
		.rst_n                      (rst_n        ),
		.tx_data                    (tx_data  ),
		.tx_data_valid              (tx_data_valid),
		.tx_data_ready              (tx_data_ready),
		.tx_pin                     (tx_pin       )
	);

endmodule
