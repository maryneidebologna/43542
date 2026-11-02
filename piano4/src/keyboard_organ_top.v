module keyboard_organ_top (
    input        clk_27m,   // E2
    output [7:0] row_o,     // X0~X7 行
    input  [7:0] col_i,     // Y0~Y7 列(需上拉)
    output       bclk, lrc, din
);
    wire rst_n = 1'b1;      // 内部复位拉高(别再对端口 assign!)

    wire [5:0]  key;        // 当前键号 0~63, 0xFF=无键
    wire [23:0] f_inc;      // 频率步进
    wire [15:0] audio_l, audio_r;

    key_matrix_scan u_scan (.clk_27m(clk_27m), .rst_n(rst_n),
                            .row_o(row_o), .col_i(col_i), .key(key));

    note_freq u_freq (.key(key), .f_inc(f_inc));

    tone_gen u_tone (.clk_27m(clk_27m), .rst_n(rst_n),
                     .key(key), .f_inc(f_inc),
                     .audio_l(audio_l), .audio_r(audio_r));

    i2s_tx #(.DIV(8)) u_i2s (.clk_27m(clk_27m), .rst_n(rst_n),
                             .audio_l(audio_l), .audio_r(audio_r),
                             .bclk(bclk), .lrc(lrc), .din(din));
endmodule
