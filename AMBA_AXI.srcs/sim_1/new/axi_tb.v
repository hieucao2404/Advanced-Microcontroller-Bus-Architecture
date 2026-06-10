`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 08:36:16 AM
// Design Name: 
// Module Name: axi_tb
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


module axi_tb(

    );
    
    reg CLK = 0;
    reg RESET_N;
    
    //50 Mhz 
    localparam clk_period = 20;
    
    always begin
        CLK = #(clk_period/2) ~CLK;
    end
    
    initial begin
        RESET_N = 0;
        #100;
        RESET_N = 1;
    end
    
    
    localparam AXI_ADDR_WIDTH = 32;
    localparam AXI_DATA_WIDTH = 32;
    
    wire [AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR;
    wire [2:0] M_AXI_AWPROT;
    wire M_AXI_AWVALID;
    wire M_AXI_AWREADY;
    
    //w
    wire [AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA;
    wire [AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB;
    wire  M_AXI_WVALID;
    wire M_AXI_WREADY;
    
    // b resp
   wire [1 : 0]                  M_AXI_BRESP;
   wire                          M_AXI_BVALID;
   wire                          M_AXI_BREADY;

   // ar
   wire [AXI_ADDR_WIDTH-1 : 0]   M_AXI_ARADDR;
   wire [2 : 0]                  M_AXI_ARPROT;
   wire                          M_AXI_ARVALID;
   wire                          M_AXI_ARREADY;

   // r
   wire [AXI_DATA_WIDTH-1 : 0]   M_AXI_RDATA;
   wire [1 : 0]                  M_AXI_RRESP;
   wire                          M_AXI_RVALID;
   wire                          M_AXI_RREADY;

   reg                           init_transaction;
   reg [31:0]                    init_counter;
   
   always @(posedge CLK)
    begin 
        if(~RESET_N) begin
            init_transaction <= 0;
            init_counter <= 0;
         end
         else begin
            init_counter <=  init_counter + 1;
            init_transaction <= 0;
            
            if(init_counter == 10) begin
                init_transaction <= 1;
            end
         end
      end
      
      // ---------------------------------------------------------
   // AXI Lite Master Instantiation
   // ---------------------------------------------------------
   axi_master
     #(
       .AXI_ADDR_WIDTH(32),
       .AXI_DATA_WIDTH(32)
       )
   axi_master_i
     (
      .init_transaction(init_transaction),

      .M_AXI_ACLK(CLK),
      .M_AXI_ARESETN(RESET_N),

      // aw
      .M_AXI_AWADDR(M_AXI_AWADDR),
      .M_AXI_AWPROT(M_AXI_AWPROT),
      .M_AXI_AWVALID(M_AXI_AWVALID),
      .M_AXI_AWREADY(M_AXI_AWREADY),

      // w
      .M_AXI_WDATA(M_AXI_WDATA),
      .M_AXI_WSTRB(M_AXI_WSTRB),
      .M_AXI_WVALID(M_AXI_WVALID),
      .M_AXI_WREADY(M_AXI_WREADY),

      // b resp
      .M_AXI_BRESP(M_AXI_BRESP),
      .M_AXI_BVALID(M_AXI_BVALID),
      .M_AXI_BREADY(M_AXI_BREADY),

      // ar
      .M_AXI_ARADDR(M_AXI_ARADDR),
      .M_AXI_ARPROT(M_AXI_ARPROT),
      .M_AXI_ARVALID(M_AXI_ARVALID),
      .M_AXI_ARREADY(M_AXI_ARREADY),

      // r
      .M_AXI_RDATA(M_AXI_RDATA),
      .M_AXI_RRESP(M_AXI_RRESP),
      .M_AXI_RVALID(M_AXI_RVALID),
      .M_AXI_RREADY(M_AXI_RREADY)
      );

   // ---------------------------------------------------------
   // Dummy AXI Slave Instantiation (Replaces VDMA)
   // ---------------------------------------------------------
   axi_slave dummy_slave
     (
      .clk(CLK),
      .resetn(RESET_N),

      .awaddr(M_AXI_AWADDR),
      .awvalid(M_AXI_AWVALID),
      .awready(M_AXI_AWREADY),

      .wdata(M_AXI_WDATA),
      .wvalid(M_AXI_WVALID),
      .wready(M_AXI_WREADY),

      .bresp(M_AXI_BRESP),
      .bvalid(M_AXI_BVALID),
      .bready(M_AXI_BREADY),

      .araddr(M_AXI_ARADDR),
      .arvalid(M_AXI_ARVALID),
      .arready(M_AXI_ARREADY),

      .rdata(M_AXI_RDATA),
      .rresp(M_AXI_RRESP),
      .rvalid(M_AXI_RVALID),
      .rready(M_AXI_RREADY)
     );
    
endmodule
