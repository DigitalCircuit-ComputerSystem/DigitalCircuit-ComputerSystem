module cpu(
	input rst,
	input clk,
	input [31:0] mem_read_data,   //内存读出来的内容
	//output [31:0] ans,
	input [31:0] inst,
	output wire [31:0] pc,
	output [31:0] mem_addr,  //内存访问地址
	output [31:0] mem_write_data,  //要写到内存里的内容
	output wren  //内存访问使能端
);

wire is_jmp;
wire [31:0] jmp_pc;
wire [31:0] read_data1;
wire [31:0] read_data2;
wire [31:0] write_data;
wire [4:0] address;
wire [4:0] write_reg;
wire [4:0] read_reg1;  //读的寄存器的地址
wire [4:0] read_reg2;
wire wr_en;  //写寄存器使能端
wire read_en1;  //读寄存器使能端
wire read_en2;

//assign address=pc[6:2];    //暂时用的5位pc

fetch_pc fetch_pc0 (.rst(rst), .clk(clk), .pc_i(pc), .is_jmp(is_jmp), .jmp_pc(jmp_pc), .pc_o(pc));  //取指令以及更新pc

decode decode0 (.inst(inst), .PC(pc), .reg1_data(read_data1), .reg2_data(read_data2), .wraddr(write_reg),
	.reg1_addr(read_reg1), .reg2_addr(read_reg2), .jmp_addr(jmp_pc), .wreg(wr_en), .is_jmp(is_jmp),
	.reg1_read(read_en1), .reg2_read(read_en2), .wdata(write_data), .mem_read_data(mem_data), 
	.mem_write_data(mem_write_data), .mem_addr(mem_addr), .wren(wren));

regs regs0 (.clk(clk), .write_data(write_data), .write_reg(write_reg), .write_en(wr_en), .read_reg1(read_reg1),
	.read_en1(read_en1), .read_reg2(read_reg2), .read_en2(read_en2), .read_data1_o(read_data1), .read_data2_o(read_data2), /*.ans(ans)*/);
	
//INST_ROM2 inst_rom0(.address(address),
//	.clock(clk),
//	.q(inst));
endmodule
