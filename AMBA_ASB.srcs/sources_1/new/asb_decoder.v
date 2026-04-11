`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 09:57:39 PM
// Design Name: 
// Module Name: asb_decoder
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


module asb_decoder
#(parameter SLAVE_BASE_ADDR = 32'h4000_0000,
  parameter ADDR_MASK = 32'hFFFF_0000)(
    input wire [31:0] ba, //bus address
    output reg dsel      
    );
    
    always @(*) begin
        //If the address matches the slave's base address space, assert DSEL
        if((ba & ADDR_MASK) == (SLAVE_BASE_ADDR & ADDR_MASK)) begin
            dsel = 1'b1;
        end
        else begin
            dsel = 1'b0;
        end
   end
endmodule
