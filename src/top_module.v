module riscv_pipeline_top (
    input wire clk,
    input wire rst
);

    // Fetch stage signals
    wire [31:0] pc_f, pc_plus_4_f, instr_f, pc_target_e;
    wire pc_src_e, stall_f;

    // Decode stage signals
    wire [31:0] instr_d, pc_d, pc_plus_4_d;
    wire [31:0] read_data_1_d, read_data_2_d, imm_ext_d;
    wire [4:0] rs1_d, rs2_d, rd_d;
    wire reg_write_d, mem_write_d, jump_d, branch_d, alu_src_d, jalr_d;
    wire [2:0] funct3_d;
    wire [2:0] result_src_d;
    wire [3:0] alu_control_d;
    wire stall_d, flush_d;
    wire is_ecall_d, is_mret_d, csr_we_d;
    wire [11:0] csr_addr_d=instr_d[31:20];
    wire [31:0] csr_rd_d;

    // Execute stage signals
    wire [31:0] read_data_1_e, read_data_2_e, imm_ext_e, pc_e, pc_plus_4_e;
    wire [31:0] alu_result_e, write_data_e;
    wire [4:0] rs1_e, rs2_e, rd_e;
    wire reg_write_e, mem_write_e, jump_e, branch_e, alu_src_e, jalr_e;
    wire [2:0] funct3_e;
    wire [2:0] result_src_e;
    wire [1:0] forward_a_e, forward_b_e;
    wire [3:0] alu_control_e;
    wire flush_e;
    wire csr_we_e;
    wire [11:0] csr_addr_e;
    wire [31:0] csr_rd_e, csr_wd_e;

    // Memory stage signals
    wire [31:0] alu_result_m, write_data_m, pc_plus_4_m, read_data_m;
    wire [4:0] rd_m;
    wire [2:0] funct3_m;
    wire reg_write_m, mem_write_m;
    wire [2:0] result_src_m;
    wire csr_we_m;
    wire [11:0] csr_addr_m;
    wire [31:0] csr_rd_m, csr_wd_m;

    // Writeback stage signals
    wire [31:0] alu_result_w, read_data_w, pc_plus_4_w, result_w;
    wire [4:0] rd_w;
    wire reg_write_w;
    wire [2:0] result_src_w;
    wire csr_we_w;
    wire [11:0] csr_addr_w;
    wire [31:0] csr_rd_w, csr_wd_w;

    // Exception PC
    wire [31:0] trap_vec, epc;

    // Enable signal for fetch stage (inverse of stall)
    wire en_f = ~stall_f;
    wire en_d = ~stall_d;

    // Fetch Cycle
    fetch_cycle fetch_stage (
        .clk(clk),
        .rst(rst),
        .en(en_f),
        .pc_src_e(pc_src_e),
        .pc_target_e(pc_target_e),
        .is_ecall(is_ecall_d),
        .is_mret(is_mret_d),
        .trap_vec(trap_vec),
        .epc(epc),
        .instr_f(instr_f),
        .pc_f(pc_f),
        .pc_plus_4_f(pc_plus_4_f)
    );

    // Pipeline Register: Fetch -> Decode
    pipeline_1_2 pipeline_fd (
        .clk(clk),
        .rst(rst),
        .clr(flush_d),
        .en(en_d),
        .instr_f(instr_f),
        .pc_f(pc_f),
        .pc_plus_4_f(pc_plus_4_f),
        .instr_d(instr_d),
        .pc_d(pc_d),
        .pc_plus_4_d(pc_plus_4_d)
    );

    // Decode Cycle
    decode_cycle decode_stage (
        .clk(clk),
        .rst(rst),
        .reg_write_w(reg_write_w),
        .rd_w(rd_w),
        .instr_d(instr_d),
        .result_w(result_w),
        .pc_in(pc_d),
        .pc_plus_4_in(pc_plus_4_d),
        .imm_ext_d(imm_ext_d),
        .read_data_1_d(read_data_1_d),
        .read_data_2_d(read_data_2_d),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .rd_d(rd_d),
        .reg_write_d(reg_write_d),
        .mem_write_d(mem_write_d),
        .jump_d(jump_d),
        .branch_d(branch_d),
        .jalr_d(jalr_d),
        .funct3_d(funct3_d),
        .alu_src_d(alu_src_d),
        .result_src_d(result_src_d),
        .alu_control_d(alu_control_d),
        .is_ecall_d(is_ecall_d),
        .is_mret_d(is_mret_d),
        .csr_we_d(csr_we_d)
    );

    // Pipeline Register: Decode -> Execute
    pipeline_2_3 pipeline_de (
        .clk(clk),
        .rst(rst),
        .clr(flush_e),
        .reg_write_d(reg_write_d),
        .mem_write_d(mem_write_d),
        .alu_src_d(alu_src_d),
        .jump_d(jump_d),
        .branch_d(branch_d),
        .jalr_d(jalr_d),
        .funct3_d(funct3_d),
        .result_src_d(result_src_d),
        .alu_control_d(alu_control_d),
        .read_data_1_d(read_data_1_d),
        .read_data_2_d(read_data_2_d),
        .pc_d(pc_d),
        .pc_plus_4_d(pc_plus_4_d),
        .imm_ext_d(imm_ext_d),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .rd_d(rd_d),
        .csr_we_d(csr_we_d),
        .csr_addr_d(csr_addr_d),
        .csr_rd_d(csr_rd_d),
        .reg_write_e(reg_write_e),
        .mem_write_e(mem_write_e),
        .alu_src_e(alu_src_e),
        .jump_e(jump_e),
        .branch_e(branch_e),
        .jalr_e(jalr_e),
        .funct3_e(funct3_e),
        .result_src_e(result_src_e),
        .alu_control_e(alu_control_e),
        .read_data_1_e(read_data_1_e),
        .read_data_2_e(read_data_2_e),
        .pc_e(pc_e),
        .pc_plus_4_e(pc_plus_4_e),
        .imm_ext_e(imm_ext_e),
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rd_e(rd_e),
        .csr_we_e(csr_we_e),
        .csr_addr_e(csr_addr_e),
        .csr_rd_e(csr_rd_e)
    );

    // MUX for rs1 to CSR
    wire [31:0] src_a_e_forwarded = (forward_a_e == 2'b10) ? alu_result_m :
                                     (forward_a_e == 2'b01) ? result_w :
                                     read_data_1_e;

    csr_alu csr_alu_inst (
        .csr_rd(csr_rd_e),
        .csr_wd(csr_wd_e),
        .imm_ext(imm_ext_e),
        .src_a(src_a_e_forwarded),
        .funct3(funct3_e)
    );

    // Execute Cycle
    execute_cycle execute_stage (
        .forward_a_e(forward_a_e),
        .forward_b_e(forward_b_e),
        .jump_e(jump_e),
        .branch_e(branch_e),
        .jalr_e(jalr_e),
        .funct3_e(funct3_e),
        .alu_src_e(alu_src_e),
        .alu_control_e(alu_control_e),
        .alu_result_m(alu_result_m),
        .read_data_1_e(read_data_1_e),
        .read_data_2_e(read_data_2_e),
        .imm_ext_e(imm_ext_e),
        .pc_e(pc_e),
        .pc_plus_4_e(pc_plus_4_e),
        .result_w(result_w),
        .rd_e(rd_e),
        .pc_target_e(pc_target_e),
        .alu_result_e(alu_result_e),
        .write_data_e(write_data_e),
        .pc_src_e(pc_src_e)
    );

    // Pipeline Register: Execute -> Memory
    pipeline_3_4 pipeline_em (
        .clk(clk),
        .rst(rst),
        .reg_write_e(reg_write_e),
        .mem_write_e(mem_write_e),
        .result_src_e(result_src_e),
        .funct3_e(funct3_e),
        .alu_result_e(alu_result_e),
        .write_data_e(write_data_e),
        .pc_plus_4_e(pc_plus_4_e),
        .rd_e(rd_e),
        .csr_we_e(csr_we_e),
        .csr_addr_e(csr_addr_e),
        .csr_rd_e(csr_rd_e),
         .csr_wd_e(csr_wd_e),
        .reg_write_m(reg_write_m),
        .mem_write_m(mem_write_m),
        .funct3_m(funct3_m),
        .result_src_m(result_src_m),
        .alu_result_m(alu_result_m),
        .write_data_m(write_data_m),
        .pc_plus_4_m(pc_plus_4_m),
        .rd_m(rd_m),
        .csr_we_m(csr_we_m),
        .csr_addr_m(csr_addr_m),
        .csr_rd_m(csr_rd_m),
        .csr_wd_m(csr_wd_m)
    );

    // Memory Cycle
    memory_cycle memory_stage (
        .clk(clk),
        .rst(rst),
        .mem_write_m(mem_write_m),
        .funct3_m(funct3_m),
        .alu_result_m(alu_result_m),
        .write_data_m(write_data_m),
        .read_data_m(read_data_m)
    );

    // Pipeline Register: Memory -> Writeback
    pipeline_4_5 pipeline_mw (
        .clk(clk),
        .rst(rst),
        .reg_write_m(reg_write_m),
        .result_src_m(result_src_m),
        .alu_result_m(alu_result_m),
        .read_data_m(read_data_m),
        .pc_plus_4_m(pc_plus_4_m),
        .rd_m(rd_m),
        .csr_we_m(csr_we_m),
        .csr_addr_m(csr_addr_m),
        .csr_rd_m(csr_rd_m),
        .csr_wd_m(csr_wd_m),
        .reg_write_w(reg_write_w),
        .result_src_w(result_src_w),
        .alu_result_w(alu_result_w),
        .read_data_w(read_data_w),
        .pc_plus_4_w(pc_plus_4_w),
        .rd_w(rd_w),
        .csr_we_w(csr_we_w),
        .csr_addr_w(csr_addr_w),
        .csr_rd_w(csr_rd_w),
        .csr_wd_w(csr_wd_w)
    );

    // csr_file instance
    // csr address is determined in decode stage and passed down to execute, memory, and writeback stages
    wire [11:0] csr_addr_to_file = (csr_we_w) ? csr_addr_w : instr_d[31:20];

    csr_file csr_file_inst (
        .clk(clk),
        .rst(rst),
        .csr_we(csr_we_w),
        .csr_addr(csr_addr_to_file),
        .csr_wd(csr_wd_w),
        .csr_rd(csr_rd_d),
        .is_exception(is_ecall_d),
        .pc(pc_d),
        .cause(32'd11), // ecall from M-mode has cause code 11
        .epc(epc),
        .trap_vec(trap_vec)
    );

    // Writeback Cycle
    writeback_cycle writeback_stage (
        .result_src_w(result_src_w),
        .alu_result_w(alu_result_w),
        .read_data_w(read_data_w),
        .pc_plus_4_w(pc_plus_4_w),
        .csr_rd_w(csr_rd_w),
        .result_w(result_w)
    );

    // Hazard Unit
    hazard_unit hazard_detection (
        .rst(rst),
        .reg_write_w(reg_write_w),
        .reg_write_m(reg_write_m),
        .pc_src_e(pc_src_e),
        .rd_m(rd_m),
        .rd_w(rd_w),
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rd_e(rd_e),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .result_src_e(result_src_e),
        .forward_a_e(forward_a_e),
        .forward_b_e(forward_b_e),
        .stall_f(stall_f),
        .stall_d(stall_d),
        .flush_e(flush_e),
        .flush_d(flush_d)
    );

endmodule


