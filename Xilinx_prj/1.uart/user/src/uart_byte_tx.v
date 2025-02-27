/*
本模块基于 uart_byte_tx_led.v 修改得到，是一个通用的串口发送模块，可以修改波特率，并且增加了与其他模块进行对接的功能，具体修改如下：
1. 增加一个 uart 的发送使能端口 i_en_uart_tx，当使能端口为高电平时，uart_tx 才会进行发送，否则 uart_tx 为高电平，处于空闲状态，i_en_uart_tx 完全替代了原本的 1s 计数器的功能，因此删掉 1s 计数器。
2. 增加一个 uart 的发送完成标志端口 o_uart_tx_done，当 uart_tx 发送完成后，o_uart_tx_done 为高电平。该信号主要用于与其他模块进行对接，当 uart_tx 发送完成后，可以触发其他模块的操作或者连续发送多个数据时保证不会在上一个数据没有发送完成的情况下发送下一个数据。
3. 删除 led 的逻辑
4. 增加修改 baud 的参数
*/
module uart_byte_tx_led
(
        input   wire            i_sysclk        ,
        input   wire            i_rst_n         ,
        input   wire    [7:0]   i_data          ,
        input   wire            i_en_uart_tx    ,

        output  reg             o_uart_tx       ,
        output  reg             o_uart_tx_done
);

//parameter define
parameter               BAUD              = 9600;                       //波特率
parameter               CLOCK_FERQ        = 50_000_000;                 //时钟频率
parameter               BAUD_COUNTER_MAX  = CLOCK_FERQ/BAUD - 1;        //波特率计数器的最大值。特别说明，这里的参数计算不会消耗 FPGA 的资源，综合工具会自动计算出最终的结果
parameter               STATE_COUNTER_MAX = 9;                          //状态记录计数器的最大值

//reg define
reg      [29:0]         r_baud_counter  ;   //波特率计数器，将波特率计数器的最大值扩大到 30 位，防止计数器溢出
reg                     en_baud_counter ;   //波特率计数器的使能信号
reg      [3:0]          r_state_counter ;   //状态记录计数器
reg      [7:0]          r_data          ;   //寄存发送的数据

//wire define
wire                    w_uart_tx       ;   //uart_tx 发送完成标志

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

//寄存拨码开关的值
//应该在开始发送时寄存数据，开始发送的时间就是定时 1s 计数器计满 1s 的时间
//这里可以不使用复位，尽量减少复位的使用
always @(posedge i_sysclk or negedge i_rst_n)
        begin
                if (~i_rst_n)
                        begin
                                r_data <= 8'b0;
                        end
                else if (i_en_uart_tx)        //uart_tx 使能时，代表要开始发送，此时寄存数据
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

//uart_tx 发送完成标志
//当 uart_tx 发送完成后，o_uart_tx_done 为高电平
//(r_state_counter == STATE_COUNTER_MAX) && (r_baud_counter == BAUD_COUNTER_MAX) 代表 uart_tx 发送完成
//使用组合逻辑，不会延迟一个时钟周期
assign w_uart_tx_done = (r_state_counter == STATE_COUNTER_MAX) && (r_baud_counter == BAUD_COUNTER_MAX);
//使用时序逻辑，延迟一个时钟周期，o_uart_tx_done 信号仅仅只在与其他模块交互时使用，本模块内部的逻辑不使用 o_uart_tx_done 信号
always @(posedge i_sysclk or negedge i_rst_n)
        o_uart_tx_done <= w_uart_tx_done;

//波特率计数器的使能信号
//i_en_uart_tx 为高电平时，代表开始发送，此时使能波特率计数器
always @(posedge i_sysclk or negedge i_rst_n)
        begin
                if (~i_rst_n)
                        begin
                                en_baud_counter <= 1'b0;
                        end
                else if (i_en_uart_tx)        //拉高波特率计数器的使能信号
                        begin
                                en_baud_counter <= 1'b1;
                        end
                else if (w_uart_tx_done)        //发送完成后，拉低波特率计数器的使能信号，注意使用 w_uart_tx_done，而非 o_uart_tx_done
                        begin
                                en_baud_counter <= 1'b0;
                        end
                else
                        begin
                                en_baud_counter <= en_baud_counter;
                        end
        end

endmodule       