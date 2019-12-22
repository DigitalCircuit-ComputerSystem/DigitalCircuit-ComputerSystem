module cs(
	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

	//////////// Audio //////////
	input 		          		AUD_ADCDAT,
	inout 		          		AUD_ADCLRCK,
	inout 		          		AUD_BCLK,
	output		          		AUD_DACDAT,
	inout 		          		AUD_DACLRCK,
	output		          		AUD_XCK,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// I2C for Audio and Video-In //////////
	output		          		FPGA_I2C_SCLK,
	inout 		          		FPGA_I2C_SDAT
);

wire [7:0]fsmin;
reg [23:0]vgadata1;
wire [23:0]vgadata;
wire [9:0]vgahaddr;
wire [9:0]vgavaddr;



reg[8:0] allchar[4095:0];  //12位，所有字符对应数据
wire[4:0] ascv;			//列坐标
wire[6:0] asch;  //行坐标  位置通过{ascv,asch}标识
wire[4:0] markv; //光标			
wire[6:0] markh;
reg[7:0] asccode;
reg[5:0]pos;   //vga扫描的行对应字符；
reg[3:0]offset; //行字符偏移
reg [7:0]vga_asc;
reg[8:0]linedata;
wire fsmen;
wire [32:0] pc;
reg [31:0] intr;  //执行指令

initial begin
	asc[0][0]=36;
	vga_sync_n = 0;
	$readmemh("D:/program/FPGA/11/vga_font.txt", allchar, 0, 4095);
end



fsm myfsm(.clk(fsmclk), .data(fsmdata), .asc(fsmin),.en(fsmen));   //当前存数据的地址

//hel_rom
//fib_rom
mips_os os0(.clk(cs_clk), .addr(pc[9:0]), .q(intr));
cpu cpu0(.clk(cs_clk), .inst(intr),.pc(pc),.raddr(memaddr),.rdata(rdata),.wren(wren),.wdata(mem));
memery memery0(.address_a(memaddr), .data_a(mem_data), .wren_a(wren),.data_a(wdata), .q_a(rdata),
					.address_b(0x2000|{vgavaddr[8:4]pos[5:0]}),wren_b(1'b0), q_b(vga_asc), clock_b(vga_clk));


always @(negedge vga_clk) begin
	 linedata = allchar[vga_asc,vgavaddr[3:0]}];
	 vgadata1 = linedata[offset]? 24'hFFFFFF: 24'h000000;
end
assign vgadata = vgadata1;

vga_ctrl my_vga(.pclk(vga_clk), .reset(reset), .vga_data(vgadata), .h_addr(vgahaddr), 
			.v_addr(vgavaddr),.boffset(offset),.hblock(pos), .hsync(hs), .vsync(vs),
			.valid(blank_n), .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b));

cpu(.pc(rom_addr), .rom_data_i(rom_data), .waddr(waddr), .wdata(wdata), .rdata(rdata), .raddr(raddr));
			
always @(posedge fsmclk) begin
	//if(fsmen)
		asc[markv[4:0]][0]=36;
		asc[ascv[4:0]][asch[6:0]]=fsmin;

end





endmodule 