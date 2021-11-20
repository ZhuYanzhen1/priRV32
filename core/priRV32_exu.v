module priRV32_EXU( 
    input clk_in,
    input rst_n,
    input [31:0] imm_decoded,
    input [31:0] rs1_decoded,
    input [31:0] rs2_decoded,
    input [4:0] rd_decoded,
    input [31:0] datafetch_latched,
    input is_lb_lh_lw_lbu_lhu,
    input is_csr_access,
    input is_fence_fencei,
    input is_sb_sh_sw,
    input is_beq_bne_blt_bge_bltu_bgeu,
    input is_alu_reg_imm,
    input is_alu_reg_reg
);

    wire instr_lui, instr_auipc, instr_jal, instr_jalr;
    wire instr_beq, instr_bne, instr_blt, instr_bge, instr_bltu, instr_bgeu;
    wire instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh, instr_sw;
    wire instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli, instr_srli, instr_srai;
    wire instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor, instr_srl, instr_sra, instr_or, instr_and;
    wire instr_fence, instr_fencei, instr_ecall, instr_ebreak;
    wire instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci;

    assign instr_lui                    = datafetch_latched[6:0] == 7'b0110111;
    assign instr_auipc                  = datafetch_latched[6:0] == 7'b0010111;
    assign instr_jal                    = datafetch_latched[6:0] == 7'b1101111;
    assign instr_jalr                   = datafetch_latched[6:0] == 7'b1100111 && datafetch_latched[14:12] == 3'b000;

    assign instr_beq  = is_beq_bne_blt_bge_bltu_bgeu && datafetch_latched[14:12] == 3'b000;
    assign instr_bne  = is_beq_bne_blt_bge_bltu_bgeu && datafetch_latched[14:12] == 3'b001;
    assign instr_blt  = is_beq_bne_blt_bge_bltu_bgeu && datafetch_latched[14:12] == 3'b100;
    assign instr_bge  = is_beq_bne_blt_bge_bltu_bgeu && datafetch_latched[14:12] == 3'b101;
    assign instr_bltu = is_beq_bne_blt_bge_bltu_bgeu && datafetch_latched[14:12] == 3'b110;
    assign instr_bgeu = is_beq_bne_blt_bge_bltu_bgeu && datafetch_latched[14:12] == 3'b111;
    
    assign instr_lb  = is_lb_lh_lw_lbu_lhu && datafetch_latched[14:12] == 3'b000;
    assign instr_lh  = is_lb_lh_lw_lbu_lhu && datafetch_latched[14:12] == 3'b001;
    assign instr_lw  = is_lb_lh_lw_lbu_lhu && datafetch_latched[14:12] == 3'b010;
    assign instr_lbu = is_lb_lh_lw_lbu_lhu && datafetch_latched[14:12] == 3'b100;
    assign instr_lhu = is_lb_lh_lw_lbu_lhu && datafetch_latched[14:12] == 3'b101;
    
    assign instr_sb = is_sb_sh_sw && datafetch_latched[14:12] == 3'b000;
    assign instr_sh = is_sb_sh_sw && datafetch_latched[14:12] == 3'b001;
    assign instr_sw = is_sb_sh_sw && datafetch_latched[14:12] == 3'b010;
    
    assign instr_addi  = is_alu_reg_imm && datafetch_latched[14:12] == 3'b000;
    assign instr_slti  = is_alu_reg_imm && datafetch_latched[14:12] == 3'b010;
    assign instr_sltiu = is_alu_reg_imm && datafetch_latched[14:12] == 3'b011;
    assign instr_xori  = is_alu_reg_imm && datafetch_latched[14:12] == 3'b100;
    assign instr_ori   = is_alu_reg_imm && datafetch_latched[14:12] == 3'b110;
    assign instr_andi  = is_alu_reg_imm && datafetch_latched[14:12] == 3'b111;
    
    assign instr_slli = is_alu_reg_imm && datafetch_latched[14:12] == 3'b001 && datafetch_latched[31:25] == 7'b0000000;
    assign instr_srli = is_alu_reg_imm && datafetch_latched[14:12] == 3'b101 && datafetch_latched[31:25] == 7'b0000000;
    assign instr_srai = is_alu_reg_imm && datafetch_latched[14:12] == 3'b101 && datafetch_latched[31:25] == 7'b0100000;
    
    assign instr_add  = is_alu_reg_reg && datafetch_latched[14:12] == 3'b000 && datafetch_latched[31:25] == 7'b0000000;
    assign instr_sub  = is_alu_reg_reg && datafetch_latched[14:12] == 3'b000 && datafetch_latched[31:25] == 7'b0100000;
    assign instr_sll  = is_alu_reg_reg && datafetch_latched[14:12] == 3'b001 && datafetch_latched[31:25] == 7'b0000000;
    assign instr_slt  = is_alu_reg_reg && datafetch_latched[14:12] == 3'b010 && datafetch_latched[31:25] == 7'b0000000;
    assign instr_sltu = is_alu_reg_reg && datafetch_latched[14:12] == 3'b011 && datafetch_latched[31:25] == 7'b0000000;
    assign instr_xor  = is_alu_reg_reg && datafetch_latched[14:12] == 3'b100 && datafetch_latched[31:25] == 7'b0000000;
    assign instr_srl  = is_alu_reg_reg && datafetch_latched[14:12] == 3'b101 && datafetch_latched[31:25] == 7'b0000000;
    assign instr_sra  = is_alu_reg_reg && datafetch_latched[14:12] == 3'b101 && datafetch_latched[31:25] == 7'b0100000;
    assign instr_or   = is_alu_reg_reg && datafetch_latched[14:12] == 3'b110 && datafetch_latched[31:25] == 7'b0000000;
    assign instr_and  = is_alu_reg_reg && datafetch_latched[14:12] == 3'b111 && datafetch_latched[31:25] == 7'b0000000;
    
    assign instr_ecall  = datafetch_latched == 32'b00000000000000000000000001110011;
    assign instr_ebreak = datafetch_latched == 32'b00000000000100000000000001110011;
    
    assign instr_fence  = is_fence_fencei && datafetch_latched[14:12] == 3'b000;
    assign instr_fencei = is_fence_fencei && datafetch_latched[14:12] == 3'b001;
    
    assign instr_csrrw  = is_csr_access && datafetch_latched[14:12] == 3'b001;
    assign instr_csrrs  = is_csr_access && datafetch_latched[14:12] == 3'b010;
    assign instr_csrrc  = is_csr_access && datafetch_latched[14:12] == 3'b011;
    assign instr_csrrwi = is_csr_access && datafetch_latched[14:12] == 3'b101;
    assign instr_csrrsi = is_csr_access && datafetch_latched[14:12] == 3'b110;
    assign instr_csrrci = is_csr_access && datafetch_latched[14:12] == 3'b111;

endmodule
