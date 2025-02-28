`timescale 1ns/1ps

module tb_uart_byte_rx;

// 仿真时钟和复位信号
reg i_sysclk;
reg i_sysrst_n;
reg i_uart_rx;

// 输出信号
wire [7:0] o_rx_data;
wire o_uart_rx_done;

// 实例化被测试模块
uart_byte_rx uut (
        .i_sysclk(i_sysclk),
        .i_sysrst_n(i_sysrst_n),
        .i_uart_rx(i_uart_rx),
        .o_rx_data(o_rx_data),
        .o_uart_rx_done(o_uart_rx_done)
);

// 生成时钟信号
initial begin
        i_sysclk = 1;
end
always #10 i_sysclk = ~i_sysclk; // 50MHz 时钟周期为20ns

// 生成复位信号
initial begin
        i_sysrst_n = 0;
        #201;
        i_sysrst_n = 1;
end

// 生成UART接收信号
initial begin
        i_uart_rx = 1; // 空闲状态
        #201;
        // 发送一个字节数据 0x55 (01010101)
        send_byte(8'h55);
        #200000; // 等待一段时间
        // 发送一个字节数据 0xAA (10101010)
        send_byte(8'hAA);
        #200000; // 等待一段时间
        $stop;
end

// 任务：发送一个字节数据
task send_byte(input [7:0] data);
        integer i;
        begin
                // 发送起始位
                i_uart_rx = 0;
                #104160; // 对应波特率9600的一个位时间

                // 发送数据位
                for (i = 0; i < 8; i = i + 1) begin
                        i_uart_rx = data[i];
                        #104160; // 对应波特率9600的一个位时间
                end

                // 发送停止位
                i_uart_rx = 1;
                #104160; // 对应波特率9600的一个位时间
        end
endtask

endmodule
