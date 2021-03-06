`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    
// Design Name:    
// Module Name:    
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 欢迎加入EDN的FPGA/CPLD助学小组一起讨论：http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module johnson(
			clk,rst_n,
			key1,key2,key3,
			led0,led1,led2,led3
		);

input clk;		//主时钟，50MHz
input rst_n;	//低电平复位
input key1,key2,key3;			// 按键接口
output led0,led1,led2,led3;		// LED等接口

//------------------------------------
reg[23:0] delay;	//延时计数器

always @ (posedge clk or negedge rst_n)
	if(!rst_n) delay <= 0;
	else delay <= delay+1;	//不断计数，周期为320ms

reg[2:0] key_value;		//键值寄存器

always @ (posedge clk or negedge rst_n)
	if(!rst_n) key_value <= 3'b111;	
	else if(delay == 24'hffffff) key_value <= {key3,key2,key1};	//delay 320ms，锁定键值

//-------------------------------------
reg[2:0] key_value_r;

always @ (posedge clk or negedge rst_n)
	if(!rst_n) key_value_r <= 3'b111;
	else key_value_r <= key_value;

wire[2:0] key_change;	//判定前后20ms的键值是否发生了改变，若是，则key_change置高

assign key_change = key_value_r & (~key_value);	//check key_value negedge per clk
//------------------------------------
reg stop_start,left_right;	//流水灯控制位

always @ (posedge clk or negedge rst_n)
	if(!rst_n) begin 
		stop_start <= 1;
		left_right <= 1;
		end
	else
		if(key_change[2]) stop_start <= ~stop_start;	//开始结束控制位
		else if(key_change[1]) left_right <= 1;			//流水灯方向控制
		else if(key_change[0]) left_right <= 0;			//流水灯方向控制

//-------------------------------------
reg[3:0] led_value_r;	// LED值寄存器

always @ (posedge clk or negedge rst_n)
	if(!rst_n) led_value_r <= 4'b1110;
	else if(delay == 24'h3fffff && stop_start)	//流水灯控制
		case (left_right)	//方向控制
			1: led_value_r <= {led_value_r[2:0],led_value_r[3]};	//右移
 		    0: led_value_r <= {led_value_r[0],led_value_r[3:1]};	//左移
			default: ;
			endcase

assign {led3,led2,led1,led0} = ~led_value_r;

endmodule
