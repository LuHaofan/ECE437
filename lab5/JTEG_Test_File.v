`timescale 1ns / 1ps

module JTEG_Test_File(
    input   wire    [4:0] okUH,
    output  wire    [2:0] okHU,
    inout   wire    [31:0] okUHU,
    inout   wire    okAA,
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,  
    output ADT7420_A0,
    output ADT7420_A1,
    output I2C_SCL_0,
    inout I2C_SDA_0 
);
    
    wire  ILA_Clk, ACK_bit, FSM_Clk, TrigerEvent;    
    wire [23:0] ClkDivThreshold = 1_000;   
    wire SCL, SDA; 
    wire [7:0] state;
    wire [15:0] temp;
    reg [15:0] send;
    reg triger = 0;
    reg [7:0] counter = 0;
    
    assign TrigerEvent = button[3];
    
    always @(posedge FSM_Clk) begin 
        if(TrigerEvent == 1'b0) triger = 1;
    end
    
    always @(posedge FSM_Clk) begin 
        if(triger == 1) begin
            if(counter == 192)begin
                counter = 1;
                send = temp;
            end
            else 
                counter = counter + 1'b1;
        end
    end

    //Instantiate the module that we like to test

    I2C_Transmit I2C_Test1 (
        .button(button),
        .led(led),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .ADT7420_A0(ADT7420_A0),
        .ADT7420_A1(ADT7420_A1),
        .I2C_SCL_0(I2C_SCL_0),
        .I2C_SDA_0(I2C_SDA_0),             
        .FSM_Clk_reg(FSM_Clk),        
        .ILA_Clk_reg(ILA_Clk),
        .ACK_bit(ACK_bit),
        .SCL(SCL),
        .SDA(SDA),
        .State_O(state),
        .SDA_data(temp)
        );
    OK_com OK_module (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okAA(okAA),
        .temp(send)
        );
    //Instantiate the ILA module
    ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({led, SDA, SCL, ACK_bit, state}),                             
        .probe1({FSM_Clk, TrigerEvent})
        );                        
endmodule