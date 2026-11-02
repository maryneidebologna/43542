module i2s_tx #(
    parameter integer DIV = 8
)(
    input              clk_27m,
    input              rst_n,
    input      [15:0]  audio_l,
    input      [15:0]  audio_r,
    output reg         bclk,
    output reg         lrc,
    output reg         din
);

    reg [15:0] div_cnt;
    reg [5:0]  slot_cnt;
    reg [15:0] shift_reg;

    wire div_tick = (div_cnt == DIV-1);

    always @(posedge clk_27m or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt   <= 16'd0;
            bclk      <= 1'b0;
            lrc       <= 1'b0;
            din       <= 1'b0;
            slot_cnt  <= 6'd0;
            shift_reg <= audio_l;
        end
        else begin
            if (div_tick) begin
                div_cnt <= 16'd0;

                if (bclk == 1'b0) begin
                    bclk <= 1'b1;
                end
                else begin
                    bclk <= 1'b0;

                    if (slot_cnt == 6'd31) begin
                        slot_cnt <= 6'd0;

                        if (lrc == 1'b0) begin
                            lrc       <= 1'b1;
                            shift_reg <= audio_r;
                        end
                        else begin
                            lrc       <= 1'b0;
                            shift_reg <= audio_l;
                        end

                        din <= 1'b0;
                    end
                    else begin
                        slot_cnt <= slot_cnt + 6'd1;

                        if ((slot_cnt >= 6'd0) &&
                            (slot_cnt < 6'd16)) begin

                            if (slot_cnt == 6'd0) begin
                                din <= 1'b0;
                            end
                            else begin
                                din       <= shift_reg[15];
                                shift_reg <= {shift_reg[14:0], 1'b0};
                            end
                        end
                        else begin
                            din <= 1'b0;
                        end
                    end
                end
            end
            else begin
                div_cnt <= div_cnt + 16'd1;
            end
        end
    end

endmodule