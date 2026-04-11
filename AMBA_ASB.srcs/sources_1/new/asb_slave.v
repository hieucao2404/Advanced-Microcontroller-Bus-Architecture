`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 10:12:52 PM
// Design Name: 
// Module Name: asb_slave
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


module asb_slave(
    input wire bclk,
    input wire bnres,
    // ASN bus interface
    input dsel,
    input[31:0] ba,
    input[1:0] btran,
    input bwrite,
    input[31:0] bdin, //data from master
    output reg [31:0] bdout, //data to master
    output reg bwait,
    output reg berror
    );
    
    //Simple single register memory for demonstration
    reg[31:0] internal_reg;
    reg active_write;
    
    always@(posedge bclk or negedge bnres) begin
        if(!bnres) begin
            bdout <= 32'd0;
            bwait <= 1'b0;
            berror <= 1'b0;
            internal_reg <= 32'd0;
            active_write <= 1'b0;
         end
         else begin
         //default status
            bwait <= 1'b0;
            berror <= 1'b0;
            
            //pipelined nature of ASB: Address phase decoded in cycle T, dataphase
            if(dsel && (btran == 2'b10|| btran == 2'b11)) begin
                if(bwrite) begin
                    active_write <= 1'b1; // setup for data capture next cycle
                 end
                 else begin
                    bdout <= internal_reg;
                 end
            end 
            else if (active_write) begin
                internal_reg <= bdin; // capture written data
                active_write <= 1'b0;
            end
         end
      end
endmodule
