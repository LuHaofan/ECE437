`timescale 1ns / 1ps

module lab5_testbench();
    wire    [4:0] okUH;
    wire    [2:0] okHU;
    wire    [31:0] okUHU;
    wire    okAA;
    reg sys_clkn=1;
    wire sys_clkp;
    wire [7:0] led;
    reg [3:0] button;

    
    wire okClk;            //These are FrontPanel wires needed to IO communication    
    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication    
    wire ADT7420_A0 = 0;
    wire ADT7420_A1 = 0;
    wire I2C_SCL_0;
    wire I2C_SDA_0;
    
    okHost hostIF (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okClk(okClk),
        .okAA(okAA),
        .okHE(okHE),
        .okEH(okEH)
    );
        //Invoke the module that we like to test
    JTEG_Test_File ModuleUnderTest (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okAA(okAA),
        .button(button),
        .led(led),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),  
        .ADT7420_A0(ADT7420_A0),
        .ADT7420_A1(ADT7420_A1),
        .I2C_SCL_0(I2C_SCL_0),
        .I2C_SDA_0(I2C_SDA_0) 
    );
    
    // Generate a clock signal. The clock will change its state every 5ns.
    //Remember that the test module takes sys_clkp and sys_clkn as input clock signals.
    //From these two signals a clock signal, clk, is derived.
    //The LVDS clock signal, sys_clkn, is always in the opposite state than sys_clkp.     
    assign sys_clkp = ~sys_clkn;    
    always begin
        #5 sys_clkn = ~sys_clkn;
    end        
      
    initial begin          
            #0 button <= 4'b1111;                                                      
            #200 button <= 4'b1111;
            #20 button <= 4'b0111;
    end 
    
endmodule
