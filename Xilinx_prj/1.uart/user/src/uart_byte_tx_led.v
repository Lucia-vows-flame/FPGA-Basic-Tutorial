/*
本模块只能接收拨码开关的值，然后发送出去，发送的波特率为 9600，数据位为 8 位，停止位为 1 位，无校验位，并且输出一个 led 信号，当发送完成后，led 翻转一次，无法作为一个通用的串口发送模块
*/
module uart_byte_tx_led
(
        input   wire            i_sysclk        ,
        input   wire            i_rst_n         ,
        input   wire    [7:0]   i_data          ,

        output  reg             o_uart_tx       ,
        output  reg             o_led
);

//parameter define
parameter               BAUD_COUNTER_MAX = 5207;        //波特率计数器的最大值
parameter               STATE_COUNTER_MAX = 9;          //状态记录计数器的最大值
parameter               COUNTER_1s_MAX = 50_000_000 - 1;        //定时 1s 计数器的最大值

//reg define
reg      [12:0]         r_baud_counter  ;   //波特率计数器
reg                     en_baud_counter ;   //波特率计数器的使能信号
reg      [3:0]          r_state_counter ;   //状态记录计数器
reg      [25:0]         r_1s_counter    ;   //定时 1s 的计数器
reg      [7:0]          r_data          ;   //寄存发送的数据

//波特率计数器，同时也是状态分割计数器
//波特率为 1/9600，使用分频得到 1/9600 的时钟，则 r_baud_counter 的计数最大值为 1/9600*1000000000/20 - 1 = 5207
//由于发送数据不是一直在进行，则 r)baud_counter 并不会一直处于计数状态，因此需要一个使能信号 en_baud_counter 控制计数器是否计数
always @(posedge i_sysclk or negedge i_rst_n)
        begin
                if (~i_rst_n)
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

//位计数器，同时也是状态记录计数器
//START + 8bit DATA + STOP = 10，共记录 10 个状态
always @(posedge i_sysclk or negedge i_rst_n)
        begin
                if (~i_rst_n)
                        begin
                                r_state_counter <= 4'b0;
                        end
                else if (r_baud_counter == BAUD_COUNTER_MAX)        //波特率计数器计数到最大值时，状态计数器进行计数
                        begin
                                if (r_state_counter == STATE_COUNTER_MAX)        //状态计数器最大值为 9
                                        r_state_counter <= 0;
                                else
                                        r_state_counter <= r_state_counter + 1;
                        end
                else    //波特率计数器未计数到最大值时，状态计数器不变
                        begin
                                r_state_counter <= r_state_counter;
                        end
        end

//定时 1s 的计数器
always @(posedge i_sysclk or negedge i_rst_n)
        begin
                if (~i_rst_n)
                        begin
                                r_1s_counter <= 0;
                        end
                else if (r_1s_counter == COUNTER_1s_MAX)        //1s 的计数值
                        begin
                                r_1s_counter <= 0;
                        end
                else
                        begin
                                r_1s_counter <= r_1s_counter + 1;
                        end
        end

//寄存拨码开关的值
//应该在开始发送时寄存数据，开始发送的时间就是定时 1s 计数器计满 1s 的时间
//这里可以不使用复位，尽量减少复位的使用
always @(posedge i_sysclk or negedge i_rst_n)
        begin
                if (~i_rst_n)
                        begin
                                r_data <= 8'b0;
                        end
                else if (r_1s_counter == COUNTER_1s_MAX)        //1s 的计数值
                        begin
                                r_data <= i_data;
                        end
                else
                        begin
                                r_data <= r_data;
                        end
        end

//位发送逻辑，同时也是线性序列机的输出逻辑，使用 case 语句实现
always @(posedge i_sysclk or negedge i_rst_n)
        begin
                if (~i_rst_n)    //复位时，uart_tx 处于空闲状态，为高电平
                        begin
                                o_uart_tx <= 1'd1;
                        end
                else if (en_baud_counter == 0)
                        begin
                                o_uart_tx <= 1'd1;              //波特率计数器失能时，uart_tx 处于空闲状态，为高电平，必须加这个判断，否则会出现
                        end
                else
                        begin
                                case (r_state_counter)
                                        4'd0:
                                                begin
                                                        o_uart_tx <= 1'd0;              //起始位
                                                end
                                        4'd1:
                                                begin
                                                        o_uart_tx <= r_data[0];         //数据位
                                                end
                                        4'd2:
                                                begin
                                                        o_uart_tx <= r_data[1];         //数据位
                                                end
                                        4'd3:
                                                begin
                                                        o_uart_tx <= r_data[2];         //数据位
                                                end
                                        4'd4:
                                                begin
                                                        o_uart_tx <= r_data[3];         //数据位
                                                end
                                        4'd5:
                                                begin
                                                        o_uart_tx <= r_data[4];         //数据位
                                                end
                                        4'd6:
                                                begin
                                                        o_uart_tx <= r_data[5];         //数据位
                                                end
                                        4'd7:
                                                begin
                                                        o_uart_tx <= r_data[6];         //数据位
                                                end
                                        4'd8:
                                                begin
                                                        o_uart_tx <= r_data[7];         //数据位
                                                end
                                        4'd9:
                                                begin
                                                        o_uart_tx <= 1'd1;              //停止位
                                                end
                                        default:
                                                begin
                                                        o_uart_tx <= o_uart_tx;         //其他状态，保持不变  
                                                end
                                endcase
                        end
        end

//led输出逻辑
//发送数据完成后翻转 led，发送完成的时刻是状态记录计数器计数到 9 并且状态分割计数器计满的时刻
always @(posedge i_sysclk or negedge i_rst_n)
        begin
                if (~i_rst_n)
                        begin
                                o_led <= 1'b0;
                        end
                else if ((r_state_counter == STATE_COUNTER_MAX) && (r_baud_counter == BAUD_COUNTER_MAX))
                        begin
                                o_led <= ~o_led;
                        end
                else
                        begin
                                o_led <= o_led;
                        end
        end

//波特率计数器的使能信号
//定时 1s 的计数器计满 1s 时，使能波特率计数器，将 en_baud_counter 拉高，led 翻转的时刻失能波特率计数器，将 en_baud_counter 拉低
always @(posedge i_sysclk or negedge i_rst_n)
        begin
                if (~i_rst_n)
                        begin
                                en_baud_counter <= 1'b0;
                        end
                else if (r_1s_counter == COUNTER_1s_MAX)        //使能波特率计数器
                        begin
                                en_baud_counter <= 1'b1;
                        end
                else if ((r_state_counter == STATE_COUNTER_MAX) && (r_baud_counter == BAUD_COUNTER_MAX))        //失能波特率计数器
                        begin
                                en_baud_counter <= 1'b0;
                        end
                else
                        begin
                                en_baud_counter <= en_baud_counter;
                        end
        end

endmodule       