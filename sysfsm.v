module sysfsm (rst_n,
               clk,
               func,
               a,
               b,
               c,
               d,
               new_cmd,
               clear_control_bit,
               sys_cordic_done,
               out1,
               out2,
               out3,
               out4,
               out5,
               out6,
               XYFRACBASE,
               PHASEFRACBASE);
input rst_n, clk; // Reset and Clock
input [2:0] func;
input [31:0] a, b, c, d;
input new_cmd;
output clear_control_bit, sys_cordic_done;
output [31:0] out1, out2, out3, out4, out5, out6;
input [4:0] XYFRACBASE, PHASEFRACBASE;
`define SYSFSM_IDLE 1'h0
    `define SYSFSM_BUSY 1'h1

reg sysfsm_state;
reg clear_control_bit, sys_cordic_done, start_cordic, update_tan_table;
reg [2:0] cordic_func;
reg [31:0] cordic_a, cordic_b, cordic_c, cordic_d;
reg [31:0] SCALE_FACTOR, XYBASEONE;
reg [31:0] INVTAN0, INVTAN1, INVTAN2, INVTAN3, INVTAN4, INVTAN5, INVTAN6, INVTAN7,
    INVTAN8, INVTAN9, INVTAN10;
reg [31:0] INVTAN11, INVTAN12, INVTAN13, INVTAN14, INVTAN15, INVTAN16, INVTAN17,
    INVTAN18, INVTAN19, INVTAN20;
reg [31:0] INVTAN21, INVTAN22, INVTAN23, INVTAN24, INVTAN25, INVTAN26, INVTAN27,
    INVTAN28, INVTAN29, INVTAN30, INVTAN31;
wire cordic_done;
always @(posedge clk) begin
    if (~rst_n) begin
        sysfsm_state      <= `SYSFSM_IDLE;
        cordic_func       <= 3'h0;
        cordic_a          <= 32'h0;
        cordic_b          <= 32'h0;
        cordic_c          <= 32'h0;
        cordic_d          <= 32'h0;
        sys_cordic_done   <= 1'b0;
        clear_control_bit <= 1'b0;
        start_cordic      <= 1'b0;
        update_tan_table  <= 1'b0;
    end
    else begin
        case (sysfsm_state)
            `SYSFSM_IDLE: begin
                sys_cordic_done <= 1'b0;
                if (new_cmd == 1'b1) begin
                    update_tan_table  <= 1'b1; // To update the Tan Table and other format dependent constants
                    clear_control_bit <= 1'b1; // To indicate that the commnand has been registered
                    cordic_func       <= func;
                    cordic_a          <= a;
                    cordic_b          <= b;
                    cordic_c          <= c;
                    cordic_d          <= d;
                    start_cordic      <= 1'b1;
                    sysfsm_state      <= `SYSFSM_BUSY;
                end
            end
            `SYSFSM_BUSY: begin
                clear_control_bit <= 1'b0;
                start_cordic      <= 1'b0;
                update_tan_table  <= 1'b0;
                if (cordic_done == 1'b1) begin
                    sys_cordic_done <= 1'b1;
                    if (new_cmd == 1'b1) begin
                        update_tan_table  <= 1'b1;
                        clear_control_bit <= 1'b1;
                        cordic_func       <= func;
                        cordic_a          <= a;
                        cordic_b          <= b;
                        cordic_c          <= c;
                        cordic_d          <= d;
                        start_cordic      <= 1'b1;
                        sysfsm_state      <= `SYSFSM_BUSY;
                    end
                    else begin
                        sysfsm_state <= `SYSFSM_IDLE;
                    end
                end
                else begin
                    sys_cordic_done <= 1'b0;
                end
            end
        endcase
    end
end
always @(posedge clk) begin
    if (~rst_n) begin
        SCALE_FACTOR <= 32'h0; // 0.6073 * 2^B1
        XYBASEONE    <= 32'h0; // 1 * 2^B1
        // Registers holding inverse tan table INVTANi = tan^{-1} (2^{-i})
        // Reset Values based on 2Q29 format. i.e. dec2hex(round(2^B2 * (inv_tan(2^(-i))))
        INVTAN0  <= 32'h0;
        INVTAN1  <= 32'h0;
        INVTAN2  <= 32'h0;
        INVTAN3  <= 32'h0;
        INVTAN4  <= 32'h0;
        INVTAN5  <= 32'h0;
        INVTAN6  <= 32'h0;
        INVTAN7  <= 32'h0;
        INVTAN8  <= 32'h0;
        INVTAN9  <= 32'h0;
        INVTAN10 <= 32'h0;
        INVTAN11 <= 32'h0;
        INVTAN12 <= 32'h0;
        INVTAN13 <= 32'h0;
        INVTAN14 <= 32'h0;
        INVTAN15 <= 32'h0;
        INVTAN16 <= 32'h0;
        INVTAN17 <= 32'h0;
        INVTAN18 <= 32'h0;
        INVTAN19 <= 32'h0;
        INVTAN20 <= 32'h0;
        INVTAN21 <= 32'h0;
        INVTAN22 <= 32'h0;
        INVTAN23 <= 32'h0;
        INVTAN24 <= 32'h0;
        INVTAN25 <= 32'h0;
        INVTAN26 <= 32'h0;
        INVTAN27 <= 32'h0;
        INVTAN28 <= 32'h0;
        INVTAN29 <= 32'h0;
        INVTAN30 <= 32'h0;
        INVTAN31 <= 32'h0;
    end
    else begin
        if (update_tan_table == 1'b1) begin
            SCALE_FACTOR <= (32'h26DD3B6A >> (5'h1E - XYFRACBASE));
            XYBASEONE    <= (32'h00000001 << XYFRACBASE);
            // Registers holding inverse tan
            // Reset Values based on 2Q29 fo
            INVTAN0 <= (32'h3243F6A9 >> (5'h1E -
                                         PHASEFRACBASE));
            INVTAN1 <= (32'h1DAC6705 >> (5'h1E -
                                         PHASEFRACBASE));
            INVTAN2 <= (32'h0FADBAFD >> (5'h1E -
                                         PHASEFRACBASE));
            INVTAN3 <= (32'h07F56EA7 >> (5'h1E -
                                         PHASEFRACBASE));
            INVTAN4 <= (32'h03FEAB77 >> (5'h1E -
                                         PHASEFRACBASE));
            INVTAN5 <= (32'h01FFD55C >> (5'h1E -
                                         PHASEFRACBASE));
            INVTAN6 <= (32'h00FFFAAB >> (5'h1E -
                                         PHASEFRACBASE));
            INVTAN7 <= (32'h007FFF55 >> (5'h1E -
                                         PHASEFRACBASE));
            INVTAN8 <= (32'h003FFFEB >> (5'h1E -
                                         PHASEFRACBASE));
            INVTAN9 <= (32'h001FFFFD >> (5'h1E -
                                         PHASEFRACBASE));
            INVTAN10 <= (32'h00100000 >> (5'h1E - PHASEFRACBASE));
            INVTAN11 <= (32'h00080000 >> (5'h1E - PHASEFRACBASE));
            INVTAN12 <= (32'h00040000 >> (5'h1E - PHASEFRACBASE));
            INVTAN13 <= (32'h00020000 >> (5'h1E - PHASEFRACBASE));
            INVTAN14 <= (32'h00010000 >> (5'h1E - PHASEFRACBASE));
            INVTAN15 <= (32'h00008000 >> (5'h1E - PHASEFRACBASE));
            INVTAN16 <= (32'h00004000 >> (5'h1E - PHASEFRACBASE));
            INVTAN17 <= (32'h00002000 >> (5'h1E - PHASEFRACBASE));
            INVTAN18 <= (32'h00001000 >> (5'h1E - PHASEFRACBASE));
            INVTAN19 <= (32'h00000800 >> (5'h1E - PHASEFRACBASE));
            INVTAN20 <= (32'h00000400 >> (5'h1E - PHASEFRACBASE));
            INVTAN21 <= (32'h00000200 >> (5'h1E - PHASEFRACBASE));
            INVTAN22 <= (32'h00000100 >> (5'h1E - PHASEFRACBASE));
            INVTAN23 <= (32'h00000080 >> (5'h1E - PHASEFRACBASE));
            INVTAN24 <= (32'h00000040 >> (5'h1E - PHASEFRACBASE));
            INVTAN25 <= (32'h00000020 >> (5'h1E - PHASEFRACBASE));
            INVTAN26 <= (32'h00000010 >> (5'h1E - PHASEFRACBASE));
            INVTAN27 <= (32'h00000008 >> (5'h1E - PHASEFRACBASE));
            INVTAN28 <= (32'h00000004 >> (5'h1E - PHASEFRACBASE));
            INVTAN29 <= (32'h00000002 >> (5'h1E - PHASEFRACBASE));
            INVTAN30 <= (32'h00000001 >> (5'h1E - PHASEFRACBASE));
            INVTAN31 <= (32'h00000001 >> (5'h1E - PHASEFRACBASE));
        end
    end
