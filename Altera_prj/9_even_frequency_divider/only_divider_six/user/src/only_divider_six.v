module only_divider_six
(
	input	wire	sys_clk,
	input	wire	sys_rst_n,

	output	reg	clk_out
);

reg	[1:0]	cnt;
always@(posedge sys_clk or negedge sys_rst_n)
	if(!sys_rst_n)
		cnt <= 2'b0;
	else if(cnt == 2'd2)
		cnt <= 2'b0;
	else
		cnt <= cnt + 1;

always@(posedge sys_clk or negedge sys_rst_n)
	if(!sys_rst_n)
		clk_out <= 2'b0;
	else if(cnt == 2'd2)
		clk_out <= ~clk_out;
	else
		clk_out <= clk_out;

endmodule
