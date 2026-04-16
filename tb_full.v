`timescale 1ns/1ps

module tb_riscv_pipeline_mega();
    reg clk;
    reg rst;

    riscv_pipeline_top dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    // Monitor additional registers for easier debugging
    wire [31:0] reg_x3  = dut.decode_stage.register_file.register_array[3];
    wire [31:0] reg_x4  = dut.decode_stage.register_file.register_array[4];
    wire [31:0] reg_x7  = dut.decode_stage.register_file.register_array[7];
    wire [31:0] reg_x8  = dut.decode_stage.register_file.register_array[8];
    wire [31:0] reg_x22 = dut.decode_stage.register_file.register_array[22];
    wire [31:0] reg_x25 = dut.decode_stage.register_file.register_array[25];
    wire [31:0] reg_x26 = dut.decode_stage.register_file.register_array[26];
    wire [31:0] reg_x29 = dut.decode_stage.register_file.register_array[29];
    wire [31:0] reg_x31 = dut.decode_stage.register_file.register_array[31];

    integer cycle = 0; // Biến đếm chu kỳ clock

    initial begin
        clk = 0; rst = 0;
        $readmemh("full_test.hex", dut.fetch_stage.instruction_memory.mem);
        
        #20 rst = 1;

        $display("\n========================================================");
        $display("   [MEGA TEST DEBUG] PIPELINE CYCLE-BY-CYCLE TRACE");
        $display("========================================================");
        
        // Chờ 400 chu kỳ clock (4000ns) để chương trình chạy
        #4000;

        $display("\n========================================================");
        $display("   [MEGA TEST DEBUG] DETAILED VALUES OF EACH REGISTER");
        $display("========================================================");
        
        $display("\n--- 1. ALU COMPUTATION STAGE (Test Data Hazard) ---");
        $display("x3  (addi -10) : %0d \t(Hex: %h)", $signed(reg_x3), reg_x3);
        $display("x4  (xori)     : %0d \t(Hex: %h)", $signed(reg_x4), reg_x4);
        $display("x7  (add)      : %0d \t(Hex: %h)", $signed(reg_x7), reg_x7);
        $display("x8  (sub)      : %0d \t(Hex: %h) -> Should be 3", $signed(reg_x8), reg_x8);

        $display("\n--- 2. COMPARISON (Test SLT signed/unsigned) ---");
        $display("x22 (slt x3,x8): %0d \t(Hex: %h) -> Should be 1", reg_x22, reg_x22);

        $display("\n--- 3. MEMORY ACCESS (Test Load-Use Stall) ---");
        $display("x25 (lw)       : %0d \t(Hex: %h)", $signed(reg_x25), reg_x25);
        $display("x26 (add x25,0): %0d \t(Hex: %h) -> Should be 3", $signed(reg_x26), reg_x26);
        $display("x29 (lb x7)    : %0d \t(Hex: %h) -> Should be ffffffef", $signed(reg_x29), reg_x29);

        $display("\n========================================================");
        $display("                   OVERALL CONCLUSION                   ");
        $display("========================================================");
        
        // Update with ACCURATE EXPECTED parameters
        $display("1. Data Hazard & ALU: %s (Expected x8 = 3)", (reg_x8 == 3) ? "PASS" : "FAIL");
        $display("2. Set Less Than    : %s (Expected x22 = 1)", (reg_x22 == 1) ? "PASS" : "FAIL");
        $display("3. Load-Use Stall   : %s (Expected x26 = 3)", (reg_x26 == 3) ? "PASS" : "FAIL");
        $display("4. Memory Access    : %s (Expected x29 = ffffffef)", (reg_x29 == 32'hFFFFFFEF) ? "PASS" : "FAIL");
        
        $display("\n--- CONTROL HAZARD SUMMARY (BRANCH/JUMP) ---");
        if (reg_x31 === 32'd1) begin
            $display(">> [PERFECT PASS] Pipeline bypassed all Traps!");
        end else if ($signed(reg_x31) < 0) begin
            $display(">> [FAIL] CPU fell into TRAP number: %0d", reg_x31);
        end else begin
            $display(">> [FAIL] System hang. x31 = %h", reg_x31);
        end

        $display("========================================================\n");
        $finish;
    end

    // =========================================================================
    // KHỐI THEO DÕI PIPELINE TẠI MỖI CHU KỲ (Chạy ở cạnh xuống của clock)
    // =========================================================================
    always @(negedge clk) begin
        if (rst == 1'b1) begin
            cycle = cycle + 1;
            $display("\n--- Cycle %0d ---", cycle);
            
            // 1. Fetch Stage
            $display("  [IF]  PC = %h | Instr = %h %s", 
                dut.pc_f, dut.instr_f, 
                dut.stall_f ? ">>> [STALL]" : "");
                
            // 2. Decode Stage
            $display("  [ID]  PC = %h | Instr = %h | rs1=x%0d, rs2=x%0d, rd=x%0d %s%s", 
                dut.pc_d, dut.instr_d, dut.rs1_d, dut.rs2_d, dut.rd_d, 
                dut.stall_d ? ">>> [STALL]" : "", 
                dut.flush_d ? ">>> [FLUSH]" : "");
                
            // 3. Execute Stage
            $display("  [EX]  PC = %h | ALU_Out = %h | rd=x%0d %s", 
                dut.pc_e, dut.alu_result_e, dut.rd_e, 
                dut.flush_e ? ">>> [FLUSH]" : "");
                
            // 4. Memory Stage
            $display("  [MEM] ALU_Out/Addr = %h | WriteData = %h | ReadData = %h | rd=x%0d | MemWr=%b", 
                dut.alu_result_m, dut.write_data_m, dut.read_data_m, dut.rd_m, dut.mem_write_m);
                
            // 5. Writeback Stage
            $display("  [WB]  Result = %h | rd=x%0d | RegWr=%b", 
                dut.result_w, dut.rd_w, dut.reg_write_w);
        end
    end

endmodule