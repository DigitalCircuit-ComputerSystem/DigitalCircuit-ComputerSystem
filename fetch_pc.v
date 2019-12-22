module fetch_pc(  //
	input rst;
	input clk;
	input [31:0]pc_i;
	input is_jmp;
	input [31:0]jmp_pc;
	output reg[31:0]pc_o;
)

always @(posedge clk) begin
	if(rst) pc_o <= 32'b0;
	else if(is_jmp) pc_o <= jmp_pc;
	else pc_o = pc_i + 32'h4;
end