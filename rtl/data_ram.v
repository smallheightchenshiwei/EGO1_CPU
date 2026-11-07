
module data_ram (
    input         clk,       // 时钟信号
    input         we,        // 写使能信号
    input  [31:0] addr,      // 32位字节地址
    input  [31:0] wdata,     // 写入数据
    output [31:0] rdata      // 读取数据
);

    // 数据存储器：256个存储单元，每个单元32位
    reg [31:0] mem [0:255];

    integer i;

    // 初始化数据存储器，所有单元清零
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0;
    end

    // 异步读：根据字节地址的[9:2]位选择存储单元
    assign rdata = mem[addr[9:2]];

    // 同步写：在时钟上升沿且写使能有效时写入数据
    always @(posedge clk) begin
        if (we)
            mem[addr[9:2]] <= wdata;
    end

endmodule
