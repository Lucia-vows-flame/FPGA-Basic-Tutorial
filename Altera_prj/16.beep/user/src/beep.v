module beep
#(
        parameter   TIME500MS   = 25'd24999999  ,//0.5s计数值
        parameter   DO          = 18'd190839    ,//"DO"的计数值
        parameter   RE          = 18'd170067    ,//"RE"的计数值
        parameter   MI          = 18'd151514    ,//"MI"的计数值
        parameter   FA          = 18'd143265    ,//"FA"的计数值
        parameter   SO          = 18'd127550    ,//"SO"的计数值
        parameter   LA          = 18'd113635    ,//"LA"的计数值
        parameter   XI          = 18'd101214     //"XI"的计数值
)
(
        input   wire    i_sysclk        ,
        input   wire    i_sysrst_n      ,

        output  reg     o_beep
);

//reg define
reg     [24:0]  r_cnt500ms   ;
reg     [2:0]   r_cnt_state  ;
reg     [17:0]  r_freq       ;
reg     [17:0]  r_cnt_pwm    ;

//wire define
wire    [16:0]  r_duty       ;

//r_cnt500ms
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if(~i_sysrst_n)
                        r_cnt500ms <= 0;
                else if(r_cnt500ms == TIME500MS)
                        r_cnt500ms <= 0;
                else
                        r_cnt500ms <= r_cnt500ms + 1;
        end

//r_cnt_state
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if(~i_sysrst_n)
                        r_cnt_state <= 0;
                else if(r_cnt500ms == TIME500MS && r_cnt_state == 3'd6)
                        r_cnt_state <= 0;
                else if(r_cnt500ms == TIME500MS)
                        r_cnt_state <= r_cnt_state + 1;
        end

//r_freq
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if(~i_sysrst_n)
                        r_freq <= DO;
                else
                        case(r_cnt_state)
                                3'd0:   r_freq <= DO;
                                3'd1:   r_freq <= RE;
                                3'd2:   r_freq <= MI;
                                3'd3:   r_freq <= FA;
                                3'd4:   r_freq <= SO;
                                3'd5:   r_freq <= LA;
                                3'd6:   r_freq <= XI;
                                default: r_freq <= 0;
                        endcase
        end

//r_cnt_pwm
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if(~i_sysrst_n)
                        r_cnt_pwm <= 0;
                else if(r_cnt_pwm == r_freq || r_cnt500ms == TIME500MS)//这里必须加上r_cnt500ms == TIME500MS，具体原因在文档中有说明
                        r_cnt_pwm <= 0;
                else
                        r_cnt_pwm <= r_cnt_pwm + 1;
        end

//o_beep
always @(posedge i_sysclk or negedge i_sysrst_n)
        begin
                if(~i_sysrst_n)
                        o_beep <= 1'b0;
                else if(r_cnt_pwm >= r_duty)
                        o_beep <= 1'b1;
                else
                        o_beep <= 1'b0;
        end

endmodule