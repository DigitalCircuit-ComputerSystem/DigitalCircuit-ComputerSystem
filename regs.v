module regs(  // chenlu: 寄存器模块，输入写数据
	input wire clk;  
	input [31:0] write_data; 		//写数据
	input [4:0]  write_reg;  		//写入寄存器的id
	input wire write_en;          //写数据使能端, 高电平有效
	input [4:0]  read_reg1;	 		//读寄存器的id
	input wire read_en1;  			//读数据使能端，高电平有效 		
	input [4:0]  read_reg2;	 		
	input wire read_en2;  			
	output [31:0] read_data1_o; 	//读出数据
	output [31:0] read_data2_o;
);  
/* 问题：读写数据可能发生冲突，暂时通过不同的时钟沿避免冲突，之后考虑如何修改  */
reg[31:0] all_reg[31:0];    //cpu内部32个寄存器

//写数据模块
always @(posedge clk) begin
		if(write_en) begin
			all_reg[write_reg] <= write_data;
		end
end

always @(negedge clk) begin  
	if(read_en1) begin
		read_data1_o <= all_reg[read_reg1];
	end
	if(read_en2) begin
		read_data2_o <= all_reg[read_reg2];
	end
end

endmodule
			