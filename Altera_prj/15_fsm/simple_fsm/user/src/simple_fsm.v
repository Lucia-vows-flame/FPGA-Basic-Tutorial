module simple_fsm
(
	input	wire	sys_clk,
	input	wire	sys_rst_n,
	input	wire	pi_money,

	output	reg	po_cola
);

parameter	IDLE  = 4'b0001;
parameter	ONE   = 4'b0010;
parameter	TWO   = 4'b0100;
parameter	THREE = 4'b1000;

reg	[3:0]	state;
//不标准的Moore型状态机
//第一段
always @(posedge sys_clk or negedge sys_rst_n)
	if(~sys_rst_n)
		state <= IDLE;	//只要复位就回到初始状态
	else
		case(state)
			IDLE :	if(pi_money == 1'b1)
					state <= ONE;
				else
					state <= IDLE;
			ONE :	if(pi_money == 1'b1)
					state <= TWO;
				else
					state <= ONE;
			TWO :	if(pi_money == 1'b1)
					state <= THREE;
				else
					state <= TWO;
			THREE :	if(pi_money == 1'b1)
					state <= ONE;
				else
					state <= IDLE;
			default :	state <= IDLE;
		endcase

//第二段
always @(posedge sys_clk or negedge sys_rst_n)
	if(~sys_rst_n)
		po_cola <= 1'b0;
	else if((state == TWO) && (pi_money == 1'b1))
		po_cola <= 1'b1;
	else
		po_cola <= 1'b0;

endmodule

