module cpu(
	input rst;
	input clk;
	input[31:0] data_rom_i;  //指令文件
	output[31:0] addr_rom_o;
)

wire pc;

wire[31:0]intr;
wire [31:0]seq_pc;
wire is_jmp;
wire jmp_pc;
wire [31:0] src1;     //值
wire [31:0] src2;
wire [31:0] dest;
wire [33:0] src1_type;  //高两位为类型 ，00：常数， 01：寄存器，此时type低5位为寄存器号， 10：内存，此时type低32位为内存地址
wire [33:0] src2_type;
wire [33:0] dest_type;

fetch_pc fetch_pc0 (.rst(rst), .clk(clk), .pc_i(pc), .is_jmp(is_jmp), .jmp_pc(jmp_pc), .pc_o(pc);  //取指令以及更新pc



