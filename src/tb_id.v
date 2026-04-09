`timescale 1ns/1ps

module tb_decode_cycle();
    reg clk, rst, reg_write_w;
    reg [4:0] rd_w;
    reg [31:0] instr_d, result_w, pc_in, pc_plus_4_in;

    wire [31:0] imm_ext_d, read_data_1_d, read_data_2_d;
    wire [4:0] rs1_d, rs2_d, rd_d;
    wire reg_write_d, mem_write_d, jump_d, branch_d, alu_src_d, jalr_d;
    wire [2:0] funct3_d;
    
    wire [2:0] result_src_d; 
    wire [3:0] alu_control_d;
    
    wire csr_we_d, is_ecall_d, is_mret_d;

    decode_cycle dut (
        .clk(clk), .rst(rst), .reg_write_w(reg_write_w), .rd_w(rd_w),
        .instr_d(instr_d), .result_w(result_w), .pc_in(pc_in), .pc_plus_4_in(pc_plus_4_in),
        .imm_ext_d(imm_ext_d), .read_data_1_d(read_data_1_d), .read_data_2_d(read_data_2_d),
        .rs1_d(rs1_d), .rs2_d(rs2_d), .rd_d(rd_d),
        .reg_write_d(reg_write_d), .mem_write_d(mem_write_d), .jump_d(jump_d),
        .branch_d(branch_d), .alu_src_d(alu_src_d), .jalr_d(jalr_d), .funct3_d(funct3_d),
        .result_src_d(result_src_d), .alu_control_d(alu_control_d),
        .csr_we_d(csr_we_d), .is_ecall_d(is_ecall_d), .is_mret_d(is_mret_d) 
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 0;
        reg_write_w = 0; rd_w = 0; result_w = 0;
        instr_d = 0; pc_in = 0; pc_plus_4_in = 4;

        $display("\n--- STARTING DECODE CYCLE TEST ---");
        #15 rst = 1;

        // PREPARATION: Write dummy data into registers x1 and x2
        reg_write_w = 1;
        rd_w = 5'd1; result_w = 32'd15; #10; // x1 = 15
        
        reg_write_w = 1;
        rd_w = 5'd2; result_w = 32'd25; #10; // x2 = 25
        reg_write_w = 0;

        // TEST 1: Decode R-type instruction (add x3, x1, x2 -> 0x002081b3)
        instr_d = 32'h002081b3;
        #10;
        if (rs1_d === 5'd1 && rs2_d === 5'd2 && read_data_1_d === 32'd15 && read_data_2_d === 32'd25 && alu_control_d === 4'b0000)
            $display("[PASS] Test 1: R-type ADD decoded correctly.");
        else 
            $display("[FAIL] Test 1: R-type decoding failed.");

        // TEST 2: Decode I-type instruction (addi x4, x1, -10 -> 0xff608213)
        instr_d = 32'hff608213;
        #10;
        if (alu_src_d === 1'b1 && imm_ext_d === 32'hFFFFFFF6) // -10 in 2's complement
            $display("[PASS] Test 2: I-type ADDI decoded correctly (Imm = -10).");
        else 
            $display("[FAIL] Test 2: I-type decoding failed. Imm = 0x%0h", imm_ext_d);

        $display("----------------------------------\n");
        $finish;
    end
endmodule