module regfile (
    input clk,//时钟信号
    input reset,//同步复位信号，高有效，复位时清零
    input we,//写使能信号高有效，1允许写入

    input [4:0] waddr,//写地址
    input [31:0] wdata,//写数据

    input [4:0] raddr1,//读端口1地址
    input [4:0] raddr2,//读端口2地址

    output [31:0] rdata1,//读端口1输出数据
    output [31:0] rdata2//读端口2输出数据
);

reg [31:0] registers [0:31];//32个32位寄存器
integer i;

// 写寄存器：时钟上升沿写入
always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'b0;
    end
    else if (we && (waddr != 5'd0)) begin
        registers[waddr] <= wdata;
    end
end

// 读取寄存器：组合逻辑读取
assign rdata1 = (raddr1 == 5'd0) ? 32'b0 : registers[raddr1];
assign rdata2 = (raddr2 == 5'd0) ? 32'b0 : registers[raddr2];

endmodule