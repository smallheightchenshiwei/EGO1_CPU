
module decoder (
    input  [31:0] inst,

    // 原始指令字段
    output [4:0] rd,
    output [4:0] rj,
    output [4:0] rk,

    // 寄存器堆读写地址
    output reg [4:0] raddr1,
    output reg [4:0] raddr2,
    output reg [4:0] waddr,

    // 立即数
    output reg [31:0] imm,

    // ALU控制
    output reg [3:0] alu_ctrl,
    output reg       alu_src_imm,

    // 写回控制
    output reg [1:0] wb_sel,
    output reg       reg_we,

    // 存储器控制
    output reg       mem_we,
    output reg       mem_re,

    // 分支控制
    output reg [2:0] branch_type,

    // 指令有效标志
    output reg       valid
);

// 1. 指令字段提取

assign rd = inst[4:0];
assign rj = inst[9:5];
assign rk = inst[14:10];


// 2. ALU控制编码


localparam ALU_ADD = 4'd0;
localparam ALU_SUB = 4'd1;
localparam ALU_AND = 4'd2;
localparam ALU_OR  = 4'd3;
localparam ALU_XOR = 4'd4;
localparam ALU_SLT = 4'd5;
localparam ALU_SLL = 4'd6;
localparam ALU_SRL = 4'd7;
localparam ALU_SRA = 4'd8;
localparam ALU_MUL = 4'd9;
localparam ALU_DIV = 4'd10;
localparam ALU_MOD = 4'd11;

// 3. 分支控制编码

localparam BR_NONE = 3'd0;
localparam BR_BEQ  = 3'd1;
localparam BR_BNE  = 3'd2;
localparam BR_BLT  = 3'd3;
localparam BR_B    = 3'd4;
localparam BR_BL   = 3'd5;

// 4. 写回数据选择编码

localparam WB_ALU = 2'd0;
localparam WB_MEM = 2'd1;
localparam WB_PC4 = 2'd2;

// 5. 指令译码

