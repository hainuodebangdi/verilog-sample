`timescale 1ns/1ns



module tb_PLL();

//input
reg clk;
reg rst_n;

//output
wire clkdiv;
wire locked;


//例化待测试的工程cyclone_PLL_top
cyclone_PLL_top		u_pll(
						.clk(clk),
						.rst_n(rst_n),
						.clkdiv(clkdiv),
						.locked(locked)
					);

//复位信号产生，低有效
initial begin
	clk = 0;
	rst_n = 0;
	#300;
	rst_n = 1;
	#800;
	$stop;
end

//25M时钟信号产生
always #20 clk = ~clk;



endmodule

