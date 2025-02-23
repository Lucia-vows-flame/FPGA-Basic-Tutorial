`timescale 1ns/1ns
module tb_beep;

// 信号定义
reg i_sysclk;
reg i_sysrst_n;
wire o_beep;

// 实例化被测模块
beep
#(
        .TIME500MS(25'd24999),
        .DO(18'd190),
        .RE(18'd170),
        .MI(18'd151),
        .FA(18'd143),
        .SO(18'd127),
        .LA(18'd113),
        .XI(18'd101)
)
uut 
(
    .i_sysclk(i_sysclk),
    .i_sysrst_n(i_sysrst_n),
    .o_beep(o_beep)
);

// 时钟生成
initial begin
    i_sysclk = 0;
    forever #10 i_sysclk = ~i_sysclk; // 50MHz 时钟
end

// 复位信号生成
initial begin
    i_sysrst_n = 0;
    #100;
    i_sysrst_n = 1;
end

// 仿真控制
initial begin
    // 仿真时间
    #1000000;
    $stop;
end

endmodule
