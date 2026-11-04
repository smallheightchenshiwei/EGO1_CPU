
module pc (
    input         clk,           //时钟
    input         reset,         // 同步高电平复位
    input         stall,         // 流水线暂停
    input         redirect_en,   // 分支或跳转使能
    input  [31:0] redirect_addr,// 分支或跳转目标地址
    output reg [31:0] pc         // 当前指令地址
);

    always @(posedge clk) begin
        if (reset) begin//reset=1时pc=0
            pc <= 32'h00000000;
        end
        else if (stall) begin//stall=1pc不变
            pc <= pc;
        end
        else if (redirect_en) begin//redirect_en=1的时候，pc=redirect_addr
            pc <= redirect_addr;
        end
        else begin//正常运行，pc=pc+4
            pc <= pc + 32'd4;
        end
    end

endmodule