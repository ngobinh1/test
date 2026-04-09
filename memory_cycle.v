module memory_cycle (
    input wire clk, rst,
    input wire mem_write_m,
    input wire [31:0] alu_result_m, write_data_m,
    input wire [2:0] funct3_m,
    output  [31:0] read_data_m
);

    data_memory data_mem (
        .clk(clk),
        .rst(rst),
        .write_en(mem_write_m),
        .addr(alu_result_m),
        .funct3(funct3_m),
        .write_data(write_data_m),
        .read_data(read_data_m)
    );

endmodule
