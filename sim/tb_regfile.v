
`timescale 1ns / 1ps

module tb_regfile;

    reg clk;
    reg reset;
    reg we;

    reg [4:0] waddr;
    reg [31:0] wdata;

    reg [4:0] raddr1;
    reg [4:0] raddr2;

    wire [31:0] rdata1;
    wire [31:0] rdata2;

    // 实例化寄存器堆
    regfile uut (
        .clk(clk),
        .reset(reset),
        .we(we),
        .waddr(waddr),
        .wdata(wdata),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    // 产生周期为10ns的时钟
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        // 初始化输入信号
        reset = 1;
        we = 0;
        waddr = 0;
        wdata = 0;
        raddr1 = 0;
        raddr2 = 0;

        // 测试1：复位功能
        #10;
        reset = 0;
        raddr1 = 1;
        raddr2 = 2;
        #1;

        if (rdata1 !== 32'd0 || rdata2 !== 32'd0)
            $display("错误：寄存器复位测试失败");
        else
            $display("通过：寄存器复位测试");

        // 测试2：向寄存器1写入数据
        @(negedge clk);
        we = 1;
        waddr = 1;
        wdata = 32'h12345678;

        @(posedge clk);
        #1;
        we = 0;
        raddr1 = 1;

        if (rdata1 !== 32'h12345678)
            $display("错误：寄存器1写入测试失败");
        else
            $display("通过：寄存器1写入测试");

        // 测试3：向寄存器2写入数据
        @(negedge clk);
        we = 1;
        waddr = 2;
        wdata = 32'hABCDEF01;

        @(posedge clk);
        #1;
        we = 0;
        raddr1 = 1;
        raddr2 = 2;

        if (rdata1 !== 32'h12345678 ||
            rdata2 !== 32'hABCDEF01)
            $display("错误：双端口读取测试失败");
        else
            $display("通过：双端口读取测试");
        // 测试4：禁止修改0号寄存器
        @(negedge clk);
        we = 1'b1;
        waddr = 5'd0;
        wdata = 32'hFFFFFFFF;

        // 等待时钟上升沿，尝试写入r0
        @(posedge clk);

        // 在下一个下降沿关闭写使能
        @(negedge clk);
        we = 1'b0;

        // 读取r0
        raddr1 = 5'd0;
        #1;

        if (rdata1 !== 32'h00000000)
           $display("错误：0号寄存器保护测试失败，读出数据=%h", rdata1);
        else
           $display("通过：0号寄存器保护测试");

        // 测试结束
        $display("寄存器堆测试结束");
        $finish;
    end

endmodule