always @(*) begin

    // 默认值
    raddr1     = 5'd0;
    raddr2     = 5'd0;
    waddr      = 5'd0;

    imm        = 32'b0;

    alu_ctrl   = ALU_ADD;
    alu_src_imm = 1'b0;

    wb_sel     = WB_ALU;
    reg_we     = 1'b0;

    mem_we     = 1'b0;
    mem_re     = 1'b0;

    branch_type = BR_NONE;
    valid       = 1'b0;

    case (1'b1)


        // ADD.W rd, rj, rk
        (inst[31:15] == 17'b00000000000100000): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_ADD;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // SUB.W rd, rj, rk
        (inst[31:15] == 17'b00000000000100010): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_SUB;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // SLT rd, rj, rk
        (inst[31:15] == 17'b00000000000100100): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_SLT;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // AND rd, rj, rk
        (inst[31:15] == 17'b00000000000101001): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_AND;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // OR rd, rj, rk
        (inst[31:15] == 17'b00000000000101010): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_OR;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // XOR rd, rj, rk
        (inst[31:15] == 17'b00000000000101011): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_XOR;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // SLL.W rd, rj, rk
        (inst[31:15] == 17'b00000000000101110): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_SLL;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // SRL.W rd, rj, rk
        (inst[31:15] == 17'b00000000000101111): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_SRL;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // SRA.W rd, rj, rk
        (inst[31:15] == 17'b00000000000110000): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_SRA;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // SLLI.W rd, rj, ui5
        (inst[31:15] == 17'b00000000010000001): begin
            raddr1     = rj;
            waddr      = rd;
            imm        = {27'b0, inst[14:10]};
            alu_ctrl   = ALU_SLL;
            alu_src_imm = 1'b1;
            reg_we     = 1'b1;
            valid      = 1'b1;
        end

        // MUL.W rd, rj, rk
        (inst[31:15] == 17'b00000000000111000): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_MUL;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // DIV.W rd, rj, rk
        (inst[31:15] == 17'b00000000001000000): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_DIV;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // MOD.W rd, rj, rk
        (inst[31:15] == 17'b00000000001000001): begin
            raddr1   = rj;
            raddr2   = rk;
            waddr    = rd;
            alu_ctrl = ALU_MOD;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // ADDI.W rd, rj, si12
        (inst[31:22] == 10'b0000001010): begin
            raddr1      = rj;
            waddr       = rd;
            imm         = {{20{inst[21]}}, inst[21:10]};
            alu_ctrl    = ALU_ADD;
            alu_src_imm = 1'b1;
            reg_we      = 1'b1;
            valid       = 1'b1;
        end

        // LU12I.W rd, si20
        (inst[31:25] == 7'b0001010): begin
            waddr    = rd;
            imm      = {inst[24:5], 12'b0};
            alu_src_imm = 1'b1;
            reg_we   = 1'b1;
            valid    = 1'b1;
        end

        // ANDI rd, rj, ui12
        (inst[31:22] == 10'b0000001101): begin
            raddr1      = rj;
            waddr       = rd;
            imm         = {20'b0, inst[21:10]};
            alu_ctrl    = ALU_AND;
            alu_src_imm = 1'b1;
            reg_we      = 1'b1;
            valid       = 1'b1;
        end

        // ORI rd, rj, ui12
        (inst[31:22] == 10'b0000001110): begin
            raddr1      = rj;
            waddr       = rd;
            imm         = {20'b0, inst[21:10]};
            alu_ctrl    = ALU_OR;
            alu_src_imm = 1'b1;
            reg_we      = 1'b1;
            valid       = 1'b1;
        end

        // LD.W rd, rj, si12
        (inst[31:22] == 10'b0010100010): begin
            raddr1      = rj;
            waddr       = rd;
            imm         = {{20{inst[21]}}, inst[21:10]};
            alu_ctrl    = ALU_ADD;
            alu_src_imm = 1'b1;
            mem_re      = 1'b1;
            wb_sel      = WB_MEM;
            reg_we      = 1'b1;
            valid       = 1'b1;
        end

        // ST.W rd, rj, si12
        (inst[31:22] == 10'b0010100110): begin
            raddr1      = rj;
            raddr2      = rd;
            imm         = {{20{inst[21]}}, inst[21:10]};
            alu_ctrl    = ALU_ADD;
            alu_src_imm = 1'b1;
            mem_we      = 1'b1;
            valid       = 1'b1;
        end

        // BEQ rj, rd, offs16
        (inst[31:26] == 6'b010110): begin
            raddr1      = rj;
            raddr2      = rd;
            imm         = {{14{inst[25]}}, inst[25:10], 2'b00};
            alu_ctrl    = ALU_SUB;
            branch_type = BR_BEQ;
            valid       = 1'b1;
        end

        // BNE rj, rd, offs16
        (inst[31:26] == 6'b010111): begin
            raddr1      = rj;
            raddr2      = rd;
            imm         = {{14{inst[25]}}, inst[25:10], 2'b00};
            alu_ctrl    = ALU_SUB;
            branch_type = BR_BNE;
            valid       = 1'b1;
        end

        // BLT rj, rd, offs16
        (inst[31:26] == 6'b011000): begin
            raddr1      = rj;
            raddr2      = rd;
            imm         = {{14{inst[25]}}, inst[25:10], 2'b00};
            alu_ctrl    = ALU_SLT;
            branch_type = BR_BLT;
            valid       = 1'b1;
        end

        // B offs26
        (inst[31:26] == 6'b010100): begin
            imm         = {{4{inst[9]}}, inst[9:0],
                           inst[25:10], 2'b00};
            branch_type = BR_B;
            valid       = 1'b1;
        end

        // BL offs26
        (inst[31:26] == 6'b010101): begin
            imm         = {{4{inst[9]}}, inst[9:0],
                           inst[25:10], 2'b00};
            waddr       = 5'd1;
            wb_sel      = WB_PC4;
            reg_we      = 1'b1;
            branch_type = BR_BL;
            valid       = 1'b1;
        end

        default: begin
            // 保持默认值，非法指令不产生写操作
        end

    endcase
end

endmodule
