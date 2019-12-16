module excute(  			//chenlu: 执行模块
	input clk;
	input [31:0] src1_i;   //原操作数
	input [31:0] src2_i;   
	input [31:0] dest_r;  //目的操作数
	input [31:0] ex_op_i;   //执行的指令
	input [31:0] now_pc;
	input [4:0] write_r_i; 
	input rst;
	
	output [4:0] write_r; //写寄存器编号
	output write_en;      //写使能
	output [31:0]write_data; //写数据
	output  write_pc; //写入pc
	output [31:0] jmp_pc;
	output read_mm;   //读mm
	output write_mm;  //写mm
	//output receive_jal;  
	output [31:0] mm_addr; //mm地址
	
)
//未实现指令：BEQ,BAL,BC1F,BC1FL,BC1T,COP1
wire[31:0] arith_sum;
wire of;                //溢出位
wire cond;              //判断两个源操作数是否相等
wire larger,ularger;    //有符号，无符号比较
reg [31:0] arith_data;
reg [31:0] logic_data;
reg [31:0] jmp_data;
reg [31:0] mm_data;
reg [17:0] pc_inc_data;
assign arith_sum = src1_i+src2_i;
assign of = (src1_i[31]&&src2_i[31]&& !arith_sum[31]) | (!src1_i[31]&&!src2_i[31]&& arith_sum[31]);
assign cond = (src1_i == src2_i);
assign larger = (src1_i<src2_i);
assign ularger = (src1_i[31]&!src2_i[31]) | ((src1_i[31] == src2_i[31])&&(src1_i[30:0]<src2_i[30:0]));
//arith
always @(*) begin
	case(ex_op_i)
		`EXE_ADD,`EXE_ADDU,`EXE_SUB,`EXE_SUBU: begin arith_data <= arith_sum; end
		`EXE_SLT: begin arith_data <= ularger end  //或可改用判断sum符号
		`EXE_SLTU:begin arith_data <= larger; end
	endcase 
end
		
		
		
//logic	
always @(*) begin
	case(ex_op_i) 
		`EXE_AND: begin logic_data <= src1_i & src2_i; end
		`EXE_OR:  begin logic_data <= src1_i | src2_i; end
		`EXE_XOR: begin logic_data <= src1_i ^ src2_i; end
		`EXE_NOR: begin logic_data <= ~(src1_i | src2_i); end
		`EXE_SLL: begin logic_data <= src1_i << src2_i; end  
		`EXE_SRL: begin logic_data <= src1_i >> src2_i; end //注意此处API接口统一src1/2
		`EXE_SRL: begin logic_data <= $signed(src1_i) >>> src2_i; end
	endcase
		
end
//jmp
always @(*) begin
	case(ex_op_i)
		`EXE_J,`EXE_JAR: begin jmp_data <= {now_pc[31:28],dest_i[25:0],2'b00}; end
		`EXE_BEQ, `EXE_BNE: begin jmp_data <= now_pc[31:0] + {dest[15:0],2'b00}; end
	endcase
end

//data-move
always @(*) begin
	case(ex_op_i)
		`EXE_LW, `EXE_SW: begin mm_data <= src1_i + src2_i; end
	endcase
end
	
always @(*) begin
	if(rst)  write_r <= 0; 
	else     write_r <= write_r_i;
	case(ex_sel)
		`EXE_SEL_ARITH: begin write_data <= arith_data;end
		`EXE_SEL_LOGIC: begin write_data <= logic_data;end
		`EXE_SEL_JMP:   begin jmp_pc <=jmp_data; end
		`EXE_SEL_MOV:   begin mm_addr <= mm_data; end
	endcase
	

endmodule


