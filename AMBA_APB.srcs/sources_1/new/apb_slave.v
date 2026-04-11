`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2026 02:08:42 PM
// Design Name: 
// Module Name: apb_slave
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


module apb_slave(
    input clk,
    input reset_n,
    
    input psel,
    input penable,
    input pwrite,
    input [31:0] paddr,
    input [31:0] pwdata,
    
    output reg [31:0] prdata,
    output reg pready
    );
    
    reg [31:0] mem [0:255]; //simple memory
    integer i;
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            pready <= 0;
            prdata <= 0;
            
            //Initial memory
            for(i = 0; i < 256; i = i + 1) 
                mem[i] <= 0;
        end 
        else begin 
            if(psel && penable && !pready) begin
                pready <= 1;
                
                if(pwrite) begin
                $display("WRITE OCCURRED: addr=%h data=%h time=%0t", paddr, pwdata, $time);
                    mem[paddr[7:0]] <= pwdata;
                end else begin
                    prdata <= mem[paddr[7:0]];
                end
                
           end else begin
                pready <= 0;
           end
        end
   end
endmodule
