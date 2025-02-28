module uart_byte_rx
(
        input   wire            i_sysclk        ,
        input   wire            i_sysrst_n      ,
        input   wire            i_uart_rx       ,
        output  reg     [7:0]   o_rx_data       ,
        output  reg             o_uart_rx_done
);

//parameter define
parameter               BAUD              = 9600;                       //波特率
parameter               CLOCK_FERQ        = 50_000_000;                 //时钟频率
parameter               BAUD_COUNTER_MAX  = CLOCK_FERQ/BAUD - 1;        //波特率计数器的最大值。特别说明，这里的参数计算不会消耗 FPGA 的资源，综合工具会自动计算出最终的结果
parameter               STATE_COUNTER_MAX = 9;                          //状态记录计数器的最大值


//reg define
reg      [29:0]         r_baud_counter  ;   //波特率计数器，位宽扩展到 30 位，以防止计数溢出
reg                     en_baud_counter ;   //波特率计数器的使能信号
reg      [3:0]          r_state_counter ;   //状态记录计数器
reg      [7:0]          r_uart_rx       ;   //寄存i_uart_rx
reg                     r1,r2           ;   //打拍用的寄存器
reg      [7:0]          r_rx_data     ;   //配合 o_rx_data 使用，用于接收数据，将串行数据转换为并行数据输出

//wire define
wire                    w_uart_rx_done  ;   //uart_rx 接收完成标志
wire                    r_negedge_start ;   //start 位的下降沿标志

//波特率计数器，同时也是状态分割计数器
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if (~i_sysrst_n)
                        begin
                                r_baud_counter  <= 0;
                        end
                else if(en_baud_counter == 1'b1)        //只有使能信号有效时才进行计数
                        begin
                                if (r_baud_counter == BAUD_COUNTER_MAX)
                                        r_baud_counter <= 0;
                                else
                                        r_baud_counter <= r_baud_counter + 1;
                        end
                else    //使能信号无效时，计数器清零
                        begin
                                r_baud_counter <= 0;
                        end
        end

//波特率计数器的使能信号
//r_negedge_start 为低电平时，代表开始接收，此时使能波特率计数器
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if (~i_sysrst_n)
                        begin
                                en_baud_counter <= 1'b0;
                        end
                else if (r_negedge_start)        //拉高波特率计数器的使能信号
                        begin
                                en_baud_counter <= 1'b1;
                        end
                else if ((r_baud_counter == BAUD_COUNTER_MAX / 2) && (r_state_counter == 0) && (r2 == 1))        //检测到毛刺时，波特率计数器的使能信号拉低。注意检测到毛刺的条件是 (r_baud_counter == BAUD_COUNTER_MAX / 2) && (r_state_counter == 0) && (i_uart_rx == 1)，由这三个条件共同决定的是一个时刻，不足这三个条件检测到的可能是一个时间段。
                        begin
                                en_baud_counter <= 1'b0;
                        end
                else if ((r_baud_counter == BAUD_COUNTER_MAX / 2) && (r_state_counter == STATE_COUNTER_MAX))     //检测到 0.5 位停止位时，波特率计数器的使能信号拉低
                        begin
                                en_baud_counter <= 1'b0;
                        end
                else
                        begin
                                en_baud_counter <= en_baud_counter;
                        end
        end

//位计数器，同时也是状态记录计数器
//START + 8bit DATA + STOP = 10，共记录 10 个状态
//这里不能使用 if-else 嵌套，因为一个是 r_baud_counter == BAUD_COUNTER_MAX / 2 时清零，一个是 r_baud_counter == BAUD_COUNTER_MAX 时计数，这两个条件不能同时满足，因此不能嵌套。
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if (~i_sysrst_n)
                        begin
                                r_state_counter <= 4'b0;
                        end
                else if ((r_baud_counter == BAUD_COUNTER_MAX / 2) && (r_state_counter == STATE_COUNTER_MAX))        //检测到 0.5 位停止位时，状态计数器清零
                        begin
                                r_state_counter <= 4'b0;
                        end
                else if (r_baud_counter == BAUD_COUNTER_MAX)    //波特率计数器计数到最大值时，状态计数器进行计数
                        begin
                                r_state_counter <= r_state_counter + 1;
                        end
                else    //波特率计数器未计数到最大值时，状态计数器不变
                        begin
                                r_state_counter <= r_state_counter;
                        end
        end

//位接收逻辑，同时也是线性序列机的输出逻辑
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if (~i_sysrst_n)
                        begin
                                o_rx_data <= 8'd0;
                        end
                else if (r_baud_counter == BAUD_COUNTER_MAX / 2)        //在波特率的中间时刻，接收稳定的数据
                        begin
                                case (r_state_counter)      //这里不用管起始位和停止位，只需要接收数据位，因为起始位已经在波特率计数器的使能信号拉高时检测到了，而停止位是因为这里我们选择的是不管停止位是否正确，均输出数据，所以不需要检测停止位。如果有检测停止位的需要，只需要 case 中加上停止位的输出即可。
                                        4'd1:
                                                begin
                                                        r_rx_data[0] <= r2;         //数据位
                                                end
                                        4'd2:
                                                begin
                                                        r_rx_data[1] <= r2;         //数据位
                                                end
                                        4'd3:
                                                begin
                                                        r_rx_data[2] <= r2;         //数据位
                                                end
                                        4'd4:
                                                begin
                                                        r_rx_data[3] <= r2;         //数据位
                                                end
                                        4'd5:
                                                begin
                                                        r_rx_data[4] <= r2;         //数据位
                                                end
                                        4'd6:
                                                begin
                                                        r_rx_data[5] <= r2;         //数据位
                                                end
                                        4'd7:
                                                begin
                                                        r_rx_data[6] <= r2;         //数据位
                                                end
                                        4'd8:
                                                begin
                                                        r_rx_data[7] <= r2;         //数据位
                                                end
                                        default:
                                                begin
                                                        r_rx_data <= r_rx_data;         //其他状态，保持不变  
                                                end
                                endcase
                        end
        end

//数据输出逻辑
//不直接使用 o_rx_data 接收数据，因为这会导致在接收完成之前，o_rx_data 一直在改变，这不是我们想要的，我们希望接收完成后输出一个稳定的值，因此使用一个中间寄存器 r_rx_data
always @(posedge i_sysclk)
        if (w_uart_rx_done)        //接收完成标志信号有效时，输出数据
                begin
                        o_rx_data <= r_rx_data;
                end

//i_uart_rx 是外部输入信号，与系统时钟异步，属于跨时钟域信号，因此需要进行打拍防止亚稳态现象
//这里只进行打拍，不进行复位
//本模块的所有 i_uart_rx 全都替换为 r2
always @(posedge i_sysclk)
        begin
                r1 <= i_uart_rx;
                r2 <= r1;
        end

//下降沿检测逻辑
always @(posedge i_sysclk)      //不需要复位
        r_uart_rx <= r2;
assign r_negedge_start = (r2 == 0) && (r_uart_rx == 1);        //下降沿检测

//接收完成标志信号
assign w_uart_rx_done = (r_state_counter == STATE_COUNTER_MAX) && (r_baud_counter == BAUD_COUNTER_MAX / 2);        //接收完成标志信号，注意只检测 0.5 位的停止位
always @(posedge i_sysclk)      //不需要复位
        o_uart_rx_done <= w_uart_rx_done;

endmodule