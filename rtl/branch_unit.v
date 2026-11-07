module branch_unit (
    input  [2:0]  branch_type,
    input  [31:0] pc,
    input  [31:0] imm,
    input  [31:0] src1,
    input  [31:0] src2,
    output reg        redirect_en,
    output reg [31:0] redirect_addr
);

    localparam BR_NONE = 3'd0;
    localparam BR_BEQ  = 3'd1;
    localparam BR_BNE  = 3'd2;
    localparam BR_BLT  = 3'd3;
    localparam BR_B    = 3'd4;
    localparam BR_BL   = 3'd5;

    always @(*) begin
        // 默认不跳转
        redirect_en   = 1'b0;
        redirect_addr = 32'h00000000;

        case (branch_type)

            BR_NONE: begin
                redirect_en = 1'b0;
            end

            BR_BEQ: begin
                if (src1 == src2) begin
                    redirect_en   = 1'b1;
                    redirect_addr = pc + imm;
                end
            end

            BR_BNE: begin
                if (src1 != src2) begin
                    redirect_en   = 1'b1;
                    redirect_addr = pc + imm;
                end
            end

            BR_BLT: begin
                if ($signed(src1) < $signed(src2)) begin
                    redirect_en   = 1'b1;
                    redirect_addr = pc + imm;
                end
            end

            BR_B: begin
                redirect_en   = 1'b1;
                redirect_addr = pc + imm;
            end

            BR_BL: begin
                redirect_en   = 1'b1;
                redirect_addr = pc + imm;
            end

            default: begin
                redirect_en   = 1'b0;
                redirect_addr = 32'h00000000;
            end

        endcase
    end

endmodule