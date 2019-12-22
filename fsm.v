module fsm( 
input clk,
input data,
//output wire[13:0]asc_show,pred_show,cou_show;
output reg[7:0]asc,
output reg en
);
reg[7:0] pred;
reg [11:0]cou;
reg [7:0]mem [255:0];
reg [7:0]nowd;
parameter [4:0] ini = 5'b00000, in0 = 5'b00001, in1 = 5'b00011, in2 = 5'b00010,
					 in3 = 5'b00110, in4 = 5'b00111, in5 = 5'b00101, in6 = 5'b00100,
					 in7 = 5'b01100, jud = 5'b01101, fin = 5'b01111;
parameter [2:0] dep0 = 3'b000, dep1 = 3'b001, dep2 = 3'b011, outdep1 = 3'b010, outdep2 = 3'b110;


reg [4:0]nows;

 reg[1:0]indi;  //0:正常，1:shift, 2:ctrl
 reg[2:0]con;
reg upper;
reg conen;
reg[7:0] line_char[69:0];
initial 
begin
  cou = 0;
  nows = ini;
  con = dep0;
  upper = 0;
  indi = 0;

  en = 0;
  $readmemh("D:/program/FPGA/8/mem.txt", mem, 0, 255);
end
//支持程序：输入异常(8), hel(9): 输出hello world; fib(10): 计算斐波那契数
always @(negedge clk) begin
	en = 0;
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
						asc = mem[pred];
						
						con <= dep1;
						end
						  dep1: begin  
									if(nowd == 8'hf0) begin con <= outdep1; end
									
								  end
						  
						  outdep1: begin con <= dep0; indi = 0; asc = 0; end
						  
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