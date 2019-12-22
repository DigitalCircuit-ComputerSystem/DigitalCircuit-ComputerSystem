
module fetch_pc(  //
	input rst,
	input clk,
	input [31:0]pc_i,
	input is_jmp,
	input [31:0]jmp_pc,
	output reg[31:0]pc_o
);

reg [1:0] count;
reg clk_5;

always @ (posedge clk)begin
	if(count==2'b11)begin
		clk_5<=1'b1;
		count<=2'b11;
	end
	else begin
		clk_5<=1'b0;
		count<=count+1;
	end
end

always @(posedge clk_5) begin
	if(rst) pc_o <= 32'b0;
	else if(is_jmp) pc_o <= jmp_pc;
	else pc_o = pc_i + 32'h4;
end 
endmodule 