`timescale 1ns/1ns

module tb_flip_flop();

reg	sys_clk;
reg	sys_rst_n;
reg	key_in;
wire	led_out;

//初始化时钟、复位、输入信号
initial
	begin
		sys_clk    = 1'b1;	//对clock的初始化使用阻塞赋值语句
		sys_rst_n <= 1'b0;
		key_in    <= 1'b0;
	end

//模拟复位信号
initial
	begin
		#20  sys_rst_n <= 1'b1;
		#210 sys_rst_n <= 1'b0;
		#40  sys_rst_n <= 1'b1;
	end
//复位信号先拉高再拉低是为了对比同步复位与异步复位的区别
		
//模拟时钟
always #10 sys_clk = ~sys_clk;		//对clock的模拟使用阻塞赋值语句

//模拟输入信号
always #20 key_in <= {$random} % 2;

//------------------------------------------------------
initial
	begin
		$timeformat(-9,0,"ns",6);
		$monitor("@time %t: key_in=%b led_out=%b",$time,key_in,led_out);
	end
//------------------------------------------------------

//flip_flop_inst
flip_flop flip_flop_inst
(
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.key_in(key_in),
	.led_out(led_out)
);

endmodule
