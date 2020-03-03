`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 09:08:40 AM
// Design Name: 
// Module Name: SPI_write
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      FSM used to write data to the imager
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SPI_write(
    input [6:0] Addr,
    input [7:0] Data,
    input sys_clkn,
    input sys_clkp,
    
    output reg SPI_EN,
    output reg SPI_IN,
    output reg SPI_Clk,
    output reg done
    );
    
    wire [23:0] ClkDivThreshold = 10;   
    wire FSM_Clk;
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk)                                    
                                       );
                             
    localparam STATE_INIT       = 8'd0;                                     
    reg [7:0] state = 8'd0;
    reg [6:0] addr_reg;
    reg [7:0] data_reg;
    
    initial  begin
        SPI_EN = 1'b0;
        SPI_IN = 1'b0;
        SPI_Clk = 1'b0;   
    end
    
    always @(posedge FSM_Clk) begin
        done <= 1'd0;
        case (state)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                SPI_EN <= 1'b0;
                SPI_IN <= 1'bz;
                SPI_Clk <= 1'b0;
                addr_reg <= Addr;
                data_reg <= Data;
                state <= state + 1'b1;
            end
            
            8'd1 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= 1'b1;     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd2 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= 1'b1;     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd3 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[6];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd4 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[6];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd5 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[5];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd6 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[5];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd7 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[4];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd8 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[4];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd9 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[3];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd10 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[3];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd11 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[2];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd12 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[2];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd13 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[1];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd14 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[1];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd15 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[0];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd16 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= addr_reg[0];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd17 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[7];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd18 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[7];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd19 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[6];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd20 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[6];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd21 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[5];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd22 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[5];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd23 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[4];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd24 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[4];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd25 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[3];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd26 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[3];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd27 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[2];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd28 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[2];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd29 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[1];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd30 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[1];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd31 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[0];     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd32 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= data_reg[0];     // Set the control bit
                SPI_Clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd33 : begin
                SPI_EN <= 1'b1;
                SPI_IN <= 1'bz;     // Set the control bit
                SPI_Clk <= 1'b0;
                state <= state + 1'b1;
            end
                     
            8'd34 : begin
                SPI_EN <= 1'b0;
                SPI_IN <= 1'bz;     // Set the control bit
                SPI_Clk <= 1'b0;
                done <= 1'd1;
                state <= STATE_INIT;
            end
        endcase
    end
endmodule
