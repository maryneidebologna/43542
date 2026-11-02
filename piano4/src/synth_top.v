module synth_top (
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
    wire [VOICES*6-1:0]  vnote;
    wire [VOICES-1:0]    vgate, vdone;
    wire [VOICES*16-1:0] vsamp;
    voice_allocator #(.VOICES(VOICES)) u_alloc(
        .clk_27m(clk_27m), .rst_n(rst_n), .press(press),
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
    wire [15:0] mix;
    mixer #(.VOICES(VOICES)) u_mix(.voice_sample(vsamp), .out(mix));
    i2s_tx #(.DIV(8)) u_i2s(
        .clk_27m(clk_27m), .rst_n(rst_n),
        .audio_l(mix), .audio_r(mix),
        .bclk(bclk), .lrc(lrc), .din(din)
    );
endmodule
