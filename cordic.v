module cordic (rst_n, clk, x, y, z, mode, x_n, y_n, z_n, start, done,
               XYFRACBASE, PHASEFRACBASE,
               SCALE_FACTOR, XYBASEONE,
               INVTAN0, INVTAN1, INVTAN2, INVTAN3, INVTAN4, INVTAN5, INVTAN6, INVTAN7,
               INVTAN8, INVTAN9, INVTAN10,
               INVTAN11, INVTAN12, INVTAN13, INVTAN14, INVTAN15, INVTAN16, INVTAN17,
               INVTAN18, INVTAN19, INVTAN20,
               INVTAN21, INVTAN22, INVTAN23, INVTAN24, INVTAN25, INVTAN26, INVTAN27,
               INVTAN28, INVTAN29, INVTAN30, INVTAN31);
parameter N = 32;
input rst_n; // Reset
input clk; // Clock
input [N-1:0] x; //
input [N-1:0] y; //
input [N-1:0] z; //
input mode; // Mode = '1' Vectoring, Mode = 0 Rotation
input start; // Indicate start of the codic iteration cycle
output [N-1:0] x_n;
output [N-1:0] y_n;
output [N-1:0] z_n;
output done; // Indicates end of cordic iteration cycles
input [4:0] XYFRACBASE, PHASEFRACBASE;
input [31:0] SCALE_FACTOR, XYBASEONE;
input [31:0] INVTAN0, INVTAN1, INVTAN2, INVTAN3, INVTAN4, INVTAN5, INVTAN6, INVTAN7,
      INVTAN8, INVTAN9, INVTAN10;
input [31:0] INVTAN11, INVTAN12, INVTAN13, INVTAN14, INVTAN15, INVTAN16, INVTAN17,
      INVTAN18, INVTAN19, INVTAN20;
input [31:0] INVTAN21, INVTAN22, INVTAN23, INVTAN24, INVTAN25, INVTAN26, INVTAN27,
      INVTAN28, INVTAN29, INVTAN30, INVTAN31;
wire d;
reg [4:0] counter;
reg [31:0] x_prev, y_prev, z_prev;
reg start_iter;
wire [31:0] sig_x_prev_d0, sig_y_prev_d0, sig_z_prev_d0;
wire [31:0] sig_x_prev_d1, sig_y_prev_d1, sig_z_prev_d1;
wire [31:0] x_mask, y_mask, x_shift, y_shift ;
wire [31:0] inv_tan;
wire [63:0] x_mult, y_mult;
wire [63:0] x_mult1, y_mult1;
wire [31:0] neg_z;
always @(posedge clk) begin
    if (~rst_n) begin
        counter <= 5'h0;
        start_iter <= 1'b0;
    end
    else begin
        start_iter <= start;
        if ((start_iter == 1'b1) || (counter != 5'h0))
            counter <= counter + 1;
    end
