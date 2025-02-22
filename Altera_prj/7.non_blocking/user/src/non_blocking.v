module non_blocking
(
	input	wire		sys_clk,	//系统时钟50Mhz
	input	wire		sys_rst_n,	//全局复位
	input	wire	[1:0]	in,		//输入按键

	output	reg	[1:0]	out		//输出控制led灯
);

reg [1:0] in_reg;

always@(posedge sys_clk,negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		begin
			in_reg 	<= 2'b0;
			out	<= 2'b0;
		end
	else
		begin
			in_reg 	<= in;
			out	<= in_reg;
		end

endmodule
