`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2026 02:12:51 PM
// Design Name: 
// Module Name: apb_tb
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


module apb_tb;
    reg clk, reset_n;
    reg transfer;
    reg [31:0] addr, wdata;
    reg write;
    
    wire psel, penable, pwrite;
    wire [31:0] paddr, pwdata, prdata;
    wire pready;
    wire [31:0] rdata;
    
    //Master
    apb_master master(
    .clk(clk),
    .reset_n(reset_n),
    .transfer(transfer),
    .addr(addr),
    .wdata(wdata),
    .write(write),
    .prdata(prdata),
    .pready(pready),
    .pselx(psel),
    .penable(penable),
    .paddr(paddr),
    .pwdata(pwdata),
    .pwrite(pwrite),
    .rdata(rdata) 
    );
    
     apb_slave slave (
        .clk(clk),
        .reset_n(reset_n),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready)
    );
    
    // CLock
    always #5 clk = ~clk;
    
    initial begin 
        clk = 0;
        reset_n = 0;
        transfer = 0;
        
        #20 reset_n = 1;
        
        //WRITE
        @(posedge clk);
           transfer = 1;
           addr = 32'h10;
           wdata = 32'hDEADBEEF;
           write = 1;
           
           @(posedge clk);
           transfer = 0;
           
           wait(pready);
           @(posedge clk);
           
          //READ
          @(posedge clk);
          transfer = 1;
          addr =  32'h10;
          write = 0;
          
          @(posedge clk);
          transfer = 0;
          wait(pready);
          
          @(posedge clk);
          #50;
          $finish;
          end 
endmodule
