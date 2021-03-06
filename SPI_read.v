`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 09:08:40 AM
// Design Name: 
// Module Name: SPI_read
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


module SPI_read(
    input [6:0] Addr,
    input FSM_Clk,
    input SPI_OUT,
    input R_en,
    
    output  SPI_EN,
    output  SPI_IN,
    output reg[7:0] DATA_OUT,
    output  SPI_CLK,   
    output reg done
    );
    
    localparam STATE_INIT       = 8'd0;                                     
    reg [7:0] state = 8'd0;
    reg [7:0] data_reg;
    
    reg SPI_en, SPI_in, SPI_clk;
    
    assign SPI_EN = SPI_en;
    assign SPI_IN = SPI_in;
    assign SPI_CLK = SPI_clk;

    initial  begin
        SPI_en = 1'b0;
        SPI_in = 1'b0;
        SPI_clk = 1'b0;   
    end
    
    always @(posedge FSM_Clk) begin
        done <= 1'b0;
        case (state)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                SPI_en <= 1'b0;
                SPI_in <= 1'bz;
                SPI_clk <= 1'b0;
                if(R_en == 1) begin
                    state <= state + 1'b1;
                end
            end
            
            8'd1 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'b0;       
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd2 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'b0;      
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd3 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[6];       
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd4 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[6];       
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd5 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[5];       
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd6 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[5];       
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd7 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[4];       
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd8 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[4];       
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd9 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[3];       
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd10 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[3];       
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd11 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[2];       
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd12 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[2];       
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd13 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[1];       
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd14 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[1];       
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd15 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[0];       
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd16 : begin
                SPI_en <= 1'b1;
                SPI_in <= Addr[0];       
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd17 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[7] <= SPI_OUT;     
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd18 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[7] <= SPI_OUT;     
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd19 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[6] <= SPI_OUT;     
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd20 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[6] <= SPI_OUT;
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd21 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[5] <= SPI_OUT;
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd22 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[5] <= SPI_OUT;
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd23 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[4] <= SPI_OUT;
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd24 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[4] <= SPI_OUT;
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd25 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[3] <= SPI_OUT;
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd26 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[3] <= SPI_OUT;
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd27 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[2] <= SPI_OUT;
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd28 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[2] <= SPI_OUT;
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd29 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[1] <= SPI_OUT;
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd30 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[1] <= SPI_OUT;
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd31 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[0] <= SPI_OUT;
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
            end
            
            8'd32 : begin
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;
                data_reg[0] <= SPI_OUT;
                SPI_clk <= 1'b1;
                state <= state + 1'b1;
            end
            
            8'd33 : begin
               
                SPI_en <= 1'b1;
                SPI_in <= 1'bz;       
                DATA_OUT <= data_reg;
                SPI_clk <= 1'b0;
                state <= state + 1'b1;
                
            end
            
            8'd34 : begin
                SPI_en <= 1'b0;
                SPI_in <= 1'bz;       
                SPI_clk <= 1'b0;
                state <= state;
                done <= 1'b1;
                if(R_en == 0) begin
                    state <= STATE_INIT;
                end
            end
        endcase
    end
endmodule