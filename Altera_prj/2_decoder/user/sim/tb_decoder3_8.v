`timescale 1ns/1ns

module	tb_decoder3_8();

reg		in1;
reg		in2;
reg		in3;
wire	[7:0]	out;

//初始化
initial
	begin
		in1 <= 1'b0;
		in2 <= 1'b0;
		in3 <= 1'b0;
	end

//模拟输入信号
always #10 in1 <= {$random} % 2;
always #10 in2 <= {$random} % 2;
always #10 in3 <= {$random} % 2;

//打印仿真结果
initial
	begin
		$timeformat(-9,0,"ns",6);
		$monitor("@time %t:in1=%b in2=%b in3=%b out=%b",$time,in1,in2,in3,out);
	end

//模块实例化
decoder3_8	decoder3_8_inst
(
	.in1(in1),
	.in2(in2),
	.in3(in3),
	.out(out)
);

endmodule
