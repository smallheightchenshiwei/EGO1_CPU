
`timescale 1ns / 1ps

module tb_data_ram;

    reg clk;
    reg we;
    reg [31:0] addr;
    reg [31:0] wdata;
    wire [31:0] rdata;

    integer pass_count;
    integer fail_count;

    // 实例化数据存储器
    data_ram uut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    // 产生时钟信号，周期为10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 检查读取结果
    task check_result;
        input [31:0] expected;
        begin
            #1;
            if (rdata === expected) begin
                $display("PASS: addr=%h data=%h", addr, rdata);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: addr=%h expected=%h actual=%h",
                         addr, expected, rdata);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        we = 0;
        addr = 0;
        wdata = 0;

        // 测试1：向地址0写入数据
        @(negedge clk);
        addr = 32'h00000000;
        wdata = 32'h12345678;
        we = 1;
        @(posedge clk);
        #1;
        we = 0;
        check_result(32'h12345678);

        // 测试2：向地址4写入数据
        @(negedge clk);
        addr = 32'h00000004;
        wdata = 32'hABCDEF01;
        we = 1;
        @(posedge clk);
        #1;
        we = 0;
        check_result(32'hABCDEF01);

        // 测试3：向地址8写入数据
        @(negedge clk);
        addr = 32'h00000008;
        wdata = 32'h87654321;
        we = 1;
        @(posedge clk);
        #1;
        we = 0;
        check_result(32'h87654321);

        // 测试4：重新读取地址0
        @(negedge clk);
        addr = 32'h00000000;
        check_result(32'h12345678);

        // 测试5：重新读取地址4
        @(negedge clk);
        addr = 32'h00000004;
        check_result(32'hABCDEF01);

        // 测试6：重新读取地址8
        @(negedge clk);
        addr = 32'h00000008;
        check_result(32'h87654321);

        // 测试7：关闭写使能，确认原数据不变
        @(negedge clk);
        addr = 32'h00000000;
        wdata = 32'hFFFFFFFF;
        we = 0;
        @(posedge clk);
        check_result(32'h12345678);

        // 输出测试统计
        #10;
        $display("--------------------------------");
        $display("DATA RAM TEST FINISHED");
        $display("PASS: %d", pass_count);
        $display("FAIL: %d", fail_count);
        $display("--------------------------------");

        $finish;
    end

endmodule
