`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 09:54:13 PM
// Design Name: 
// Module Name: asb_arbiter
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


module asb_arbiter(
    input bclk,
    input bnres,
    input areq,
    output reg agnt
    );
    
    //Simple fixed priority or single-master grant logic
    always@(posedge bclk or negedge bnres) begin
        if(!bnres) begin
            agnt <= 1'b0;
        end
        else begin
            //grant the bus if requested
            // In a multi-master system, this logic evaluate multiple areq signal
            if(areq)
                agnt <= 1'b1;
            else 
                agnt <= 1'b0;
            end
   end
endmodule
