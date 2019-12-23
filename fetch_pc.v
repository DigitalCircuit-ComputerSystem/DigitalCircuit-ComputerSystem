module fetch_pc(  //
	input rst,
	input clk,
	input [31:0]pc_i,
	input is_jmp,
	input [31:0]jmp_pc,
	output [31:0]pc_o
);
reg [31:0] pc;
initial begin
	pc = 0;
end
//reg [1:0] count;
//reg clk_2=1'b0;
//
//always @ (posedge clk)begin
//	clk_2=~clk_2;
//end

always @(posedge clk) begin
	if(rst) pc <= 32'b0;
	else if(is_jmp) pc <= jmp_pc;
	else pc <= pc_i + 32'd4;
end 

assign pc_o = pc;
endmodule 