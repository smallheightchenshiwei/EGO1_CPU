
`timescale 1ns / 1ps

module tb_inst_rom;

    reg [31:0] addr;
    wire [31:0] inst;

    // 实例化指令ROM
    inst_rom uut (
        .addr(addr),
        .inst(inst)
    );

    initial begin

        // 测试第0条指令
        addr = 32'd0;
        #10;
        if (inst !== 32'h02000000)
            $display("错误：第0条指令读取失败");
        else
            $display("通过：第0条指令读取");

        // 测试第1条指令
        addr = 32'd4;
        #10;
        if (inst !== 32'h04000000)
            $display("错误：第1条指令读取失败");
        else
            $display("通过：第1条指令读取");

        // 测试第2条指令
        addr = 32'd8;
        #10;
        if (inst !== 32'h00000000)
            $display("错误：第2条指令读取失败");
        else
            $display("通过：第2条指令读取");

        $display("指令ROM测试结束");
        $finish;
    end

endmodule
