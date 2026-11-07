
`timescale 1ns / 1ps

module tb_alu;

    reg  [31:0] src1;
    reg  [31:0] src2;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;

    integer pass_count;
    integer fail_count;

    alu uut (
        .src1(src1),
        .src2(src2),
        .alu_ctrl(alu_ctrl),
        .result(result)
    );

    task check_result;
        input [31:0] expected;
        begin
            #10;
            if (result === expected) begin
                $display("PASS: ctrl=%d result=%h",
                         alu_ctrl, result);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: ctrl=%d expected=%h actual=%h",
                         alu_ctrl, expected, result);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        // 1. ADD
        src1 = 32'd10;
        src2 = 32'd20;
        alu_ctrl = 4'd0;
        check_result(32'd30);

        // 2. SUB
        src1 = 32'd20;
        src2 = 32'd5;
        alu_ctrl = 4'd1;
        check_result(32'd15);

        // 3. AND
        src1 = 32'h0000F0F0;
        src2 = 32'h00000FF0;
        alu_ctrl = 4'd2;
        check_result(32'h000000F0);

        // 4. OR
        src1 = 32'h0000F000;
        src2 = 32'h00000F00;
        alu_ctrl = 4'd3;
        check_result(32'h0000FF00);

        // 5. XOR
        src1 = 32'hAAAA5555;
        src2 = 32'hFFFF0000;
        alu_ctrl = 4'd4;
        check_result(32'h55555555);

        // 6. SLT (signed: -5 < 3)
        src1 = 32'hFFFFFFFB;
        src2 = 32'd3;
        alu_ctrl = 4'd5;
        check_result(32'd1);

        // 7. SLL
        src1 = 32'd1;
        src2 = 32'd4;
        alu_ctrl = 4'd6;
        check_result(32'd16);

        // 8. SRL
        src1 = 32'h80000000;
        src2 = 32'd4;
        alu_ctrl = 4'd7;
        check_result(32'h08000000);

        // 9. SRA
        src1 = 32'h80000000;
        src2 = 32'd4;
        alu_ctrl = 4'd8;
        check_result(32'hF8000000);

        // 10. MUL
        src1 = 32'hFFFFFFFD;
        src2 = 32'd5;
        alu_ctrl = 4'd9;
        check_result(32'hFFFFFFF1);

        #10;
        $display("--------------------------------");
        $display("ALU TEST FINISHED");
        $display("PASS: %d", pass_count);
        $display("FAIL: %d", fail_count);
        $display("--------------------------------");

        $finish;
    end

endmodule
