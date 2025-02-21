module flip_flop
(
	input	wire	sys_clk,	//时钟clock
	input	wire	sys_rst_n,	//复位信号
	input	wire	key_in,		//输入信号

	output	reg	led_out		//输出信号
);

//异步复位
always@(posedge sys_clk or negedge sys_rst_n)
	if(!sys_rst_n)
		led_out <= 1'b0;
	else
		led_out <= key_in;

/*
//同步复位
always@(posedge sys_clk)
	if(!sys_rst_n)
		led_out <= 1'b0;
	else
		led_out <= key_in;
*/

endmodule
