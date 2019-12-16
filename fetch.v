module fetch(clk, set_pc, new_pc, pc);    //chenlu: 取指令模块
//input [31:0] intr;    //取到的指令			//输入：时钟
input clk;											//输出：新的pc值
input set_pc;   //设置pc的地址
input [31:0] new_pc;
output reg [31:0] pc;



always @(posedge clk) begin
	if(set_pc) pc <= new_pc;
	else pc <= pc + 4'h4;
end
