module cpu(
	input rst,
	input clk,
	input [31:0] mem_read_data,   //内存读出来的内容
	//output [31:0] ans,
	input [31:0] inst,
	output reg [31:0] pc,
	output reg [31:0] mem_addr,  //内存访问地址
	output reg [31:0] mem_write_data,  //要写到内存里的内容
	output reg wren,  //内存访问使能端
	output wire [31:0] r31
);

reg is_jmp;
reg [31:0] jmp_addr;
reg [31:0] reg1_data;
reg [31:0] reg2_data;
reg [31:0] wdata;
reg [4:0] wraddr;
reg [4:0] reg1_addr;  //读的寄存器的地址
reg [4:0] reg2_addr;
initial begin
	pc = 0;
end
//assign address=pc[6:2];    //暂时用的5位pc

/*fetch_pc fetch_pc0 (.rst(rst), .clk(clk), .pc_i(pc), .is_jmp(is_jmp), .jmp_pc(jmp_pc), .pc_o(pc));  //取指令以及更新pc

decode decode0 (.inst(inst), .PC(pc), .reg1_data(read_data1), .reg2_data(read_data2), .wraddr(write_reg),
	.reg1_addr(read_reg1), .reg2_addr(read_reg2), .jmp_addr(jmp_pc), .wreg(wr_en), .is_jmp(is_jmp),
	.reg1_read(read_en1), .reg2_read(read_en2), .wdata(write_data), .mem_read_data(mem_data), 
	.mem_write_data(mem_write_data), .mem_addr(mem_addr), .wren(wren));

regs regs0 (.clk(clk), .write_data(write_data), .write_reg(write_reg), .write_en(wr_en), .read_reg1(read_reg1),
	.read_en1(read_en1), .read_reg2(read_reg2), .read_en2(read_en2), .
	(read_data1), .read_data2_o(read_data2));
*/
	
reg [31:0] imm;
reg[31:0] all_reg[31:0];    //cpu内部32个寄存器
assign r31 = all_reg[31];
wire [5:0] opcode=inst[31:26];
wire [4:0] rs=inst[25:21];    //R-type&I-type
wire [4:0] rt=inst[20:16];    //R-type&I-type
wire [4:0] rd=inst[15:11];    //R-type
wire [4:0] shamt=inst[10:6];  //R-type
wire [5:0] funct=inst[5:0];   //R-type
wire [15:0] Iimm=inst[15:0];  //I-type
wire [25:0] Jimm=inst[25:0];  //J-type

wire [31:0] pcadd4;
wire [31:0] pcadd8;
wire [31:0] imm_sext_mov2;
wire [31:0] imm_sext;
wire [31:0] imm_zext;
wire [31:0] neg;

