`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 01:25:02 AM
// Design Name: 
// Module Name: axi_slave
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


module axi_slave(
    input wire clk,
    input wire resetn,
    
    //Write address channedl
    input wire [31:0] awaddr,
    input wire awvalid,
    output wire awready,
    
    //Write Data Channel
    input wire [31:0] wdata,
    input wire wvalid,
    output wire wready,
    
    //Write response channel
    output reg [1:0] bresp,
    output reg bvalid,
    input wire bready,
    
    //Read address channedl
    input wire [31:0] araddr,
    input wire arvalid,
    output wire arready,
    
    //Ready data
    output reg [31:0] rdata,
    output reg [1:0] rresp,
    output reg rvalid,
    input wire rready
    );
    
    assign awready = 1'b1;
    assign wready = 1'b1;
    assign arready = 1'b1;
    
    // Internal mock registers matching the Master's target addresses
    reg [31:0] reg_30; // WR_REG_VDMACR
    reg [31:0] reg_A0; // WR_REG_MM2S_VSIZE
    reg [31:0] reg_A4; // WR_REG_MM2S_HSIZE
    
    //Write Logic
    always @(posedge clk)  begin
        if(!resetn) begin
            reg_30 <= 32'd0;
            reg_A0 <= 32'd0;
            reg_A4 <= 32'd0;
            bvalid <= 1'b0;
            bresp  <= 2'b00; // OKAY respons
            
        end else begin
        //capture data on simultaneous valid and ready
        if(awvalid && awready  && wvalid && wready) begin
            case (awaddr)
                32'h30: reg_30 <= wdata;
                32'hA0: reg_A0 <= wdata;
                32'hA4: reg_A4 <= wdata;
            endcase
            bvalid <= 1'b1;
        end else if(bready && bvalid) begin
            // Clrear valid once master acknowledges
            bvalid <= 1'b0;
        end
      end
  end
  
  // -------------------------
    // Read Logic
    // -------------------------
    always @(posedge clk) begin
        if (!resetn) begin
            rdata  <= 32'd0;
            rvalid <= 1'b0;
            rresp  <= 2'b00; // OKAY response
        end 
        else begin
            if(arvalid && arready) begin
                rvalid <= 1'b1;
                //return requested register data
                // Return the requested register data
                case (araddr)
                    32'h30: rdata <= reg_30;
                    32'hA0: rdata <= reg_A0;
                    32'hA4: rdata <= reg_A4;
                    default: rdata <= 32'hDEADBEEF;
                endcase
                end else if(rready && rvalid) begin
                // Clear valid once master receivs data
                rvalid <= 1'b0;
                end
                end
                end  
  
endmodule
