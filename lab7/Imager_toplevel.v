`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 09:09:30 AM
// Design Name: 
// Module Name: Imager_toplevel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Imager_toplevel(
    input   wire    [4:0] okUH,
    output  wire    [2:0] okHU,
    inout   wire    [31:0] okUHU,
    inout   wire    okAA,
    
    input [3:0] button,
    output [7:0] led,
    
    input sys_clkn,
    input sys_clkp,
    input CVM300_SPI_OUT,
    
    output  CVM300_SPI_EN,
    output  CVM300_SPI_IN,
    output  CVM300_SPI_CLK
    );
    
    wire [23:0] ClkDivThreshold = 10;   
    wire  FSM_Clk, TrigerEvent;    
    wire [7:0] data_recv;
    reg triger = 0;
    reg SPI_en, SPI_in, SPI_clk;
    wire SPI_EN_W, SPI_IN_W, SPI_CLK_W, SPI_EN_R, SPI_IN_R, SPI_CLK_R;
    reg [7:0] counter;
    wire [6:0] ADDR;
    wire [7:0] DATA_IN;
    wire [7:0] DATA_OUT;
    wire       R_W;
    reg flag;
    wire flag_W, flag_R;
    
    assign TrigerEvent = button[3];
    assign CVM300_SPI_EN = SPI_en;
    assign CVM300_SPI_IN = SPI_in;
    assign CVM300_SPI_CLK = SPI_clk;
    
    always @(posedge FSM_Clk) begin 
        if(TrigerEvent == 1'b0) triger = 1;
        else triger = 0;
    end
    
    always@(*) begin 
        if(R_W == 1) begin
            SPI_en = SPI_EN_W;
            SPI_in = SPI_IN_W;
            SPI_clk = SPI_CLK_W;
            flag = flag_W;
        end
        else begin
            SPI_en = SPI_EN_R;
            SPI_in = SPI_IN_R;
            SPI_clk = SPI_CLK_R;
            flag = flag_R;
        end
    
    end
    
    always @(posedge FSM_Clk) begin 
        if(triger == 1) begin
            counter = counter + 1'b1;
        end
    end
    
    SPI_write write1 (
        .Addr(ADDR),
        .Data(DATA_IN),
        .R_W(R_W),
        .FSM_Clk(FSM_Clk),
        .SPI_EN(SPI_EN_W),
        .SPI_IN(SPI_IN_W),
        .SPI_CLK(SPI_CLK_W),
        .done(flag_W)
    );
    
    SPI_read read1 (
        .Addr(ADDR),
        .FSM_Clk(FSM_Clk),
        .SPI_OUT(CVM300_SPI_OUT),
        .R_W(R_W),
        .SPI_EN(SPI_EN_R),
        .SPI_IN(SPI_IN_R),
        .DATA_OUT(DATA_OUT),
        .SPI_CLK(SPI_CLK_R),
        .done(flag_R)        
    );
    
    OK_com OK_module (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okAA(okAA),
        .DATA_OUT(DATA_OUT),
        .flag_W(flag_W),
        .flag_R(flag_R),
        .ADDR(ADDR),
        .DATA_IN(DATA_IN),
        .R_W(R_W)   //write: 1, read: 0
        );
        
    
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk)                                    
                                       );
endmodule
