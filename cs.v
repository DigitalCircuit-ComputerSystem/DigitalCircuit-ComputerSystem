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
	output		reg          		VGA_SYNC_N,
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

reg [23:0]vgadata1;
wire [23:0]vgadata;
wire [9:0]vgahaddr;
wire [9:0]vgavaddr;
reg[8:0] allchar[4095:0];  //12位，所有字符对应数据

reg[7:0] asccode;
reg[5:0]pos;   //vga扫描的行对应字符；
reg[3:0]offset; //行字符偏移
wire [7:0]vga_asc;
reg[8:0]linedata;
wire fsmen;
wire [32:0] pc;
wire [31:0] intr;  //执行指令

initial begin

	VGA_SYNC_N = 0;
	$readmemh("D:/program/FPGA/11/vga_font.txt", allchar, 0, 4095);
end

clkgen #(500000) my_csclk(CLOCK_50,SW[0],1'b1,cs_clk);
//assign cs_clk = KEY[0];
clkgen #(25000000) my_vgaclk(CLOCK_50,SW[0],1'b1,vga_clk);
fsm myfsm(.clk(PS2_CLK), .data(PS2_DAT), .asc(fsmin),.en(fsmen));   //当前存数据的地址
wire [31:0] wdata;
wire wren;
wire [31:0] rdata;
wire [31:0] rdata1;
wire [31:0] memaddr;
wire rst;

mips_os os0(.clock(cs_clk), .address(pc[11:2]), .q(intr));
cpu cpu0(.rst(rst),.clk(cs_clk), .inst(intr),.pc(pc),.mem_addr(memaddr),.mem_read_data(rdata),.wren(wren),.mem_write_data(wdata));

memery memery0(.address_a(memaddr), .data_a(wdata), .wren_a(wren),.clock_a(cs_clk), .q_a(rdata1),
					.address_b(14'h2000|{vgavaddr[8:4],pos[5:0]}),.wren_b(1'b0), .q_b(vga_asc), .clock_b(vga_clk));

assign rdata = memaddr == 14'h2000 ? fsmin: rdata1;
always @(negedge vga_clk) begin
	 linedata = allchar[{vga_asc,vgavaddr[3:0]}];
	 vgadata1 = linedata[offset]? 24'hFFFFFF: 24'h000000;
end
assign vgadata = vgadata1;
assign VGA_CLK = vga_clk;
vga_ctrl my_vga(.pclk(vga_clk), .reset(reset), .vga_data(vgadata), .h_addr(vgahaddr), 
			.v_addr(vgavaddr),.boffset(offset),.hblock(pos), .hsync(VGA_HS), .vsync(VGA_VS),
			.valid(VGA_BLANK_N), .vga_r(VGA_R), .vga_g(VGA_G), .vga_b(VGA_B));

			
assign LEDR[3:0] = intr[29:26];
assign LEDR[9:4] = pc[7:2];
assign rst = SW[0];
endmodule 