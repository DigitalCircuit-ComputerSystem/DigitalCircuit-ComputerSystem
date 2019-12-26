module vga_ctrl(
	input pclk,
	input reset,
	input [23:0]vga_data,
	output [9:0]h_addr,
	output [9:0]v_addr,
	output reg[3:0] boffset,
	output reg[5:0] hblock,
	output hsync,
	output vsync,
	output valid,
	output [7:0]vga_r,
	output [7:0]vga_g,
	output [7:0]vga_b);

	
	parameter h_frontporch = 96;
	parameter h_active = 144;
	parameter h_backporch = 784;
	parameter h_total = 800;

	parameter v_frontporch = 2;
	parameter v_active = 35;
	parameter v_backporch = 515;
	parameter v_total = 525;
	parameter charwidth = 9;
	parameter totalhblock = 70;
	// 像素计数值
 
	reg [9:0] x_cnt=1;
	reg [9:0] y_cnt=1;
	wire h_valid;
	wire v_valid;

	always @(posedge reset or posedge pclk) // 行像素计数
		if (reset == 1'b1)  x_cnt <= 1;
		else begin
			if (x_cnt == h_total)begin x_cnt <= 1; end
			else
				x_cnt <= x_cnt + 10'd1;
			if(x_cnt <= 145 || x_cnt >721) begin     //是否需要等于呢
				boffset <= 0;
				hblock <= 0;
			end
			else boffset <= boffset+1;
			if(boffset == 8) begin
				boffset <= 0;
				hblock <= hblock +1;
			end
		end

	always @(posedge pclk) // 列像素计数
		if (reset == 1'b1) y_cnt <= 1;
		else begin
			if (y_cnt == v_total & x_cnt == h_total)
				y_cnt <= 1;
			else if (x_cnt == h_total)
				y_cnt <= y_cnt + 10'd1;
		end
		
	// 生成同步信号
	assign hsync = (x_cnt > h_frontporch);
	assign vsync = (y_cnt > v_frontporch);
	// 生成消隐信号
	assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
	assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
	assign valid = h_valid & v_valid;
	// 计算当前有效像素坐标
	assign h_addr = h_valid ? (x_cnt - 10'd145) : {10{1'b0}};
	assign v_addr = v_valid ? (y_cnt - 10'd36) : {10{1'b0}};
	// 设置输出的颜色值
	assign vga_r = {vga_data[11:8],4'b0000};
	assign vga_g = {vga_data[7:4],4'b0000};
	assign vga_b = {vga_data[3:0],4'b0000};

endmodule