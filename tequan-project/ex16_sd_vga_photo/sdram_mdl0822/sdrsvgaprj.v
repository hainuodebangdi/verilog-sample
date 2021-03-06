`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: 特权 franchises3
// Create Date	: 2009.05.04
// Design Name	: 
// Module Name	: sdrsvgaprj
// Project Name	: sdrsvgaprj
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module sdrsvgaprj(
				clk,rst_n,
				rs232_tx,
				spi_miso,spi_mosi,spi_clk,spi_cs_n,led
			);

input clk;		//FPAG输入时钟信号25MHz
input rst_n;	//FPGA输入复位信号

output rs232_tx;	// RS232发送数据信号

input spi_miso;		//SPI主机输入从机输出数据信号
output spi_mosi;	//SPI主机输出从机输入数据信号
output spi_clk;		//SPI时钟信号，由主机产生
output spi_cs_n;	//SPI从设备使能信号，由主设备控制

output[3:0] led;	//调试使用

//------------------------------------------------
wire clk_25m;		//PLL输出25MHz时钟
wire clk_100m;	//PLL输出100MHz时钟
wire sys_rst_n;	//系统复位信号，低有效

wire tx_start;		//串口发送数据启动标志位，高有效

wire[7:0] fifo232_din;	//FIFO写入数据
wire fifo232_wrreq;		//FIFO写请求信号，高有效
wire fifo232_rdreq;		//FIFO读请求信号，高有效
wire[7:0] fifo232_dout;	//FIFO读出数据，即串口待发送数据
wire fifo232_empty;	//FIFO空标志位，高有效


assign tx_start = ~fifo232_empty;	//检测FIFO不空，就启动串口读FIFO并发送数据
//------------------------------------------------
//例化系统复位信号和PLL控制模块
sys_ctrl		uut_sysctrl(
					.clk(clk),
					.rst_n(rst_n),
					.sys_rst_n(sys_rst_n),
					.clk_25m(clk_25m),
					.clk_100m(clk_100m)
					);


//例化串口数据发送控制模块
uart_ctrl		uut_uartctrl(
					.clk(clk_25m),
					.rst_n(sys_rst_n),
					.tx_data(fifo232_dout),
					.tx_start(tx_start),
					.fifo232_rdreq(fifo232_rdreq),
					.rs232_tx(rs232_tx)
					);

//例化串口发送数据缓存FIFO模块
sdrd_fifo			sdrd_fifo_inst(
					.data(rdfifo_din),
					.rdclk(clk_25m),
					.rdreq(rdfifo_rdreq),
					.wrclk(clk_100m),
					.wrreq(rdfifo_wrreq),
					.empty(fifo232_empty),
					.q(fifo232_dout)					
					);


//sd控制模块
sdcard_ctrl		uut_sdcartctrl(
					.clk(clk_25m),
					.rst_n(sys_rst_n),
					.spi_miso(spi_miso),
					.spi_mosi(spi_mosi),
					.spi_clk(spi_clk),
					.spi_cs_n(spi_cs_n),
					.sd_dout(fifo232_din),
					.sd_fifowr(fifo232_wrreq)
					.led(led)
				);


endmodule
