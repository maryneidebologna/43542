module synth_top_test (
    input  clk_27m,
    input  [7:0] col_i,
    output [7:0] row_o,
    output bclk, lrc, din
);
    localparam VOICES = 32;
    wire rst_n;
    assign rst_n = 1'b1;

    wire [63:0] press;
    key_matrix_scan u_scan(
        .clk_27m(clk_27m), .rst_n(rst_n), .col_i(col_i), .row_o(row_o),
        .press(press)
    );

    // ---- 测试键 + 武装逻辑 ----
    wire test_key_raw = press[48];

    reg        test_armed;
    reg [15:0] arm_cnt;
    always @(posedge clk_27m or negedge rst_n) begin
        if (!rst_n) begin
            test_armed <= 1'b0;
            arm_cnt    <= 16'd0;
        end else if (!test_armed) begin
            if (test_key_raw)
                arm_cnt <= 16'd0;                 // 上电就被按住 → 清零重等
            else if (arm_cnt < 16'd50000)
                arm_cnt <= arm_cnt + 16'd1;       // 松开状态累计 ~1.85ms
            else
                test_armed <= 1'b1;               // 武装成功
        end
    end
    wire test_on = test_armed & test_key_raw;   // 武装后按住才算数
    // --------------------------

    wire [63:0] press_eff;
    assign press_eff = test_on ? 64'h0000_0000_FFFF_FFFF
                               : (press & 64'h0000_FFFF_FFFF_FFFF);

    wire [VOICES*6-1:0]  vnote;
    wire [VOICES-1:0]    vgate, vdone;
    wire [VOICES*16-1:0] vsamp;
    wire [15:0]          mix;

    voice_allocator #(.VOICES(VOICES)) u_alloc(
        .clk_27m(clk_27m), .rst_n(rst_n), .press(press_eff),
        .voice_done(vdone),
        .voice_note(vnote), .voice_gate(vgate)
    );

    reg [8:0] s_cnt;
    wire sample_tick = (s_cnt == 9'd511);
    always @(posedge clk_27m or negedge rst_n)
        if (!rst_n) s_cnt <= 9'd0;
        else s_cnt <= (s_cnt == 9'd511) ? 9'd0 : s_cnt + 9'd1;

    osc_bank #(.VOICES(VOICES)) u_bank(
        .clk_27m(clk_27m), .rst_n(rst_n), .sample_tick(sample_tick),
        .voice_note(vnote), .voice_gate(vgate),
        .voice_sample(vsamp), .voice_done(vdone)
    );

    mixer #(.VOICES(VOICES)) u_mix(.voice_sample(vsamp), .out(mix));

    i2s_tx #(.DIV(8)) u_i2s(
        .clk_27m(clk_27m), .rst_n(rst_n),
        .audio_l(mix), .audio_r(mix),
        .bclk(bclk), .lrc(lrc), .din(din)
    );
endmodule