`timescale 1ns / 1ps
module wb_slave(

   // Global Signals
    input wire         clk_i,
    input wire         rst_i,

    // Wishbone Interface Inputs
    input wire [31:0]  adr_i,
    input wire [31:0]  dat_i,
    input wire         we_i,
    input wire [3:0]   sel_i,
    input wire         stb_i,
    input wire         cyc_i,
    
    // Wishbone Interface Outputs
    output reg [31:0]  dat_o,
    output reg         ack_o
);

    // Internal Storage (4 Registers of 32-bits each)
    reg [31:0] memory [0:3];

    // Address decoding assuming word-aligned transfers (adr_i[3:2])
    wire [1:0] reg_index = adr_i[3:2];

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            ack_o     <= 1'b0;
            dat_o     <= 32'h0;
            // Initialize memory with dummy test data
            memory[0] <= 32'hA5A5A5A5;
            memory[1] <= 32'h12345678;
            memory[2] <= 32'h00000000;
            memory[3] <= 32'h00000000;
        end else begin
            // Enforce Classic Wishbone Handshake rules:
            // A transaction occurs only when both CYC and STB are high.
            if (cyc_i && stb_i && !ack_o) begin
                ack_o <= 1'b1; // Generate 1-cycle Acknowledge
                
                // Write Cycle handling byte-selects (SEL)
                if (we_i) begin
                    if (sel_i[0]) memory[reg_index][7:0]   <= dat_i[7:0];
                    if (sel_i[1]) memory[reg_index][15:8]  <= dat_i[15:8];
                    if (sel_i[2]) memory[reg_index][23:16] <= dat_i[23:16];
                    if (sel_i[3]) memory[reg_index][31:24] <= dat_i[31:24];
                end
                
                // Read Cycle
                dat_o <= memory[reg_index];
            end else begin
                ack_o <= 1'b0; // Drop ACK as soon as Master drops STB or transaction finishes
            end
        end
    end
endmodule