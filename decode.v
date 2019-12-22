module decode(
	input [31:0] inst,  //指令码
	input [31:0] PC,
	input [31:0] reg1_data,
	input [31:0] reg2_data,
	input [31:0] mem_data;
	output reg [4:0] wraddr,   //写入的寄存器  对接regs.v的write_reg
	output reg [31:0] reg1_addr, //读的寄存器
	output reg [31:0] reg2_addr,
	output reg [31:0] jmp_addr,
	output reg wreg,
	output reg is_jmp,
	output reg reg1_read,
	output reg reg2_read,
	output reg [31:0] wdata,
	output reg [31:0] mem_addr,
	output reg wren
	);
	
reg [31:0] imm;
reg [31:0] reg1_o;  //操作数1的数据
reg [31:0] reg2_o;
reg valid;
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

assign pcadd4=PC+4;
assign pcadd8=PC+8;
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
/*在执行指令的时候需要用到inout进来的regdata，但是这个regdata比接收到ins要慢。（要先让寄存器
模块先接收到本模块传出的regaddr才能将regdata进到本模块中。*/

/*把译码和执行写到一起，就不需要写ALU*/

/*这个到时候到顶层模块调用吧
	regs decode_reg(
	.clk(clk), .write_data(wdata), .write_reg(wraddr), .write_en(wreg),
	.read_reg1(reg1_addr), .read_reg2(reg2_addr), 
	.read_en1(reg1_read), .read_en2(reg2_read),
	.read_data1_o(reg1_data), .read_data2_O(reg2_data));
*/

