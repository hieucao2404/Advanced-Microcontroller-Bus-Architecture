`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 10:01:35 PM
// Design Name: 
// Module Name: asb_master
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


module asb_master(
    input bclk,
    input bnres,
    //arbiter interface
    output reg areq,
    input agnt,
    //ASB Bus Interface
    output reg [31:0] ba, // bus address
    output reg [1:0] btran, // transfer type (IDLE NONSEQ, SEQ
    output reg bwrite,
    output reg [31:0] bdout,
    input [31:0] bdin,
    input bwait,
    input berror
    );
    
    // btrans type
    localparam IDLE = 2'b00;
    localparam NONSEQ = 2'b10;
    
    reg[2:0] state;
    localparam s_idle = 3'd0;
    localparam s_req = 3'd1;
    localparam s_addr = 3'd2;
    localparam s_data = 3'd3;
    
    always @(posedge bclk or negedge bnres) begin
        if(!bnres) begin
            areq <= 1'b0;
            btran <= IDLE;
            bwrite <= 1'b0;
            ba <= 32'd0;
            bdout <=  32'd0;
            state <= s_idle;
        end
        else begin
            case(state)
                s_idle: begin
                    // trigger condition to start a transaction goes here
                    areq <= 1'b1;
                    state <= s_req;
                end
                
                s_req: begin
                    if(agnt) begin
                        ba <= 32'h4000_0004; //Target address
                        btran <= NONSEQ; // start non-sequential transfer
                        bwrite <=  1'b1;
                        state <= s_addr;
                     end
                 end
                 
                 s_addr: begin
                    btran <= IDLE; //end of addres phase
                    if(!bwait) begin
                        bdout <= 32'hDEADBEEF; //data phase
                        state <= s_data;
                    end
                 end
                 
                 s_data: begin
                    if(!bwait) begin
                        areq <= 1'b0; // drop request
                        state <= s_idle; // transaction complete
                    end
                end
                
                default: state <= s_idle;
                endcase
                end
                end
endmodule
