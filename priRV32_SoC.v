`include "./core/priRV32_top.v"
`include "./periph/uart/uart_top.v"
`include "./fpga/itcm_ram.v"
`include "./periph/flash/spi_flash"

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
    output tx_pin,
    output spi_cs_pin,
    output spi_clk_pin,
    output spi_mosi_pin,
    input spi_miso_pin
);
    wire rst_n;
    wire [31:0]readwrite_address, mem_read_data, itcm_address, itcm_data;

    PowerOn_RST po_rst(
		.clk_in(clk_in),
		.rst_in(rst_in),
		.rst_n(rst_n)
	);

    itcm_ram itcm_ram1(
	    .address(itcm_address),
		.clock(clk_in),
		.data(itcm_data),
		.wren(),
		.q(mem_read_data)
    );
	
    priRV32 rv32_core(
        .clk_in(clk_in),
		.rst_n(rst_n),
        .itcm_address(itcm_address),
        .itcm_data(itcm_data),
        .mem_readwrite_address(readwrite_address),
        .mem_read_data(mem_read_data),
        .mem_write_data()
    );

    uart_top #(
        .CLK_FREQUENCY(50_000_000),
		.BAUD_RATE(115200)
    )uart1(
        .clk_in(clk_in),
		.rst_n(rst_n),
        .tx_pin(tx_pin),
		.rx_pin(rx_pin),
        .write_valid(1'b1),
        .read_valid(1'b1),
        .write_data(),
        .read_data(),
        .write_address(readwrite_address),
        .read_address(readwrite_address)
    );

    spi_flash_xip flash_xip(
        .clk(clk_in),
		.rst_n(rst_n),
		.ncs(spi_cs_pin),
		.dclk(spi_clk_pin),
		.mosi(spi_mosi_pin),
		.miso(spi_miso_pin)
    );

endmodule
