module fsm(clk,data,asc,ascv,asch,en,markh,markv); 
input clk, data;
//output wire[13:0]asc_show,pred_show,cou_show;
reg [11:0]cou;
reg [7:0]mem [255:0];
output reg[7:0]asc;
output reg en;
reg[7:0] pred;
output reg[6:0] asch;			//列坐标
output reg[4:0] ascv;  //行坐标  ，将cou进行转换   两个用于上层对数据进行写入
output reg[6:0] markh;		
output reg[4:0] markv;
reg [7:0]nowd;
parameter [4:0] ini = 5'b00000, in0 = 5'b00001, in1 = 5'b00011, in2 = 5'b00010,
					 in3 = 5'b00110, in4 = 5'b00111, in5 = 5'b00101, in6 = 5'b00100,
					 in7 = 5'b01100, jud = 5'b01101, fin = 5'b01111;
parameter [2:0] dep0 = 3'b000, dep1 = 3'b001, dep2 = 3'b011, outdep1 = 3'b010, outdep2 = 3'b110;
parameter vbound = 30;
parameter hbound = 70;   //我没有加超过vbound的判断
reg[6:0] line_end[29:0]; //用于标识每一行的最后字符的位置(光标位置)
reg[11:0] mark;  //前5个标识纵坐标，后7个标识横坐标  //用于标识当前位置（光标位置）
reg [4:0]nows;

 reg[1:0]indi;  //0:正常，1:shift, 2:ctrl
 reg[2:0]con;
reg upper;
reg conen;
initial 
begin
  cou = 0;
  nows = ini;
  con = dep0;
  upper = 0;
  indi = 0;
  asch = 0;
  ascv = 0;
  markh = 1;
  markv = 0;
  $readmemh("D:/program/FPGA/8/mem.txt", mem, 0, 255);
end

always @(negedge clk) begin
	//en = 0;
	//conen <= 0;
	case(nows)
		ini: begin nows <= in0; conen <= 0;end
		in0: begin nowd[0] = data; nows <= in1; conen <= 0; end
		in1: begin nowd[1] = data; nows <= in2; conen <= 0; end
		in2: begin nowd[2] = data; nows <= in3; conen <= 0; end
		in3: begin nowd[3] = data; nows <= in4; conen <= 0; end
		in4: begin nowd[4] = data; nows <= in5; conen <= 0; end
		in5: begin nowd[5] = data; nows <= in6; conen <= 0; end
		in6: begin nowd[6] = data; nows <= in7; conen <= 0; end
		in7: begin nowd[7] = data; nows <= jud; conen <= 0; end
		jud: begin nows <= fin; end 
		fin: begin 
				
				conen <= 1;
				case(con)
			  dep0: begin   //未输入数据：四个灯灭
						pred = nowd;
						if(pred == 8'h66) begin   //删除  
								asc = 0;
								if({markv,markh} != 1) begin
										if(markh == 1) begin 
												markv = markv-1;
												markh = line_end[markv]; 
										end
										else markh = markh-1;
								end 
								asch <= markh; ascv <= markv;
								end
								
						
						else if(pred == 8'h5a) begin //无需写入因此ascv,h保持不变
								asc <= 0;
								asch <= markh; ascv <= markv;
								line_end[markv] = markh;  //记录光标位置
								markh = 1;
								markv = markv+1;
						end
						else if(pred == 8'h12)begin indi = 1;end
						else if(pred == 8'h58)begin indi = 2;upper = ~upper; end

						else begin
						asch <= markh; ascv <= markv;  //写入和删除的定位不一样
								asc = mem[pred];
								if(markh == 70) begin
									line_end[markv] = markh;
									markh = 1;
									markv = markv+1;
								end
								else markh = markh + 1;
								if(asc >= 8'h61 && asc <= 8'h7a) asc <= upper? asc: asc - 32;
								else if(asc >= 8'h41 && asc <= 8'h5a) asc <= upper? asc: asc + 32;
								
						end
						con <= dep1;
				
						end
						  dep1: begin  
									if(nowd == 8'hf0) begin con <= outdep1; end
									else if(indi == 1) begin 
										if(pred != nowd) begin 
											pred = nowd;con <= dep2;upper = ~upper;
											asc = mem[pred];
											asch <= markh; ascv <= markv;
												markh = markh+1;
												if(markh == 70) begin
													line_end[markv] = markh;
													markh = 1;
													markv = markv+1;
												end
												if(asc >= 8'h61 && asc <= 8'h7a) asc <= upper? asc: asc - 32;
												else if(asc >= 8'h41 && asc <= 8'h5a) asc <= upper? asc: asc + 32;
											
											end
									end
									else if(indi == 2) ;
									else begin 
										pred = nowd;
										if(pred == 8'h66) begin   //删除  
											if({markv,markh} != 0) begin
													if(markh == 0) begin 
															markv = markv-1;
															markh = line_end[markv]; 
													end
													else markh = markh-1;
											end
											asch <= markh; ascv <= markv;
										end
										else begin
											asc = mem[pred];
											asch <= markh; ascv <= markv;
												markh = markh+1;
												if(markh == 70) begin
													line_end[markv] = markh;
													markh = 1;
													markv = markv+1;
												end
												if(asc >= 8'h61 && asc <= 8'h7a) asc <= upper? asc: asc - 32;
												else if(asc >= 8'h41 && asc <= 8'h5a) asc <= upper? asc: asc + 32;
												
										end
									end
								  end
						  dep2: begin 
									if(nowd == 8'hf0) begin con <= outdep2; upper = ~upper; end
									else begin pred = nowd;asc = mem[pred]; 
											asch <= markh; ascv <= markv;	
												markh = markh+1;
												if(markh == 70) begin
													markh = 1;
													markv = markv+1;
												end
												if(asc >= 8'h61 && asc <= 8'h7a) asc <= upper? asc-32: asc;
												else if(asc >= 8'h41 && asc <= 8'h5a) asc <= upper? asc+32: asc;
												
									end
								  end
						  outdep2: begin con <= dep1; 
										if(indi == 1) begin pred = 8'h12; end
										end
						  
						  outdep1: begin con <= dep0; indi = 0;end
						  
						  default: begin con <= dep0; end
						endcase
						
						en = 0;
				nows <= ini;
			end
		default: nows <= ini;
	endcase
	
end

//segment seg1(.i(cou),.o(cou_show));
//zero_seg seg2(.i(pred),.o(pred_show),.indi(con));
//zero_seg seg3(.i(asc-upper*32),.o(asc_show),.indi(con));
	
endmodule 