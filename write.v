module write(
	input [4:0] write_r;
	input write_en;
	input [31:0]write_data;
	input write_pc;
	input [31:0] jmp_pc;
	input read_mm;
	input write_mm;
	input [31:0] mm_addr;
	
)

always @(posedge clk) begin
	if(write_en)

output [4:0] write_r; //写寄存器编号
	output write_en;      //写使能
	output [31:0]write_data; //写数据
	output  write_pc; //写入pc
	output [31:0] jmp_pc;
	output read_mm;   //读mm
	output write_mm;  //写mm
	output [31:0] mm_addr; //mm地址