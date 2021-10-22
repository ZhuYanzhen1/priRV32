module priRV32
#(
	parameter CLK_FREQUENCY = 50,
	parameter BAUD_RATE = 115200
)
(
	input clk_in,
	input rst_n,
	input rx_pin,
   output tx_pin
);

	reg write_valid, read_valid;
	reg [31:0] write_data, write_address, read_address;
	wire [31:0]read_data;
	reg [2:0] status;

	always @(negedge clk_in or negedge rst_n) begin
		if (rst_n == 1'b0) begin
			status <= 3'b000;
			write_valid <= 1'b0;
			read_valid <= 1'b0;
			write_data <= 32'h00000000;
			write_address <= 32'h00000000;
			read_address <= 32'h00000000;
		end else begin
			case (status)
				3'b000: begin
					write_address <= 32'h10000000;
					write_data <= 32'h000000a5;
					status <= 3'b001;
				end 
				3'b001: begin
					write_valid <= 1'b1;
					status <= 3'b010;
				end
				3'b010: begin
					write_valid <= 1'b0;
					status <= 3'b011;
				end
				3'b011: begin
					write_address <= 32'h10000002;
					write_data <= 32'h00000001;
					status <= 3'b100;
				end
				3'b100: begin
					write_valid <= 1'b1;
					status <= 3'b101;
				end
				3'b101: begin
					write_valid <= 1'b0;
					status <= 3'b110;
				end
				default: begin
					status <= status;
				end
			endcase
		end
	end

    uart_top #
    (
		.CLK_FREQUENCY(CLK_FREQUENCY),
		.BAUD_RATE(BAUD_RATE)
	) uart1(
        .clk_in         (clk_in),
        .rst_n          (rst_n),
        .rx_pin         (rx_pin),
        .tx_pin         (tx_pin),
	    .write_valid    (write_valid),
	    .read_valid     (read_valid),
	    .write_data     (write_data),
	    .read_data      (read_data),
        .write_address  (write_address),
	    .read_address   (read_address)
    );

endmodule
