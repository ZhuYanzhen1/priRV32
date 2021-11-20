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
    wire instr_fence, instr_fencei, instr_ecall, instr_ebreak;
    wire instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci;

    assign  {instr_lui, instr_auipc, instr_jal, instr_jalr, instr_beq, instr_bne, instr_blt, instr_bge
            , instr_bltu, instr_bgeu, instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh
            , instr_sw, instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli
            , instr_srli, instr_srai, instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor
            , instr_srl, instr_sra, instr_or, instr_and, instr_fence, instr_fencei, instr_ecall
            , instr_ebreak, instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci} = instrset_latched;

endmodule
