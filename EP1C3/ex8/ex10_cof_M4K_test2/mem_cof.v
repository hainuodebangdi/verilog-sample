`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: 特权 franchise.3
// Create Date	: 2009.04.20
// Design Name	: mem_cof
// Module Name	: mem_cof
// Project Name	: mem_cof
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 配置M4K产生一个4*4*8bit的移位寄存器
//				
// Revision		: V1.0
// Additional Comments	:  
// 欢迎加入EDN的FPGA/CPLD助学小组一起讨论：http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module mem_cof(
			clk,rst_n,
			shift_din,shift_dout,//shift_all_data
			taps0x,taps1x,taps2x,taps3x,taps4x,taps5x,taps6x,taps7x
		);

input clk;		//系统输入时钟，25M
input rst_n;	//系统服务信号，低有效

input[3:0] shift_din;					//移位RAM输入数据
output[3:0] shift_dout;				//移位RAM输出数据
//output[31:0] shift_all_data;	//移位RAM全部64bit数据
output	[3:0]  taps0x;
output	[3:0]  taps1x;
output	[3:0]  taps2x;
output	[3:0]  taps3x;
output	[3:0]  taps4x;
output	[3:0]  taps5x;
output	[3:0]  taps6x;
output	[3:0]  taps7x;

//例化M4K生成的移位RAM
shift_ram 	uut_shift(
				.clken(rst_n),		//移位RAM使能信号，高有效
				.clock(clk),
				.shiftin(shift_din),
				.shiftout(shift_dout),
				//.taps(shift_all_data)
				.taps0x(taps0x),
				.taps1x(taps1x),
				.taps2x(taps2x),
				.taps3x(taps3x),
				.taps4x(taps4x),
				.taps5x(taps5x),
				.taps6x(taps6x),
				.taps7x(taps7x)
				);


endmodule

