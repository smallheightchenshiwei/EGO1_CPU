
`timescale 1ns / 1ps

module data_ram (
    input         clk,
    input         we,
    input  [31:0] addr,
    input  [31:0] wdata,
    output [31:0] rdata
);

    // 256个32位存储单元
    reg [31:0] ram [0:255];

    integer i;

    // 初始化数据存储器
    initial begin
        for (i = 0; i < 256; i = i + 1)
            ram[i] = 32'b0;
    end

    // 同步写入
    always @(posedge clk) begin
        if (we)
            ram[addr[9:2]] <= wdata;
    end

    // 组合读取
    assign rdata = ram[addr[9:2]];

endmodule
