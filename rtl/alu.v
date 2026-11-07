
`timescale 1ns / 1ps

module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  alu_ctrl,
    output reg [31:0] result
);

    // ALU控制编码，与decoder.v保持一致
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

    // 有符号运算使用的临时变量
    reg signed [31:0] signed_a;
    reg signed [31:0] signed_b;

    always @(*) begin
        signed_a = a;
        signed_b = b;

        // 默认结果
        result = 32'b0;

        case (alu_ctrl)

            ALU_ADD: begin
                result = a + b;
            end

            ALU_SUB: begin
                result = a - b;
            end

            ALU_AND: begin
                result = a & b;
            end

            ALU_OR: begin
                result = a | b;
            end

            ALU_XOR: begin
                result = a ^ b;
            end

            ALU_SLT: begin
                result = (signed_a < signed_b) ? 32'd1 : 32'd0;
            end

            ALU_SLL: begin
                result = a << b[4:0];
            end

            ALU_SRL: begin
                result = a >> b[4:0];
            end

            ALU_SRA: begin
                result = signed_a >>> b[4:0];
            end

            ALU_MUL: begin
                result = a * b;
            end

            ALU_DIV: begin
                if (b == 32'b0)
                    result = 32'b0;
                else if ((a == 32'h80000000) &&
                         (b == 32'hFFFFFFFF))
                    result = 32'h80000000;
                else
                    result = signed_a / signed_b;
            end

            ALU_MOD: begin
                if (b == 32'b0)
                    result = 32'b0;
                else if ((a == 32'h80000000) &&
                         (b == 32'hFFFFFFFF))
                    result = 32'b0;
                else
                    result = signed_a % signed_b;
            end

            default: begin
                result = 32'b0;
            end

        endcase
    end

endmodule
