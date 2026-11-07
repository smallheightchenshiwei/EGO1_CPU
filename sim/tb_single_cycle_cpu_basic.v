
`timescale 1ns / 1ps

module tb_single_cycle_cpu_basic;

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

    // 时钟：周期10ns
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

    // SLLI.W编码
    function [31:0] enc_slli;
        input [4:0] rd;
        input [4:0] rj;
        input [4:0] shamt;
        begin
            enc_slli = {
                17'b00000000010000001,
                shamt,
                rj,
                rd
            };
        end
    endfunction

    // 测试结果检查
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

        // 等待ROM初始化完成
        #2;

        // ROM清零
        for (i = 0; i < 256; i = i + 1)
            uut.u_inst_rom.rom[i] = 32'b0;

        // ==============================
        // 测试程序
        // ==============================

        // 0: LU12I.W r1, 0x00001
        uut.u_inst_rom.rom[0] =
            enc_lu12(5'd1, 20'h00001);

        // 1: ADDI.W r1, r1, 5
        uut.u_inst_rom.rom[1] =
            enc_i12(10'b0000001010, 1, 1, 12'd5);

        // 2: LU12I.W r2, 0x00002
        uut.u_inst_rom.rom[2] =
            enc_lu12(5'd2, 20'h00002);

        // 3: ADDI.W r2, r2, -3
        uut.u_inst_rom.rom[3] =
            enc_i12(10'b0000001010, 2, 2, 12'hFFD);

        // 4: ADDI.W r20, r0, 1
        uut.u_inst_rom.rom[4] =
            enc_i12(10'b0000001010, 20, 0, 12'd1);

        // 5: ADD.W r3, r1, r2
        uut.u_inst_rom.rom[5] =
            enc3r(17'b00000000000100000, 3, 1, 2);

        // 6: SUB.W r4, r1, r2
        uut.u_inst_rom.rom[6] =
            enc3r(17'b00000000000100010, 4, 1, 2);

        // 7: SLT r5, r2, r1
        uut.u_inst_rom.rom[7] =
            enc3r(17'b00000000000100100, 5, 2, 1);

        // 8: AND r6, r1, r2
        uut.u_inst_rom.rom[8] =
            enc3r(17'b00000000000101001, 6, 1, 2);

        // 9: OR r7, r1, r2
        uut.u_inst_rom.rom[9] =
            enc3r(17'b00000000000101010, 7, 1, 2);

        // 10: XOR r8, r1, r2
        uut.u_inst_rom.rom[10] =
            enc3r(17'b00000000000101011, 8, 1, 2);

        // 11: ANDI r9, r1, 0x00F
        uut.u_inst_rom.rom[11] =
            enc_i12(10'b0000001101, 9, 1, 12'h00F);

        // 12: ORI r10, r1, 0x00F
        uut.u_inst_rom.rom[12] =
            enc_i12(10'b0000001110, 10, 1, 12'h00F);

        // 13: SLL.W r11, r1, r20
        uut.u_inst_rom.rom[13] =
            enc3r(17'b00000000000101110, 11, 1, 20);

        // 14: SRL.W r12, r1, r20
        uut.u_inst_rom.rom[14] =
            enc3r(17'b00000000000101111, 12, 1, 20);

        // 15: SRA.W r13, r2, r20
        uut.u_inst_rom.rom[15] =
            enc3r(17'b00000000000110000, 13, 2, 20);

        // 16: SLLI.W r14, r1, 3
        uut.u_inst_rom.rom[16] =
            enc_slli(14, 1, 3);

        // 17: MUL.W r15, r1, r20
        uut.u_inst_rom.rom[17] =
            enc3r(17'b00000000000111000, 15, 1, 20);

        // 18: DIV.W r16, r1, r20
        uut.u_inst_rom.rom[18] =
            enc3r(17'b00000000001000000, 16, 1, 20);

        // 19: MOD.W r17, r1, r20
        uut.u_inst_rom.rom[19] =
            enc3r(17'b00000000001000001, 17, 1, 20);

        // 20: ADDI.W r18, r0, 256
        uut.u_inst_rom.rom[20] =
            enc_i12(10'b0000001010, 18, 0, 12'd256);

        // 21: ST.W r3, r18, 0
        uut.u_inst_rom.rom[21] =
            enc_i12(10'b0010100110, 3, 18, 12'd0);

        // 22: LD.W r19, r18, 0
        uut.u_inst_rom.rom[22] =
            enc_i12(10'b0010100010, 19, 18, 12'd0);

        // 23: B 0，原地循环，防止执行空指令
        uut.u_inst_rom.rom[23] = {
            6'b010100, 26'b0
        };

        // 复位两个时钟周期
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // 执行前23条指令
        repeat (23) begin
            @(posedge clk);
            #1;
        end

        // ==============================
        // 检查寄存器结果
        // ==============================

        $display("");
        $display("========== CPU TEST RESULTS ==========");

        check_reg(1,  32'h00001005, "ADDI.W / LU12I.W");
        check_reg(2,  32'h00001FFD, "ADDI.W");
        check_reg(3,  32'h00003002, "ADD.W");
        check_reg(4,  32'hFFFFF008, "SUB.W");
        check_reg(5,  32'h00000000, "SLT");
        check_reg(6,  32'h00001005, "AND");
        check_reg(7,  32'h00001FFD, "OR");
        check_reg(8,  32'h00000FF8, "XOR");
        check_reg(9,  32'h00000005, "ANDI");
        check_reg(10, 32'h0000100F, "ORI");
        check_reg(11, 32'h0000200A, "SLL.W");
        check_reg(12, 32'h00000802, "SRL.W");
        check_reg(13, 32'h00000FFE, "SRA.W");
        check_reg(14, 32'h00008028, "SLLI.W");
        check_reg(15, 32'h00001005, "MUL.W");
        check_reg(16, 32'h00001005, "DIV.W");
        check_reg(17, 32'h00000000, "MOD.W");
        check_reg(18, 32'h00000100, "RAM BASE");
        check_reg(19, 32'h00003002, "LD.W");

        // 检查RAM第64个字
        if (uut.u_data_ram.mem[64] === 32'h00003002) begin
            $display("[PASS] ST.W");
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] ST.W expected=00003002 actual=%h",
                uut.u_data_ram.mem[64]);
            fail_count = fail_count + 1;
        end

        $display("--------------------------------------");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("======================================");

        if (fail_count == 0)
            $display("CPU NON-BRANCH TEST PASSED!");
        else
            $display("CPU NON-BRANCH TEST FAILED!");

        $finish;
    end

endmodule
