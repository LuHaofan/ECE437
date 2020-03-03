`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 09:21:04 AM
// Design Name: 
// Module Name: ClockGenerator
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


module ClockGenerator(
    input sys_clkn,
    input sys_clkp,     
    input [23:0] ClkDivThreshold,
    output reg FSM_Clk
    );

    //Generate high speed main clock from two differential clock signals        
    wire clk;
    reg [23:0] ClkDiv = 24'd0;  

    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );    
         
    // Initialize the two registers used in this module  
    initial begin
        FSM_Clk = 1'b0;        
    end
 
    // We will derive a clock signal for the finite state machine from the ILA clock
    // This clock signal will be used to run the finite state machine for the I2C protocol
    always @(posedge clk) begin        
       if (ClkDiv == ClkDivThreshold) begin
         FSM_Clk <= !FSM_Clk;                   
         ClkDiv <= 0;
       end else begin
         ClkDiv <= ClkDiv + 1'b1;             
       end
    end          
endmodule