end
control cordic_control(.rst_n(rst_n), .clk(clk), .cordic_start(start_cordic),
                       .cordic_func(cordic_func), .a(cordic_a), .b(cordic_b), .c(cordic_c), .d(cordic_d),
                       .out1(out1), .out2(out2), .out3(out3), .out4(out4), .out5(out5), .out6(out6),
                       .write_op(cordic_done), .XYFRACBASE(XYFRACBASE), .PHASEFRACBASE(PHASEFRACBASE),
                       .SCALE_FACTOR(SCALE_FACTOR), .XYBASEONE(XYBASEONE), .INVTAN0(INVTAN0), .INVTAN1(INVTAN1),
                       .INVTAN2(INVTAN2), .INVTAN3(INVTAN3), .INVTAN4(INVTAN4), .INVTAN5(INVTAN5),
                       .INVTAN6(INVTAN6), .INVTAN7(INVTAN7), .INVTAN8(INVTAN8), .INVTAN9(INVTAN9),
                       .INVTAN10(INVTAN10), .INVTAN11(INVTAN11), .INVTAN12(INVTAN12), .INVTAN13(INVTAN13),
                       .INVTAN14(INVTAN14), .INVTAN15(INVTAN15), .INVTAN16(INVTAN16), .INVTAN17(INVTAN17),
                       .INVTAN18(INVTAN18), .INVTAN19(INVTAN19), .INVTAN20(INVTAN20), .INVTAN21(INVTAN21),
                       .INVTAN22(INVTAN22), .INVTAN23(INVTAN23), .INVTAN24(INVTAN24), .INVTAN25(INVTAN25),
                       .INVTAN26(INVTAN26), .INVTAN27(INVTAN27), .INVTAN28(INVTAN28), .INVTAN29(INVTAN29),
                       .INVTAN30(INVTAN30), .INVTAN31(INVTAN31));
endmodule
