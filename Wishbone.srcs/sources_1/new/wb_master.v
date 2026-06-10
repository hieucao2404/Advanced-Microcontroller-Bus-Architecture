`timescale 1ns / 1ps
module wb_master(
    input wire clk_i,
    input wire rst_i,
    
    //Wishbone interface outputs
    output reg[31:0] adr_o,
    output reg[31:0] dat_o,
    output reg we_o,
    output reg[3:0] sel_o,
    output reg stb_o,
    output reg cyc_o,
    
    //Wishbone intereface inputs
    input wire [31:0] dat_i,
    input wire ack_i,
    
    //Local CPU/User Control Inteface
    input wire req_i, // Assert to start a transaction
    input wire write_i, //1 = Write, 0 = Read
    input wire [31:0] addr_i, // Target address
    input wire [31:0] wdata_i, // Datat to write
    output reg [31:0] rdata_o, // Data read from slave
    output reg ack_o // High when transaction finish
    );
    
    // Slate Machine States
    localparam STATE_IDLE = 1'b0;
    localparam STATE_BUSY = 1'b1;
    reg state;
    
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            state <= STATE_IDLE;
            adr_o   <= 32'h0;
            dat_o   <= 32'h0;
            we_o    <= 1'b0;
            sel_o   <= 4'h0;
            stb_o   <= 1'b0;
            cyc_o   <= 1'b0;
            rdata_o <= 32'h0;
            ack_o   <= 1'b0;
         end else begin
            ack_o <= 1'b0;
            
           case (state)
                STATE_IDLE: begin
                    if (req_i) begin
                        state <= STATE_BUSY;
                        adr_o <= addr_i;
                        we_o  <= write_i;
                        sel_o <= 4'hF;     // Select all 4 bytes (32-bit word)
                        cyc_o <= 1'b1;     // Assert cycle
                        stb_o <= 1'b1;     // Assert strobe
                        if (write_i) begin
                            dat_o <= wdata_i;
                        end
                    end
                end

                STATE_BUSY: begin
                    // Wait for Slave to acknowledge
                    if (ack_i) begin
                        cyc_o <= 1'b0;     // Drop cycle
                        stb_o <= 1'b0;     // Drop strobe
                        we_o  <= 1'b0;
                        ack_o <= 1'b1;     // Notify local controller
                        
                        if (!we_o) begin
                            rdata_o <= dat_i; // Capture read data
                        end
                        state <= STATE_IDLE;
                    end
                end
                
                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule