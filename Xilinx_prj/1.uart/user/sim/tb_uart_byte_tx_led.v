`timescale 1ns/1ps

module tb_uart_byte_tx_led;

// 信号定义
reg             tb_sysclk;
reg             tb_rst_n;
reg     [7:0]   tb_data;
wire            tb_uart_tx;
wire            tb_led;

// 实例化被测试模块
uart_byte_tx_led uut (
        .i_sysclk(tb_sysclk),
        .i_rst_n(tb_rst_n),
        .i_data(tb_data),
        .o_uart_tx(tb_uart_tx),
        .o_led(tb_led)
);

//修改仿真参数，将 1s 修改为 1ms
defparam uut.COUNTER_1s_MAX = 50_000_0 - 1;

// 时钟初始化
initial begin
        tb_sysclk = 1;
end

// 时钟生成
always #10 tb_sysclk = ~tb_sysclk; // 50MHz 时钟

// 复位信号和数据信号初始化
initial begin
        tb_rst_n = 0;
        #201;
        tb_rst_n = 1;
        tb_data = 8'b0101_0101;
        #30000000;
        tb_data = 8'b1010_1010;
        #30000000;
end

endmodule
