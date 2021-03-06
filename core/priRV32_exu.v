module priRV32_EXU( 
    input clk_i,
    input rst_n,
    output reg[31:0] mem_readwrite_address,
    input [31:0] mem_read_data,
    output reg[31:0] mem_write_data,
    output reg [4:0] rd_reg_latched,
    output reg[31:0] reg_write_data,
    input [31:0] imm_decoded,
    input [31:0] rs1_decoded,
    input [31:0] rs2_decoded,
    input [31:0] pc_latched,
    input [4:0] rs2_reg,
    input [4:0] rd_reg,
    input [46:0] instrset_latched
);

    wire instr_lui, instr_auipc, instr_jal, instr_jalr;
    wire instr_beq, instr_bne, instr_blt, instr_bge, instr_bltu, instr_bgeu;
    wire instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh, instr_sw;
    wire instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli, instr_srli, instr_srai;
    wire instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor, instr_srl, instr_sra, instr_or, instr_and;
    wire instr_fence, instr_fencei, instr_ecall, instr_ebreak, is_beq_bne_blt_bge_bltu_bgeu;
    wire instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci;
    wire is_lui_auipc_jal, is_lb_lh_lw_lbu_lhu, is_slli_srli_srai, is_jalr_addi_slti_sltiu_xori_ori_andi, is_sb_sh_sw;

    assign  {instr_lui, instr_auipc, instr_jal, instr_jalr, instr_beq, instr_bne, instr_blt, instr_bge
            , instr_bltu, instr_bgeu, instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh
            , instr_sw, instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli
            , instr_srli, instr_srai, instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor
            , instr_srl, instr_sra, instr_or, instr_and, instr_fence, instr_fencei, instr_ecall
            , instr_ebreak, instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci} = instrset_latched;
    assign is_beq_bne_blt_bge_bltu_bgeu = |{instr_beq, instr_bne, instr_blt, instr_bge, instr_bltu, instr_bgeu};
    assign is_lui_auipc_jal = |{instr_lui, instr_auipc, instr_jal};
    assign is_lb_lh_lw_lbu_lhu = |{instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu};
    assign is_slli_srli_srai = |{instr_slli, instr_srli, instr_srai};
    assign is_jalr_addi_slti_sltiu_xori_ori_andi = |{instr_jalr, instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi};
    assign is_sb_sh_sw = |{instr_sb, instr_sh, instr_sw};

    reg [31:0] alu_out, alu_add_sub, alu_shl, alu_shr, reg_op1, reg_op2, reg_out, mem_out;
    reg alu_eq, alu_ltu, alu_lts;
    always @* begin
        mem_readwrite_address <= rs1_decoded + imm_decoded;
        /* ALU shift, addition, subtraction and comparison calculations */
        alu_add_sub <= instr_sub ? reg_op1 - reg_op2 : reg_op1 + reg_op2;
        alu_eq <= reg_op1 == reg_op2;
        alu_lts <= $signed(reg_op1) < $signed(reg_op2);
        alu_ltu <= reg_op1 < reg_op2;
        alu_shl <= reg_op1 << reg_op2[4:0];
        alu_shr <= $signed({instr_sra || instr_srai ? reg_op1[31] : 1'b0, reg_op1}) >>> reg_op2[4:0];
        /* ALU output data processing */
        alu_out <= 'bx;
        case (1'b1)
			|{instr_lui, instr_auipc, instr_jal, instr_jalr, instr_addi, instr_add, instr_sub}:
				alu_out <= instr_jalr ? alu_add_sub + 32'd4 : alu_add_sub;
			|{is_beq_bne_blt_bge_bltu_bgeu, instr_slti, instr_slt, instr_sltiu, instr_sltu}: begin
                case (1'b1)
                    instr_beq:
                        alu_out <= alu_eq;
                    instr_bne:
                        alu_out <= !alu_eq;
                    instr_bge:
                        alu_out <= !alu_lts;
                    instr_bgeu:
                        alu_out <= !alu_ltu;
                    |{instr_slti, instr_blt, instr_slt}:
                        alu_out <= alu_lts;
                    |{instr_sltiu, instr_bltu, instr_sltu}:
                        alu_out <= alu_ltu;
                endcase
            end
			instr_xori || instr_xor:
				alu_out <= reg_op1 ^ reg_op2;
			instr_ori || instr_or:
				alu_out <= reg_op1 | reg_op2;
			instr_andi || instr_and:
				alu_out <= reg_op1 & reg_op2;
			instr_sll || instr_slli:
				alu_out <= alu_shl;
			instr_srl || instr_srli || instr_sra || instr_srai:
				alu_out <= alu_shr;
		endcase
    end

    /* ALU incoming value selection */
    always @(*) begin
        reg_op1 <= rs1_decoded;
        reg_op2 <= rs2_decoded;
        case (1'b1)
            is_lui_auipc_jal: begin
                reg_op1 <= instr_lui ? 0 : pc_latched;
                reg_op2 <= imm_decoded;
            end
            |{is_jalr_addi_slti_sltiu_xori_ori_andi, is_slli_srli_srai}:
                reg_op2 <= is_slli_srli_srai ? rs2_reg : imm_decoded;
            |{is_lb_lh_lw_lbu_lhu, is_sb_sh_sw}:
                reg_op2 <= imm_decoded;
        endcase
    end

    always @(*) begin
        if (|{is_lb_lh_lw_lbu_lhu, is_sb_sh_sw})
            mem_readwrite_address <= alu_add_sub;
        else
            mem_readwrite_address <= 32'b0;
    end

    always @(*) begin
        case (1'b1)
            |{instr_lui, instr_auipc, instr_jal, instr_jalr, instr_addi, instr_add, instr_sub
            , instr_xori, instr_xor, instr_ori, instr_or, instr_andi, instr_and, instr_sll, instr_slli
            , instr_srl, instr_srli, instr_sra, instr_srai}:
                reg_out <= alu_out;
            instr_lb:
                reg_out <= $signed(mem_read_data[7:0]);
            |{instr_lbu, instr_lhu, instr_lw}:
                reg_out <= mem_read_data;
			instr_lh:
                reg_out <= $signed(mem_read_data[15:0]);
            instr_sw:
                mem_out <= rs2_decoded;
            instr_sh:
                mem_out <= {16'h0000, rs2_decoded[15:0]};
            instr_sb:
                mem_out <= {24'h000000, rs2_decoded[7:0]};
        endcase
    end

    always @(posedge clk_i) begin
        if(!{instr_sw, instr_sh, instr_sb}) begin
            mem_write_data <= mem_out;

            reg_write_data <= 32'h00000000;
            rd_reg_latched <= 5'd0;
        end else begin
            reg_write_data <= reg_out;
            rd_reg_latched <= rd_reg;
        end
    end
    
endmodule
