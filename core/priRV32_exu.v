module priRV32_EXU( 
    input clk_in,
    input rst_n,
    input [31:0] imm_decoded,
    input [31:0] rs1_decoded,
    input [31:0] rs2_decoded,
    input [4:0] rd_decoded,
    input [46:0] instrset_latched
);

    wire instr_lui, instr_auipc, instr_jal, instr_jalr;
    wire instr_beq, instr_bne, instr_blt, instr_bge, instr_bltu, instr_bgeu;
    wire instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh, instr_sw;
    wire instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli, instr_srli, instr_srai;
    wire instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor, instr_srl, instr_sra, instr_or, instr_and;
    wire instr_fence, instr_fencei, instr_ecall, instr_ebreak, is_beq_bne_blt_bge_bltu_bgeu;
    wire instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci;

    assign  {instr_lui, instr_auipc, instr_jal, instr_jalr, instr_beq, instr_bne, instr_blt, instr_bge
            , instr_bltu, instr_bgeu, instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh
            , instr_sw, instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli
            , instr_srli, instr_srai, instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor
            , instr_srl, instr_sra, instr_or, instr_and, instr_fence, instr_fencei, instr_ecall
            , instr_ebreak, instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci} = instrset_latched;
    assign is_beq_bne_blt_bge_bltu_bgeu = instr_beq && instr_bne && instr_blt && instr_bge && instr_bltu && instr_bgeu;

    reg alu_add_sub, alu_eq, alu_lts, alu_ltu, alu_shl, alu_shr, alu_out_0, alu_out;
    always @* begin
        alu_add_sub = instr_sub ? rs1_decoded - rs2_decoded : rs1_decoded + rs2_decoded;
        alu_eq = rs1_decoded == rs2_decoded;
        alu_lts = $signed(rs1_decoded) < $signed(rs2_decoded);
        alu_ltu = rs1_decoded < rs2_decoded;
        alu_shl = rs1_decoded << rs2_decoded[4:0];
        alu_shr = $signed({instr_sra || instr_srai ? rs1_decoded[31] : 1'b0, rs1_decoded}) >>> rs2_decoded[4:0];
	end

    always @(*) begin
        alu_out_0 = 1'bx;
        case (1'b1)
            instr_beq:
				alu_out_0 = alu_eq;
			instr_bne:
				alu_out_0 = !alu_eq;
			instr_bge:
				alu_out_0 = !alu_lts;
			instr_bgeu:
				alu_out_0 = !alu_ltu;
			|{instr_slti, instr_blt, instr_slt}:
				alu_out_0 = alu_lts;
			|{instr_sltiu, instr_bltu, instr_sltu}:
				alu_out_0 = alu_ltu;
        endcase

        case (1'b1)
			|{instr_lui, instr_auipc, instr_jal, instr_jalr, instr_addi, instr_add, instr_sub}:
				alu_out = alu_add_sub;
			|{is_beq_bne_blt_bge_bltu_bgeu, instr_slti, instr_slt, instr_sltiu, instr_sltu}:
				alu_out = alu_out_0;
			instr_xori || instr_xor:
				alu_out = rs1_decoded ^ rs2_decoded;
			instr_ori || instr_or:
				alu_out = rs1_decoded | rs2_decoded;
			instr_andi || instr_and:
				alu_out = rs1_decoded & rs2_decoded;
			instr_sll || instr_slli:
				alu_out = alu_shl;
			instr_srl || instr_srli || instr_sra || instr_srai:
				alu_out = alu_shr;
		endcase
    end

endmodule
