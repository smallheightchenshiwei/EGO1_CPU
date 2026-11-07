
module inst_rom (
    input  [31:0] addr,    // 指令地址输入
    output [31:0] inst     // 读取的32位指令
);

    // 定义256个字，每个字32位
    reg [31:0] rom [0:255];

    integer i;

    // 初始化指令存储器
    initial begin
        // 将全部存储单元初始化为0
        for (i = 0; i < 256; i = i + 1) begin
            rom[i] = 32'h00000000;
        end

        // 临时测试指令
        // opcode=0000001，对应ADD.W
        rom[0] = 32'h02000000;

        // opcode=0000010，对应SUB.W
        rom[1] = 32'h04000000;
    end

    // 根据字节地址读取对应指令
    assign inst = rom[addr[9:2]];

endmodule
