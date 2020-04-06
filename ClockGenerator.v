`timescale 1ns / 1ps

module ClockGenerator(
    input sys_clkn,
    input sys_clkp,     
    input [23:0] ClkDivThreshold,
    output reg FSM_Clk,    
    output reg ILA_Clk,
    output wire clk,
    output reg CVM_Clk,
    output reg SPI_Clk
    );

    //Generate high speed main clock from two differential clock signals        
    reg [23:0] ClkDiv = 24'd0;     
    reg [23:0] ClkDivILA = 24'd0;   
    reg [23:0] ClkDivCVM = 24'd0;    
    reg [23:0] ClkDivSPI = 24'd0;
    
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );    
         
    // Initialize the two registers used in this module  
    initial begin
        FSM_Clk = 1'b0;        
        ILA_Clk = 1'b0;
        CVM_Clk = 1'b0;
        SPI_Clk = 1'b0;
    end
 
    always @(posedge clk) begin
        if (ClkDivCVM == 7) begin       // The CVM clock is 8 times slower than the system clk
            CVM_Clk <= ~CVM_Clk;                            // i.e. 25MHz
            ClkDivCVM <= 0;
        end
        else begin
            ClkDivCVM <= ClkDivCVM + 1'b1;
        end
    end
    
    always @(posedge clk) begin
        if (ClkDivSPI == 4) begin       // The SPI clock is 5 times slower than the system clk
            SPI_Clk <= ~SPI_Clk;                            // i.e. 40MHz
            ClkDivSPI <= 0;
        end
        else begin
            ClkDivSPI <= ClkDivSPI + 1'b1;
        end
    end
    // We derive a clock signal that will be used for sampling signals for the ILA
    // This clock will be 10 times slower than the system clock.    
    always @(posedge clk) begin        
        if (ClkDivILA == 10) begin
            ILA_Clk <= !ILA_Clk;                       
            ClkDivILA <= 0;
        end else begin                        
            ClkDivILA <= ClkDivILA + 1'b1;
        end
    end      

    // We will derive a clock signal for the finite state machine from the ILA clock
    // This clock signal will be used to run the finite state machine for the I2C protocol
    always @(posedge ILA_Clk) begin        
       if (ClkDiv == ClkDivThreshold) begin
         FSM_Clk <= !FSM_Clk;                   
         ClkDiv <= 0;
       end else begin
         ClkDiv <= ClkDiv + 1'b1;             
       end
    end          
endmodule
