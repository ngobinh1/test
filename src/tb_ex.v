`timescale 1ns/1ps

module tb_execute_cycle();
    reg [1:0] forward_a_e, forward_b_e;
    reg jump_e, branch_e, alu_src_e, jalr_e;
    reg [2:0] funct3_e;
    reg [3:0] alu_control_e;
    reg [31:0] alu_result_m, read_data_1_e, read_data_2_e, imm_ext_e, pc_e, pc_plus_4_e, result_w;
    reg [4:0] rd_e;

    wire [31:0] pc_target_e, alu_result_e, write_data_e;
    wire pc_src_e;

    execute_cycle dut (
        .forward_a_e(forward_a_e), .forward_b_e(forward_b_e), 
        .jump_e(jump_e), .branch_e(branch_e), .alu_src_e(alu_src_e), .jalr_e(jalr_e),
        .funct3_e(funct3_e), .alu_control_e(alu_control_e),
        .alu_result_m(alu_result_m), .read_data_1_e(read_data_1_e), .read_data_2_e(read_data_2_e), 
        .imm_ext_e(imm_ext_e), .pc_e(pc_e), .pc_plus_4_e(pc_plus_4_e), .result_w(result_w),
        .rd_e(rd_e), 
        .pc_target_e(pc_target_e), .alu_result_e(alu_result_e), .write_data_e(write_data_e), 
        .pc_src_e(pc_src_e)
    );

    initial begin
        // Initialize default values
        forward_a_e = 0; forward_b_e = 0;
        jump_e = 0; branch_e = 0; alu_src_e = 0; jalr_e = 0;
        funct3_e = 0; alu_control_e = 0;
        alu_result_m = 0; result_w = 0; pc_e = 0; pc_plus_4_e = 4;
        read_data_1_e = 32'd10; read_data_2_e = 32'd20; imm_ext_e = 32'd50;

        $display("\n--- STARTING EXECUTE CYCLE TEST ---");

        // TEST 1: Normal ADD operation (10 + 20)
        alu_control_e = 4'b0000; // ADD
        #10;
        if (alu_result_e === 32'd30) $display("[PASS] Test 1: Normal ADD (Result = 30)");
        else $display("[FAIL] Test 1: Expected 30, Got %0d", alu_result_e);

        // TEST 2: ADD with Immediate (10 + 50)
        alu_src_e = 1'b1; 
        #10; 
        if (alu_result_e === 32'd60) $display("[PASS] Test 2: Immediate ADD (Result = 60)");
        else $display("[FAIL] Test 2: Expected 60, Got %0d", alu_result_e);

        // TEST 3: Data Forwarding from Memory Stage
        alu_src_e = 1'b0;
        forward_a_e = 2'b10; // Select ALU source A from alu_result_m
        alu_result_m = 32'd100;
        #10; 
        if (alu_result_e === 32'd120) $display("[PASS] Test 3: Forwarding from MEM (100 + 20 = 120)");
        else $display("[FAIL] Test 3: Forwarding failed. Expected 120, Got %0d", alu_result_e);

        // TEST 4: Branch Condition (BEQ) evaluation
        forward_a_e = 2'b00; 
        read_data_1_e = 32'd15; read_data_2_e = 32'd15; // Equal values
        branch_e = 1'b1; 
        funct3_e = 3'b000; // BEQ
        alu_control_e = 4'b0001; // SUB operation is required for branch comparison
        #10;
        if (pc_src_e === 1'b1) $display("[PASS] Test 4: Branch Equal (BEQ) taken correctly.");
        else $display("[FAIL] Test 4: BEQ failed to take branch.");

        $display("-----------------------------------\n");
        $finish;
    end
endmodule