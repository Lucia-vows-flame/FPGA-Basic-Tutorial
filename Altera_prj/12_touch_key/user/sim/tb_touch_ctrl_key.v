`timescale 1ns/1ns

module tb_touch_ctrl_key();

reg	sys_clk;
reg	sys_rst_n;
reg	touch_key;
wire	led;

initial
	begin
		sys_clk = 1'b1;
		sys_rst_n <= 1'b0;
		#200
		sys_rst_n <= 1'b1;
	end

always #10 sys_clk = ~sys_clk;

initial
	begin
		touch_key <= 1'b1;
		#400
		touch_key <= 1'b0;
		#2000
		touch_key <= 1'b1;
		#1000
		touch_key <= 1'b0;
		#3000
		touch_key <= 1'b1;
	end

touch_ctrl_key touch_ctrl_key_inst
(
	.sys_clk(sys_clk)	,
	.sys_rst_n(sys_rst_n)	,
	.touch_key(touch_key)	,

	.led(led)
);

endmodule

