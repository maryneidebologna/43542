module voice_allocator #(parameter VOICES = 32)(
    input  clk_27m,
    input  rst_n,
    input  [63:0] press,
    input  [VOICES-1:0]   voice_done,
    output reg [VOICES*6-1:0] voice_note,   
    output reg [VOICES-1:0]  voice_gate
);
    reg [63:0] press_d1;
    reg [VOICES-1:0] done_d1;              
    reg [5:0]  key_voice [0:47];
    reg [VOICES-1:0] voice_active;
    integer k, v, free_v;
    always @(posedge clk_27m or negedge rst_n)
        if (!rst_n) begin
            press_d1     <= 64'd0;
            done_d1      <= {VOICES{1'b0}};
            voice_gate   <= {VOICES{1'b0}};
            voice_active <= {VOICES{1'b0}};
            for (k=0; k<48; k=k+1) key_voice[k] <= 6'd63;
            for (v=0; v<VOICES; v=v+1) voice_note[v*6 +: 6] <= 6'd0;
        end else begin
            press_d1 <= press;
            done_d1  <= voice_done;
            
            for (v=0; v<VOICES; v=v+1)
                if (voice_done[v] && !done_d1[v] && !voice_gate[v]) begin
                    voice_active[v] <= 1'b0;
                    voice_gate[v]   <= 1'b0;
                    for (k=0; k<48; k=k+1)
                        if (key_voice[k] == v[5:0])
                            key_voice[k] <= 6'd63;
                end
           
            for (k=0; k<48; k=k+1) begin
                if (press[k] && !press_d1[k]) begin
                    free_v = 32;
                    for (v=0; v<VOICES; v=v+1)
                        if (!voice_active[v] && free_v==32)
                            free_v = v;
                    if (free_v < VOICES) begin
                        voice_active[free_v]      <= 1'b1;
                        voice_gate[free_v]        <= 1'b1;
                        voice_note[free_v*6 +: 6] <= k[5:0];
                        key_voice[k]              <= free_v[5:0];
                    end
                end
              
                if (!press[k] && press_d1[k]) begin
                    if (key_voice[k] != 6'd63)
                        voice_gate[key_voice[k]] <= 1'b0;
                end
            end
        end
endmodule