always @ (*) begin
	//
	//valid<=INVALID;    //先把指令设成无效
	is_jmp<=DISABLE;
	//wreg<=DISABLE;
	//reg1_read<=DISABLE;
	//reg2_read<=DISABLE;
	case(opcode)
		EXE_SPECIAL: begin    //R-type
			case(funct)
			
				EXE_ADD: begin   //rd<-rs+rt
					//aluop<=ADD;   //有符号加法
					wreg<=ENABLE;    //需要写入寄存器，默认的rd 
					reg1_read<=ENABLE;   //需要读入 rs
					reg2_read<=ENABLE;   //需要读入 rt
					valid<=VALID;    //设成有效
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg1_data+reg2_data;
				end
				
				EXE_ADDU: begin
					//aluop<=ADDU;   //无符号数
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg1_data+reg2_data;
				end
				
				EXE_SUB:begin
					//aluop<=SUB;     //有符号  rd<-rs-rt
					wreg<=ENABLE; //rd
					reg1_read<=ENABLE;  //rs
					reg2_read<=ENABLE;  //rt
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg1_data+neg;
				end
				
				EXE_SUBU:begin
					//aluop<=SUBU;     //无符号
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg1_data+neg;
				end
				
				EXE_AND:begin
					//aluop<=AND;
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg1_data&reg2_data;
				end
				
				EXE_OR:begin
					//aluop<=OR;
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg1_data|reg2_data;
				end
				
				EXE_XOR:begin
					//aluop<=XOR;
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg1_data^reg2_data;
				end
				
				EXE_NOR:begin
					//aluop<=NOR;
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=~(reg1_data|reg2_data);
				end
				
				EXE_SLT:begin
					//aluop<=SLT;
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					if(reg1_data<reg2_data)wdata<=1;
					else wdata<=0;  //有符号
				end
				
				EXE_SLTU:begin
					//aluop<=SLTU;   //无符号
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					if(reg1_data<reg2_data)wdata<=1;
					else wdata<=0;
				end
				
				EXE_SLL:begin
					//aluop<=SLL;
					wreg<=ENABLE;   //rd
					reg1_read<=DISABLE;  //rs
					reg2_read<=ENABLE;  //rt
					valid<=VALID;    //rd=rt<<shamt
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg2_data<<shamt;
				end
				
				EXE_SRL:begin
					//aluop<=SRL;   //逻辑右移
					wreg<=ENABLE; 
					reg1_read<=DISABLE;   //rs
					reg2_read<=ENABLE;   //rt
					valid<=VALID;    //rd=rt>>shamt
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg2_data>>shamt;
				end
				
				EXE_SRA:begin
					//aluop<=SRA;   //算数右移
					wreg<=ENABLE; 
					reg1_read<=DISABLE;   //rs
					reg2_read<=ENABLE;  //rt
					valid<=VALID;   //rd=rt>>shamt
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=$signed(reg2_data)>>>shamt;
				end
				
				EXE_SLLV:begin
					//aluop<=SLLV;    //rd=rt<<rs
					wreg<=ENABLE; 
					reg1_read<=ENABLE; 
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg2_data<<reg1_data;
				end
				
				EXE_SRLV:begin
					//aluop<=SRLV;    //rd=rt>>rs 逻辑
					wreg<=ENABLE; 
					reg1_read<=ENABLE; 
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=reg2_data>>reg1_data;
				end
				
				EXE_SRAV:begin
					//aluop<=SRAV;    //rd=rt>>rs 算数
					wreg<=ENABLE; 
					reg1_read<=ENABLE; 
					reg2_read<=ENABLE;
					valid<=VALID;
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					wdata<=$signed(reg2_data)>>>reg1_data;
				end
				
				EXE_JR:begin
					//aluop<=JR;    //PC<-rs
					wreg<=DISABLE;  //rd 
					reg1_read<=ENABLE;   //rs
					reg2_read<=DISABLE;   //rt
					wraddr<=rd;   //默认写入rd
					reg1_addr<=rs;//reg1默认rs
					reg2_addr<=rt;//reg2默认rt
					valid<=VALID;
					jmp_addr<=reg1_o;
					is_jmp<=ENABLE;
				end
				default:begin
				end
			endcase
			end
		
		EXE_ADDI:begin   //I-type   rt<-rs+(sign-extended)immediate
			//aluop<=ADD;   //同样用加法器
			wreg<=ENABLE;  //rt
			reg1_read<=ENABLE;  //rs
			reg2_read<=DISABLE;
			valid<=VALID;
			imm<=imm_sext;   //符号扩展
			wraddr<=rt;   //不是默认的rd
			reg1_addr<=rs;//reg1默认rs
			wdata<=reg1_o+reg2_o;  //这里的reg2_o是imm
		end
		
		EXE_ADDIU:begin
			//aluop<=ADDU;
			wreg<=ENABLE;
			reg1_read<=ENABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm<=imm_zext;   //零扩展
			wraddr<=rt;
			reg1_addr<=rs;//reg1默认rs
			wdata<=reg1_o+reg2_o;  //这里的reg2_o是imm
		end
		
		EXE_ANDI:begin
			//aluop<=AND;
			wreg<=ENABLE;
			reg1_read<=ENABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm<=imm_zext;   //零扩展
			wraddr<=rt;
			reg1_addr<=rs;//reg1默认rs
			wdata<=reg1_o&imm;
		end
		//001100 00001 00011 
		EXE_ORI:begin
			//aluop<=OR;
			wreg<=ENABLE;
			reg1_read<=ENABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm<=imm_zext;   //零扩展
			wraddr<=rt;
			reg1_addr<=rs;//reg1默认rs
			wdata<=reg1_o|imm;
		end
		
		EXE_XORI:begin
			//aluop<=XOR;
			wreg<=ENABLE;
			reg1_read<=ENABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_zext;   //零扩展
			wraddr<=rt;
			reg1_addr<=rs;//reg1默认rs
			wdata<=reg1_o^imm;
		end
		
		EXE_LUI:begin
			//aluop<=LUI;   //将16位立即数放到目标寄存器高16位，低16位填0
			wreg<=ENABLE;
			reg1_read<=DISABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm<={Iimm[15:0],16'H0};  //imm*65536
			wraddr<=rt;
			wdata<=imm;
		end
		
		EXE_LW:begin
		//不确定
			//aluop<=LW;    //$1=memory[$2+10]
			wreg<=ENABLE; 
			reg1_read<=ENABLE; 
			reg2_read<=DISABLE;
			wraddr<=rt;
			reg1_addr<=rs;//reg1默认rs
			valid<=VALID;
			imm<=imm_sext;   //符号扩展
			mem_addr<=reg1_o+imm;
			wren<=1'b0;  //读内存
			wdata<=mem_data;
		end
		
		EXE_SW:begin
		//不确定
			//aluop<=SW;    //memory[$2+10]=$1
			wreg<=DISABLE; 
			reg1_read<=ENABLE; 
			reg2_read<=ENABLE;
			valid<=VALID;
			reg1_addr<=rs;//reg1默认rs
			reg2_addr<=rt;//reg2默认rt
			imm<=imm_sext;   //符号扩展
			wren<=1'b1;  //写内存
			mem_addr<=reg1_o+imm;
			mem_data<=reg2_o;
		end
		
		EXE_BEQ:begin
			//aluop<=BEQ;
			wreg<=DISABLE;
			reg1_read<=ENABLE;
			reg2_read<=ENABLE;
			valid<=VALID;
			imm<=imm_sext_mov2;
			reg1_addr<=rs;//reg1默认rs
			reg2_addr<=rt;//reg2默认rt
			if(reg1_o==reg2_o)begin
				//jmp_flag<=1;
				jmp_addr<=pcadd4+imm;
				is_jmp<=ENABLE;
			end
		end
		
		EXE_BNE:begin    //和BEQ类似，只不过是不等于
			//aluop<=BNE;
			wreg<=DISABLE;
			reg1_read<=ENABLE;
			reg2_read<=ENABLE;
			valid<=VALID;
			imm<=imm_sext_mov2;
			reg1_addr<=rs;//reg1默认rs
			reg2_addr<=rt;//reg2默认rt
			if(reg1_o!=reg2_o)begin
				//jmp_flag<=1;
				jmp_addr<=pcadd4+imm;
				is_jmp<=ENABLE;
			end
		end
		
		EXE_SLTI:begin
			//aluop<=SLT;   
			wreg<=ENABLE;  //rt
			reg1_read<=ENABLE;  //rs
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_sext;   //符号扩展
			wraddr<=rt;
			reg1_addr<=rs;//reg1默认rs
			if(reg1_o<imm)wdata<=1;
			else wdata<=0;
		end
		
		EXE_SLTIU:begin
			//aluop<=SLT; 
			wreg<=ENABLE;  //rt
			reg1_read<=ENABLE;  //rs
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_zext;   //零扩展
			wraddr<=rt;
			reg1_addr<=rs;//reg1默认rs
			if(reg1_o<imm)wdata<=1;
			else wdata<=0;
		end
		
		//EXE_PREF:begin
			
		//end
		EXE_BLEZ:begin
			//aluop<=BLEZ;
			wreg<=DISABLE;
			reg1_read<=DISABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			if(reg1_o[31]==1||reg1_o==31'd0)begin
				imm<=pcadd4+imm_sext_mov2;
				//jmp_flag<=1;
				jmp_addr<=imm;
				is_jmp<=ENABLE;
			end
		end
		
		//EXE_BGTZ:begin
		//end
		//EXE_REGIMM:  //先不写吧
		EXE_J:begin
			//aluop<=J;
			wreg<=DISABLE;
			reg1_read<=DISABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm<={{pcadd4[31:28]},Jimm,{2'b00}};
			//jmp_flag<=1;
			jmp_addr<=imm;
			is_jmp<=ENABLE;
		end
		
		
		EXE_JAL:begin
			//aluop<=JAL;
			wreg<=ENABLE;
			reg1_read<=DISABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			wraddr<=5'b11111;  //貌似是$31
			imm<={{pcadd4[31:28]},Jimm,{2'b00}};
			wdata<=pcadd8;
			//jmp_flag<=1;
			jmp_addr<=imm;
			is_jmp<=ENABLE;
		end
		
		//EX_LB:begin
		//end
		//EX_LBU:begin
		//end
		default:begin
		end
	endcase
end
	
always @ (*)begin
	if(reg1_read==ENABLE)reg1_o<=reg1_data;
	else reg1_o<=imm;
end
	
always @ (*)begin
	if(reg2_read==ENABLE)reg2_o<=reg2_data;
	else reg2_o<=imm;
end
endmodule 