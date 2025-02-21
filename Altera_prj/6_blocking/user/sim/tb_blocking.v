`timescale 1ns/1ns

module tb_blocking();

reg		sys_clk;
reg		sys_rst_n;
reg	[1:0]	in;

wire	[1:0]	out;

//初始化系统时钟、全局复位和输入信号
initial
	begin
		sys_clk		<= 1'b1;
		sys_rst_n	<= 1'b0;
		in		<= 2'b0;
		#20
		sys_rst_n	<= 1'b1;
	end

//模拟系统时钟
always #10 sys_clk = ~sys_clk;

//模拟按键输入
always #20 in <= {$random} % 4;

//blocking模块实例化
blocking	blocking_inst
(
	.sys_clk	(sys_clk),
	.sys_rst_n	(sys_rst_n),
	.in		(in),

	.out		(out)
);

endmodule
