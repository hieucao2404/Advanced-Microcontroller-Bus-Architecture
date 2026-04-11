`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2026 10:18:07 AM
// Design Name: 
// Module Name: apb_tb_slave
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


module apb_tb_slave;
    reg clk, reset_n;
    wire pselx;
    wire penable;
    wire [31:0] paddr;
    wire [31:0] pwdata;
    wire pwrite;
    reg pready;
    
    reg transfer;
    reg [31:0] addr;
    reg [31:0] wdata;
    reg write;

    apb_master dut (
    .clk      (clk),
    .reset_n  (reset_n),
    .transfer (transfer),
    .addr     (addr),
    .wdata   (wdata),    // Driving the input pwdata with wdata
    .write    (write),
    .pselx    (pselx),
    .penable  (penable),
    .paddr    (paddr),
    .pwdata    (pwdata),   // Connecting the master's output typo 'pwata' to TB pwdata
    .pwrite   (pwrite),
    .pready   (pready)
);
    initial 
        begin
            {clk, transfer, addr, wdata, write} = 0;
         end
         
         always #5 clk = ~clk;
         
         initial
            begin
            reset_n = 0;
            write = 1;
            pready = 0;
            
            #20;
            
            reset_n = 1;
            
            @(posedge clk);
                transfer = 1;
                addr = 32'habcd_1234;
                wdata = 32'hface_cafe;
                write = 1;
                
                
                @(posedge clk);
                 transfer <= 0;
                
                repeat(3)
                    @(posedge clk);
                
                pready <= 1;
                
                @(posedge clk);
                    pready <= 0;
                
                #50;
                
                $finish;
                end


endmodule
