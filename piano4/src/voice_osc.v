module voice_osc #(
    parameter [15:0] ATTACK_STEP  = 16'd256,   
    parameter [15:0] RELEASE_STEP = 16'd32,    
    parameter [15:0] ENV_MAX      = 16'd12000  
)(
    input        clk_27m,
    input        rst_n,
    input        sample_tick,
    input  [5:0] voice_note,      // 键号 0~47
    input        voice_gate,      // 1=发声，0=释放
    output [15:0] sample,         // 有符号方波×包络
    output reg    voice_done      // 包络放完=1
);
    wire [23:0] f_inc;
    note_freq u_freq(.key(voice_note), .f_inc(f_inc));

    reg [23:0] phase;
    reg [15:0] env;
    reg        voice_on;

    always @(posedge clk_27m or negedge rst_n)
        if (!rst_n) begin
            phase      <= 24'd0;
            env        <= 16'd0;
            voice_on   <= 1'b0;
            voice_done <= 1'b0;
        end else if (sample_tick) begin
            phase <= phase + f_inc;              

            if (voice_gate) begin                
                voice_on   <= 1'b1;
                voice_done <= 1'b0;
                env <= (env > ENV_MAX - ATTACK_STEP) ? ENV_MAX
                                                     : env + ATTACK_STEP;
            end else if (voice_on) begin         
                if (env <= RELEASE_STEP) begin
                    env        <= 16'd0;
                    voice_on   <= 1'b0;
                    voice_done <= 1'b1;          
                end else
                    env <= env - RELEASE_STEP;
            end else begin                       
                voice_done <= 1'b0;
            end
        end

   
    assign sample = phase[23] ? -$signed({1'b0, env}) : $signed({1'b0, env});
endmodule
