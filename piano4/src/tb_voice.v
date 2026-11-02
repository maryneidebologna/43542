`timescale 1ns/1ps
module tb_voice;
    localparam VOICES = 32;
    reg clk = 0;
    always #18.5 clk = ~clk;      // ~27MHz

    reg rst_n;
    initial begin
        rst_n = 0;
        #100 rst_n = 1;
    end

  
    reg [8:0] s_cnt = 0;
    wire sample_tick = (s_cnt == 9'd511);
    always @(posedge clk)
        if (!rst_n) s_cnt <= 9'd0;
        else s_cnt <= (s_cnt==9'd511) ? 9'd0 : s_cnt + 9'd1;

    reg [63:0] press = 0;
    wire [VOICES*6-1:0]  vnote;
    wire [VOICES-1:0]    vgate, vdone;
    wire [VOICES*16-1:0] vsamp;
    wire [15:0] mix;

    voice_allocator #(.VOICES(VOICES)) u_alloc(
        .clk_27m(clk), .rst_n(rst_n), .press(press),
        .voice_done(vdone), .voice_note(vnote), .voice_gate(vgate)
    );
    osc_bank #(.VOICES(VOICES)) u_bank(
        .clk_27m(clk), .rst_n(rst_n), .sample_tick(sample_tick),
        .voice_note(vnote), .voice_gate(vgate),
        .voice_sample(vsamp), .voice_done(vdone)
    );
    mixer #(.VOICES(VOICES)) u_mix(.voice_sample(vsamp), .out(mix));

    initial begin
       
        #2000;
        press[0] = 1'b1;
        #60000;
        press[0] = 1'b0;
        #20000;

      
        press[1] = 1'b1;
        press[2] = 1'b1;
        #100000;                
        press[1] = 1'b0;
        press[2] = 1'b0;
        #30000;

      
        press[0] = 1'b1;
        press[7] = 1'b1;
        press[14]= 1'b1;
        #150000;
        press = 64'd0;
        #30000;
        $finish;
    end
endmodule
