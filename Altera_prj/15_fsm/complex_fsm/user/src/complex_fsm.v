module complex_fsm
(
        input   wire    i_sysclk        ,
        input   wire    i_sysrst_n      ,
        input   wire    i_money_one     ,
        input   wire    i_money_half    ,

        output  reg     o_money         ,
        output  reg     o_cola          ,
        output  wire    o_state
);

// State definitions
parameter       IDLE            = 5'b00001,
                HALF            = 5'b00010,
                ONE             = 5'b00100,
                ONE_HALF        = 5'b01000,
                TWO             = 5'b10000;

// State register
reg [4:0]       state;

//wire define
wire    [1:0]   money;

assign  money = {i_money_one, i_money_half};

// State machine
//first stage : state transition
always @(posedge i_sysclk or negedge i_sysrst_n)
        if(!i_sysrst_n)
                state <= IDLE;
        else
                case(state)
                        IDLE:
                                if(money == 2'b01)
                                        state <= HALF;
                                else if(money == 2'b10)
                                        state <= ONE;
                                else
                                        state <= IDLE;
                        HALF:
                                if(money == 2'b01)
                                        state <= ONE;
                                else if(money == 2'b10)
                                        state <= ONE_HALF;
                                else
                                        state <= HALF;
                        ONE:
                                if(money == 2'b01)
                                        state <= ONE_HALF;
                                else if(money == 2'b10)
                                        state <= TWO;
                                else
                                        state <= ONE;
                        ONE_HALF:
                                if(money == 2'b01)
                                        state <= TWO;
                                else if(money == 2'b10)
                                        state <= IDLE;
                                else
                                        state <= ONE_HALF;
                        TWO:
                                if((money == 2'b01) || (money == 2'b10))
                                        state <= IDLE;
                                else
                                        state <= TWO;
                        default:
                                state <= IDLE;
                endcase

//second stage : output logic
//o_money
always @(posedge i_sysclk or negedge i_sysrst_n)
        if(!i_sysrst_n)
                o_money <= 1'b0;
        else if((state == TWO) && (money == 2'b10))
                o_money <= 1'b1;
        else
                o_money <= 1'b0;
//o_cola
always @(posedge i_sysclk or negedge i_sysrst_n)
        if(!i_sysrst_n)
                o_cola <= 1'b0;
        else if((state == TWO) && (money == 2'b01) || (state == TWO) && (money == 2'b10) || (state == ONE_HALF) && (money == 2'b10))
                o_cola <= 1'b1;
        else
                o_cola <= 1'b0;

//o_state : output state
assign  o_state = state;

endmodule