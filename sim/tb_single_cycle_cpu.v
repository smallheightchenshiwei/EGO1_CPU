`timescale 1ns / 1ps

module tb_single_cycle_cpu;

    reg clk;
    reg reset;

    wire [31:0] debug_pc;
    wire [31:0] debug_inst;

    // 实例化单周期CPU
    single_cycle_cpu uut (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_inst(debug_inst)
    );

    // 时钟产生
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // 复位及仿真控制
    initial begin
        reset = 1'b1;
        #20;
        reset = 1'b0;

        #80;
        $finish;
    end

    // 观察PC和指令
    initial begin
        $monitor("time=%0t reset=%b PC=%h INST=%h",
                 $time, reset, debug_pc, debug_inst);
    end

endmodule