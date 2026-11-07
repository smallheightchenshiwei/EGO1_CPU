`timescale 1ns / 1ps

module tb_divider;

    reg  [31:0] dividend;
    reg  [31:0] divisor;
    wire [31:0] quotient;
    wire [31:0] remainder;

    integer errors;
    integer tests;

    divider uut (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder)
    );

    task check_result;
        input [31:0] a;
        input [31:0] b;
        input [31:0] expected_q;
        input [31:0] expected_r;
        begin
            dividend = a;
            divisor  = b;
            #10;

            tests = tests + 1;

            if ((quotient !== expected_q) ||
                (remainder !== expected_r)) begin
                errors = errors + 1;
                $display("FAIL: dividend=%h divisor=%h q=%h r=%h expected_q=%h expected_r=%h",
                         a, b, quotient, remainder,
                         expected_q, expected_r);
            end
            else begin
                $display("PASS: dividend=%h divisor=%h quotient=%h remainder=%h",
                         a, b, quotient, remainder);
            end
        end
    endtask

    initial begin
        errors = 0;
        tests  = 0;
        dividend = 0;
        divisor  = 0;

        $display("========== DIVIDER TEST START ==========");

        // 正数除法
        check_result(32'd10, 32'd3, 32'd3, 32'd1);
        check_result(32'd20, 32'd5, 32'd4, 32'd0);

        // 负数除法
        check_result(-32'sd10, 32'd3, -32'sd3, -32'sd1);
        check_result(32'd10, -32'sd3, -32'sd3, 32'd1);
        check_result(-32'sd10, -32'sd3, 32'd3, -32'sd1);

        // 被除数为0
        check_result(32'd0, 32'd5, 32'd0, 32'd0);

        // 除数为0
        check_result(32'd10, 32'd0, 32'd0, 32'd0);
        check_result(-32'sd10, 32'd0, 32'd0, 32'd0);

        // INT_MIN / -1
        check_result(32'h80000000, 32'hFFFFFFFF,
                     32'h80000000, 32'h00000000);

        // INT_MIN / 1
        check_result(32'h80000000, 32'd1,
                     32'h80000000, 32'h00000000);

        // 除数大于被除数
        check_result(32'd3, 32'd10, 32'd0, 32'd3);

        // 负数边界
        check_result(-32'sd7, 32'd2, -32'sd3, -32'sd1);

        $display("----------------------------------------");
        $display("Total tests: %0d", tests);
        $display("Errors: %0d", errors);

        if (errors == 0)
            $display("ALL DIVIDER TESTS PASSED");
        else
            $display("DIVIDER TESTS FAILED");

        $display("========== DIVIDER TEST END ==========");

        $finish;
    end

endmodule