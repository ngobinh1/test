`timescale 1ns/1ps

module tb_fetch_cycle();
    reg clk;
    reg rst;
    reg en;
    reg pc_src_e;
    reg [31:0] pc_target_e;
    reg is_ecall;
    reg is_mret;
    reg [31:0] trap_vec;
    reg [31:0] epc;

    wire [31:0] instr_f;
    wire [31:0] pc_f;
    wire [31:0] pc_plus_4_f;

    // Instantiate the Unit Under Test (UUT)
    fetch_cycle dut (
        .clk(clk), .rst(rst), .en(en),
        .pc_src_e(pc_src_e), .pc_target_e(pc_target_e),
        .is_ecall(is_ecall), .is_mret(is_mret),      // THÊM VÀO ĐÂY
        .trap_vec(trap_vec), .epc(epc),              // THÊM VÀO ĐÂY
        .instr_f(instr_f), .pc_f(pc_f), .pc_plus_4_f(pc_plus_4_f)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 0; en = 1;
        pc_src_e = 0; pc_target_e = 32'h00000000;
        
        // THÊM: Khởi tạo các tín hiệu exception bằng 0
        is_ecall = 0; is_mret = 0;
        trap_vec = 32'h00000000; epc = 32'h00000000;

        $display("\n--- STARTING FETCH CYCLE TEST ---");
        // Release Reset
        #15 rst = 1;

        // TEST 1: Normal PC increment
        #20;
        // Wait for a few clock cycles
        if (pc_f === 32'h00000008) $display("[PASS] Test 1: Normal PC increment (PC = 0x%0h)", pc_f);
        else $display("[FAIL] Test 1: Expected PC = 0x00000008, Got 0x%0h", pc_f);

        // TEST 2: Branching / Jumping (Simulate branch taken to 0x20)
        pc_src_e = 1;
        pc_target_e = 32'h00000020;
        #10;
        if (pc_f === 32'h00000020) $display("[PASS] Test 2: Branch taken (PC = 0x%0h)", pc_f);
        else $display("[FAIL] Test 2: Expected PC = 0x00000020, Got 0x%0h", pc_f);

        // TEST 3: Return to normal increment from new address
        pc_src_e = 0;
        #10;
        if (pc_f === 32'h00000024) $display("[PASS] Test 3: Increment after branch (PC = 0x%0h)", pc_f);
        else $display("[FAIL] Test 3: Expected PC = 0x00000024, Got 0x%0h", pc_f);

        // TEST 4: Pipeline Stall (en = 0), PC should hold its value
        en = 0;
        #20;
        if (pc_f === 32'h00000024) $display("[PASS] Test 4: Pipeline Stall (PC held at 0x%0h)", pc_f);
        else $display("[FAIL] Test 4: Stall failed. Expected PC = 0x00000024, Got 0x%0h", pc_f);
        
        $display("---------------------------------\n");
        $finish;
    end
endmodule