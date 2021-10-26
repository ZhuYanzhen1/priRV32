module priRV32_IFU(input clk_in,
                       input rst_n,
                       output [31:0] pc_addr_o,
                       input [31:0] pc_data_i);
    
    wire is_lb_lh_lw_lbu_lhu, is_slli_srli_srai, is_jalr_addi_slti_sltiu_xori_ori_andi, is_csr_access, is_fence_fencei;
    wire is_sb_sh_sw, is_sll_srl_sra, is_beq_bne_blt_bge_bltu_bgeu, is_alu_reg_imm, is_alu_reg_reg;
    
    wire instr_lui, instr_auipc, instr_jal, instr_jalr;
    wire instr_beq, instr_bne, instr_blt, instr_bge, instr_bltu, instr_bgeu;
    wire instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh, instr_sw;
    wire instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli, instr_srli, instr_srai;
    wire instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor, instr_srl, instr_sra, instr_or, instr_and;
    wire instr_fence, instr_fencei, instr_ecall, instr_ebreak;
    wire instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci;
    
    reg [31:0]decoded_imm_j, decoded_imm;
    reg [4:0]decoded_rs1, decoded_rs2, decoded_rd;
    
    wire [31:0] decoder_datafetch_reg;
    assign decoder_datafetch_reg = pc_data_i;
    
    assign instr_lui                    = decoder_datafetch_reg[6:0] == 7'b0110111;
    assign instr_auipc                  = decoder_datafetch_reg[6:0] == 7'b0010111;
    assign instr_jal                    = decoder_datafetch_reg[6:0] == 7'b1101111;
    assign instr_jalr                   = decoder_datafetch_reg[6:0] == 7'b1100111 && decoder_datafetch_reg[14:12] == 3'b000;
    assign is_beq_bne_blt_bge_bltu_bgeu = decoder_datafetch_reg[6:0] == 7'b1100011;
    assign is_lb_lh_lw_lbu_lhu          = decoder_datafetch_reg[6:0] == 7'b0000011;
    assign is_sb_sh_sw                  = decoder_datafetch_reg[6:0] == 7'b0100011;
    assign is_alu_reg_imm               = decoder_datafetch_reg[6:0] == 7'b0010011;
    assign is_alu_reg_reg               = decoder_datafetch_reg[6:0] == 7'b0110011;
    assign is_csr_access                = decoder_datafetch_reg[6:0] == 7'b1110011;
    assign is_fence_fencei              = decoder_datafetch_reg[6:0] == 7'b0001111;
    
    assign instr_beq  = is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b000;
    assign instr_bne  = is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b001;
    assign instr_blt  = is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b100;
    assign instr_bge  = is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b101;
    assign instr_bltu = is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b110;
    assign instr_bgeu = is_beq_bne_blt_bge_bltu_bgeu && decoder_datafetch_reg[14:12] == 3'b111;
    
    assign instr_lb  = is_lb_lh_lw_lbu_lhu && decoder_datafetch_reg[14:12] == 3'b000;
    assign instr_lh  = is_lb_lh_lw_lbu_lhu && decoder_datafetch_reg[14:12] == 3'b001;
    assign instr_lw  = is_lb_lh_lw_lbu_lhu && decoder_datafetch_reg[14:12] == 3'b010;
    assign instr_lbu = is_lb_lh_lw_lbu_lhu && decoder_datafetch_reg[14:12] == 3'b100;
    assign instr_lhu = is_lb_lh_lw_lbu_lhu && decoder_datafetch_reg[14:12] == 3'b101;
    
    assign instr_sb = is_sb_sh_sw && decoder_datafetch_reg[14:12] == 3'b000;
    assign instr_sh = is_sb_sh_sw && decoder_datafetch_reg[14:12] == 3'b001;
    assign instr_sw = is_sb_sh_sw && decoder_datafetch_reg[14:12] == 3'b010;
    
    assign instr_addi  = is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b000;
    assign instr_slti  = is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b010;
    assign instr_sltiu = is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b011;
    assign instr_xori  = is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b100;
    assign instr_ori   = is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b110;
    assign instr_andi  = is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b111;
    
    assign instr_slli = is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b001 && decoder_datafetch_reg[31:25] == 7'b0000000;
    assign instr_srli = is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b101 && decoder_datafetch_reg[31:25] == 7'b0000000;
    assign instr_srai = is_alu_reg_imm && decoder_datafetch_reg[14:12] == 3'b101 && decoder_datafetch_reg[31:25] == 7'b0100000;
    
    assign instr_add  = is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b000 && decoder_datafetch_reg[31:25] == 7'b0000000;
    assign instr_sub  = is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b000 && decoder_datafetch_reg[31:25] == 7'b0100000;
    assign instr_sll  = is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b001 && decoder_datafetch_reg[31:25] == 7'b0000000;
    assign instr_slt  = is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b010 && decoder_datafetch_reg[31:25] == 7'b0000000;
    assign instr_sltu = is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b011 && decoder_datafetch_reg[31:25] == 7'b0000000;
    assign instr_xor  = is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b100 && decoder_datafetch_reg[31:25] == 7'b0000000;
    assign instr_srl  = is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b101 && decoder_datafetch_reg[31:25] == 7'b0000000;
    assign instr_sra  = is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b101 && decoder_datafetch_reg[31:25] == 7'b0100000;
    assign instr_or   = is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b110 && decoder_datafetch_reg[31:25] == 7'b0000000;
    assign instr_and  = is_alu_reg_reg && decoder_datafetch_reg[14:12] == 3'b111 && decoder_datafetch_reg[31:25] == 7'b0000000;
    
    assign instr_ecall  = decoder_datafetch_reg == 32'b00000000000000000000000001110011;
    assign instr_ebreak = decoder_datafetch_reg == 32'b00000000000100000000000001110011;
    
    assign instr_fence  = is_fence_fencei && decoder_datafetch_reg[14:12] == 3'b000;
    assign instr_fencei = is_fence_fencei && decoder_datafetch_reg[14:12] == 3'b001;
    
    assign instr_csrrw  = is_csr_access && decoder_datafetch_reg[14:12] == 3'b001;
    assign instr_csrrs  = is_csr_access && decoder_datafetch_reg[14:12] == 3'b010;
    assign instr_csrrc  = is_csr_access && decoder_datafetch_reg[14:12] == 3'b011;
    assign instr_csrrwi = is_csr_access && decoder_datafetch_reg[14:12] == 3'b101;
    assign instr_csrrsi = is_csr_access && decoder_datafetch_reg[14:12] == 3'b110;
    assign instr_csrrci = is_csr_access && decoder_datafetch_reg[14:12] == 3'b111;
    
    always @(*) begin
        { decoded_imm_j[31:20], decoded_imm_j[10:1], decoded_imm_j[11], decoded_imm_j[19:12], decoded_imm_j[0] }
 		<= $signed({decoder_datafetch_reg[31:12], 1'b0});
        
        decoded_rd  <= decoder_datafetch_reg[11:7];
        decoded_rs1 <= decoder_datafetch_reg[19:15];
        decoded_rs2 <= decoder_datafetch_reg[24:20];
        
        case (1'b1)
            instr_jal:
            decoded_imm <= decoded_imm_j;
            |{instr_lui, instr_auipc}:
            decoded_imm <= decoder_datafetch_reg[31:12] << 12;
            |{instr_jalr, is_lb_lh_lw_lbu_lhu, is_alu_reg_imm, instr_fencei}:
            decoded_imm <= $signed(decoder_datafetch_reg[31:20]);
            is_beq_bne_blt_bge_bltu_bgeu:
            decoded_imm <= $signed({decoder_datafetch_reg[31], decoder_datafetch_reg[7],
            decoder_datafetch_reg[30:25], decoder_datafetch_reg[11:8], 1'b0});
            is_sb_sh_sw:
            decoded_imm <= $signed({decoder_datafetch_reg[31:25], decoder_datafetch_reg[11:7]});
            default:
            decoded_imm <= 1'bx;
        endcase
    end
    
endmodule
