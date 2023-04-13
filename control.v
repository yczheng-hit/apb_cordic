module control (rst_n,
                clk,
                cordic_start,
                cordic_func,
                a,
                b,
                c,
                d,
                out1,
                out2,
                out3,
                out4,
                out5,
                out6,
                write_op,
                XYFRACBASE,
                PHASEFRACBASE,
                SCALE_FACTOR,
                XYBASEONE,
                INVTAN0,
                INVTAN1,
                INVTAN2,
                INVTAN3,
                INVTAN4,
                INVTAN5,
                INVTAN6,
                INVTAN7,
                INVTAN8,
                INVTAN9,
                INVTAN10,
                INVTAN11,
                INVTAN12,
                INVTAN13,
                INVTAN14,
                INVTAN15,
                INVTAN16,
                INVTAN17,
                INVTAN18,
                INVTAN19,
                INVTAN20,
                INVTAN21,
                INVTAN22,
                INVTAN23,
                INVTAN24,
                INVTAN25,
                INVTAN26,
                INVTAN27,
                INVTAN28,
                INVTAN29,
                INVTAN30,
                INVTAN31);
input rst_n, clk; // Reset and Clock
input [31:0] a, b, c, d; // Inputs
input cordic_start;
input [2:0] cordic_func;
output [31:0] out1, out2, out3, out4, out5, out6;
output write_op;
input [4:0] XYFRACBASE, PHASEFRACBASE;
input [31:0] SCALE_FACTOR, XYBASEONE;
input [31:0] INVTAN0, INVTAN1, INVTAN2, INVTAN3, INVTAN4, INVTAN5, INVTAN6, INVTAN7,
      INVTAN8, INVTAN9, INVTAN10;
input [31:0] INVTAN11, INVTAN12, INVTAN13, INVTAN14, INVTAN15, INVTAN16, INVTAN17,
      INVTAN18, INVTAN19, INVTAN20;
input [31:0] INVTAN21, INVTAN22, INVTAN23, INVTAN24, INVTAN25, INVTAN26, INVTAN27,
      INVTAN28, INVTAN29, INVTAN30, INVTAN31;
