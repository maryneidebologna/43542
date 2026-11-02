module tone_gen (
    input        clk_27m,
    input        rst_n,
    input  [5:0] key,         
    input  [23:0] f_inc,
    output reg [15:0] audio_l,
    output reg [15:0] audio_r
);
    reg [8:0] samp_cnt;                 
    wire sample_tick = (samp_cnt == 9'd511);
    always @(posedge clk_27m or negedge rst_n) begin
        if (!rst_n) samp_cnt <= 0;
        else samp_cnt <= sample_tick ? 9'd0 : samp_cnt + 1'b1;
    end

    wire note_active = (key < 8'd48);
    reg [23:0] phase;
    always @(posedge clk_27m or negedge rst_n) begin
        if (!rst_n) begin phase <= 0; audio_l <= 0; audio_r <= 0; end
        else if (sample_tick) begin
            if (note_active) begin
                phase   <= phase + f_inc;
                audio_l <= phase[23] ? 16'd14000 : 16'd2000;  
                audio_r <= audio_l;
            end else begin
                audio_l <= 0; audio_r <= 0;
            end
        end
    end
endmodule
