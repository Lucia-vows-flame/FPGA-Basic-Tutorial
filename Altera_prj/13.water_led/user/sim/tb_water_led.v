`timescale 1ns/1ns
module tb_water_led();

reg	sys_clk;
reg	sys_rst_n;
wire	led_out;

initial
	begin
		sys_clk = 1'b1;
		sys_rst_n <= 1'b0;
		#20
		sys_rst_n <= 1'b1;
		end

always #10 sys_clk = ~sys_clk;

water_led
#(	.CNT_MAX(25'd24)
)
water_led_inst
(
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),

	.led_out(led_out)
);

endmodule

