`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 10:31:26 PM
// Design Name: 
// Module Name: asb_top_tb
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


module asb_top_tb;
    reg bclk;
    reg bnres;
    
    //INstantiate the top-levle unit under test
    asb_top uut(.bclk(bclk),.bnres(bnres));
    
    //1. Clock generation
    initial begin
        bclk = 0;
        forever #5 bclk = ~bclk; // 10ns / period
     end
     
     //2. Test sequence 
     initial begin
        bnres = 0;
        
        #20;
        //release reset
        bnres = 1;
        //Allow the hardcoded transaction to its course
        // (IDLE -> Req -> Addt -> data -> IDLE)
        #100;
      
        $finish;
        
        end
        
        
    
endmodule