assign pcadd4=pc+4;
assign pcadd8=pc+8;
assign imm_sext_mov2={{14{Iimm[15]}},Iimm[15:0],2'b00};  //符号扩展再左移两位
assign imm_sext={{16{Iimm[15]}},Iimm[15:0]};   //符号扩展
assign imm_zext={16'H0,Iimm[15:0]};   //零扩展
assign neg=(~reg2_data)+1;

parameter INVALID=1'b0;
parameter VALID=1'b1;
parameter ENABLE=1'b1;
parameter DISABLE=1'b0;	
parameter EXE_SPECIAL=6'b000000;
parameter EXE_ADD=6'b100000;
parameter EXE_ADDU=6'b100001;
parameter EXE_SUB=6'b100010;
parameter EXE_SUBU=6'b100011;
parameter EXE_AND=6'b100100;
parameter EXE_OR=6'b100101;
parameter EXE_XOR=6'b100110;
parameter EXE_NOR=6'b100111;
parameter EXE_SLT=6'b101010;
parameter EXE_SLTU=6'b101011;
parameter EXE_SLL=6'b000000;
parameter EXE_SRL=6'b000010;
parameter EXE_SRA=6'b000011;
parameter EXE_SLLV=6'b000100;
parameter EXE_SRLV=6'b000110;
parameter EXE_SRAV=6'b000111;
parameter EXE_JR=6'b001000;
parameter EXE_ADDI=6'b001000;
parameter EXE_ADDIU=6'b001001;
parameter EXE_ANDI=6'b001100;
parameter EXE_ORI=6'b001101;
parameter EXE_XORI=6'b001110;
parameter EXE_LUI=6'b001111;
parameter EXE_LW=6'b100011;
parameter EXE_SW=6'b101011;
parameter EXE_BEQ=6'b000100;
parameter EXE_BNE=6'b000101;
parameter EXE_SLTI=6'b001010;
parameter EXE_SLTIU=6'b001011;
parameter  EXE_BLEZ=6'b000110;
parameter  EXE_J=6'b000010;
parameter  EXE_JAL=6'b000011;
parameter  EXE_LBU=6'b100100;
/*在执行指令的时候需要用到inout进来的regdata，但是这个regdata比接收到ins要慢。（要先让寄存器
模块先接收到本模块传出的regaddr才能将regdata进到本模块中。*/

/*把译码和执行写到一起，就不需要写ALU*/

/*这个到时候到顶层模块调用吧
	regs decode_reg(
	.clk(clk), .write_data(wdata), .write_reg(wraddr), .write_en(wreg),
	.read_reg1(reg1_addr), .read_reg2(reg2_addr), 
	.read_en1(reg1_read), .read_en2(reg2_read),
	.reg1_data(reg1_data), .read_data2_O(reg2_data));
*/



always @ (posedge clk) begin

	if(rst) pc <= 32'b0;
	else if(is_jmp)pc<=pc;
	else pc <= pc + 32'd4;
	
	case(opcode)
		EXE_SPECIAL: begin    //R-type
			case(funct)
			
				EXE_ADD: begin   //rd<-rs+rt
					is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg1_data+reg2_data;
					all_reg[wraddr] <= wdata;    //需要写入寄存器，默认的rd 
				end
				
				EXE_ADDU: begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg1_data+reg2_data;
					all_reg[wraddr] <= wdata;    //需要写入寄存器，默认的rd 
				end
				
				EXE_SUB:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg1_data+neg;
					all_reg[wraddr] <= wdata;    //需要写入寄存器，默认的rd 
				end
				
				EXE_SUBU:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg1_data+neg;
					all_reg[wraddr] <= wdata;    //需要写入寄存器，默认的rd 
				end
				
				EXE_AND:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg1_data&reg2_data;
					all_reg[wraddr] <= wdata;    //需要写入寄存器，默认的rd 
				end
				
				EXE_OR:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg1_data|reg2_data;
					all_reg[wraddr] <= wdata;    //需要写入寄存器，默认的rd 
				end
				
				EXE_XOR:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg1_data^reg2_data;
					all_reg[wraddr] <= wdata;    //需要写入寄存器，默认的rd 
				end
				
				EXE_NOR:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=~(reg1_data|reg2_data);
					all_reg[wraddr] <= wdata;    //需要写入寄存器，默认的rd 
				end
				
				EXE_SLT:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					if(reg1_data<reg2_data)wdata<=1;
					else wdata<=0;  //有符号
					all_reg[wraddr] <= wdata;    //需要写入寄存器，默认的rd 
				end
				
				EXE_SLTU:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					if(reg1_data<reg2_data)wdata<=1;
					else wdata<=0;  //有符号
					all_reg[wraddr] <= wdata;    //需要写入寄存器，默认的rd 
				end
				
				EXE_SLL:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg2_addr<=rt;//reg2默认rt
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg2_data<<shamt;
					all_reg[wraddr] <= wdata;
				end
				
				EXE_SRL:begin
					wraddr<=rd;   //默认写入rd
					reg2_addr<=rt;//reg2默认rt
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg2_data>>shamt;
					all_reg[wraddr] <= wdata;
				end
				
				EXE_SRA:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg2_addr<=rt;//reg2默认rt
					reg2_data<= all_reg[reg2_addr];
					wdata<=$signed(reg2_data)>>>shamt;
					all_reg[wraddr] <= wdata;
				end
				
				EXE_SLLV:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg2_data<<reg1_data;
					all_reg[wraddr] <= wdata;
				end
				
				EXE_SRLV:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=reg2_data>>reg1_data;
					all_reg[wraddr] <= wdata;
				end
				
				EXE_SRAV:begin
				is_jmp<=0;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					reg1_data<= all_reg[reg1_addr];
					reg2_data<= all_reg[reg2_addr];
					wdata<=$signed(reg2_data)>>>reg1_data;
					all_reg[wraddr] <= wdata;
				end
				
				EXE_JR:begin
				is_jmp<=1;
					reg1_addr<=rs;//reg1默认rs
					reg1_data<= all_reg[reg1_addr];
					jmp_addr<=reg1_data;
					pc<=jmp_addr;
				end
				default:begin
				end
			endcase
			end
		
		EXE_ADDI:begin   //I-type   rt<-rs+(sign-extended)immediate			
		is_jmp<=0;
			wraddr<=rt;   //默认写入rd
			reg1_addr<=rs;//reg1默认rs
			reg1_data<= all_reg[reg1_addr];
			imm<=imm_sext;   //符号扩展
			wdata<=reg1_data+imm;  //这里的reg2_o是imm
			all_reg[wraddr] <= wdata;
		end
		
		EXE_ADDIU:begin
		is_jmp<=0;
			wraddr<=rt;   //默认写入rd
			reg1_addr<=rs;//reg1默认rs
			reg1_data<= all_reg[reg1_addr];
			imm<=imm_zext;   //符号扩展
			wdata<=reg1_data+imm;  //这里的reg2_o是imm
			all_reg[wraddr] <= wdata;
		end
		
		EXE_ANDI:begin
		is_jmp<=0;
			wraddr<=rt;   //默认写入rd
			reg1_addr<=rs;//reg1默认rs
			reg1_data<= all_reg[reg1_addr];
			imm<=imm_zext;   //零扩展
			wdata<=reg1_data&imm;
			all_reg[wraddr] <= wdata;
		end
		//001100 00001 00011 
		EXE_ORI:begin
		is_jmp<=0;
			wraddr<=rt;   //默认写入rd
			reg1_addr<=rs;//reg1默认rs
			reg1_data<= all_reg[reg1_addr];
			imm<=imm_zext;   //零扩展
			wdata<=reg1_data|imm;
			all_reg[wraddr] <= wdata;
		end
		
		EXE_XORI:begin
		is_jmp<=0;
			wraddr<=rt;   //默认写入rd
			reg1_addr<=rs;//reg1默认rs
			reg1_data<= all_reg[reg1_addr];
			imm<=imm_zext;   //零扩展
			wdata<=reg1_data^imm;
			all_reg[wraddr] <= wdata;
		end
		
		EXE_LUI:begin
		is_jmp<=0;
			//aluop<=LUI;   //将16位立即数放到目标寄存器高16位，低16位填0
			wraddr<=rt;
			imm<={Iimm[15:0],16'H0};  //imm*65536
			wdata<=imm;
			all_reg[wraddr] <= wdata;
		end
		
		EXE_LW:begin
		is_jmp<=0;
		//不确定
			//aluop<=LW;    //$1=memory[$2+10]
			wraddr<=rt;   //默认写入rd
			reg1_addr<=rs;//reg1默认rs
			reg1_data<= all_reg[reg1_addr];
			imm<=imm_sext;   //符号扩展
			mem_addr<=reg1_data+imm;
			wren<=1'b0;  //读内存
			wdata<=mem_read_data;
			all_reg[wraddr] <= wdata;
		end
		
		EXE_SW:begin
		is_jmp<=0;
		//不确定
			//aluop<=SW;    //memory[$2+10]=$1
			reg1_addr<=rs;//reg1默认rs
			reg2_addr<=rt;//reg2默认rt
			reg1_data<= all_reg[reg1_addr];
			reg2_data<= all_reg[reg2_addr];
			imm<=imm_sext;   //符号扩展
			wren<=1'b1;  //写内存
			mem_addr<=reg1_data+imm;
			mem_write_data<=reg2_data;
		end
		
		EXE_BEQ:begin
		is_jmp<=1;
			//aluop<=BEQ;
			imm<=imm_sext_mov2;
			reg1_addr<=rs;//reg1默认rs
			reg2_addr<=rt;//reg2默认rt
			reg1_data<= all_reg[reg1_addr];
			reg2_data<= all_reg[reg2_addr];
			if(reg1_data==reg2_data)begin
				//_flag<=1;
				jmp_addr<=pcadd4+imm;
				pc<=jmp_addr;
			end
		end
		
		EXE_BNE:begin    //和BEQ类似，只不过是不等于
		is_jmp<=1;
			//aluop<=BEQ;
			imm<=imm_sext_mov2;
			reg1_addr<=rs;//reg1默认rs
			reg2_addr<=rt;//reg2默认rt
			reg1_data<= all_reg[reg1_addr];
			reg2_data<= all_reg[reg2_addr];
			if(reg1_data!=reg2_data)begin
				//_flag<=1;
				jmp_addr<=pcadd4+imm;
				pc<=jmp_addr;
			end
		end
		
		EXE_SLTI:begin
		is_jmp<=0;
			imm=imm_sext;   //符号扩展
			wraddr<=rt;
			reg1_addr<=rs;//reg1默认rs
			reg1_data<= all_reg[reg1_addr];
			if(reg1_data<imm)wdata<=1;
			else wdata<=0;
			all_reg[wraddr] <= wdata;
		end
		
		EXE_SLTIU:begin
		is_jmp<=0;
			imm=imm_zext;   //符号扩展
			wraddr<=rt;
			reg1_addr<=rs;//reg1默认rs
			reg1_data<= all_reg[reg1_addr];
			if(reg1_data<imm)wdata<=1;
			else wdata<=0;
			all_reg[wraddr] <= wdata;
		end
		
		//EXE_PREF:begin
			
		//end
		EXE_BLEZ:begin
		is_jmp<=1;
			//aluop<=BLEZ;
			reg1_addr<=rs;//reg1默认rs
			reg1_data<= all_reg[reg1_addr];
			if(reg1_data[31]==1||reg1_data==31'd0)begin
				imm<=pcadd4+imm_sext_mov2;
				//jmp_flag<=1;
				jmp_addr<=imm;
				pc<=jmp_addr;
			end
		end
		
		//EXE_BGTZ:begin
		//end
		//EXE_REGIMM:  //先不写吧
		EXE_J:begin
			is_jmp<=1;
			imm<={{pcadd4[31:28]},Jimm,{2'b00}};
			//jmp_flag<=1;
			jmp_addr<=imm;
			pc<=jmp_addr;
		end
		
		
		EXE_JAL:begin
		is_jmp<=1;
			//aluop<=JAL;
			//wreg<=ENABLE;
			wraddr<=5'b11111;  //貌似是$31
			imm<={{pcadd4[31:28]},Jimm,{2'b00}};
			wdata<=pcadd8;
			all_reg[wraddr] <= wdata;
			jmp_addr<=imm;
			pc<=jmp_addr;
		end
		
		//EX_LB:begin
		//end
		EXE_LBU:begin
		is_jmp<=0;
			wraddr<=rt;   //默认写入rd
			reg1_addr<=rs;//reg1默认rs
			reg1_data<= all_reg[reg1_addr];
			imm<=imm_sext;   //符号扩展
			mem_addr<=reg1_data+imm;
			wren<=1'b0;  //读内存
			case(mem_addr[1:0])
				2'b00:wdata<={{24{1'b0}},mem_read_data[31:24]};
				2'b01:wdata<={{24{1'b0}},mem_read_data[23:16]};
				2'b10:wdata<={{24{1'b0}},mem_read_data[15:8]};
				2'b11:wdata<={{24{1'b0}},mem_read_data[7:0]};
				default:begin
				end
			endcase
			all_reg[wraddr] <= wdata;
		end
		
		default:begin
		end
	endcase
end
	
/*always @ (*)begin
	if(reg1_read==ENABLE)reg1_o<=reg1_data;
	else reg1_o<=imm;
end
	
always @ (*)begin
	if(reg2_read==ENABLE)reg2_o<=reg2_data;
	else reg2_o<=imm;
end
*/
//写数据模块
/*
always @(*) begin
		if(wreg) begin
			all_reg[wraddr] <= wdata;
		end
end

always @(*) begin  
	if(reg1_read) begin
		 reg1_data<= all_reg[reg1_addr];
	end
	if(reg2_read) begin
		reg2_data <= all_reg[reg2_addr];
	end
end
*/
//INST_ROM2 inst_rom0(.address(address),
//	.clock(clk),
//	.q(inst));
endmodule
