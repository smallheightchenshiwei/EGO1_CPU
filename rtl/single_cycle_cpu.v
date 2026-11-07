module single_cycle_cpu (
    input clk,
    input reset,

    output [31:0] debug_pc,
    output [31:0] debug_inst
);

    //==================================================
    // 1. PC 和指令
    //==================================================

    wire [31:0] current_pc;
    wire [31:0] current_inst;
    wire [31:0] pc_plus4;

    assign pc_plus4 = current_pc + 32'd4;

    assign debug_pc = current_pc;
    assign debug_inst = current_inst;

    //==================================================
    // 2. Decoder 输出信号
    //==================================================

    wire [4:0] rd;
    wire [4:0] rj;
    wire [4:0] rk;

    wire [4:0] raddr1;
    wire [4:0] raddr2;
    wire [4:0] waddr;

    wire [31:0] imm;

    wire [3:0] alu_ctrl;
    wire alu_src_imm;

    wire [1:0] wb_sel;

    wire reg_we;
    wire mem_we;
    wire mem_re;

    wire [2:0] branch_type;
    wire valid;

    //==================================================
    // 3. Regfile 信号
    //==================================================

    wire [31:0] rdata1;
    wire [31:0] rdata2;

    wire [31:0] wb_data;
    wire regfile_we;

    assign regfile_we = reg_we && valid && !reset;

    //==================================================
    // 4. ALU 信号
    //==================================================

    wire [31:0] alu_src2;
    wire [31:0] alu_result;

    assign alu_src2 = alu_src_imm ? imm : rdata2;

    //==================================================
    // 5. Divider 信号
    //==================================================

    wire [31:0] div_quotient;
    wire [31:0] div_remainder;

    //==================================================
    // 6. 执行结果选择器
    //==================================================

    reg [31:0] exec_result;

    always @(*) begin
        case (alu_ctrl)
            4'd10: exec_result = div_quotient;
            4'd11: exec_result = div_remainder;
            default: exec_result = alu_result;
        endcase
    end

    //==================================================
    // 7. Data RAM 信号
    //==================================================

    wire [31:0] mem_rdata;
    wire ram_we;

    assign ram_we = mem_we && valid && !reset;

    //==================================================
    // 8. Branch Unit 信号
    //==================================================

    wire branch_redirect_en;
    wire [31:0] redirect_addr;
    wire redirect_en;

    assign redirect_en = branch_redirect_en && valid;

    //==================================================
    // 9. 最终写回选择器
    //==================================================

    reg [31:0] writeback_data;

    always @(*) begin
        case (wb_sel)
            2'b00: writeback_data = exec_result;
            2'b01: writeback_data = mem_rdata;
            2'b10: writeback_data = pc_plus4;
            default: writeback_data = 32'b0;
        endcase
    end

    assign wb_data = writeback_data;

    //==================================================
    // 10. PC 模块
    //==================================================

    pc u_pc (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .redirect_en(redirect_en),
        .redirect_addr(redirect_addr),
        .pc(current_pc)
    );

    //==================================================
    // 11. Inst ROM
    //==================================================

    inst_rom u_inst_rom (
        .addr(current_pc),
        .inst(current_inst)
    );

    //==================================================
    // 12. Decoder
    //==================================================

    decoder u_decoder (
        .inst(current_inst),

        .rd(rd),
        .rj(rj),
        .rk(rk),

        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),

        .imm(imm),

        .alu_ctrl(alu_ctrl),
        .alu_src_imm(alu_src_imm),

        .wb_sel(wb_sel),

        .reg_we(reg_we),
        .mem_we(mem_we),
        .mem_re(mem_re),

        .branch_type(branch_type),
        .valid(valid)
    );

    //==================================================
    // 13. Regfile
    //==================================================

    regfile u_regfile (
        .clk(clk),
        .reset(reset),

        .we(regfile_we),
        .waddr(waddr),
        .wdata(wb_data),

        .raddr1(raddr1),
        .raddr2(raddr2),

        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    //==================================================
    // 14. ALU
    //==================================================

    alu u_alu (
        .src1(rdata1),
        .src2(alu_src2),
        .alu_ctrl(alu_ctrl),
        .result(alu_result)
    );

    //==================================================
    // 15. Divider
    //==================================================

    divider u_divider (
        .dividend(rdata1),
        .divisor(rdata2),
        .quotient(div_quotient),
        .remainder(div_remainder)
    );

    //==================================================
    // 16. Data RAM
    //==================================================

    data_ram u_data_ram (
        .clk(clk),
        .we(ram_we),
        .addr(alu_result),
        .wdata(rdata2),
        .rdata(mem_rdata)
    );

    //==================================================
    // 17. Branch Unit
    //==================================================

    branch_unit u_branch_unit (
        .branch_type(branch_type),
        .pc(current_pc),
        .imm(imm),
        .src1(rdata1),
        .src2(rdata2),
        .redirect_en(branch_redirect_en),
        .redirect_addr(redirect_addr)
    );

endmodule