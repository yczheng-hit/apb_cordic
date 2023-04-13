`timescale 1ns/10ps
module test;
reg PCLK;
reg PRESETn;
reg PSEL;
reg PENABLE;
reg [5:0] PADDR;
reg PWRITE;
reg [31:0] PWDATA;
wire [31:0] PRDATA;
wire INT;

// cordic address map
`define CONTROL 6'h0
`define PROG_A 6'h4
`define PROG_B 6'h8
`define PROG_C 6'hc
`define PROG_D 6'h10
`define OUT1 6'h14
`define OUT2 6'h18
`define OUT3 6'h1c
`define OUT4 6'h20
`define OUT5 6'h24
`define OUT6 6'h28
`define XYFRACBASE 6'h2C
`define PHASEFRACBASE 6'h30
`define CMD_SVD 6'h07
`define CMD_CLEAR 6'h00
`define CMD_SINCOS 6'h01
`define CMD_INVTAN 6'h03
`define RAD_60 32'h10c15238
`define RAD_120 32'h2182a470
`define RAD_N_60 32'hefbeadc8
`define RAD_N_120 32'hde7d5b90
`define RAD_0 32'h00000000
`define RAD_90 32'h1921FB54
`define RAD_45_BASE_20 32'h000C90FE

initial begin
    PCLK=0;
    PRESETn=0;
    APB_write(`CONTROL,`CMD_CLEAR);
    @(posedge PCLK);
    @(posedge PCLK);
    PRESETn=1;
    /*
    //Test 1 SVD Mode format XYBASE 1.15.16 - a=1 b=2 c=5 d=7 PHASE 3.28
    APB_write(`PROG_A,32'h00010000);
    APB_write(`PROG_B,32'h00020000);
    APB_write(`PROG_C,32'h00050000);
    APB_write(`PROG_D,32'h00070000);
    APB_write(`CONTROL,`CMD_SVD);
    repeat(128) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    APB_read(`OUT3);
    APB_read(`OUT4);
    APB_read(`OUT5);
    APB_read(`OUT6);
    //Test 2 SVD Mode format XYBASE 1.11.20 - a=1 b=2 c=5 d=7 PHASE 3.28
    APB_write(`CONTROL,`CMD_CLEAR);
    APB_write(`XYFRACBASE,5'h14);
    APB_write(`PROG_A,32'h00100000);
    APB_write(`PROG_B,32'h00200000);
    APB_write(`PROG_C,32'h00500000);
    APB_write(`PROG_D,32'h00700000);
    APB_write(`CONTROL,`CMD_SVD);
    repeat(128) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    APB_read(`OUT3);
    APB_read(`OUT4);
    APB_read(`OUT5);
    APB_read(`OUT6);
    //Test 3 SVD Mode format XYBASE 1.7.24 - a=1 b=2 c=5 d=7 PHASE 3.28
    APB_write(`CONTROL,`CMD_CLEAR);
    APB_write(`XYFRACBASE,5'h18);
    APB_write(`PROG_A,32'h01000000);
    APB_write(`PROG_B,32'h02000000);
    APB_write(`PROG_C,32'h05000000);
    APB_write(`PROG_D,32'h07000000);
    APB_write(`CONTROL,`CMD_SVD);
    repeat(128) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    APB_read(`OUT3);
    APB_read(`OUT4);
    APB_read(`OUT5);
    APB_read(`OUT6);
    //Test 4 SVD Mode format XYBASE 1.19.12 - a=1 b=2 c=5 d=7 PHASE 3.28
    APB_write(`CONTROL,`CMD_CLEAR);
    APB_write(`XYFRACBASE,5'h0c);
    APB_write(`PROG_A,32'h00001000);
    APB_write(`PROG_B,32'h00002000);
    APB_write(`PROG_C,32'h00005000);
    APB_write(`PROG_D,32'h00007000);
    APB_write(`CONTROL,`CMD_SVD);
    repeat(128) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    APB_read(`OUT3);
    APB_read(`OUT4);
    APB_read(`OUT5);
    APB_read(`OUT6);
    //Test 5 SVD Mode format XYBASE 1.23.8 - a=1 b=2 c=5 d=7 PHASE 3.28
    APB_write(`CONTROL,`CMD_CLEAR);
    APB_write(`XYFRACBASE,5'h08);
    APB_write(`PROG_A,32'h00000100);
    APB_write(`PROG_B,32'h00000200);
    APB_write(`PROG_C,32'h00000500);
    APB_write(`PROG_D,32'h00000700);
    APB_write(`CONTROL,`CMD_SVD);
    repeat(128) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    APB_read(`OUT3);
    APB_read(`OUT4);
    APB_read(`OUT5);
    APB_read(`OUT6);
    //Test 6 SVD Mode format XYBASE 1.27.4 - a=1 b=5 c=2 d=7 (T of earlier matrix) PHASE 3.28
    APB_write(`XYFRACBASE,5'h04);
    APB_write(`PROG_A,32'h00000010);
    APB_write(`PROG_B,32'h00000020);
    APB_write(`PROG_C,32'h00000050);
    APB_write(`PROG_D,32'h00000070);
    APB_write(`CONTROL,`CMD_SVD);
    repeat(128) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    APB_read(`OUT3);
    APB_read(`OUT4);
    APB_read(`OUT5);
    APB_read(`OUT6);
    //Test 7 SVD Mode format XYBASE 1.30.0 - a=1 b=2 c=5 d=7
    APB_write(`XYFRACBASE,5'h00);
    APB_write(`PROG_A,32'h00000001);
    APB_write(`PROG_B,32'h00000002);
    APB_write(`PROG_C,32'h00000005);
    APB_write(`PROG_D,32'h00000007);
    APB_write(`CONTROL,`CMD_SVD);
    repeat(128) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    APB_read(`OUT3);
    APB_read(`OUT4);
    APB_read(`OUT5);
    APB_read(`OUT6);
    //Test 8 SVD Mode format XYBASE 1.15.16 - a=1 b=2 c=5 d=7 (T of earlier matrix) PHASE
    2.29
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PROG_A,32'h00010000);
    APB_write(`PROG_B,32'h00050000);
    APB_write(`PROG_C,32'h00020000);
    APB_write(`PROG_D,32'h00070000);
    APB_write(`CONTROL,`CMD_SVD);
    repeat(128) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    APB_read(`OUT3);
    APB_read(`OUT4);
    APB_read(`OUT5);
    APB_read(`OUT6);
    //Test 9 SVD Mode format XYBASE 1.15.16 - a=-1 b=-2 c=-5 d=-7 PHASE 2.29
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PROG_A,32'hffff0000);
    APB_write(`PROG_B,32'hfffe0000);
    APB_write(`PROG_C,32'hfffb0000);
    APB_write(`PROG_D,32'hfff90000);
    APB_write(`CONTROL,`CMD_SVD);
    repeat(128) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    APB_read(`OUT3);
    APB_read(`OUT4);
    APB_read(`OUT5);
    APB_read(`OUT6);
    // Test 10 SINCOS Mode format 1.15.16 - cos/sin(60) PHASE Format 3.28
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h1c);
    APB_write(`PROG_A,`RAD_60);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_SINCOS);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    //Test 11 SINCOS Mode format 1.15.16 - cos/sin(120) PHASE Format 3.28
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h1c);
    APB_write(`PROG_A,`RAD_120);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_SINCOS);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    //Test 12 SINCOS Mode format 1.15.16 - cos/sin(-60) PHASE Format 3.28
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h1c);
    APB_write(`PROG_A,`RAD_N_60);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_SINCOS);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    //Test 13 SINCOS Mode format 1.15.16 - cos/sin(-120) PHASE Format 3.28
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h1c);
    APB_write(`PROG_A,`RAD_N_120);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_SINCOS);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    //Test 14 SINCOS Mode format 1.15.16 - cos/sin(0) PHASE Format 3.28
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h1c);
    APB_write(`PROG_A,`RAD_0);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_SINCOS);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    //Test 15 SINCOS Mode format 1.15.16 - cos/sin(0) PHASE Format 3.28
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h1c);
    APB_write(`PROG_A,`RAD_90);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_SINCOS);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    //Test 16 SINCOS Mode format 1.15.16 - cos/sin(45) PHASE Format 11.20
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h14);
    APB_write(`PROG_A,`RAD_45_BASE_20);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_SINCOS);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    APB_read(`OUT2);
    */
    //Test 17 INVTAN Mode format 1.15.16 - atan(1)
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h1c);
    APB_write(`PROG_A,32'h00010000);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_INVTAN);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    //Test 18 INVTAN Mode format 1.15.16 - atan(32767)
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h1c);
    APB_write(`PROG_A,32'h7fff0000);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_INVTAN);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    //Test 19 INVTAN Mode format 1.15.16 - atan(-6550)
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h1c);
    APB_write(`PROG_A,32'he66a0000);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_INVTAN);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    //Test 20 INVTAN Mode format 1.15.16 - atan(0)
    APB_write(`XYFRACBASE,5'h10);
    APB_write(`PHASEFRACBASE,5'h1c);
    APB_write(`PROG_A,32'h00000000);
    APB_write(`PROG_B,32'h00000000);
    APB_write(`PROG_C,32'h00000000);
    APB_write(`PROG_D,32'h00000000);
    APB_write(`CONTROL,`CMD_INVTAN);
    repeat(32) @(posedge PCLK);
    APB_read(`OUT1);
    #1000 $finish;
end
// test for
always
    #10 PCLK = ~PCLK;
// main inputs
main Imain( .PCLK(PCLK),
            .PRESETn(PRESETn),
            .PSEL(PSEL),
            .PADDR(PADDR),
            .PENABLE(PENABLE),
            .PWRITE(PWRITE),
            .PWDATA(PWDATA),
            .PRDATA(PRDATA),
            .INT(INT));
//====================================================
// test tasks
//====================================================
task APB_write;
    input [5:0] paddr;
    input [31:0] pdata;
    begin
        PSEL <= 1;
        PADDR <= paddr;
        PWDATA <= pdata;
        PENABLE <= 0;
        PWRITE <= 1;
        @(posedge PCLK);
        PENABLE <= 1;
        @(posedge PCLK);
        PENABLE <= 0;
        PSEL <= 0;
    end
endtask
task APB_read;
    input [5:0] paddr;
    begin
        PSEL <=1;
        PADDR <= paddr;
        PENABLE <= 0;
        PWRITE <= 0;
        @(posedge PCLK);
        PENABLE <= 1;
        @(posedge PCLK);
        PENABLE <= 0;
        PSEL <= 0;
    end
endtask
endmodule
