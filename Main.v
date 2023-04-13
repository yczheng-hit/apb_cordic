module main(PRESETn, PCLK, PSEL, PADDR, PENABLE, PWRITE, PWDATA, PRDATA, INT);
input PRESETn, PCLK; // Reset and clock
input PSEL, PENABLE, PWRITE;
input [5:0] PADDR;
input [31:0] PWDATA;
output INT;
output [31:0] PRDATA;
wire sys_cordic_done, clear_control_bit;
wire [31:0] out1, out2, out3, out4, out5, out6;
wire [5:0] CONTROL;
wire [31:0] a, b, c, d;
wire [4:0] XYFRACBASE, PHASEFRACBASE;
intf apb_intf(.PRESETn(PRESETn), .PCLK(PCLK), .PSEL(PSEL), .PADDR(PADDR),
              .PENABLE(PENABLE), .PWRITE(PWRITE), .PWDATA(PWDATA), .PRDATA(PRDATA), .INT(INT),
              .sys_cordic_done(sys_cordic_done), .clear_control_bit(clear_control_bit),
              .cordic_out1(out1), .cordic_out2(out2), .cordic_out3(out3),
              .cordic_out4(out4), .cordic_out5(out5), .cordic_out6(out6),
              .CONTROL(CONTROL),
              .PROG_A(a), .PROG_B(b), .PROG_C(c), .PROG_D(d),
              .XYFRACBASE(XYFRACBASE), .PHASEFRACBASE(PHASEFRACBASE));
sysfsm cordic_sysfsm (.rst_n(PRESETn), .clk(PCLK), .func(CONTROL[3:1]), .a(a), .b(b),
                      .c(c), .d(d), .new_cmd(CONTROL[0]),
                      .clear_control_bit(clear_control_bit), .sys_cordic_done(sys_cordic_done),
                      .out1(out1), .out2(out2), .out3(out3), .out4(out4), .out5(out5), .out6(out6),
                      .XYFRACBASE(XYFRACBASE), .PHASEFRACBASE(PHASEFRACBASE));
endmodule
