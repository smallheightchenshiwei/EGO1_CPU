`timescale 1ns / 1ps

module tb_branch_unit;

    reg  [2:0]  branch_type;
    reg  [31:0] pc;
    reg  [31:0] imm;
    reg  [31:0] src1;
    reg  [31:0] src2;

    wire        redirect_en;
    wire [31:0] redirect_addr;

    integer test_count;
    integer error_count;

    branch_unit uut (
        .branch_type(branch_type),
        .pc(pc),
        .imm(imm),
        .src1(src1),
        .src2(src2),
        .redirect_en(redirect_en),
        .redirect_addr(redirect_addr)
    );

    task check_branch;
        input expected_en;
        input [31:0] expected_addr;
        input [200*8-1:0] test_name;
        begin
            #10;
            test_count = test_count + 1;

            if ((redirect_en !== expected_en) ||
                (redirect_addr !== expected_addr)) begin
                error_count = error_count + 1;
                $display("FAIL: %0s", test_name);
                $display("  Expected: en=%b addr=%h",
                         expected_en, expected_addr);
                $display("  Actual:   en=%b addr=%h",
                         redirect_en, redirect_addr);
            end
            else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

    initial begin
        test_count = 0;
        error_count = 0;

        pc = 32'h00001000;
        imm = 32'h00000010;
        src1 = 32'd5;
        src2 = 32'd5;

        // 1. NONE：不跳转
        branch_type = 3'd0;
        check_branch(1'b0, 32'h00000000, "NONE");

        // 2. BEQ：相等，跳转
        branch_type = 3'd1;
        src1 = 32'd5;
        src2 = 32'd5;
        check_branch(1'b1, 32'h00001010, "BEQ true");

        // 3. BEQ：不相等，不跳转
        src2 = 32'd6;
        check_branch(1'b0, 32'h00000000, "BEQ false");

        // 4. BNE：不相等，跳转
        branch_type = 3'd2;
        check_branch(1'b1, 32'h00001010, "BNE true");

        // 5. BNE：相等，不跳转
        src2 = 32'd5;
        check_branch(1'b0, 32'h00000000, "BNE false");

        // 6. BLT：有符号  -1 < 1，跳转
        branch_type = 3'd3;
        src1 = 32'hFFFFFFFF;
        src2 = 32'd1;
        check_branch(1'b1, 32'h00001010, "BLT signed true");

        // 7. BLT：有符号  1 < -1，不成立
        src1 = 32'd1;
        src2 = 32'hFFFFFFFF;
        check_branch(1'b0, 32'h00000000, "BLT signed false");

        // 8. B：无条件跳转
        branch_type = 3'd4;
        check_branch(1'b1, 32'h00001010, "B unconditional");

        // 9. BL：无条件跳转
        branch_type = 3'd5;
        check_branch(1'b1, 32'h00001010, "BL unconditional");

        // 10. 正偏移：直接计算 PC + imm
        branch_type = 3'd4;
        pc = 32'h00002000;
        imm = 32'h00000004;
        check_branch(1'b1, 32'h00002004, "Positive offset");

        // 11. 负偏移：直接计算 PC + imm
        pc = 32'h00002000;
        imm = 32'hFFFFFFFC;
        check_branch(1'b1, 32'h00001FFC, "Negative offset");

        // 12. 非法 branch_type = 6
        branch_type = 3'd6;
        check_branch(1'b0, 32'h00000000, "Invalid type 6");

        // 13. 非法 branch_type = 7
        branch_type = 3'd7;
        check_branch(1'b0, 32'h00000000, "Invalid type 7");

        $display("--------------------------------");
        $display("Total tests: %0d", test_count);
        $display("Errors: %0d", error_count);

        if (error_count == 0)
            $display("ALL BRANCH UNIT TESTS PASSED");
        else
            $display("BRANCH UNIT TESTS FAILED");

        $finish;
    end

endmodule