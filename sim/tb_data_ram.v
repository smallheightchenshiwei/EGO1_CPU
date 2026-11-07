
`timescale 1ns / 1ps

module tb_data_ram;

    reg clk;
    reg we;
    reg [31:0] addr;
    reg [31:0] wdata;
    wire [31:0] rdata;

    integer errors;
    integer tests;

    data_ram uut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    // 产生时钟
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 写入任务
    task write_word;
        input [31:0] address;
        input [31:0] data;
        begin
            @(negedge clk);
            addr = address;
            wdata = data;
            we = 1;

            @(posedge clk);
            #1;
            we = 0;
        end
    endtask

    // 读取并检查任务
    task check_read;
        input [31:0] address;
        input [31:0] expected;
        input [200*8:1] test_name;
        begin
            @(negedge clk);
            addr = address;
            #1;

            tests = tests + 1;

            if (rdata !== expected) begin
                $display("FAIL: %0s", test_name);
                $display("Expected: %h", expected);
                $display("Actual:   %h", rdata);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

    initial begin
        clk = 0;
        we = 0;
        addr = 0;
        wdata = 0;
        errors = 0;
        tests = 0;

        $display("========== DATA RAM TEST START ==========");

        // 1. 检查初始数据
        check_read(32'd0, 32'd0, "Initial value");

        // 2. 写入并读取第一个地址
        write_word(32'd0, 32'h12345678);
        check_read(32'd0, 32'h12345678, "Write and read address 0");

        // 3. 写入并读取第二个地址
        write_word(32'd4, 32'hAABBCCDD);
        check_read(32'd4, 32'hAABBCCDD, "Write and read address 4");

        // 4. 写入并读取第三个地址
        write_word(32'd8, 32'h87654321);
        check_read(32'd8, 32'h87654321, "Write and read address 8");

        // 5. 检查不同地址之间的数据隔离
        check_read(32'd0, 32'h12345678, "Address isolation 0");
        check_read(32'd4, 32'hAABBCCDD, "Address isolation 4");
        check_read(32'd8, 32'h87654321, "Address isolation 8");

        // 6. 覆盖写入
        write_word(32'd4, 32'hFFFFFFFF);
        check_read(32'd4, 32'hFFFFFFFF, "Overwrite address 4");

        // 7. 检查其他地址没有受到影响
        check_read(32'd0, 32'h12345678, "Other address unchanged");

        // 8. 检查最后一个存储单元
        write_word(32'd1020, 32'h55AA55AA);
        check_read(32'd1020, 32'h55AA55AA, "Last address");

        // 9. 检查写使能关闭时不会写入
        @(negedge clk);
        addr = 32'd0;
        wdata = 32'hFFFFFFFF;
        we = 0;

        @(posedge clk);
        #1;

        check_read(32'd0, 32'h12345678, "Write disabled");

        $display("-----------------------------------------");
        $display("Total tests: %0d", tests);
        $display("Errors: %0d", errors);

        if (errors == 0)
            $display("ALL DATA RAM TESTS PASSED");
        else
            $display("DATA RAM TESTS FAILED");

        $display("========== DATA RAM TEST END ==========");

        $finish;
    end

endmodule