`define FSM_Idle 3'h0
    `define FSM_WAIT_DONE 3'h1
    `define FSM_SVD_STAGE2 3'h2
    `define FSM_SVD_STAGE3 3'h3
    `define FSM_SVD_STAGE4 3'h4
    `define FSM_SVD_WAIT_DONE 3'h5
    `define FUNC_SINCOS 3'h0
    `define FUNC_INVTAN 3'h1
    `define FUNC_VECROT 3'h2
    `define FUNC_SVD 3'h3
    `define FUNC_GEN_VEC 3'h4

reg [2:0] fsm_state;
reg [31:0] x_c1, y_c1, z_c1, x_c2, y_c2, z_c2;
reg [31:0] out1, out2, out3, out4, out5, out6;
reg [31:0] eig1, eig2, theta_r, theta_l;
reg start_c1, start_c2, mode_c1, mode_c2, write_op;
wire [31:0] sig_theta_r, sig_theta_l;
wire [31:0] temp_theta_r, temp_theta_l;
wire [31:0] x_n_c1, y_n_c1, z_n_c1, x_n_c2, y_n_c2, z_n_c2;
wire done_c1, done_c2;
always @(posedge clk) begin
    if (~rst_n) begin
        fsm_state <= `FSM_Idle ;
        // Cordic Processor 1
        x_c1     <= 32'h0;
        y_c1     <= 32'h0;
        z_c1     <= 32'h0;
        mode_c1  <= 1'b0;
        start_c1 <= 1'b0;
        // Cordic Processor 2
        x_c2     <= 32'h0;
        y_c2     <= 32'h0;
        z_c2     <= 32'h0;
        mode_c2  <= 1'b0;
        start_c2 <= 1'b0;
        // Answers
        write_op <= 1'b0;
        out1     <= 32'h0;
        out2     <= 32'h0;
        out3     <= 32'h0;
        out4     <= 32'h0;
        out5     <= 32'h0;
        out6     <= 32'h0;
        // Intermediate for SVD
        theta_r <= 32'h0;
        theta_l <= 32'h0;
        eig1    <= 32'h0;
        eig2    <= 32'h0;
    end
    else begin
        case(fsm_state)
            `FSM_Idle: begin
                write_op <= 1'b0; // Pull down write signal
                if (cordic_start == 1'b1) begin
                    if (cordic_func == `FUNC_SINCOS) begin
                        x_c1 <= XYBASEONE ; // x0 = 1 for sin/cos calculations
                        y_c1 <= 32'h0; // y0 = 0 for sin/cos calculations
                        z_c1 <= a; // Will Compute y = Sin(a), x = Cos(a)
                        mode_c1   <= 1'b0; // Rotation Mode
                        start_c1  <= 1'b1;
                        fsm_state <= `FSM_WAIT_DONE;
                    end
                    else if (cordic_func == `FUNC_INVTAN) begin
                        x_c1 <= XYBASEONE; // x0 = 1 for inv_tan calculation
                        y_c1 <= a; // will compute z = inv_tan(a)
                        z_c1 <= 32'h0; // z0 = 0 for inv_tan calculation
                        mode_c1   <= 1'b1; // Vectoring mode
                        start_c1  <= 1'b1;
                        fsm_state <= `FSM_WAIT_DONE;
                    end
                    else if (cordic_func == `FUNC_VECROT) begin
                        x_c1 <= a; // Vector to be rotated = (a, b)
                        y_c1      <= b; //
                        z_c1      <= c; // Angle by which rotation has to be done
                        mode_c1   <= 1'b0; // Rotation Mode
                        start_c1  <= 1'b1;
                        fsm_state <= `FSM_WAIT_DONE;
                    end
                    else if (cordic_func == `FUNC_GEN_VEC) // Generic Vectoring mode
                    begin
                        x_c1 <= a; // Vector to be rotated = (a, b)
                        y_c1      <= b; //
                        z_c1      <= c; // Phase
                        mode_c1   <= 1'b1; // Vectoring Mode
                        start_c1  <= 1'b1;
                        fsm_state <= `FSM_WAIT_DONE;
                    end
                    else if (cordic_func == `FUNC_SVD) begin
                        // Cordic Processor 1
                        x_c1 <= d - a; // Stage1 : Calculation of Theta_{sum}
                        y_c1 <= c + b; // inv_tan (c+b / d-a) = theta_{sum}
                        z_c1 <= 32'h0; // z0 = 0 for inv_tan calculation
                        mode_c1  <= 1'b1; // Vectoring mode
                        start_c1 <= 1'b1;
                        // Cordic Processor 2
                        x_c2 <= d + a; // Stage1 : Calculation of Theta_{diff}
                        y_c2 <= c - b; // inv_tan (c-b / d+a) = theta_{diff}
                        z_c2 <= 32'h0; // z0 = 0 for inv_tan calculation
                        mode_c2   <= 1'b1; // Vectoring mode
                        start_c2  <= 1'b1;
                        fsm_state <= `FSM_SVD_STAGE2; // Go to state 2
                    end
                end
            end
            `FSM_WAIT_DONE: begin
                start_c1 <= 1'b0;
                if (done_c1 == 1'b1) begin
                    write_op  <= 1'b1;
                    out1      <= x_n_c1;
                    out2      <= y_n_c1;
                    out3      <= z_n_c1;
                    out4      <= 32'h0;
                    out5      <= 32'h0;
                    out6      <= 32'h0;
                    fsm_state <= `FSM_Idle;
                end
            end
            `FSM_SVD_STAGE2: begin
                start_c1 <= 1'b0;
                start_c2 <= 1'b0;
                if (done_c1 == 1'b1 && done_c2 == 1'b1) begin
                    // Register theta_r, theta_l
                    theta_r <= sig_theta_r;
                    theta_l <= sig_theta_l;
                    // Rotate vector (a,b) by theta_r
                    x_c1     <= a;
                    y_c1     <= b;
                    z_c1     <= sig_theta_r;
                    mode_c1  <= 1'b0;
                    start_c1 <= 1'b1;
                    // Rotate vector (c,d) by theta_r
                    x_c2     <= c;
                    y_c2     <= d;
                    z_c2     <= sig_theta_r;
                    mode_c2  <= 1'b0;
                    start_c2 <= 1'b1;
                    //
                    fsm_state <= `FSM_SVD_STAGE3;
                end
            end
            `FSM_SVD_STAGE3: begin
                start_c1 <= 1'b0;
                start_c2 <= 1'b0;
                if (done_c1 == 1'b1 && done_c2 == 1'b1) begin
                    // Rotate vector (x1,x2) by theta_l
                    x_c1     <= x_n_c1;
                    y_c1     <= x_n_c2;
                    z_c1     <= theta_l;
                    mode_c1  <= 1'b0;
                    start_c1 <= 1'b1;
                    // Rotate vector (y1,y2) by theta_l
                    x_c2     <= y_n_c1;
                    y_c2     <= y_n_c2;
                    z_c2     <= theta_l;
                    mode_c2  <= 1'b0;
                    start_c2 <= 1'b1;
                    //
                    fsm_state <= `FSM_SVD_STAGE4;
                end
            end
            `FSM_SVD_STAGE4: begin
                start_c1 <= 1'b0;
                start_c2 <= 1'b0;
                if (done_c1 == 1'b1 && done_c2 == 1'b1) begin
                    // Register the eignevalue op's
                    eig1 <= x_n_c1;
                    eig2 <= y_n_c2;
                    // Calculate sin/cos of theta_r
                    x_c1     <= XYBASEONE;
                    y_c1     <= 32'h0;
                    z_c1     <= theta_r;
                    mode_c1  <= 1'b0;
                    start_c1 <= 1'b1;
                    // Calculate sin/cos of theta_l
                    x_c2     <= XYBASEONE;
                    y_c2     <= 32'h0;
                    z_c2     <= theta_l;
                    mode_c2  <= 1'b0;
                    start_c2 <= 1'b1;
                    //
                    fsm_state <= `FSM_SVD_WAIT_DONE;
                end
            end
            `FSM_SVD_WAIT_DONE: begin
                start_c1 <= 1'b0;
                start_c2 <= 1'b0;
                if (done_c1 == 1'b1 && done_c2 == 1'b1) begin
                    write_op  <= 1'b1;
                    out1      <= eig1;
                    out2      <= eig2;
                    out3      <= x_n_c1;
                    out4      <= y_n_c1;
                    out5      <= x_n_c2;
                    out6      <= y_n_c2;
                    fsm_state <= `FSM_Idle;
                end
            end
        endcase
    end
end
cordic cordic1 (.rst_n(rst_n), .clk(clk), .x(x_c1), .y(y_c1), .z(z_c1), .mode(mode_c1),
                .x_n(x_n_c1), .y_n(y_n_c1), .z_n(z_n_c1), .start(start_c1), .done(done_c1),
                .XYFRACBASE(XYFRACBASE), .SCALE_FACTOR(SCALE_FACTOR), .XYBASEONE(XYBASEONE),
                .PHASEFRACBASE(PHASEFRACBASE), .INVTAN0(INVTAN0), .INVTAN1(INVTAN1), .INVTAN2(INVTAN2),
                .INVTAN3(INVTAN3), .INVTAN4(INVTAN4), .INVTAN5(INVTAN5), .INVTAN6(INVTAN6),
                .INVTAN7(INVTAN7), .INVTAN8(INVTAN8), .INVTAN9(INVTAN9), .INVTAN10(INVTAN10),
                .INVTAN11(INVTAN11), .INVTAN12(INVTAN12), .INVTAN13(INVTAN13), .INVTAN14(INVTAN14),
                .INVTAN15(INVTAN15), .INVTAN16(INVTAN16), .INVTAN17(INVTAN17), .INVTAN18(INVTAN18),
                .INVTAN19(INVTAN19), .INVTAN20(INVTAN20), .INVTAN21(INVTAN21), .INVTAN22(INVTAN22),
                .INVTAN23(INVTAN23), .INVTAN24(INVTAN24), .INVTAN25(INVTAN25), .INVTAN26(INVTAN26),
                .INVTAN27(INVTAN27), .INVTAN28(INVTAN28), .INVTAN29(INVTAN29), .INVTAN30(INVTAN30),
                .INVTAN31(INVTAN31));
cordic cordic2 (.rst_n(rst_n), .clk(clk), .x(x_c2), .y(y_c2), .z(z_c2), .mode(mode_c2),
                .x_n(x_n_c2), .y_n(y_n_c2), .z_n(z_n_c2), .start(start_c2), .done(done_c2),
                .XYFRACBASE(XYFRACBASE), .SCALE_FACTOR(SCALE_FACTOR), .XYBASEONE(XYBASEONE),
                .PHASEFRACBASE(PHASEFRACBASE), .INVTAN0(INVTAN0), .INVTAN1(INVTAN1), .INVTAN2(INVTAN2),
                .INVTAN3(INVTAN3), .INVTAN4(INVTAN4), .INVTAN5(INVTAN5), .INVTAN6(INVTAN6),
                .INVTAN7(INVTAN7), .INVTAN8(INVTAN8), .INVTAN9(INVTAN9), .INVTAN10(INVTAN10),
                .INVTAN11(INVTAN11), .INVTAN12(INVTAN12), .INVTAN13(INVTAN13), .INVTAN14(INVTAN14),
                .INVTAN15(INVTAN15), .INVTAN16(INVTAN16), .INVTAN17(INVTAN17), .INVTAN18(INVTAN18),
                .INVTAN19(INVTAN19), .INVTAN20(INVTAN20), .INVTAN21(INVTAN21), .INVTAN22(INVTAN22),
                .INVTAN23(INVTAN23), .INVTAN24(INVTAN24), .INVTAN25(INVTAN25), .INVTAN26(INVTAN26),
                .INVTAN27(INVTAN27), .INVTAN28(INVTAN28), .INVTAN29(INVTAN29), .INVTAN30(INVTAN30),
                .INVTAN31(INVTAN31));
assign temp_theta_r = z_n_c1 + z_n_c2;
assign temp_theta_l = z_n_c1 - z_n_c2;
assign sig_theta_r = (temp_theta_r[31]) ? (temp_theta_r >> 1'b1) | (32'h80000000):
       (temp_theta_r >> 1'b1);
assign sig_theta_l = (temp_theta_l[31]) ? (temp_theta_l >> 1'b1) | (32'h80000000):
       (temp_theta_l >> 1'b1);
endmodule
