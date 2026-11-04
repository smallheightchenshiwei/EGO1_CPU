module regfile (
    input clk,
    input reset,
    input we,

    input [4:0] waddr,
    input [31:0] wdata,

    input [4:0] raddr1,
    input [4:0] raddr2,

    output [31:0] rdata1,
    output [31:0] rdata2
);

reg [31:0] registers [0:31];
integer i;

// Ğ´¼Ä´æÆ÷£ºÊ±ÖÓÉÏÉıÑØĞ´Èë
always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'b0;
    end
    else if (we && (waddr != 5'd0)) begin
        registers[waddr] <= wdata;
    end
end

// ¶ÁÈ¡¼Ä´æÆ÷£º×éºÏÂß¼­¶ÁÈ¡
assign rdata1 = (raddr1 == 5'd0) ? 32'b0 : registers[raddr1];
assign rdata2 = (raddr2 == 5'd0) ? 32'b0 : registers[raddr2];

endmodule