`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 10:19:52 PM
// Design Name: 
// Module Name: asb_top
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


module asb_top(
    input bclk,
    input bnres
    );
    //internal ASB signals
    wire [31:0] ba;
    wire [1:0] btran;
    wire bwrite;
    wire bwait;
    wire berror;
    
    //Master/Slave data multiplexing wires
    wire[31:0] m_bdout;
    wire[31:0] s_bdout;
    wire[31:0] bdbus;
    
    //arbitration and decode wires
    wire areq, agnt, dsel;
    
    //bus multiplexing
    assign bdbus = bwrite ? m_bdout : s_bdout;
    
    //1. Instatiate Arbiter
    asb_arbiter u_arbiter(
    .bclk(bclk),
    .bnres(bnres),
    .areq(areq),
    .agnt(agnt)
    );
    
    //2. Instatiate decoder
    asb_decoder u_decoder(
    .ba(ba),
    .dsel(dsel)
    );
    
    //3. Initiante master
    asb_master u_master(
    .bclk(bclk),
    .bnres(bnres),
    .areq(areq),
    .agnt(agnt),
    .ba(ba),
    .btran(btran),
    .bwrite(bwrite),
    .bdout(m_bdout),
    .bdin(bdbus),
    .bwait(bwait),
    .berror(berror)
    );
    
    //4. Instantiate Slave
    asb_slave u_slave(
    .bclk(bclk),
    .bnres(bnres),
    .dsel(dsel),
    .ba(ba),
    .btran(btran),
    .bwrite(bwrite),
    .bdin(bdbus),
    .bdout(s_bdout),
    .bwait(bwait),
    .berror(berror)
    );
    
    
    
endmodule
