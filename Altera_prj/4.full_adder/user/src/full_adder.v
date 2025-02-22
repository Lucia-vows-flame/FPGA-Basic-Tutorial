module full_adder
(
	input	wire	in1,
	input	wire	in2,
	input	wire	cin,

	output	wire	cout,
	output	wire	sum
);

wire	h0_sum;
wire	h0_cout;
wire	h1_cout;

half_adder half_adder0
(
	.in1(in1),
	.in2(in2),
	.cout(h0_cout),
	.sum(h0_sum)
);

half_adder half_adder1
(
	.in1(h0_sum),
	.in2(cin),
	.cout(h1_cout),
	.sum(sum)
);

assign	cout = h0_cout | h1_cout;

endmodule
