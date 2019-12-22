module fetch_pc(  //
	input rst,
	input clk,
	input [31:0]pc_i,
	input is_jmp,
	input [31:0]jmp_pc,
	output reg[31:0]pc_o
);

//reg [1:0] count;
//reg clk_2=1'b0;
//
//always @ (posedge clk)begin
//	clk_2=~clk_2;
//end

always @(posedge clk) begin
	if(rst) pc_o <= 32'b0;
	else if(is_jmp) pc_o <= jmp_pc;
	else pc_o <= pc_i + 32'd4;
end 
endmodule 