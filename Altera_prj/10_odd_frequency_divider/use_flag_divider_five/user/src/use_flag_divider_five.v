module use_flag_divider_five
(
	input	wire	sys_clk,
	input	wire	sys_rst_n,
	output	reg	clk_flag
);

reg	[3:0]	cnt;
always @(posedge sys_clk or negedge sys_rst_n)
	if(~sys_rst_n)
		cnt <= 4'b0;
	else if(cnt == 4'd4)
		cnt <= 4'b0;
	else
		cnt <= cnt + 1;

always @(posedge sys_clk or negedge sys_rst_n)
	if(~sys_rst_n)
		clk_flag <= 1'b0;
	else if(cnt == 4'd3)
		clk_flag <= 1'b1;
	else
		clk_flag <= 1'b0;
endmodule

