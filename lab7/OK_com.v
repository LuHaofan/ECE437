`timescale 1ns / 1ps

module OK_com(
        input   wire    [4:0] okUH,
        output  wire    [2:0] okHU,
        inout   wire    [31:0] okUHU,
        inout   wire    okAA,
        input   wire    sys_clkn,
        input   wire    sys_clkp,
        // Your signals go here
        input wire [7:0] temp
    );
       
    wire okClk;            //These are FrontPanel wires needed to IO communication    
    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication    
            
    //Declare your registers or wires to send or recieve data
    //wire [31:0] variable_1, variable_2;      //signals that are outputs from a module must be wires
    wire [31:0] result_wire;                 //signals that go into modules can be wires or registers
    //reg  [31:0] result_register;             //signals that go into modules can be wires or registers
    
    //This is the OK host that allows data to be sent or recived    
    okHost hostIF (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okClk(okClk),
        .okAA(okAA),
        .okHE(okHE),
        .okEH(okEH)
    );
        
    //Depending on the number of outgoing endpoints, adjust endPt_count accordingly.
    //In this example, we have 2 output endpoints, hence endPt_count = 2.
    localparam  endPt_count = 1;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);
    
    // Clock
    wire clk;
    reg [31:0] clkdiv;
    reg slow_clk;
    reg [7:0] counter;
    
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );
    
    assign result_wire = temp;    // Left-Side of 'assign' statement must be a 'wire'

    // result_wire is transmited to the PC via address 0x20   
    okWireOut wire20 (  .okHE(okHE), 
                        .okEH(okEHx[ 0*65 +: 65 ]),
                        .ep_addr(8'h20), 
                        .ep_datain(result_wire));
                        

endmodule

