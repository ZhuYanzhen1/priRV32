`timescale 1ns/1ns
`include "./core/priRV32_exu.v"

module priRV32_tb;

    reg clk, rst_n;
    reg [31:0]pc_data_i, pc_addr_i, imm_decoded, rs1_decoded, rs2_decoded, pc_latched;
    reg instr_lui, instr_auipc, instr_jal, instr_jalr;
    reg instr_beq, instr_bne, instr_blt, instr_bge, instr_bltu, instr_bgeu;
    reg instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh, instr_sw;
    reg instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli, instr_srli, instr_srai;
    reg instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor, instr_srl, instr_sra, instr_or, instr_and;
    reg instr_fence, instr_fencei, instr_ecall, instr_ebreak, is_beq_bne_blt_bge_bltu_bgeu;
    reg instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci;
    reg is_lui_auipc_jal, is_lb_lh_lw_lbu_lhu, is_slli_srli_srai, is_jalr_addi_slti_sltiu_xori_ori_andi;
    wire [46:0] instruction_set;

    assign instruction_set =    {instr_lui, instr_auipc, instr_jal, instr_jalr, instr_beq, instr_bne, instr_blt, instr_bge
                                , instr_bltu, instr_bgeu, instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh
                                , instr_sw, instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli
                                , instr_srli, instr_srai, instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor
                                , instr_srl, instr_sra, instr_or, instr_and, instr_fence, instr_fencei, instr_ecall
                                , instr_ebreak, instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci};

    priRV32_EXU exu(.clk_i(clk),
                    .rst_n(rst_n),
                    .mem_readwrite_address(),
                    .mem_read_data(),
                    .imm_decoded(imm_decoded),
                    .rs1_decoded(rs1_decoded),
                    .rs2_decoded(rs2_decoded),
                    .pc_latched(pc_latched),
                    .rd_reg(),
                    .rs2_reg(),
                    .instrset_latched(instruction_set)
    );

    initial begin
        $dumpfile("./priRV32_tb.vcd");
        $dumpvars(0, priRV32_tb);
        rst_n = 1'b1;
        clk = 1'b0;
        #2
        rst_n = 0;
        #3
        rst_n = 1;
        
        #50
		$stop;
    end

    always
        #1 clk = ~clk;

endmodule
