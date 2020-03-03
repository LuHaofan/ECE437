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
    input SPI_OUT,
    
    output reg SPI_EN,
    output reg SPI_IN,
    output reg SPI_Clk
    );
    
    wire  FSM_Clk, TrigerEvent;    
    wire [7:0] data_recv;
    reg triger = 0;
    reg ptr = 0;
    reg n_pairs = 2;
    reg [7:0] counter;
    reg [7:0] ADDR [1:0];
    reg [8:0] DATA [1:0];
    wire [6:0] addr_reg;
    wire [7:0] data_send;
    reg [6:0] curr_addr;
    reg [7:0] curr_data;
    wire flag;
    
    assign TrigerEvent = button[3];
    assign addr_reg = curr_addr;
    assign data_send = curr_data;
    
    always @(posedge FSM_Clk) begin 
        if(TrigerEvent == 1'b0) triger = 1;
    end
    
    always @(posedge FSM_Clk) begin 
        if(triger == 1) begin
            counter = counter + 1'b1;
        end
    end
    
    always @(posedge flag) begin
        if (ptr < n_pairs) begin
            ptr = ptr + 1;
            curr_addr <= ADDR[ptr];
            curr_data <= DATA[ptr];
        end
    end
    
    SPI_write write1 (
        .Addr(addr_reg),
        .Data(data_send),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        
        .SPI_EN(SPI_EN),
        .SPI_IN(SPI_IN),
        .SPI_Clk(SPI_Clk),
        .done(flag)
    );
    
    SPI_read read1 (
        .Addr(addr_reg),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .SPI_OUT(SPI_OUT),
        
        .SPI_EN(SPI_EN),
        .SPI_IN(SPI_IN),
        .SPI_Clk(SPI_Clk),
        .done(flag)        
    );
    
    OK_com OK_module (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okAA(okAA),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .temp(data_recv)
        );
        
endmodule
