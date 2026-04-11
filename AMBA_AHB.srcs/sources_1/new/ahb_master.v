`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2026 11:21:29 AM
// Design Name: 
// Module Name: ahb_master
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


module ahb_master(
    input hclk,
    input hresetn,
    input enable,
    input [31:0] data_in_a,
    input [31:0] data_in_b,
    input [31:0] addr,
    input wr,
    input hreadyout,
    input hresp,
    input [31:0] hrdata,
    input [1:0] slave_sel,
    
    output reg [1:0] sel,
    output reg [31:0] haddr,
    output reg hwrite,
    output reg [2:0] hsize,
    output reg [2:0] hburst,
    output reg [3:0] hprot,
    output reg [1:0] htrans,
    output reg hready,
    output reg [31:0] hwdata,
    output reg [32:0] dout
    );
    
    
    //state machine parameter
    reg [1:0] current_state, next_state;
    parameter idle = 2'b00;
    parameter s1 = 2'b01;
    parameter s2 = 2'b10;
    parameter s3 = 2'b11;
    
    //current state logic
    always @(posedge hclk)
     begin
        if(!hresetn) 
            current_state <= idle;
        else 
            current_state <= next_state;
     end
     
    //next state logic
    always@(*)
        begin
            case(current_state)
                idle: begin
                     sel <= 2'b00;
                     haddr <=  32'h00000000;
                     hwrite <= 1'b0;
                     hsize <= 3'b000;
                     hburst <= 3'b000;
                     hprot <= 4'b0000;
                     htrans <= 2'b00;
                     hready <= 1'b0;
                     hwdata <= 32'h00000000;
                     dout <= 32'h00000000;
                     if(enable == 1'b1)
                        next_state <= s1;
                     else 
                        next_state <= idle;
                end
                
                s1: begin
                     sel <= slave_sel;
                     haddr <=  addr;
                     hwrite <= wr;
                     hburst <= 3'b000;
                     hready <= 1'b1;
                     hwdata <= data_in_a + data_in_b;
                     dout <= dout;
                     if(wr == 1'b1)
                        next_state = s2;
                     else 
                        next_state = s3;
                end
                
                s2: begin
                    sel <= slave_sel;
                     haddr <=  addr;
                     hwrite <= wr;
                     hburst <= 3'b000;
                     hready <= 1'b1;
                     hwdata <= data_in_a + data_in_b;
                     dout <= dout;
                     if(enable == 1'b1) 
                        next_state <= s1;
                     else
                        next_state <= idle;
                end
                
                s3: begin
                    sel <= slave_sel;
                     haddr <=  addr;
                     hwrite <= wr;
                     hburst <= 3'b000;
                     hready <= 1'b1;
                     hwdata <= hwdata;
                     dout <= hrdata;
                    if(enable == 1'b1)
                        next_state = s1;
                    else 
                        next_state = idle;
                end
                default :begin
                     sel <= slave_sel;
                     haddr <=  haddr;
                     hwrite <= hwrite;
                     hburst <= hburst;
                     hready <= 1'b0;
                     hwdata <= hwdata;
                     dout <= dout;
                     
                     next_state <= idle;
                end
                endcase
                end
                
endmodule
