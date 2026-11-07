
`timescale 1ns / 1ps

module tb_single_cycle_cpu_boundary;

    reg clk;
    reg reset;

    wire [31:0] debug_pc;
    wire [31:0] debug_inst;

    integer i;
    integer pass_count;
    integer fail_count;

    single_cycle_cpu uut (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_inst(debug_inst)
    );

    // 时钟
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 3R指令编码
    function [31:0] enc3r;
        input [16:0] op;
        input [4:0] rd;
        input [4:0] rj;
        input [4:0] rk;
        begin
            enc3r = {op, rk, rj, rd};
        end
    endfunction

    // I12指令编码
    function [31:0] enc_i12;
        input [9:0] op;
        input [4:0] rd;
        input [4:0] rj;
        input [11:0] imm;
        begin
            enc_i12 = {op, imm, rj, rd};
        end
    endfunction

    // LU12I.W编码
    function [31:0] enc_lu12;
        input [4:0] rd;
        input [19:0] imm;
        begin
            enc_lu12 = {7'b0001010, imm, rd};
        end
    endfunction

    // 检查寄存器
    task check_reg;
        input [4:0] addr;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            if (uut.u_regfile.registers[addr] === expected) begin
                $display("[PASS] %0s", test_name);
                pass_count = pass_count + 1;
            end
            else begin
                $display("[FAIL] %0s expected=%h actual=%h",
                    test_name,
                    expected,
                    uut.u_regfile.registers[addr]);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;
        reset = 1;

        // 等待ROM初始化
        #2;

        // 清空ROM
        for (i = 0; i < 256; i = i + 1)
            uut.u_inst_rom.rom[i] = 32'b0;

        // =================================
        // 边界测试程序
        // =================================

        // 0: ADDI.W r1, r0, -7
        uut.u_inst_rom.rom[0] =
            enc_i12(10'b0000001010, 1, 0, 12'hFF9);

        // 1: ADDI.W r2, r0, 3
        uut.u_inst_rom.rom[1] =
            enc_i12(10'b0000001010, 2, 0, 12'd3);

        // 2: ADDI.W r20, r0, 1
        // 移位量 = 1
        uut.u_inst_rom.rom[2] =
            enc_i12(10'b0000001010, 20, 0, 12'd1);

        // 3: ADD.W r3, r1, r2
        // -7 + 3 = -4
        uut.u_inst_rom.rom[3] =
            enc3r(17'b00000000000100000, 3, 1, 2);

        // 4: SUB.W r4, r2, r1
        // 3 - (-7) = 10
        uut.u_inst_rom.rom[4] =
            enc3r(17'b00000000000100010, 4, 2, 1);

        // 5: SLT r5, r1, r2
        // -7 < 3，结果为1
        uut.u_inst_rom.rom[5] =
            enc3r(17'b00000000000100100, 5, 1, 2);

        // 6: SLT r6, r2, r1
        // 3 < -7不成立，结果为0
        uut.u_inst_rom.rom[6] =
            enc3r(17'b00000000000100100, 6, 2, 1);

        // 7: SRA.W r7, r1, r20
        // -7算术右移1位 = -4
        uut.u_inst_rom.rom[7] =
            enc3r(17'b00000000000110000, 7, 1, 20);

        // 8: SRL.W r8, r1, r20
        // 逻辑右移1位
        uut.u_inst_rom.rom[8] =
            enc3r(17'b00000000000101111, 8, 1, 20);

        // 9: DIV.W r9, r1, r2
        // -7 / 3 = -2
        uut.u_inst_rom.rom[9] =
            enc3r(17'b00000000001000000, 9, 1, 2);

        // 10: MOD.W r10, r1, r2
        // -7 % 3 = -1
        uut.u_inst_rom.rom[10] =
            enc3r(17'b00000000001000001, 10, 1, 2);

        // 11: DIV.W r11, r1, r0
        // 除数为0，结果为0
        uut.u_inst_rom.rom[11] =
            enc3r(17'b00000000001000000, 11, 1, 0);

        // 12: MOD.W r12, r1, r0
        // 除数为0，结果为0
        uut.u_inst_rom.rom[12] =
            enc3r(17'b00000000001000001, 12, 1, 0);

        // 13: LU12I.W r13, 0x80000
        // 得到 INT_MIN
        uut.u_inst_rom.rom[13] =
            enc_lu12(13, 20'h80000);

        // 14: ADDI.W r14, r0, -1
        uut.u_inst_rom.rom[14] =
            enc_i12(10'b0000001010, 14, 0, 12'hFFF);

        // 15: DIV.W r15, r13, r14
        // INT_MIN / -1 = INT_MIN
        uut.u_inst_rom.rom[15] =
            enc3r(17'b00000000001000000, 15, 13, 14);

        // 16: MOD.W r16, r13, r14
        // INT_MIN % -1 = 0
        uut.u_inst_rom.rom[16] =
            enc3r(17'b00000000001000001, 16, 13, 14);

        // 17: ADDI.W r0, r0, 123
        // 尝试写入R0
        uut.u_inst_rom.rom[17] =
            enc_i12(10'b0000001010, 0, 0, 12'd123);

        // 18: ADDI.W r17, r0, 5
        // R0仍然为0，因此r17应该为5
        uut.u_inst_rom.rom[18] =
            enc_i12(10'b0000001010, 17, 0, 12'd5);

        // 19: ADDI.W r18, r0, 7
        uut.u_inst_rom.rom[19] =
            enc_i12(10'b0000001010, 18, 0, 12'd7);

        // 20: ADDI.W r21, r0, -3
        uut.u_inst_rom.rom[20] =
            enc_i12(10'b0000001010, 21, 0, 12'hFFD);

        // 21: DIV.W r22, r1, r21
        // -7 / -3 = 2
        uut.u_inst_rom.rom[21] =
            enc3r(17'b00000000001000000, 22, 1, 21);

        // 22: MOD.W r23, r1, r21
        // -7 % -3 = -1
        uut.u_inst_rom.rom[22] =
            enc3r(17'b00000000001000001, 23, 1, 21);

        // 23: DIV.W r24, r18, r21
        // 7 / -3 = -2
        uut.u_inst_rom.rom[23] =
            enc3r(17'b00000000001000000, 24, 18, 21);

        // 24: MOD.W r25, r18, r21
        // 7 % -3 = 1
        uut.u_inst_rom.rom[24] =
            enc3r(17'b00000000001000001, 25, 18, 21);

        // 25: B 0，原地循环
        uut.u_inst_rom.rom[25] =
            {6'b010100, 26'b0};

        // =================================
        // 复位及运行
        // =================================

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // 执行0~25号指令
        repeat (26) begin
            @(posedge clk);
            #1;
        end

        // =================================
        // 检查测试结果
        // =================================

        $display("");
        $display("======= BOUNDARY TEST RESULTS =======");

        check_reg(0,  32'h00000000, "R0 always zero");
        check_reg(1,  32'hFFFFFFF9, "Negative ADDI");
        check_reg(2,  32'h00000003, "Positive ADDI");
        check_reg(3,  32'hFFFFFFFC, "Negative ADD");
        check_reg(4,  32'h0000000A, "Negative SUB");
        check_reg(5,  32'h00000001, "SLT negative < positive");
        check_reg(6,  32'h00000000, "SLT positive < negative");
        check_reg(7,  32'hFFFFFFFC, "SRA negative");
        check_reg(8,  32'h7FFFFFFC, "SRL negative");
        check_reg(9,  32'hFFFFFFFE, "DIV -7 / 3");
        check_reg(10, 32'hFFFFFFFF, "MOD -7 % 3");
        check_reg(11, 32'h00000000, "DIV by zero");
        check_reg(12, 32'h00000000, "MOD by zero");
        check_reg(13, 32'h80000000, "INT_MIN generation");
        check_reg(14, 32'hFFFFFFFF, "Negative one");
        check_reg(15, 32'h80000000, "INT_MIN / -1");
        check_reg(16, 32'h00000000, "INT_MIN % -1");
        check_reg(17, 32'h00000005, "R0 write protection");
        check_reg(18, 32'h00000007, "Positive seven");
        check_reg(21, 32'hFFFFFFFD, "Negative three");
        check_reg(22, 32'h00000002, "DIV -7 / -3");
        check_reg(23, 32'hFFFFFFFF, "MOD -7 % -3");
        check_reg(24, 32'hFFFFFFFE, "DIV 7 / -3");
        check_reg(25, 32'h00000001, "MOD 7 % -3");

        $display("-------------------------------------");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("=====================================");

        if (fail_count == 0)
            $display("BOUNDARY TEST PASSED!");
        else
            $display("BOUNDARY TEST FAILED!");

        $finish;
    end

endmodule
