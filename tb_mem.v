`timescale 1ns/1ps

module tb_memory_cycle();
    reg clk, rst, mem_write_m;
    
    reg [2:0] funct3_m; 
    reg [31:0] alu_result_m, write_data_m;

    wire [31:0] read_data_m;

    memory_cycle dut (
        .clk(clk), .rst(rst),
        .mem_write_m(mem_write_m), 
        .funct3_m(funct3_m), // THÊM VÀO DUT
        .alu_result_m(alu_result_m),
        .write_data_m(write_data_m), .read_data_m(read_data_m)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 0;
        mem_write_m = 0;
        alu_result_m = 0; write_data_m = 0;
        
        funct3_m = 3'b010; 

        $display("\n--- STARTING MEMORY CYCLE TEST ---");
        #15 rst = 1;

        // TEST 1: Write data 0xDEADBEEF to address 0x00000020
        mem_write_m = 1'b1;
        alu_result_m = 32'h00000020;
        write_data_m = 32'hDEADBEEF;
        #10;
        $display("[INFO] Wrote 0xDEADBEEF to address 0x20");

        // TEST 2: Read data from the same address 0x00000020
        mem_write_m = 1'b0;
        // Disable write
        #10;
        if (read_data_m === 32'hDEADBEEF) $display("[PASS] Test 2: Read memory correctly (Data = 0x%0h)", read_data_m);
        else $display("[FAIL] Test 2: Expected 0xDEADBEEF, Got 0x%0h", read_data_m);

        // TEST 3: Read data from an unwritten address 0x00000040
        alu_result_m = 32'h00000040;
        #10;
        if (read_data_m === 32'h00000000) $display("[PASS] Test 3: Read empty memory correctly (Data = 0x00000000)");
        else $display("[FAIL] Test 3: Expected 0x00000000, Got 0x%0h", read_data_m);

        $display("----------------------------------\n");
        $finish;
    end
endmodule