module counter
#(
	parameter	CNT_MAX = 25'd24
)
(
	input	wire	sys_clk,
	input	wire	sys_rst_n,
	
	output	reg	led_out
);


reg	[24:0]	cnt;
reg		cnt_flag;

//计数器
always@(posedge sys_clk or negedge sys_rst_n)
	if(!sys_rst_n)
		cnt <= 25'b0;
	else if(cnt == CNT_MAX)
		cnt <= 25'b0;
	else
		cnt <= cnt + 1;

//led_out
always@(posedge sys_clk or negedge sys_rst_n)
	if(!sys_rst_n)
		led_out <= 1'b0;
	else if(cnt == CNT_MAX)
		led_out <= ~led_out;


//cnt_flag
always@(posedge sys_clk or negedge sys_rst_n)
	if(!sys_rst_n)
		cnt_flag <= 1'b0;
	else if(cnt == CNT_MAX - 25'b1)
		cnt_flag <= 1'b1;
	else
		cnt_flag <= 0;

endmodule
