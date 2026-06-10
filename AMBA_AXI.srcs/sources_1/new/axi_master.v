`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2026 11:24:56 PM
// Design Name: 
// Module Name: axi_master
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


module axi_master#
(parameter integer AXI_ADDR_WIDTH = 32,
 parameter integer AXI_DATA_WIDTH = 32)(
 input                                init_transaction,

    input wire                           M_AXI_ACLK,
    input wire                           M_AXI_ARESETN,

    // aw
    output wire [AXI_ADDR_WIDTH-1 : 0]   M_AXI_AWADDR,
    output wire [2 : 0]                  M_AXI_AWPROT,
    output wire                          M_AXI_AWVALID,
    input wire                           M_AXI_AWREADY,

    // w
    output wire [AXI_DATA_WIDTH-1 : 0]   M_AXI_WDATA,
    output wire [AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
    output wire                          M_AXI_WVALID,
    input wire                           M_AXI_WREADY,

    // b resp
    input wire [1 : 0]                   M_AXI_BRESP,
    input wire                           M_AXI_BVALID,
    output wire                          M_AXI_BREADY,

    // ar
    output wire [AXI_ADDR_WIDTH-1 : 0]   M_AXI_ARADDR,
    output wire [2 : 0]                  M_AXI_ARPROT,
    output wire                          M_AXI_ARVALID,
    input wire                           M_AXI_ARREADY,

    // r
    input wire [AXI_DATA_WIDTH-1 : 0]    M_AXI_RDATA,
    input wire [1 : 0]                   M_AXI_RRESP,
    input wire                           M_AXI_RVALID,
    output wire                          M_AXI_RREADY

    );

   // CAPITALS reserved for parameters and external signals.
   // internal signals are lowercase

   localparam HSIZE = 640;
   localparam VSIZE = 480;

   // aw
   reg [AXI_ADDR_WIDTH-1 : 0]           axi_awaddr;
   reg                                  axi_awvalid;

   // assign outputs to top level signals
   assign M_AXI_AWADDR = axi_awaddr;
   assign M_AXI_AWVALID = axi_awvalid;
   assign M_AXI_AWPROT =  3'b000;

   // w
   reg [AXI_DATA_WIDTH-1 : 0]           axi_wdata;
   reg [AXI_DATA_WIDTH/8-1 : 0]         axi_wstrb;
   reg                                  axi_wvalid;
   
   assign M_AXI_WSTRB = axi_wstrb;
   assign M_AXI_WVALID = axi_wvalid;
   assign M_AXI_WDATA = axi_wdata;

   // b
   reg                                  axi_bready;
   reg                                  axi_berror;
   assign M_AXI_BREADY = axi_bready;

   // ar
   reg [AXI_ADDR_WIDTH-1 : 0]           axi_araddr;
   reg                                  axi_arvalid;
   assign M_AXI_ARADDR = axi_araddr;
   assign M_AXI_ARVALID = axi_arvalid;
   assign M_AXI_ARPROT = 3'b000;

   // r
   reg                                  axi_rready; // Fixed: Originally declared as [AXI_DATA_WIDTH-1 : 0]
   reg                                  axi_rerror;
   assign M_AXI_RREADY = axi_rready;

   // Write is done when b interface acknowledges write
   wire                                 write_done;
   assign write_done = axi_bready & M_AXI_BVALID;

   wire                                 read_done;
   assign read_done = axi_rready & M_AXI_RVALID;

   // Write interfaces
   reg                                  init_transaction_i;

   // edge detect on input_fsync
   always @(posedge M_AXI_ACLK)
     begin
        init_transaction_i <= init_transaction;
     end

   wire start;
   assign start = (init_transaction & ~init_transaction_i) ? 1'b1 : 1'b0;

   // State machine definitions
   localparam [2:0] 
     IDLE              = 3'd0, 
     WR_REG_VDMACR     = 3'd1, 
     WR_REG_MM2S_HSIZE = 3'd2, 
     WR_REG_MM2S_VSIZE = 3'd3, 
     RD_REG_VDMACR     = 3'd4, 
     RD_REG_MM2S_HSIZE = 3'd5, 
     RD_REG_MM2S_VSIZE = 3'd6;

   reg [2:0] current_state;
   reg [2:0] next_state;

   reg       start_write;
   reg       start_read;

   always @*
     begin
        start_write = 1'b0;
        start_read = 1'b0;
        next_state  = current_state;

        case (current_state)
          IDLE   :
            begin
               if (start) begin
                  next_state  = WR_REG_VDMACR;
                  start_write = 1'b1;
               end
            end
          WR_REG_VDMACR  :
            begin
               if (write_done) begin
                  next_state  = WR_REG_MM2S_HSIZE;
                  start_write = 1'b1;
               end
            end
          WR_REG_MM2S_HSIZE   :
            begin
               if (write_done) begin
                  next_state = WR_REG_MM2S_VSIZE;
                  start_write = 1'b1;
               end
            end
          WR_REG_MM2S_VSIZE:
          begin 
            if(write_done) begin
                next_state =  RD_REG_VDMACR;
                start_read = 1'b1;
            end
         end
         
         RD_REG_VDMACR: begin
          if(read_done) begin
            next_state = RD_REG_MM2S_HSIZE;
            start_read = 1'b1;
          end
        end
        
        RD_REG_MM2S_HSIZE:
         begin
            if(read_done) begin
             next_state = RD_REG_MM2S_VSIZE;
             start_read = 1'b1;
           end
         end
         
         RD_REG_MM2S_VSIZE:
            begin
                if(read_done) begin
                    next_state = IDLE;
                 end
             end
          RD_REG_VDMACR  :
            begin
               if (read_done) begin
                  next_state = RD_REG_MM2S_HSIZE;
                  start_read = 1'b1;
               end
            end
          RD_REG_MM2S_HSIZE   :
            begin
               if (read_done) begin
                  next_state = RD_REG_MM2S_VSIZE;
                  start_read = 1'b1;
               end
            end
          RD_REG_MM2S_VSIZE   :
            begin
               if (read_done) begin
                  next_state = IDLE;
               end
            end
          default:
            next_state = current_state;
        endcase
     end
     
     always @(posedge M_AXI_ACLK)
     begin
        if (~M_AXI_ARESETN) begin
           current_state <= IDLE;
        end
        else begin
           current_state <= next_state;
        end
     end
     
   always @*
     begin
        axi_awaddr <= 0;
        case (current_state)
          WR_REG_VDMACR     : axi_awaddr <= 'h30;
          WR_REG_MM2S_HSIZE : axi_awaddr <= 'hA4;
          WR_REG_MM2S_VSIZE : axi_awaddr <= 'hA0;
          default           : axi_awaddr <= 0;
        endcase
     end

   // Data write interface
   always @*
     begin
        axi_wdata <= 0;
        case (current_state)
          WR_REG_VDMACR     : axi_wdata <= 'h03;
          WR_REG_MM2S_HSIZE : axi_wdata <= HSIZE;
          WR_REG_MM2S_VSIZE : axi_wdata <= VSIZE;
          default           : axi_wdata <= 0;
        endcase
     end

   // Address read interface
   always @*
     begin
        axi_araddr <= 0;
        case (current_state)
          RD_REG_VDMACR     : axi_araddr <= 'h30;
          RD_REG_MM2S_HSIZE : axi_araddr <= 'hA4;
          RD_REG_MM2S_VSIZE : axi_araddr <= 'hA0;
          default           : axi_araddr <= 0;
        endcase
     end

   // r expected values
   reg [AXI_DATA_WIDTH-1 : 0]    rdata_expected;
   always @*
     begin
        rdata_expected <= 0;
        case (current_state)
          RD_REG_VDMACR     : rdata_expected <= 'h03;
          RD_REG_MM2S_HSIZE : rdata_expected <= HSIZE;
          RD_REG_MM2S_VSIZE : rdata_expected <= VSIZE;
          default           : rdata_expected <= 0;
        endcase
     end

   // Address write valid control
   always @(posedge M_AXI_ACLK)
     begin
        if (M_AXI_ARESETN == 1'b0 )
          begin
             axi_awvalid <= 1'b0;
          end
        else
          begin
             if (start_write)
               begin
                  axi_awvalid <= 1'b1;
               end

             if (M_AXI_AWREADY && axi_awvalid)
               begin
                  axi_awvalid <= 1'b0;
               end
          end
     end

   // Data write valid and strobe control
   always @(posedge M_AXI_ACLK)
     begin
        if (M_AXI_ARESETN == 1'b0 )
          begin
             axi_wvalid <= 1'b0;
             axi_wstrb  <= 0;
          end
        else
          begin
             if (start_write)
               begin
                  axi_wvalid <= 1'b1;
                  axi_wstrb <= {(AXI_DATA_WIDTH/8){1'b1}}; // Parametrized all 1s
               end

             if (M_AXI_WREADY && axi_wvalid)
               begin
                  axi_wvalid <= 1'b0;
                  axi_wstrb  <= 0;
               end
          end
     end

   // Response channel with error check
   always @(posedge M_AXI_ACLK)
     begin
        if (M_AXI_ARESETN == 1'b0)
          begin
             axi_bready <= 1'b0;
             axi_berror <= 1'b0;
          end
        else begin
           axi_bready <= 1'b1;

           if (M_AXI_BVALID && axi_bready) begin
              if (M_AXI_BRESP > 0) begin
                 axi_berror <= 1'b1;
              end
              else begin
                 axi_berror <= 1'b0;
              end
           end
        end
     end

   // Address read valid control
   always @(posedge M_AXI_ACLK)
     begin
        if (M_AXI_ARESETN == 1'b0 )
          begin
             axi_arvalid <= 1'b0;
          end
        else
          begin
             if (start_read)
               begin
                  axi_arvalid <= 1'b1;
               end

             if (M_AXI_ARREADY && axi_arvalid)
               begin
                  axi_arvalid <= 1'b0;
               end
          end
     end

   // Data read interface with error check
   always @(posedge M_AXI_ACLK)
     begin
        if (M_AXI_ARESETN == 1'b0)
          begin
             axi_rready <= 1'b0;
             axi_rerror <= 1'b0;
          end
        else begin
           axi_rready <= 1'b1;

           if (M_AXI_RVALID && axi_rready) begin
              if (M_AXI_RRESP > 0) begin
                 axi_rerror <= 1'b1;
              end
              else if (M_AXI_RDATA != rdata_expected) begin
                 axi_rerror <= 1'b1;
              end
              else begin
                 axi_rerror <= 1'b0;
              end
           end
        end
     end
     
             
      
endmodule
