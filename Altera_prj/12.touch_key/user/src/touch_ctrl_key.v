module touch_ctrl_key
(
	input	wire	sys_clk,
	input	wire	sys_rst_n,
	input	wire	touch_key,

	output	reg	led
);

reg	touch_key_dly1;
reg	touch_key_dly2;
wire	touch_flag;

//touch_key_dly1
always @(posedge sys_clk or negedge sys_rst_n)
	if(~sys_rst_n)
		touch_key_dly1 <= 1'b0;
	else
		touch_key_dly1 <= touch_key;

//touch_key_dly2
always @(posedge sys_clk or negedge sys_rst_n)
	if(~sys_rst_n)
		touch_key_dly2 <= 1'b0;
	else
		touch_key_dly2 <= touch_key_dly1;

//边沿检测
assign	touch_flag = ~touch_key_dly1 & touch_key_dly2;

//led控制信号
always @(posedge sys_clk or negedge sys_rst_n)
	if(~sys_rst_n)
		led <= 1'b0;
	else if(touch_flag == 1'b1)
		led <= ~led;
	else
		led <= led;

endmodule

