module decode(
	input [31:0] ins,  //指令码
	//input clk,
	input [31:0]PC;
	input [31:0] reg1_data;
	input [31:0] reg2_data;
	output reg [4:0] wraddr,   //写入的寄存器
	output reg aluop,  //要写个alu
	output reg [4:0] shift,   //移位指令的位数
	output reg [31:0] imm,    //输出的立即数
	output reg [31:0] addrout,   //JAL指令用
	output reg [31:0] reg1_addr; //读的寄存器
	output reg [31:0] reg2_addr;
	output reg [31:0] reg1_o;  //输出的数据
	output reg [31:0] reg2_o;
	output reg jmp_flag;
	output reg [31:0] jmp_addr;
	);
	
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

assign pcadd4=PC+4;
assign pcadd8=PC+8;
assign imm_sext_mov2={{14{Iimm[15]}},Iimm[15:0],2'b00};
assign imm_sext={{16{Iimm[15]},Iimm[15:0]}};
assign imm_zext={16'H0,Iimm[15:0]};

parameter EXE_SPECIAL=6'b000000;   //R-type到时候写到宏里
parameter EXE_ADD=6'b100000,
			 EXE_ADDU=6'b100001,
			 EXE_SUB=6'b100010,
			 EXE_SUBU=6'b100011,
			 //......
			 
			
always @ (*) begin
	//
	valid<=INVALID;    //先把指令设成无效
	wraddr<=rd;   //默认写入rd
	reg1_addr<=rs;//reg1默认rs
	reg2_addr<=rt;//reg2默认rt
	jmp_flag=0;
	case(opcode)begin	
		EXE_SPECIAL: begin    //R-type
			case(funct)begin
			
				EXE_ADD:begin   //rd<-rs+rt
					aluop<=ADD;   //有符号加法
					wreg<=ENABLE;    //需要写入寄存器，默认的rd 
					reg1_read<=ENABLE;   //需要读入 rs
					reg2_read<=ENABLE;   //需要读入 rt
					valid<=VALID;    //设成有效
				end
				
				EXE_ADDU:begin
					aluop<=ADDU;   //无符号数
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				
				EXE_SUB:begin
					aluop<=SUB;     //有符号  rd<-rs-rt
					wreg<=ENABLE; //rd
					reg1_read<=ENABLE;  //rs
					reg2_read<=ENABLE;  //rt
					valid<=VALID;
				end
				
				EXE_SUBU:begin
					aluop<=SUBU;     //无符号
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				
				EXE_AND:begin
					aluop<=AND;
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				
				EXE_OR:begin
					aluop<=OR;
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				
				EXE_XOR:begin
					aluop<=XOR;
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				
				EXE_NOR:begin
					aluop<=NOR;
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				
				EXE_SLT:begin
					aluop<=SLT;
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				EXE_SLTU:begin
					aluop<=SLTU;   //无符号
					wreg<=ENABLE; 
					reg1_read<=ENABLE;
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				EXE_SLL:begin
					aluop<=SLL;
					wreg<=ENABLE;   //rd
					reg1_read<=DISABLE;  //rs
					reg2_read<=DENABLE;  //rt
					valid<=VALID;
					shift<=shamt;   //rd=rt<<shamt
				end
				EXE_SRL:begin
					aluop<=SRL;   //逻辑右移
					wreg<=ENABLE; 
					reg1_read<=DISABLE;   //rs
					reg2_read<=ENABLE;   //rt
					valid<=VALID;
					shift<=shamt;   //rd=rt>>shamt
				end
				EXE_SRA:begin
					aluop<=SRA;   //算数右移
					wreg<=ENABLE; 
					reg1_read<=DISABLE;   //rs
					reg2_read<=ENABLE;  //rt
					valid<=VALID;
					shift<=shamt;   //rd=rt>>shamt
				end
				EXE_SLLV:begin
					aluop<=SLL;    //rd=rt<<rs
					wreg<=ENABLE; 
					reg1_read<=ENABLE; 
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				EXE_SRLV:begin
					aluop<=SRL;    //rd=rt<<rs 逻辑
					wreg<=ENABLE; 
					reg1_read<=ENABLE; 
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				EXE_SRAV:begin
					aluop<=SRA;    //rd=rt<<rs 算数
					wreg<=ENABLE; 
					reg1_read<=ENABLE; 
					reg2_read<=ENABLE;
					valid<=VALID;
				end
				EXE_JR:begin
					aluop<=JR;    //PC<-rs
					wreg<=DISABLE;  //rd 
					reg1_read<=ENABLE;   //rs
					reg2_read<=DISABLE;   //rt
					valid<=VALID;
					jmp_flag<=1;
					jmp_addr<=reg1_o;
				end
				default:begin
				end
			endcase
			end
		end
		EXE_ADDI:begin   //I-type   rt<-rs+(sign-extended)immediate
			aluop<=ADD;   //同样用加法器
			wreg<=ENABLE;  //rt
			reg1_read<=ENABLE;  //rs
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_sext;   //符号扩展
			wraddr<=rt;   //不是默认的rd
		end
		EXE_ADDIU:begin
			aluop<=ADDU;
			wreg<=ENABLE;
			reg1_read<=ENABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_zext;   //零扩展
			wraddr<=rt;
		end
		EXE_ANDI:begin
			aluop<=AND;
			wreg<=ENABLE;
			reg1_read<=ENABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_zext;   //零扩展
			wraddr<=rt;
		end
		EXE_ORI:begin
			aluop<=OR;
			wreg<=ENABLE;
			reg1_read<=ENABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_zext;   //零扩展
			wraddr<=rt;
		end
		EXE_XORI:begin
			aluop<=XOR;
			wreg<=ENABLE;
			reg1_read<=ENABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_zext;   //零扩展
			wraddr<=rt;
		end
		EXE_LUI:begin
			aluop<=LUI;   //将16位立即数放到目标寄存器高16位，低16位填0
			wreg<=ENABLE;
			reg1_read<=DISABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_zext;   //零扩展
			wraddr<=rt;
		end
		EXE_LW:begin
		//不确定
			aluop<=LW;    //$1=memory[$2+10]
			wreg<=ENABLE; 
			reg1_read<=ENABLE; 
			reg2_read<=DISABLE;
			wraddr<=rt;
			valid<=VALID;
			imm=imm_sext;   //符号扩展
		end
		EXE_SW:begin
		//不确定
			aluop<=SW;    //memory[$2+10]=$1
			wreg<=DISABLE; 
			reg1_read<=ENABLE; 
			reg2_read<=ENABLE;
			valid<=VALID;
			imm=imm_sext;   //符号扩展
		end
		EXE_BEQ:begin
			aluop<=BEQ;
			wreg<=DISABLE;
			reg1_read<=ENABLE;
			reg2_read<=ENABLE;
			valid<=VALID;
			imm=imm_sext_mov2;
			if(reg1_o==reg2_o)begin
				jmp_flag<=1;
				jmp_addr<=pcadd4+imm;
			end
		end
		EXE_BNE:begin    //和BEQ类似，只不过是不等于
			aluop<=BNE;
			wreg<=DISABLE;
			reg1_read<=ENABLE;
			reg2_read<=ENABLE;
			valid<=VALID;
			imm=imm_sext_mov2;
			if(reg1_o!=reg2_o)begin
				jmp_flag<=1;
				jmp_addr<=pcadd4+imm;
			end
		end
		EXE_SLTI:begin
			aluop<=SLT;   
			wreg<=ENABLE;  //rt
			reg1_read<=ENABLE;  //rs
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_sext;   //符号扩展
			wraddr<=rt;
		end
		EXE_SLTIU:begin
			aluop<=SLT; 
			wreg<=ENABLE;  //rt
			reg1_read<=ENABLE;  //rs
			reg2_read<=DISABLE;
			valid<=VALID;
			imm=imm_zext;   //零扩展
			wraddr<=rt;
		end
		//EXE_PREF:begin
			
		//end
		EXE_BLEZ:begin
			aluop<=BLEZ;
			wreg<=DISABLE;
			reg1_read<=DISABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			if(reg1_o[31]==1||reg1_o=31'd0)begin
				imm=pcadd4+imm_sext_mov2;
				jmp_flag<=1;
				jmp_addr<=imm;
			end
		end
		//EXE_BGTZ:begin
		//end
		//EXE_REGIMM:  //先不写吧
		EXE_J:begin
			aluop<=J;
			wreg<=DISABLE;
			reg1_read<=DISABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			imm={{pcadd4[31:28]},Jimm,2'b00};
			jmp_flag<=1;
			jmp_addr<=imm;
		end
		EXE_JAL:begin
			aluop<=JAL;
			wreg<=ENABLE;
			reg1_read<=DISABLE;
			reg2_read<=DISABLE;
			valid<=VALID;
			wraddr<=5'b11111;  //貌似是$31
			imm={{pcadd4[31:28]},Jimm,2'b00};
			addrout<=pcadd8;
			jmp_flag<=1;
			jmp_addr<=imm;
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
					
					
			