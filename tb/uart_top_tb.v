`timescale 1ns/1ns

module uart_tb;

reg clk_in, rst_n, rx_pin, write_valid, read_valid;
reg [31:0] write_data, write_address, read_address;
wire [31:0]read_data;
wire led, tx_pin;

    uart_top #
    (
		.CLK_FREQUENCY(50),
		.BAUD_RATE(5000000)
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

    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);
        rst_n = 1;
        clk_in = 0;
        #25 rst_n = 0;
        #25 rst_n = 1;
        write_address = 32'h10000000;
        write_data = 32'h000000a5;
        #25 write_valid = 1'b1;
        #25 write_valid = 1'b0;
        write_address = 32'h10000002;
        write_data = 32'h00000001;
        #25 write_valid = 1'b1;
        #25 write_valid = 1'b0;
        #3000
		$stop;
    end

    always
        #10 clk_in = ~clk_in;
endmodule
