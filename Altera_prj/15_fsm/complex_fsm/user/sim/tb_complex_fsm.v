`timescale 1ns/1ns
module tb_complex_fsm();

//reg define
reg     i_sysclk        ;
reg     i_sysrst_n      ;
reg     i_money_one     ;
reg     i_money_half    ;
reg     random_data_gen ;

//wire define
wire    o_money         ;
wire    o_cola          ;
wire    o_state         ;

// Instantiate the Unit Under Test (UUT)
complex_fsm uut (
        .i_sysclk(i_sysclk),
        .i_sysrst_n(i_sysrst_n),
        .i_money_one(i_money_one),
        .i_money_half(i_money_half),
        .o_money(o_money),
        .o_cola(o_cola),
        .o_state(o_state)
);

// initialize clock and reset
initial begin
        i_sysclk        = 1'b1;
        i_sysrst_n      = 1'b1;
        #20
        i_sysrst_n      = 1'b0;
end

// clock generator
always
        #10 i_sysclk = ~i_sysclk;

// simulate inputs
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if(!i_sysrst_n)
                        random_data_gen <= 1'b0;
                else
                        random_data_gen <= {$random} % 2;
        end
// simulate i_money_one
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if(!i_sysrst_n)
                        i_money_one <= 1'b0;
                else
                        i_money_one <= random_data_gen;
        end
// simulate i_money_half
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if(!i_sysrst_n)
                        i_money_half <= 1'b0;
                else
                        i_money_half <= ~random_data_gen;
        end

endmodule