end
assign done = (counter == 5'h1F);
assign d = (mode)? (~(y_prev[31])) : z_prev[31]; // d = 0 add, d=1 subtract
assign neg_z = 'h0 - z;
always @(posedge clk) begin
    if (~rst_n) begin
        x_prev <= 32'h0;
        y_prev <= 32'h0;
        z_prev <= 32'h0;
    end
    else
        if (start == 1'b1 && counter == 5'h0) begin
            // Check if coarse rotation need to be performed. If yes, do it !
            if (mode == 1'b0) // Rotation
            begin
                if (z[31] == 1'b0 && z > (32'h6487ED51 >> (5'h1E - PHASEFRACBASE))) begin
                    x_prev <= 'h0 - y;
                    y_prev <= x;
                    z_prev <= z - (32'h6487ED51 >> (5'h1E -
                                                    PHASEFRACBASE));
                end
                else if ((z[31] == 1'b1) && neg_z > (32'h6487ED51 >>
                                                     (5'h1E - PHASEFRACBASE))) begin
                    x_prev <= y;
                    y_prev <= 'h0 - x;
                    z_prev <= z + (32'h6487ED51 >> (5'h1E -
                                                    PHASEFRACBASE));
                end
                else begin
                    x_prev <= x;
                    y_prev <= y;
                    z_prev <= z;
                end
            end
            else // Vectoring
            begin
                if (x[31] == 1'b1 && y[31] == 1'b0) // x < 0, y > 0
                begin
                    x_prev <= y;
                    y_prev <= 'h0 - x;
                    z_prev <= z + (32'h6487ED51 >> (5'h1E -
                                                    PHASEFRACBASE));
                end
                else if (x[31] == 1'b1 && y[31] == 1'b1) // x < 0, y > 0
                begin
                    x_prev <= 'h0 - y;
                    y_prev <= x;
                    z_prev <= z - (32'h6487ED51 >> (5'h1E -
                                                    PHASEFRACBASE));
                end
                else begin
                    x_prev <= x;
                    y_prev <= y;
                    z_prev <= z;
                end
            end
        end
        else if (counter != 5'h0 || start_iter == 1'b1) begin
            if (d == 0) begin
                // x_prev <= x_prev - y_shift;
                // y_prev <= y_prev + x_shift;
                // z_prev <= z_prev - inv_tan;
                x_prev <= sig_x_prev_d0;
                y_prev <= sig_y_prev_d0;
                z_prev <= sig_z_prev_d0;
            end
            else begin
                // x_prev <= x_prev + y_shift;
                // y_prev <= y_prev - x_shift;
                // z_prev <= z_prev + inv_tan;
                x_prev <= sig_x_prev_d1;
                y_prev <= sig_y_prev_d1;
                z_prev <= sig_z_prev_d1;
            end
        end
end
// d = 0 adders
// adder adder_inst1 (.a_in(x_prev), .b_in(y_shift), .add_nsub(1'b0),
//                    .s_out(sig_x_prev_d0));
assign sig_x_prev_d0 = x_prev + y_shift;
// adder adder_inst2 (.a_in(y_prev), .b_in(x_shift), .add_nsub(1'b1),
//                    .s_out(sig_y_prev_d0));
assign sig_y_prev_d0 = y_prev - x_shift;
// adder adder_inst3 (.a_in(z_prev), .b_in(inv_tan), .add_nsub(1'b0),
//                    .s_out(sig_z_prev_d0));
assign sig_z_prev_d0 = z_prev + inv_tan;
// d = 1 adders
// adder adder_inst4 (.a_in(x_prev), .b_in(y_shift), .add_nsub(1'b1),
//                    .s_out(sig_x_prev_d1));
assign sig_x_prev_d1 = x_prev - y_shift;
// adder adder_inst5 (.a_in(y_prev), .b_in(x_shift), .add_nsub(1'b0),
//                    .s_out(sig_y_prev_d1));
assign sig_y_prev_d1 = y_prev + x_shift;
// adder adder_inst6 (.a_in(z_prev), .b_in(inv_tan), .add_nsub(1'b1),
//                    .s_out(sig_z_prev_d1));
assign sig_z_prev_d1 = z_prev - inv_tan;

assign y_shift = (y_prev >> counter) | y_mask ;
assign y_mask = ~(y_prev[31]) ? 32'h0 : ~(32'hFFFFFFFF >> counter);
assign x_shift = (x_prev >> counter) | x_mask ;
assign x_mask = ~(x_prev[31]) ? 32'h0 : ~(32'hFFFFFFFF >> counter);
assign x_mult = (x_prev[31])? ({32'hFFFFFFFF, x_prev} * SCALE_FACTOR) : (x_prev *
        SCALE_FACTOR );
assign y_mult = (y_prev[31])? ({32'hFFFFFFFF, y_prev} * SCALE_FACTOR) : (y_prev *
        SCALE_FACTOR );
assign x_mult1 = x_mult >> XYFRACBASE;
assign y_mult1 = y_mult >> XYFRACBASE;
assign x_n = x_mult1[31:0];
assign y_n = y_mult1[31:0];
assign z_n = z_prev;
assign inv_tan = (counter == 5'd0) ? INVTAN0 :
       (counter == 5'd1) ? INVTAN1 :
       (counter == 5'd2) ? INVTAN2 :
       (counter == 5'd3) ? INVTAN3 :
       (counter == 5'd4) ? INVTAN4 :
       (counter == 5'd5) ? INVTAN5 :
       (counter == 5'd6) ? INVTAN6 :
       (counter == 5'd7) ? INVTAN7 :
       (counter == 5'd8) ? INVTAN8 :
       (counter == 5'd9) ? INVTAN9 :
       (counter == 5'd10) ? INVTAN10 :
       (counter == 5'd11) ? INVTAN11 :
       (counter == 5'd12) ? INVTAN12 :
       (counter == 5'd13) ? INVTAN13 :
       (counter == 5'd14) ? INVTAN14 :
       (counter == 5'd15) ? INVTAN15 :
       (counter == 5'd16) ? INVTAN16 :
       (counter == 5'd17) ? INVTAN17 :
       (counter == 5'd18) ? INVTAN18 :
       (counter == 5'd19) ? INVTAN19 :
       (counter == 5'd20) ? INVTAN20 :
       (counter == 5'd21) ? INVTAN21 :
       (counter == 5'd22) ? INVTAN22 :
       (counter == 5'd23) ? INVTAN23 :
       (counter == 5'd24) ? INVTAN24 :
       (counter == 5'd25) ? INVTAN25 :
       (counter == 5'd26) ? INVTAN26 :
       (counter == 5'd27) ? INVTAN27 :
       (counter == 5'd28) ? INVTAN28 :
       (counter == 5'd29) ? INVTAN29 :
       (counter == 5'd30) ? INVTAN30 :
       (counter == 5'd31) ? INVTAN31 : 32'h00000000;
endmodule
