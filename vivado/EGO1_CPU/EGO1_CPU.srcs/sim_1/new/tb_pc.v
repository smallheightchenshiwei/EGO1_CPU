
`timescale 1ns / 1ps

module tb_pc;

    reg clk;
    reg reset;
    reg stall;
    reg redirect_en;
    reg [31:0] redirect_addr;

    wire [31:0] pc;

    // 实例化PC模块
    pc uut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .redirect_en(redirect_en),
        .redirect_addr(redirect_addr),
        .pc(pc)
    );

    // 产生时钟信号，周期为10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        // 初始化所有输入信号
        reset = 1;
        stall = 0;
        redirect_en = 0;
        redirect_addr = 32'h00000000;

        // 测试1：复位功能
        #10;
        if (pc !== 32'h00000000)
            $display("错误：复位测试失败");
        else
            $display("通过：复位测试");

        reset = 0;

        // 测试2：PC正常加4
        #10;
        if (pc !== 32'h00000004)
            $display("错误：PC加4测试失败");
        else
            $display("通过：PC加4测试");

        // 测试3：流水线暂停
        stall = 1;
        #10;
        if (pc !== 32'h00000004)
            $display("错误：暂停测试失败");
        else
            $display("通过：暂停测试");

        // 测试4：分支跳转
        stall = 0;
        redirect_en = 1;
        redirect_addr = 32'h00000040;
        #10;
        if (pc !== 32'h00000040)
            $display("错误：跳转测试失败");
        else
            $display("通过：跳转测试");

        redirect_en = 0;
        #10;

        $display("PC模块测试结束");
        $finish;
    end

endmodule
