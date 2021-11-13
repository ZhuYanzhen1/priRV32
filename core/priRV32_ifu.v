module priRV32_IFU ( 
    input clk_i,
    input rst_n,
    output reg branch_result_o,
    input exu_branch_result_i,
    output [31:0] pc_addr_o,
    input [31:0] pc_data_i,
    input [31:0] pc_addr_i,
    output reg [31:0] imm_latched,
    output reg [4:0] rs1_latched,
    output reg [4:0] rs2_latched,
    output reg [4:0] rd_latched
);
    
    localparam STRONG_TOKEN = 2'b00;
    localparam WEAK_TOKEN = 2'b01;
    localparam WEAK_NOTOKEN = 2'b10;
    localparam STRONG_NOTOKEN = 2'b11;

    output wire instr_lui, instr_auipc, instr_jal, instr_jalr;
    output wire instr_beq, instr_bne, instr_blt, instr_bge, instr_bltu, instr_bgeu;
    output wire instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb, instr_sh, instr_sw;
    output wire instr_addi, instr_slti, instr_sltiu, instr_xori, instr_ori, instr_andi, instr_slli, instr_srli, instr_srai;
    output wire instr_add, instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor, instr_srl, instr_sra, instr_or, instr_and;
    output wire instr_fence, instr_fencei, instr_ecall, instr_ebreak;
    output wire instr_csrrw, instr_csrrs, instr_csrrc, instr_csrrwi, instr_csrrsi, instr_csrrci;
    
    wire is_lb_lh_lw_lbu_lhu, is_slli_srli_srai, is_jalr_addi_slti_sltiu_xori_ori_andi, is_csr_access, is_fence_fencei;
    wire is_sb_sh_sw, is_sll_srl_sra, is_beq_bne_blt_bge_bltu_bgeu, is_alu_reg_imm, is_alu_reg_reg;
    
    reg [31:0]decoded_imm_j, decoded_imm;
    reg [4:0]decoded_rs1, decoded_rs2, decoded_rd;
    reg [1:0]two_bit_saturation_counter;
    reg [31:0] pc_addr_predict;
    reg branch_result, is_last_branch_instr;

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
    
    //   * JAL: The target address of JAL is calculated based on current PC value
    //          and offset, and JAL is unconditionally always jump
    //   * JALR with rs1 == x0: The target address of JALR is calculated based on
    //          x0+offset, and JALR is unconditionally always jump
    //   * JALR with rs1 != x0: The target address of JALR need to be resolved
    //          at EXU stage, hence have to be forced halted, wait the EXU to be
    //          empty and then read the regfile to grab the value of xN.
    //          This will exert 1 cycle performance lost for JALR instruction
    //   * Bxxx: Conditional branch is always predicted as taken if it is backward
    //          jump, and not-taken if it is forward jump. The target address of JAL
    //          is calculated based on current PC value and offset

    assign pc_addr_o = pc_addr_predict;
    always @(*) begin
        case (1'b1)
            instr_jal:
                pc_addr_predict <= pc_addr_i + decoded_imm;
            is_beq_bne_blt_bge_bltu_bgeu: begin
                case (1'b1)
                    |{two_bit_saturation_counter == STRONG_TOKEN, two_bit_saturation_counter == WEAK_TOKEN}:
                        pc_addr_predict <= pc_addr_i + decoded_imm;
                    |{two_bit_saturation_counter == STRONG_NOTOKEN, two_bit_saturation_counter == WEAK_NOTOKEN}:
                        pc_addr_predict <= pc_addr_i + 32'd4;
                endcase
            end
            default:
                pc_addr_predict <= pc_addr_i + 32'd4;
        endcase
    end

    always @(*) begin
        case (two_bit_saturation_counter)
            STRONG_TOKEN:
                branch_result = 1;
            WEAK_TOKEN: 
                branch_result = 1;
            STRONG_NOTOKEN:
                branch_result = 0;
            WEAK_NOTOKEN:
                branch_result = 0;
        endcase
    end

    always @(negedge clk_i or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            two_bit_saturation_counter <= 2'b00;
            is_last_branch_instr <= 1'b0;
        end else begin
            if (is_last_branch_instr == 1'b1) begin
                is_last_branch_instr <= 1'b0;
                if (exu_branch_result_i == 1'b0) begin
                    case (two_bit_saturation_counter)
                        STRONG_TOKEN:
                            two_bit_saturation_counter <= WEAK_TOKEN;
                        WEAK_TOKEN:
                            two_bit_saturation_counter <= WEAK_NOTOKEN;
                        default:
                            two_bit_saturation_counter <= STRONG_NOTOKEN;
                    endcase
                end else begin
                    case (two_bit_saturation_counter)
                        STRONG_NOTOKEN:
                            two_bit_saturation_counter <= WEAK_NOTOKEN;
                        WEAK_NOTOKEN:
                            two_bit_saturation_counter <= WEAK_TOKEN;
                        default:
                            two_bit_saturation_counter <= STRONG_TOKEN;
                    endcase
                end
            end else if(is_beq_bne_blt_bge_bltu_bgeu == 1'b1) begin
                is_last_branch_instr <= 1'b1;
            end else begin
                is_last_branch_instr <= is_last_branch_instr;
            end
        end
    end

    always @(negedge clk_i or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            imm_latched <= 32'h00000000;
            rs1_latched <= 5'b00000;
            rs2_latched <= 5'b00000;
            rd_latched  <= 5'b00000;
        end else begin
            imm_latched <= decoded_imm;
            rs1_latched <= decoded_rs1;
            rs2_latched <= decoded_rs2;
            rd_latched  <= decoded_rd;
            branch_result_o <= branch_result;
        end
    end

endmodule
