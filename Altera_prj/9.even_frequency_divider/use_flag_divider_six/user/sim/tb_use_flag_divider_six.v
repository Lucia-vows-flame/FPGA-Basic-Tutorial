`timescale 1ns/1ns

module tb_use_flag_divider_six();

reg	sys_clk;
reg	sys_rst_n;

wire	cnt_flag;

initial
	begin
		sys_clk    = 1'b1;
		sys_rst_n <= 1'b0;
		#20;
		sys_rst_n <= 1'b1;
	end

always #10 sys_clk = ~sys_clk;

use_flag_divider_six use_flag_divider_six_inst
(
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.cnt_flag(cnt_flag)
);

endmodule
