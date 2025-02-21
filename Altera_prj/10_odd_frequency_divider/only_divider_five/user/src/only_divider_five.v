module only_divider_five
(
	input	wire	sys_clk,
	input	wire	sys_rst_n,
	output	wire	clk_out
);

reg	[3:0]	cnt;
reg		clk1;
reg		clk2;

//cnt
always@(posedge sys_clk or negedge sys_rst_n)
	if(~sys_rst_n)
		cnt <= 4'b0;
	else if(cnt == 4'd4)
		cnt <= 4'b0;
	else
		cnt <= cnt + 1;
//clk1
always@(posedge sys_clk or negedge sys_rst_n)
	if(~sys_rst_n)	      
		clk1 <= 1'b0;
	else if(cnt == 4'd2)
		clk1 <= 1'b1;
	else if(cnt == 4'd4)
		clk1 <= 1'b0;
	else
		clk1 <= clk1;

//clk2
always@(negedge sys_clk or negedge sys_rst_n)
	if(~sys_rst_n)	      
		clk2 <= 1'b0;
	else if(cnt == 4'd2)
		clk2 <= 1'b1;
	else if(cnt == 4'd4)
		clk2 <= 1'b0;
	else
		clk2 <= clk2;

//clk_out
assign	clk_out = clk1 | clk2;

endmodule

