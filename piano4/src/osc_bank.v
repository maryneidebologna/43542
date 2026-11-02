module osc_bank #(parameter VOICES = 32)(
    input  clk_27m,
    input  rst_n,
    input  sample_tick,
    input  [VOICES*6-1:0]  voice_note,    // 打包：每 6 位一个声道
    input  [VOICES-1:0]    voice_gate,
    output [VOICES*16-1:0] voice_sample,  // 打包：每 16 位一个声道
    output [VOICES-1:0]    voice_done
);
    genvar g;
    generate
        for (g=0; g<VOICES; g=g+1) begin : vosc
            voice_osc u_v(
                .clk_27m(clk_27m), .rst_n(rst_n), .sample_tick(sample_tick),
                .voice_note(voice_note[g*6 +: 6]),
                .voice_gate(voice_gate[g]),
                .sample(voice_sample[g*16 +: 16]),
                .voice_done(voice_done[g])
            );
        end
    endgenerate
endmodule

