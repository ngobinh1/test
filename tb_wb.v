`timescale 1ns/1ps

module tb_writeback_cycle();
    reg [2:0] result_src_w; 
    
    reg [31:0] alu_result_w, read_data_w, pc_plus_4_w, csr_rd_w; 

    wire [31:0] result_w;

    writeback_cycle dut (
        .result_src_w(result_src_w),
        .alu_result_w(alu_result_w),
        .read_data_w(read_data_w),
        .pc_plus_4_w(pc_plus_4_w),
        .csr_rd_w(csr_rd_w), // THÊM VÀO DUT
        .result_w(result_w)
    );

    initial begin
        // Setup dummy values
        alu_result_w = 32'hAAAAAAAA; // Data from ALU
        read_data_w  = 32'hBBBBBBBB; // Data from Memory
        pc_plus_4_w  = 32'hCCCCCCCC; // Data from PC+4 (for JAL/JALR)
        csr_rd_w     = 32'hDDDDDDDD; // Data from CSR

        $display("\n--- STARTING WRITEBACK CYCLE TEST ---");

        // TEST 1: Select result from ALU (result_src_w = 000)
        result_src_w = 3'b000;
        #10;
        if (result_w === 32'hAAAAAAAA) $display("[PASS] Test 1: Selected ALU Result correctly.");
        else $display("[FAIL] Test 1: Expected 0xAAAAAAAA, Got 0x%0h", result_w);

        // TEST 2: Select result from Memory (result_src_w = 001)
        result_src_w = 3'b001;
        #10;
        if (result_w === 32'hBBBBBBBB) $display("[PASS] Test 2: Selected Memory Data correctly.");
        else $display("[FAIL] Test 2: Expected 0xBBBBBBBB, Got 0x%0h", result_w);

        // TEST 3: Select result from PC+4 (result_src_w = 010)
        result_src_w = 3'b010;
        #10;
        if (result_w === 32'hCCCCCCCC) $display("[PASS] Test 3: Selected PC+4 Data correctly.");
        else $display("[FAIL] Test 3: Expected 0xCCCCCCCC, Got 0x%0h", result_w);

        // TEST 4: Select result from CSR (result_src_w = 011)
        result_src_w = 3'b011;
        #10;
        if (result_w === 32'hDDDDDDDD) $display("[PASS] Test 4: Selected CSR Data correctly.");
        else $display("[FAIL] Test 4: Expected 0xDDDDDDDD, Got 0x%0h", result_w);

        $display("-------------------------------------\n");
        $finish;
    end
endmodule