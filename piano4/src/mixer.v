module mixer #(parameter VOICES = 32)(
    input  [VOICES*16-1:0] voice_sample,  
    output reg [15:0] out
);
    integer m;
    reg signed [20:0] sum;
    reg [5:0] act;
    reg [4:0] shift;

    always @(*) begin
        sum = 21'sd0;
        act = 6'd0;
        for (m=0; m<VOICES; m=m+1) begin
            sum = sum + $signed(voice_sample[m*16 +: 16]);
            if (voice_sample[m*16 +: 16] != 16'd0) act = act + 1;
        end
    end

    always @(*) begin
        case (act)
            6'd0,6'd1:             shift = 5'd0;
            6'd2:                  shift = 5'd1;
            6'd3,6'd4:             shift = 5'd2;
            6'd5,6'd6,6'd7,6'd8:   shift = 5'd3;
            6'd9,6'd10,6'd11,6'd12,6'd13,6'd14,6'd15,6'd16: shift = 5'd4;
            default:               shift = 5'd5;   
        endcase
    end

    always @(*) begin
        if (act == 6'd0) out = 16'd0;
        else             out = sum >>> shift;
    end
endmodule
