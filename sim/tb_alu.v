
`timescale 1ns / 1ps

module tb_alu;

    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;

    integer errors;
    integer tests;

    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result)
    );

    task check_result;
        input [31:0] expected;
        input [200*8:1] test_name;
        begin
            #10;
            tests = tests + 1;

            if (result !== expected) begin
                $display("FAIL: %0s", test_name);
                $display("  Expected: %h", expected);
                $display("  Actual:   %h", result);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

    initial begin
        a = 0;
        b = 0;
        alu_ctrl = 0;
        errors = 0;
        tests = 0;

        $display("========== ALU TEST START ==========");

        // 1. ADD
        alu_ctrl = 4'd0;
        a = 32'd10;
        b = 32'd20;
        check_result(32'd30, "ADD");

        // 2. SUB
        alu_ctrl = 4'd1;
        a = 32'd20;
        b = 32'd8;
        check_result(32'd12, "SUB");

        // 3. AND
        alu_ctrl = 4'd2;
        a = 32'hF0F0F0F0;
        b = 32'h0FF00FF0;
        check_result(32'h00F000F0, "AND");

        // 4. OR
        alu_ctrl = 4'd3;
        a = 32'hF0000000;
        b = 32'h0000000F;
        check_result(32'hF000000F, "OR");

        // 5. XOR
        alu_ctrl = 4'd4;
        a = 32'hAAAAAAAA;
        b = 32'h55555555;
        check_result(32'hFFFFFFFF, "XOR");

        // 6. SLT
        alu_ctrl = 4'd5;
        a = -32'sd5;
        b = 32'd3;
        check_result(32'd1, "SLT negative");

        // 7. SLL
        alu_ctrl = 4'd6;
        a = 32'd1;
        b = 32'd4;
        check_result(32'd16, "SLL");

        // 8. SRL
        alu_ctrl = 4'd7;
        a = 32'h80000000;
        b = 32'd1;
        check_result(32'h40000000, "SRL");

        // 9. SRA
        alu_ctrl = 4'd8;
        a = 32'h80000000;
        b = 32'd1;
        check_result(32'hC0000000, "SRA");

        // 10. MUL
        alu_ctrl = 4'd9;
        a = 32'd100;
        b = 32'd20;
        check_result(32'd2000, "MUL");

        // 11. DIV
        alu_ctrl = 4'd10;
        a = -32'sd10;
        b = 32'd3;
        check_result(-32'sd3, "DIV negative");

        // 12. MOD
        alu_ctrl = 4'd11;
        a = -32'sd10;
        b = 32'd3;
        check_result(-32'sd1, "MOD negative");

        // 13. DIV by zero
        alu_ctrl = 4'd10;
        a = 32'd100;
        b = 32'd0;
        check_result(32'd0, "DIV by zero");

        // 14. MOD by zero
        alu_ctrl = 4'd11;
        a = 32'd100;
        b = 32'd0;
        check_result(32'd0, "MOD by zero");

        // 15. Signed division overflow boundary
        alu_ctrl = 4'd10;
        a = 32'h80000000;
        b = 32'hFFFFFFFF;
        check_result(32'h80000000, "DIV overflow boundary");

        // 16. Signed modulo overflow boundary
        alu_ctrl = 4'd11;
        a = 32'h80000000;
        b = 32'hFFFFFFFF;
        check_result(32'd0, "MOD overflow boundary");

        $display("------------------------------------");
        $display("Total tests: %0d", tests);
        $display("Errors: %0d", errors);

        if (errors == 0)
            $display("ALL ALU TESTS PASSED");
        else
            $display("ALU TESTS FAILED");

        $display("========== ALU TEST END ==========");

        $finish;
    end

endmodule
