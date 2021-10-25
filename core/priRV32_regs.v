module cpu_regs(
	input clk_in,
	input rst_n,
	// from ex
    input wire we_i,
    input wire[4:0] waddr_i,
    input wire[31:0] wdata_i, 

    // from id
    input wire[4:0] raddr1_i,
	input wire[4:0] raddr2_i,

    // to id
	output reg[31:0] rdata1_o,
    output reg[31:0] rdata2_o
);
    reg[31:0] regs[0:31];

    // 写寄存器
    always @ (posedge clk_in) begin
        if (rst_n == 1'b1) begin
            if ((we_i == 1'b1) && (waddr_i != 5'h0)) begin
                regs[waddr_i] <= wdata_i;
            end
        end
    end

    always @ (*) begin
        if (raddr1_i == 5'h0) begin
            rdata1_o = 32'h0;
        end else if (raddr1_i == waddr_i && we_i == 1'b1) begin
            rdata1_o = wdata_i;
        end else begin
            rdata1_o = regs[raddr1_i];
        end
    end

    always @ (*) begin
        if (raddr2_i == 5'h0) begin
            rdata2_o = 32'h0;
        end else if (raddr2_i == waddr_i && we_i == 1'b1) begin
            rdata2_o = wdata_i;
        end else begin
            rdata2_o = regs[raddr2_i];
        end
    end

endmodule
