`include "./core/priRV32_top.v"
`include "./periph/uart/uart_top.v"

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

module priRV32_SoC (
    input clk_in,
    input rst_in,
    input rx_pin,
    output tx_pin
);
    wire rst_n;

    PowerOn_RST po_rst(
		.clk_in(clk_in),
		.rst_in(rst_in),
		.rst_n(rst_n)
	);

    itcm_ram itcm_ram1(
	   .address(),
		.clock(clk_in),
		.data(),
		.wren(),
		.q()
    );
	
    priRV32 rv32_core(
        .clk_in(clk_in),
		.rst_n(rst_n)
    );

    uart_top #(
        .CLK_FREQUENCY(CLK_FREQUENCY),
		.BAUD_RATE(BAUD_RATE)
    )uart1(
        .clk_in(clk_in),
		.rst_n(rst_n),
        .tx_pin(tx_pin),
		.rx_pin(rx_pin)
    );

endmodule
