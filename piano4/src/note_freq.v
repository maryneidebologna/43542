module note_freq (
    input      [5:0] key,
    output reg [23:0] f_inc
);
    always @(*) begin
        case (key)
            6'd0 : f_inc = 24'd20809;   // C2   65.4Hz
            6'd1 : f_inc = 24'd22046;   // C#2
            6'd2 : f_inc = 24'd23357;   // D2
            6'd3 : f_inc = 24'd24746;   // D#2
            6'd4 : f_inc = 24'd26218;   // E2
            6'd5 : f_inc = 24'd27777;   // F2
            6'd6 : f_inc = 24'd29428;   // F#2
            6'd7 : f_inc = 24'd31178;   // G2
            6'd8 : f_inc = 24'd33033;   // G#2
            6'd9 : f_inc = 24'd34996;   // A2
            6'd10: f_inc = 24'd37077;   // A#2
            6'd11: f_inc = 24'd39282;   // B2
            6'd12: f_inc = 24'd41617;   // C3
            6'd13: f_inc = 24'd44092;   // C#3
            6'd14: f_inc = 24'd46714;   // D3
            6'd15: f_inc = 24'd49491;   // D#3
            6'd16: f_inc = 24'd52434;   // E3
            6'd17: f_inc = 24'd55552;   // F3
            6'd18: f_inc = 24'd58857;   // F#3
            6'd19: f_inc = 24'd62357;   // G3
            6'd20: f_inc = 24'd66063;   // G#3
            6'd21: f_inc = 24'd69993;   // A3
            6'd22: f_inc = 24'd74154;   // A#3
            6'd23: f_inc = 24'd78563;   // B3
            6'd24: f_inc = 24'd83237;   // C4
            6'd25: f_inc = 24'd88184;   // C#4
            6'd26: f_inc = 24'd93427;   // D4
            6'd27: f_inc = 24'd98985;   // D#4
            6'd28: f_inc = 24'd104871;  // E4
            6'd29: f_inc = 24'd111107;  // F4
            6'd30: f_inc = 24'd117712;  // F#4
            6'd31: f_inc = 24'd124714;  // G4
            6'd32: f_inc = 24'd132127;  // G#4
            6'd33: f_inc = 24'd139985;  // A4  440Hz
            6'd34: f_inc = 24'd148308;  // A#4
            6'd35: f_inc = 24'd157127;  // B4
            6'd36: f_inc = 24'd166471;  // C5
            6'd37: f_inc = 24'd176372;  // C#5
            6'd38: f_inc = 24'd186858;  // D5
            6'd39: f_inc = 24'd197968;  // D#5
            6'd40: f_inc = 24'd209742;  // E5
            6'd41: f_inc = 24'd222214;  // F5
            6'd42: f_inc = 24'd235426;  // F#5
            6'd43: f_inc = 24'd249425;  // G5
            6'd44: f_inc = 24'd264257;  // G#5
            6'd45: f_inc = 24'd279970;  // A5
            6'd46: f_inc = 24'd296619;  // A#5
            6'd47: f_inc = 24'd314257;  // B5
            default: f_inc = 24'd0;     // ≥48 静音
        endcase
    end
endmodule
