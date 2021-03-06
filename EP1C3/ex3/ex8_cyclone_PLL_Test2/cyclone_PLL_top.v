`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: 特权 franchise.3
// Create Date	: 2009.04.20
// Design Name	: cyclone_PLL_top
// Module Name	: cyclone_PLL_top
// Project Name	: cyclone_PLL_top
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 配置PLL产生一个100M时钟和一个25M时钟，
//					同时控制LED闪烁，用于我们观察PLL输出的效果					
// Revision		: V1.0
// Additional Comments	:  
// 欢迎加入EDN的FPGA/CPLD助学小组一起讨论：http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module cyclone_PLL_top(
				clk,rst_n,
				led0,led1
			);

input clk;		//25MHz
input rst_n;	//low reset signal

output led0,led1;

wire clk_100m;	//输入时钟的4倍频,100MHz	
wire clk_25m;	//输入时钟的1倍频,25MHz	
wire locked;	//PLL输出有效标志位,高有效

//PLL产生模块
//产生一个系统输入时钟2/5分频，相移90度的时钟
PLL_ctrl	PLL_ctrl_inst (
				.areset(!rst_n),	//PLL异步复位信号
				.inclk0(clk),		//PLL输入时钟
				.c0(clk_100m),		//输入时钟的4倍频,100MHz	
				.c1(clk_25m),		//输入时钟的1倍频,25MHz					
				.locked(locked)		//PLL输出有效标志位,高有效
			);


//使用PLL输出时钟100M产生1s的方波给led0
reg[26:0] cnt_100m;
always @ (posedge clk_100m or negedge rst_n) begin
	if(!rst_n) cnt_100m <= 27'd0;
	else if(cnt_100m == 27'd100_000_000) cnt_100m <= 27'd0;
	else cnt_100m <= cnt_100m+1'b1;
end

assign led0 = cnt_100m[26];

//使用PLL输出时钟25M产生1s的方波给led1
reg[24:0] cnt_25m;
always @ (posedge clk_25m or negedge rst_n) begin
	if(!rst_n) cnt_25m <= 25'd0;
	else if(cnt_25m == 25'd25_000_000) cnt_25m <= 25'd0;
	else cnt_25m <= cnt_25m+1'b1;
end

assign led1 = cnt_25m[24];


endmodule

