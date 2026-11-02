module key_matrix_scan #(
    parameter integer SCAN_DIV = 200,
    parameter integer DB_TH    = 8
)(
    input        clk_27m,
    input        rst_n,
    input  [7:0] col_i,
    output [7:0] row_o,
    output reg [63:0] press            
);
    reg [7:0] col_s0, col_s1;
    always @(posedge clk_27m or negedge rst_n)
        if (!rst_n) begin col_s0 <= 8'hFF; col_s1 <= 8'hFF; end
        else begin col_s0 <= col_i; col_s1 <= col_s0; end

    reg [15:0] scan_cnt;
    reg [2:0]  scan_row;
    reg [63:0] raw;
    wire scan_tick = (scan_cnt == SCAN_DIV-1);
    wire scan_done = scan_tick && (scan_row == 3'd7);

    always @(posedge clk_27m or negedge rst_n)
        if (!rst_n) begin
            scan_cnt <= 16'd0; scan_row <= 3'd0; raw <= 64'd0;
        end else if (scan_tick) begin
            scan_cnt <= 16'd0;
            raw[scan_row*8 +: 8] <= ~col_s1;      
            scan_row <= scan_row + 3'd1;
        end else
            scan_cnt <= scan_cnt + 16'd1;

    assign row_o = ~(8'd1 << scan_row);

    
    wire [63:0] raw_t;
    genvar r, c;
    generate
        for (r=0; r<8; r=r+1) begin : t_row
            for (c=0; c<8; c=c+1) begin : t_col
                assign raw_t[c*8+r] = raw[r*8+c];
            end
        end
    endgenerate

  
    reg [3:0] db_cnt [63:0];
    integer k;
    always @(posedge clk_27m or negedge rst_n)
        if (!rst_n) begin
            press <= 64'd0;
            for (k=0; k<64; k=k+1) db_cnt[k] <= 4'd0;
        end else if (scan_done) begin
            for (k=0; k<64; k=k+1) begin
                if (raw_t[k] != press[k]) begin
                    if (db_cnt[k] == DB_TH[3:0]) begin
                        press[k] <= raw_t[k];
                        db_cnt[k] <= 4'd0;
                    end else
                        db_cnt[k] <= db_cnt[k] + 4'd1;
                end else
                    db_cnt[k] <= 4'd0;
            end
        end
endmodule
