module single_cycle_cpu (
    input clk,
    input reset,

    output [31:0] debug_pc,
    output [31:0] debug_inst
);

    // 当前PC地址
    wire [31:0] current_pc;

    // 当前指令
    wire [31:0] current_inst;

    // PC模块
    pc u_pc (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .redirect_en(1'b0),
        .redirect_addr(32'b0),
        .pc(current_pc)
    );

    // 指令ROM模块
    inst_rom u_inst_rom (
        .addr(current_pc),
        .inst(current_inst)
    );

    // 调试输出
    assign debug_pc = current_pc;
    assign debug_inst = current_inst;

endmodule