`timescale 1ns / 1ps

module BTPipeExample(
    input   wire    [4:0] okUH,
    output  wire    [2:0] okHU,
    inout   wire    [31:0] okUHU,
    inout   wire    okAA,
    input  [9:0] CVM300_D,
    output  CVM300_Line_valid,
    output  CVM300_Data_valid,
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,
    output CVM300_CLK_IN,
    input CVM300_CLK_OUT,
    input CVM300_SPI_OUT,
    output  CVM300_SPI_EN,
    output  CVM300_SPI_IN,
    output  CVM300_SPI_CLK,
    output  CVM300_SYS_RES_N,
    output  CVM300_FRAME_REQ,
    output reg CVM300_Enable_LVDS
    );
    wire [31:0] Addr;
    wire [31:0] Data;
    wire W_en, R_en;
    wire okClk;            //These are FrontPanel wires needed to IO communication    
    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication     
    wire clk;
    wire FSM_Clk, ILA_Clk; 
    wire SPI_CLK_IN;
    wire w_flag, r_flag;
    reg SPI_en, SPI_in, SPI_clk;
    wire SPI_EN_W, SPI_IN_W, SPI_CLK_W, SPI_EN_R, SPI_IN_R, SPI_CLK_R;
    wire [7:0] OUT_Re;
    assign CVM300_SPI_EN = SPI_en;
    assign CVM300_SPI_IN = SPI_in;
    assign CVM300_SPI_CLK = SPI_clk;
    
    
     always@(*) begin 
        if(W_en == 1) begin
            SPI_en = SPI_EN_W;
            SPI_in = SPI_IN_W;
            SPI_clk = SPI_CLK_W;
        end
        else begin
            SPI_en = SPI_EN_R;
            SPI_in = SPI_IN_R;
            SPI_clk = SPI_CLK_R;
        end
     end
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
    
    SPI_write write1(
        .Addr(Addr[6:0]),
        .Data(Data[7:0]),
        .W_en(W_en),
        .FSM_Clk(SPI_CLK_IN),
    
        .SPI_EN(SPI_EN_W),
        .SPI_IN(SPI_IN_W),
        .SPI_CLK(SPI_CLK_W),
        .done(w_flag)
    );
    
    SPI_read read1 (
        .Addr(Addr[6:0]),
        .FSM_Clk(SPI_CLK_IN),
        .SPI_OUT(CVM300_SPI_OUT),
        .R_en(R_en),
        .SPI_EN(SPI_EN_R),
        .SPI_IN(SPI_IN_R),
        .DATA_OUT(OUT_Re),
        .SPI_CLK(SPI_CLK_R),
        .done(r_flag)        
    );
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 2; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk),
                                      .clk(clk),
                                      .CVM_Clk(CVM300_CLK_IN),
                                      .SPI_Clk(SPI_CLK_IN)
                                  );
    //Depending on the number of outgoing endpoints, adjust endPt_count accordingly.
    //In this example, we have 1 output endpoints, hence endPt_count = 1.
    localparam  endPt_count = 2;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);    
    
                                                                                  
    localparam STATE_INIT                = 8'd0;
    localparam STATE_RESET               = 8'd1;   
    localparam STATE_DELAY               = 8'd2;
    localparam STATE_RESET_FINISHED      = 8'd3;
    localparam STATE_ENABLE_WRITING      = 8'd4;
    localparam STATE_COUNT               = 8'd5;
    localparam STATE_FINISH              = 8'd6;
    localparam STATE_TAIL                = 8'd7;
    localparam STATE_REQ                 = 8'd8;
    localparam STATE_EXPO                = 8'd9;
    reg [31:0] counter = 8'd0;
    reg [15:0] counter_delay = 16'd0;
    reg [7:0] State = STATE_INIT;
    reg [7:0] led_register = 0;
    reg [9:0] DATA_OUT;
    reg [3:0] button_reg, write_enable_counter;  
    reg write_reset, read_reset;
    wire [31:0] Reset_Counter;
    wire [31:0] DATA_Counter;    
    wire FIFO_read_enable, FIFO_BT_BlockSize_Full, FIFO_full, FIFO_empty, BT_Strobe;
    reg write_enable = 1'b0;
    reg [1:0] LD_enable;
    wire [31:0] FIFO_data_out;
    wire LVAL, DVAL;
    wire [31:0]SYS_RES_N, F_REQ;
    reg [7:0] default_out = 10'h0;
    wire [9:0] fifo_out;
    reg frame_request;
    
    assign LVAL = LD_enable[1];
    assign DVAL = LD_enable[0];
    assign CVM300_Line_valid = LVAL;
    assign CVM300_Data_valid = DVAL;
    assign led[0] = ~FIFO_empty; 
    assign led[1] = ~FIFO_full;
    assign led[2] = ~FIFO_BT_BlockSize_Full;
    assign led[3] = ~FIFO_read_enable;  
    assign led[7] = ~read_reset;
    assign led[6] = ~write_reset;
    assign CVM300_SYS_RES_N = SYS_RES_N[0];
    assign CVM300_FRAME_REQ = frame_request;
//    assign fifo_out = (write_enable == 1'b1)? DATA_OUT : 10'h0;
    
    initial begin
        write_reset <= 1'b0;
        read_reset <= 1'b0;       
        CVM300_Enable_LVDS <= 1'b0;    
    end
    
//    always @(negedge CVM300_CLK_OUT) begin
//        DATA_OUT = CVM300_D;
//        if (LD_enable == 2'b11) begin
//            write_enable = 1'b1;
//        end       
//        else begin
//            write_enable = 1'b0;
//        end
//    end
    
                        
    always @(posedge CVM300_CLK_OUT) begin     
        button_reg <= ~button;   // Grab the values from the button, complement and store them in register                
        if (Reset_Counter[0] == 1'b1) State <= STATE_RESET;
        case (State)
            
            STATE_INIT:   begin                              
                write_reset <= 1'b1;
                read_reset <= 1'b1;             
                LD_enable <= 2'b00;
                write_enable_counter <= 1'b0;
                if (Reset_Counter[0] == 1'b1) State <= STATE_RESET;                
            end
            
            STATE_RESET:   begin
                counter <= 0;
                counter_delay <= 0;
                write_reset <= 1'b1;
                read_reset <= 1'b1;                     
                LD_enable <= 2'b00;    
                write_enable_counter <= 1'b0;       
                if (Reset_Counter[0] == 1'b0) State <= STATE_RESET_FINISHED;             
            end                                     
 
           STATE_RESET_FINISHED:   begin
                write_reset <= 1'b0;
                read_reset <= 1'b0;  
                LD_enable <= 2'b00;          
                write_enable_counter <= 1'b0;     
                State <= STATE_DELAY;                                   
            end   
                          
            STATE_DELAY:   begin
                write_enable_counter <= 1'b0;
                if (counter_delay == 16'b0000_1111_1111_1111)  State <= STATE_ENABLE_WRITING;
                else counter_delay <= counter_delay + 1;
            end
            
             STATE_ENABLE_WRITING:   begin
                LD_enable <= 2'b00;
                write_enable_counter <= 1'b0;
                State <= STATE_REQ;
             end
                          
             STATE_REQ: begin
                if (F_REQ[0] == 1'b1) begin
                    frame_request <= 1'b1;
                    State <= STATE_EXPO;
                end
                else begin
                    frame_request <= 1'b0;
                    State <= STATE_REQ;
                end
             end

             STATE_EXPO: begin
                if (counter == 160520+1660) begin
                    counter <= 0;
                    State <= STATE_COUNT;
                    write_enable_counter <= 1'b0;
                end 
                else begin
                    counter <= counter +1'b1;
                end
             end
             
             STATE_COUNT:   begin;
                counter <= counter + 1;  
                if (write_enable_counter == 324) begin              
                    LD_enable <= 2'b10;
                    write_enable_counter <= write_enable_counter +1;
                end 
                else if (write_enable_counter == 649) begin
                    LD_enable <= 2'b00;
                    write_enable_counter <= 0;
                end
                else begin
                    write_enable_counter <= write_enable_counter +1; 
                    LD_enable <= 2'b11;                      
                end                                    
                if(counter == 650*488)  begin
                    State <= STATE_FINISH;       
                    counter <= 0;
                    write_enable_counter <= 1'b0;
                end  
             end
            
             STATE_FINISH:   begin  
                LD_enable <= 2'b01;                                                                                          
            end

        endcase
    end    
       
    fifo_generator_0 FIFO_for_Counter_BTPipe_Interface (
        .wr_clk(~CVM300_CLK_OUT),
        .wr_rst(write_reset),
        .rd_clk(okClk),
        .rd_rst(read_reset),
        .din({22'h0,CVM300_D}),
        .wr_en(LD_enable[0]),
        .rd_en(FIFO_read_enable),
        .dout(FIFO_data_out),
        .full(FIFO_full), 
        .empty(FIFO_empty),       
        .prog_full(FIFO_BT_BlockSize_Full)        
    );
      
    okBTPipeOut CounterToPC (
        .okHE(okHE), 
        .okEH(okEHx[ 0*65 +: 65 ]),
        .ep_addr(8'ha0), 
        .ep_datain(FIFO_data_out), 
        .ep_read(FIFO_read_enable),
        .ep_blockstrobe(BT_Strobe), 
        .ep_ready(FIFO_BT_BlockSize_Full)
    );                                      
    
    okWireIn wire00 (   .okHE(okHE), 
                        .ep_addr(8'h00), 
                        .ep_dataout(Reset_Counter));  
                        
    okWireIn wire10 (   .okHE(okHE), 
                        .ep_addr(8'h10), 
                        .ep_dataout(Addr));
                        
    //  variable_2 is a wire that contains data sent from the PC to FPGA.
    //  The data is communicated via memeory location 0x01                 
    okWireIn wire11 (   .okHE(okHE), 
                        .ep_addr(8'h11), 
                        .ep_dataout(Data));
                                      
    okWireIn wire12 (   .okHE(okHE), 
                        .ep_addr(8'h12), 
                        .ep_dataout(W_en));  
                                                 
    okWireIn wire13 (   .okHE(okHE), 
                        .ep_addr(8'h13), 
                        .ep_dataout(SYS_RES_N));   
                                                
    okWireIn wire14 (   .okHE(okHE), 
                        .ep_addr(8'h14), 
                        .ep_dataout(F_REQ));
                        
    okWireIn wire15 (   .okHE(okHE), 
                        .ep_addr(8'h15), 
                        .ep_dataout(R_en));
                        
    okWireOut wire20 (  .okHE(okHE), 
                        .okEH(okEHx[ 1*65 +: 65 ]),
                        .ep_addr(8'h20), 
                        .ep_datain(OUT_Re));
                        
    ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({CVM300_CLK_IN, CVM300_CLK_OUT, CVM300_SPI_OUT,  CVM300_SPI_EN,  CVM300_SPI_CLK,  SYS_RES_N[0], CVM300_FRAME_REQ,CVM300_Line_valid, CVM300_Data_valid}),                             
        .probe1({CVM300_CLK_IN, SYS_RES_N[0]})
        );      
endmodule
