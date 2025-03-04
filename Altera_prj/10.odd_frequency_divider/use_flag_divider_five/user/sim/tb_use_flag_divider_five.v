`timescale 1ns/1ns

module tb_use_flag_divider_five();

reg	sys_clk;
reg	sys_rst_n;
wire	clk_flag;

initial
	begin
		sys_clk = 1'b1;
		sys_rst_n <= 1'b0;
		#20;
		sys_rst_n <= 1'b1;
	end

always #20 sys_clk = ~sys_clk;

use_flag_divider_five use_flag_divider_five_inst
(
	.sys_clk(sys_clk)	,
	.sys_rst_n(sys_rst_n)	,
	.clk_flag(clk_flag)
);

endmodule

