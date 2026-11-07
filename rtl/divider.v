module divider (
    input  [31:0] dividend,
    input  [31:0] divisor,
    output reg [31:0] quotient,
    output reg [31:0] remainder
);

    // 有符号运算中间变量
    reg signed [31:0] signed_dividend;
    reg signed [31:0] signed_divisor;

    always @(*) begin
        signed_dividend = dividend;
        signed_divisor  = divisor;

        // 默认输出
        quotient  = 32'h00000000;
        remainder = 32'h00000000;

        // 特殊情况一：除数为0
        if (divisor == 32'h00000000) begin
            quotient  = 32'h00000000;
            remainder = 32'h00000000;
        end

        // 特殊情况二：INT_MIN / -1
        else if ((dividend == 32'h80000000) &&
                 (divisor  == 32'hFFFFFFFF)) begin
            quotient  = 32'h80000000;
            remainder = 32'h00000000;
        end

        // 正常有符号除法
        else begin
            quotient  = signed_dividend / signed_divisor;
            remainder = signed_dividend % signed_divisor;
        end
    end

endmodule