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

reg [25:0]counter;
reg [1:0]led_reg;

assign led = led_reg;

always @(posedge clk)
begin
	if(rst_n == 1'b0)begin
		counter <= 26'd0;
		led_reg <= 1'b0;
	end else if(counter == 26'd10) begin
		counter <= 26'd0;
		led_reg <= ~led_reg;
	end else begin
		counter <= counter + 26'd1;
	end
end


endmodule
