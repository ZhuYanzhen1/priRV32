module decoder(
	input clk_in,
	input rst_n,
	output [31:0] pc_addr_o,
	input [31:0] pc_data_i
);

	reg is_lui_auipc_jal, is_lb_lh_lw_lbu_lhu, is_slli_srli_srai, is_jalr_addi_slti_sltiu_xori_ori_andi;
	reg is_sb_sh_sw, is_sll_srl_sra, is_lui_auipc_jal_jalr_addi_add_sub, is_slti_blt_slt, is_sltiu_bltu_sltu;
	reg is_beq_bne_blt_bge_bltu_bgeu, is_lbu_lhu_lw, is_alu_reg_imm, is_alu_reg_reg, is_compare;
	reg is_mul_div_rem, is_csr_access, is_fence_fencei;

	reg instr_lui, instr_auipc, instr_jal, instr_jalr;
	reg instr_beq, instr_bne, instr_blt, instr_bge, instr_bltu, instr_bgeu;
	reg instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh, instr_sw;
	reg instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli, instr_srli, instr_srai;
	reg instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor, instr_srl, instr_sra, instr_or, instr_and;
	reg instr_fence, instr_fencei, instr_ecall, instr_ebreak;
	reg instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci;
	reg instr_mul, instr_mulh, instr_mulhsu, instr_mulhu, instr_div, instr_divu, instr_rem, instr_remu;

	wire [31:0] decoder_datafetch_reg;
	assign decoder_datafetch_reg = pc_data_i;

	always @(*) begin
		is_lui_auipc_jal <= |{instr_lui, instr_auipc, instr_jal};
		is_lui_auipc_jal_jalr_addi_add_sub <= |{instr_lui, instr_auipc, instr_jal, instr_jalr, instr_addi, instr_add, instr_sub};
		is_slti_blt_slt <= |{instr_slti, instr_blt, instr_slt};
		is_sltiu_bltu_sltu <= |{instr_sltiu, instr_bltu, instr_sltu};
		is_lbu_lhu_lw <= |{instr_lbu, instr_lhu, instr_lw};
		is_compare <= |{is_beq_bne_blt_bge_bltu_bgeu, instr_slti, instr_slt, instr_sltiu, instr_sltu};

		instr_lui     <= decoder_datafetch_reg[6:0] == 7'b0110111;
		instr_auipc   <= decoder_datafetch_reg[6:0] == 7'b0010111;
		instr_jal     <= decoder_datafetch_reg[6:0] == 7'b1101111;
		instr_jalr    <= decoder_datafetch_reg[6:0] == 7'b1100111 && decoder_datafetch_reg[14:12] == 3'b000;
		is_beq_bne_blt_bge_bltu_bgeu <= decoder_datafetch_reg[6:0] == 7'b1100011;
		is_lb_lh_lw_lbu_lhu          <= decoder_datafetch_reg[6:0] == 7'b0000011;
		is_sb_sh_sw                  <= decoder_datafetch_reg[6:0] == 7'b0100011;
		is_alu_reg_imm               <= decoder_datafetch_reg[6:0] == 7'b0010011;
		is_alu_reg_reg               <= decoder_datafetch_reg[6:0] == 7'b0110011;
		is_mul_div_rem    <= decoder_datafetch_reg[6:0] == 7'b0110011;
		is_csr_access     <= decoder_datafetch_reg[6:0] == 7'b1110011;
		is_fence_fencei   <= decoder_datafetch_reg[6:0] == 7'b0001111;

		instr_beq   <= is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b000;
		instr_bne   <= is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b001;
		instr_blt   <= is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b100;
		instr_bge   <= is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b101;
		instr_bltu  <= is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b110;
		instr_bgeu  <= is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b111;

		instr_lb    <= is_lb_lh_lw_lbu_lhu && decoder_datafetch_reg[14:12] == 3'b000;
		instr_lh    <= is_lb_lh_lw_lbu_lhu && decoder_datafetch_reg[14:12] == 3'b001;
		instr_lw    <= is_lb_lh_lw_lbu_lhu && decoder_datafetch_reg[14:12] == 3'b010;
		instr_lbu   <= is_lb_lh_lw_lbu_lhu && decoder_datafetch_reg[14:12] == 3'b100;
		instr_lhu   <= is_lb_lh_lw_lbu_lhu && decoder_datafetch_reg[14:12] == 3'b101;

		instr_sb    <= is_sb_sh_sw && decoder_datafetch_reg[14:12] == 3'b000;
		instr_sh    <= is_sb_sh_sw && decoder_datafetch_reg[14:12] == 3'b001;
		instr_sw    <= is_sb_sh_sw && decoder_datafetch_reg[14:12] == 3'b010;

		instr_addi  <= is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b000;
		instr_slti  <= is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b010;
		instr_sltiu <= is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b011;
		instr_xori  <= is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b100;
		instr_ori   <= is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b110;
		instr_andi  <= is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b111;

		instr_slli  <= is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b001 && decoder_datafetch_reg[31:25] == 7'b0000000;
		instr_srli  <= is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b101 && decoder_datafetch_reg[31:25] == 7'b0000000;
		instr_srai  <= is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b101 && decoder_datafetch_reg[31:25] == 7'b0100000;

		instr_add   <= is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b000 && decoder_datafetch_reg[31:25] == 7'b0000000;
		instr_sub   <= is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b000 && decoder_datafetch_reg[31:25] == 7'b0100000;
		instr_sll   <= is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b001 && decoder_datafetch_reg[31:25] == 7'b0000000;
		instr_slt   <= is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b010 && decoder_datafetch_reg[31:25] == 7'b0000000;
		instr_sltu  <= is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b011 && decoder_datafetch_reg[31:25] == 7'b0000000;
		instr_xor   <= is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b100 && decoder_datafetch_reg[31:25] == 7'b0000000;
		instr_srl   <= is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b101 && decoder_datafetch_reg[31:25] == 7'b0000000;
		instr_sra   <= is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b101 && decoder_datafetch_reg[31:25] == 7'b0100000;
		instr_or    <= is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b110 && decoder_datafetch_reg[31:25] == 7'b0000000;
		instr_and   <= is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b111 && decoder_datafetch_reg[31:25] == 7'b0000000;

		instr_ecall   <= decoder_datafetch_reg == 32'b00000000000000000000000001110011;
		instr_ebreak  <= decoder_datafetch_reg == 32'b00000000000100000000000001110011;

		instr_fence   <= is_fence_fencei && decoder_datafetch_reg[14:12] == 3'b000;
		instr_fencei  <= is_fence_fencei && decoder_datafetch_reg[14:12] == 3'b001;

		instr_csrrw   <= is_csr_access && decoder_datafetch_reg[14:12] == 3'b001;
		instr_csrrs   <= is_csr_access && decoder_datafetch_reg[14:12] == 3'b010;
		instr_csrrc   <= is_csr_access && decoder_datafetch_reg[14:12] == 3'b011;
		instr_csrrwi  <= is_csr_access && decoder_datafetch_reg[14:12] == 3'b101;
		instr_csrrsi  <= is_csr_access && decoder_datafetch_reg[14:12] == 3'b110;
		instr_csrrci  <= is_csr_access && decoder_datafetch_reg[14:12] == 3'b111;

		instr_mul     <= is_mul_div_rem && decoder_datafetch_reg[14:12] == 3'b000 && decoder_datafetch_reg[31:25] == 7'b0000001;
		instr_mulh    <= is_mul_div_rem && decoder_datafetch_reg[14:12] == 3'b001 && decoder_datafetch_reg[31:25] == 7'b0000001;
		instr_mulhsu  <= is_mul_div_rem && decoder_datafetch_reg[14:12] == 3'b010 && decoder_datafetch_reg[31:25] == 7'b0000001;
		instr_mulhu   <= is_mul_div_rem && decoder_datafetch_reg[14:12] == 3'b011 && decoder_datafetch_reg[31:25] == 7'b0000001;
		instr_div     <= is_mul_div_rem && decoder_datafetch_reg[14:12] == 3'b100 && decoder_datafetch_reg[31:25] == 7'b0000001;
		instr_divu    <= is_mul_div_rem && decoder_datafetch_reg[14:12] == 3'b101 && decoder_datafetch_reg[31:25] == 7'b0000001;
		instr_rem     <= is_mul_div_rem && decoder_datafetch_reg[14:12] == 3'b110 && decoder_datafetch_reg[31:25] == 7'b0000001;
		instr_remu    <= is_mul_div_rem && decoder_datafetch_reg[14:12] == 3'b111 && decoder_datafetch_reg[31:25] == 7'b0000001;
	end


endmodule
