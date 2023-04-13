module intf(PRESETn, PCLK, PSEL, PADDR, PENABLE, PWRITE, PWDATA, PRDATA, INT,sys_cordic_done, clear_control_bit,cordic_out1, cordic_out2, cordic_out3, cordic_out4, cordic_out5, cordic_out6,CONTROL,PROG_A, PROG_B, PROG_C, PROG_D,XYFRACBASE, PHASEFRACBASE);
input PRESETn, PCLK; // Reset and clock
input PSEL, PENABLE, PWRITE;
input [5:0] PADDR;
input [31:0] PWDATA;
input sys_cordic_done, clear_control_bit;
input [31:0] cordic_out1, cordic_out2, cordic_out3, cordic_out4, cordic_out5,
      cordic_out6;
output INT;
output [31:0] PRDATA;
output [5:0] CONTROL;
output [31:0] PROG_A, PROG_B, PROG_C, PROG_D;
output [4:0] XYFRACBASE, PHASEFRACBASE;
// Registers
reg [5:0] CONTROL; // 0x0
reg [31:0] PROG_A; // 0x4
reg [31:0] PROG_B; // 0x8
reg [31:0] PROG_C; // 0xC
reg [31:0] PROG_D; // 0x10
reg [31:0] OUT1; // 0x14
reg [31:0] OUT2; // 0x18
reg [31:0] OUT3; // 0x1C
reg [31:0] OUT4; // 0x20
reg [31:0] OUT5; // 0x24
reg [31:0] OUT6; // 0x28
// Format dependent factors
reg [4:0] XYFRACBASE; // 0x2C
reg [4:0] PHASEFRACBASE; // 0x30
always @(posedge PCLK) begin
    if (~PRESETn) begin
        // Control Register is done in a different process
        PROG_A <= 32'h0; // 0x04
        PROG_B <= 32'h0; // 0x08
        PROG_C <= 32'h0; // 0x0C
        PROG_D <= 32'h0; // 0x10
        // Skipping output registers
        // Output Registers are read only registers
        XYFRACBASE <= 5'h10; // 0x2C // Reset Value = 16 (i.e. 16Frac Bits)
        PHASEFRACBASE <= 5'h1C; // 0x30 // Reset Value = 28 (i.e. 28Frac Bits)
    end
    else begin
        if (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b1) begin
            case(PADDR)
                6'h04:
                    PROG_A <= PWDATA; // 0x04
                6'h08:
                    PROG_B <= PWDATA; // 0x08
                6'h0C:
                    PROG_C <= PWDATA; // 0x0C
                6'h10:
                    PROG_D <= PWDATA; // 0x10
                // Skipping output registers as they are read only
                6'h2C:
                    XYFRACBASE <= PWDATA; // 0x2C
                6'h30:
                    PHASEFRACBASE <= PWDATA; // 0x30
            endcase
        end
    end
end
always @(posedge PCLK) begin
    if (~PRESETn)
        CONTROL <= 6'h00;
    else begin
        if (clear_control_bit == 1'b1)
            CONTROL[0] <= 1'b0;
        else if (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b1 && PADDR ==
                 6'h00)
            CONTROL[0] <= PWDATA[0];
        if (sys_cordic_done == 1'b1)
            CONTROL[4] <= 1'b1;
        else if (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b1 && PADDR ==
                 6'h00)
            CONTROL[4] <= PWDATA[4];
        if (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b1 && PADDR == 6'h00) begin
            CONTROL[3:1] <= PWDATA[3:1];
            CONTROL[5] <= PWDATA[5];
        end
    end
end
always @(posedge PCLK) begin
    if (~PRESETn) begin
        OUT1 <= 32'h0;
        OUT2 <= 32'h0;
        OUT3 <= 32'h0;
        OUT4 <= 32'h0;
        OUT5 <= 32'h0;
        OUT6 <= 32'h0;
    end
    else if (sys_cordic_done == 1'b1) begin
        OUT1 <= cordic_out1;
        OUT2 <= cordic_out2;
        OUT3 <= cordic_out3;
        OUT4 <= cordic_out4;
        OUT5 <= cordic_out5;
        OUT6 <= cordic_out6;
    end
end
assign PRDATA = (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h00)?
       {27'h0, CONTROL} :
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h04)?
       PROG_A :
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h08)?
       PROG_B : // 0x8
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h0C)?
       PROG_C : // 0xC
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h10)?
       PROG_D : // 0x10
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h14)?
       OUT1 : // 0x14
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h18)?
       OUT2 : // 0x18
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h1C)?
       OUT3 : // 0x1C
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h20)?
       OUT4 : // 0x20
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h24)?
       OUT5 : // 0x24
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h28)?
       OUT6 : // 0x28
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h2C)?
       {27'h0, XYFRACBASE}: // 0x2C
       (PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0 && PADDR == 6'h30)?
       {27'h0, PHASEFRACBASE} : 32'h0; // 0x30
assign INT = (CONTROL[4] & CONTROL[5]);
endmodule
