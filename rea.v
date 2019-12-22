module rea( input fsmclk, 
				input clk,
			   input fsmdata,
				input reset,
			   output hs,
				output vs,
				output [7:0]vga_r,
				output [7:0]vga_g,
				output [7:0]vga_b,
				output reg vga_sync_n,
				output blank_n,
				output vga_clk,
				output reg [9:0]led
			  );


wire [7:0]fsmin;
reg [23:0]vgadata1;
wire [23:0]vgadata;
wire [9:0]vgahaddr;
wire [9:0]vgavaddr;

reg[11:0] cou;          //标识输入按键数目
reg[7:0] asc[29:0][69:0];    //30行(32,5位)*70(128, 高7位)  第i,j位字符的asc码  //4095太大
reg[8:0] allchar[4095:0];  //12位，所有字符对应数据
wire[4:0] ascv;			//列坐标
wire[6:0] asch;  //行坐标  位置通过{ascv,asch}标识
wire[4:0] markv;			
wire[6:0] markh;
reg[7:0] asccode;
//reg[6:0] line_end[29:0]; //用于标识每一行的最后字符的位置(光标位置)
//reg[11:0] mark;  //前5个标识纵坐标，后7个标识横坐标
reg[1:0] glink;  //多少帧改变一次
reg[6:0]pos;   //vga扫描的行对应字符；
reg[3:0]offset; //行字符偏移

reg[8:0]linedata;
wire fsmen;
initial begin
	asc[0][0]=36;
	vga_sync_n = 0;
	cou = 0;
	$readmemh("D:/program/FPGA/11/vga_font.txt", allchar, 0, 4095);
end

fsm myfsm(.clk(fsmclk), .data(fsmdata), .asc(fsmin),.ascv(ascv),
			.asch(asch),.en(fsmen),.markh(markh),.markv(markv));   //当前存数据的地址

clk50to25 newclk(.clkin(clk), .clkout(vga_clk));

always @(negedge vga_clk) begin
	 //asccode = asc[vgavaddr[8:4]][pos[6:0]];
	 linedata = allchar[{asc[vgavaddr[8:4]][pos[6:0]],vgavaddr[3:0]}];
	 if({vgavaddr[8:4],pos[6:0]} == {markv,markh}) linedata = ~linedata;
	 vgadata1 = linedata[offset]? 24'hFFFFFF: 24'h000000;
end
assign vgadata = vgadata1;
vga_ctrl my_vga(.pclk(vga_clk), .reset(reset), .vga_data(vgadata), .h_addr(vgahaddr), 
			.v_addr(vgavaddr),.boffset(offset),.hblock(pos), .hsync(hs), .vsync(vs),
			.valid(blank_n), .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b));

always @(posedge fsmclk) begin
	//if(fsmen)
		asc[markv[4:0]][0]=36;
		asc[ascv[4:0]][asch[6:0]]=fsmin;
end
endmodule

//坐标错误
//几块数据之间的强依赖关系
//有一部分字符占三个字符那么长

//一行只能显示63个字符，并且每个字符右方有黄边，猜测每个数据有10位  **在vha_ctrl中boffset==9换成8
//字符边界出现红色、绿色 **下降沿再对vga数据进行赋值
//字符边缘模糊         **//将vga_ctrl里面的<换成<=就好了
//一次改变两个数据		**// asc中always没有时钟
//列扫描出错       		**//想着asc应该为12根线，结果变成了11：0呜呜呜
//初始时显示字符   		**//不知道为什么初始时就没有字符了
//字符与按键不匹配  		**//fsm输出为键码，而非asc码