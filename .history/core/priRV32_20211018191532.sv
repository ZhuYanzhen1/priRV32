module priRV32
#(
	parameter Clock = 50,
	parameter Baud = 115200
)
(
	input clk,
	input rst_n,
	output led
);

reg [31:0]counter;
reg [1:0]led_reg;

assign led = led_reg;

always @(posedge clk)
begin
	if
	if(counter == 32'd24999999) begin
		counter <= 32'd0;
		led_reg <= ~led_reg;
	end else begin
		counter <= counter + 32'd1;
	end
end

endmodule
