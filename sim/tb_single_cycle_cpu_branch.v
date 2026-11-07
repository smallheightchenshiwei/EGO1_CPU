
`timescale 1ns / 1ps

module tb_single_cycle_cpu_branch;

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

    // I12编码
    function [31:0] enc_i12;
        input [9:0] op;
        input [4:0] rd;
        input [4:0] rj;
        input [11:0] imm;
        begin
            enc_i12 = {op, imm, rj, rd};
        end
    endfunction

    // BEQ、BNE、BLT编码
    function [31:0] enc_b16;
        input [5:0] op;
        input [4:0] rj;
        input [4:0] rd;
        input [15:0] offset;
        begin
            enc_b16 = {op, offset, rj, rd};
        end
    endfunction

    // B、BL编码
    function [31:0] enc_b26;
        input [5:0] op;
        input [25:0] offset;
        begin
            enc_b26 = {op, offset[15:0], offset[25:16]};
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
        // 初始化寄存器
        // =================================

        // 0: ADDI.W r1, r0, 5
        uut.u_inst_rom.rom[0] =
            enc_i12(10'b0000001010, 1, 0, 12'd5);

        // 1: ADDI.W r2, r0, 5
        uut.u_inst_rom.rom[1] =
            enc_i12(10'b0000001010, 2, 0, 12'd5);

        // 2: BEQ r1, r2, +2
        // 相等，跳到第4条
        uut.u_inst_rom.rom[2] =
            enc_b16(6'b010110, 1, 2, 16'd2);

        // 3: 不应执行，r10保持0
        uut.u_inst_rom.rom[3] =
            enc_i12(10'b0000001010, 10, 0, 12'd1);

        // 4: ADDI.W r3, r0, 7
        uut.u_inst_rom.rom[4] =
            enc_i12(10'b0000001010, 3, 0, 12'd7);

        // 5: BNE r1, r2, +2
        // 相等，不跳转
        uut.u_inst_rom.rom[5] =
            enc_b16(6'b010111, 1, 2, 16'd2);

        // 6: ADDI.W r4, r0, 8
        uut.u_inst_rom.rom[6] =
            enc_i12(10'b0000001010, 4, 0, 12'd8);

        // 7: BNE r1, r3, +2
        // 不相等，跳到第9条
        uut.u_inst_rom.rom[7] =
            enc_b16(6'b010111, 1, 3, 16'd2);

        // 8: 不应执行，r11保持0
        uut.u_inst_rom.rom[8] =
            enc_i12(10'b0000001010, 11, 0, 12'd1);

        // 9: BLT r1, r3, +2
        // 5 < 7，跳到第11条
        uut.u_inst_rom.rom[9] =
            enc_b16(6'b011000, 1, 3, 16'd2);

        // 10: 不应执行，r12保持0
        uut.u_inst_rom.rom[10] =
            enc_i12(10'b0000001010, 12, 0, 12'd1);

        // 11: BLT r3, r1, +2
        // 7 < 5不成立，不跳转
        uut.u_inst_rom.rom[11] =
            enc_b16(6'b011000, 3, 1, 16'd2);

        // 12: ADDI.W r5, r0, 9
        uut.u_inst_rom.rom[12] =
            enc_i12(10'b0000001010, 5, 0, 12'd9);

        // 13: B +2
        // 跳过第14条
        uut.u_inst_rom.rom[13] =
            enc_b26(6'b010100, 26'd2);

        // 14: 不应执行，r13保持0
        uut.u_inst_rom.rom[14] =
            enc_i12(10'b0000001010, 13, 0, 12'd1);

        // 15: BL +2
        // 跳到第17条，同时R1=PC+4=64
        uut.u_inst_rom.rom[15] =
            enc_b26(6'b010101, 26'd2);

        // 16: 不应执行，r14保持0
        uut.u_inst_rom.rom[16] =
            enc_i12(10'b0000001010, 14, 0, 12'd1);

        // 17: B 0，原地循环
        uut.u_inst_rom.rom[17] =
            enc_b26(6'b010100, 26'd0);

        // =================================
        // 复位并运行
        // =================================

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // 运行20个时钟周期
        repeat (20) begin
            @(posedge clk);
            #1;
        end

        // =================================
        // 检查结果
        // =================================

        $display("");
        $display("======= BRANCH TEST RESULTS =======");

        check_reg(10, 32'd0, "BEQ taken");
        check_reg(3,  32'd7, "BEQ target");

        check_reg(4,  32'd8, "BNE not taken");
        check_reg(11, 32'd0, "BNE taken");

        check_reg(12, 32'd0, "BLT taken");
        check_reg(5,  32'd9, "BLT not taken");

        check_reg(13, 32'd0, "B unconditional");

        check_reg(1, 32'd64, "BL link address");

        check_reg(14, 32'd0, "BL target");

        $display("-----------------------------------");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("===================================");

        if (fail_count == 0)
            $display("BRANCH TEST PASSED!");
        else
            $display("BRANCH TEST FAILED!");

        $finish;
    end

endmodule
