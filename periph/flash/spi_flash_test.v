`include "./periph/flash/spi_flash_defines.v"

module spi_flash_xip(	input clk,
						input rst_n,
						output ncs,
						output dclk,
						output mosi,
						input miso
);
	localparam S_IDLE       = 0;
	localparam S_READ_ID    = 1;
	localparam S_SE         = 2;//Sector Erase
	localparam S_PP         = 3;
	localparam S_READ       = 4;
	localparam S_WAIT       = 5;

	reg[3:0] state;
	reg[7:0] read_data;
	reg[31:0] timer;

	reg            flash_read;
	reg            flash_write;
	wire           flash_read_ack;
	wire           flash_write_ack;
	wire           flash_bulk_erase_ack;
	wire           flash_sector_erase_ack;
	reg[23:0]      flash_read_addr;
	reg[23:0]      flash_write_addr;
	reg[23:0]      flash_sector_addr;
	reg[7:0]       flash_write_data_in;
	wire[8:0]      flash_read_size;
	wire[8:0]      flash_write_size;
	wire           flash_write_data_req;
	wire[7:0]      flash_read_data_out;
	wire           flash_read_data_valid;

	assign flash_read_size = 9'd1;
	assign flash_write_size = 9'd1;
	always@(posedge clk or negedge rst_n)
	begin
		if(rst_n == 1'b0)
		begin
			state <= S_IDLE;
			flash_read <= 1'b0;
			flash_write <= 1'b0;
			flash_bulk_erase <= 1'b0;
			flash_sector_erase <= 1'b0;
			flash_read_addr <= 24'd0;
			flash_write_addr <= 24'd0;
			flash_sector_addr <= 24'd0;
			flash_write_data_in <= 8'd0;
			timer <= 32'd0;
		end
		else
			case(state)
				S_IDLE:
				begin
					if(timer >= 32'd12_499_999)
						state <= S_READ;
					else
						timer <= timer + 32'd1;
				end
				S_WAIT:
					if(button_negedge == 1'b1)
					begin
						state <= S_SE;
						read_data <= read_data + 8'd1;
					end
				S_SE:
				begin
					if(flash_sector_erase_ack == 1'b1)
					begin
						flash_sector_erase <= 1'b0;
						state <= S_PP;
					end
					else
					begin
						flash_sector_erase <= 1'b1;
						flash_sector_addr <= 24'd0;
					end
				end
				S_PP:
				begin
					if(flash_write_data_req == 1'b1)
						flash_write_data_in <= read_data;

					if(flash_write_ack == 1'b1)
					begin
						flash_write <= 1'b0;
						state <= S_READ;
					end
					else
					begin
						flash_write <= 1'b1;
						flash_write_addr <= 24'd0;
					end
				end
				S_READ:
				begin
					if(flash_read_data_valid == 1'b1)
						read_data <= flash_read_data_out;

					if(flash_read_ack == 1'b1)
					begin
						flash_read <= 1'd0;
						state <= S_WAIT;
					end
					else
					begin
						flash_read <= 1'd1;
						flash_read_addr <= 24'd0;
					end
				end
				default:
					state <= S_IDLE;
			endcase
	end

	spi_flash_top spi_flash_top_m0(
		.sys_clk                     (clk                      ),
		.rst                         (~rst_n                   ),
		.nCS                         (ncs                      ),
		.DCLK                        (dclk                     ),
		.MOSI                        (mosi                     ),
		.MISO                        (miso                     ),
		.clk_div                     (16'd0                    ),
		.flash_read                  (flash_read               ),
		.flash_write                 (flash_write              ),
		.flash_bulk_erase            (flash_bulk_erase         ),
		.flash_sector_erase          (flash_sector_erase       ),
		.flash_read_ack              (flash_read_ack           ),
		.flash_write_ack             (flash_write_ack          ),
		.flash_bulk_erase_ack        (flash_bulk_erase_ack     ),
		.flash_sector_erase_ack      (flash_sector_erase_ack   ),
		.flash_read_addr             (flash_read_addr          ),
		.flash_write_addr            (flash_write_addr         ),
		.flash_sector_addr           (flash_sector_addr        ),
		.flash_write_data_in         (flash_write_data_in      ),
		.flash_read_size             (flash_read_size          ),
		.flash_write_size            (flash_write_size         ),
		.flash_write_data_req        (flash_write_data_req     ),
		.flash_read_data_out         (flash_read_data_out      ),
		.flash_read_data_valid       (flash_read_data_valid    )
	);
endmodule