`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 03:54:51 PM
// Design Name: 
// Module Name: wb_top
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


module wb_top(
input wire         clk,
    input wire         rst,
    
    // External Local CPU Control Bus
    input wire         cpu_req,
    input wire         cpu_write,
    input wire [31:0]  cpu_addr,
    input wire [31:0]  cpu_wdata,
    output wire [31:0] cpu_rdata,
    output wire        cpu_ack
);

    // Interconnect Intermediary Wires
    wire [31:0] wb_adr;
    wire [31:0] wb_m2s_dat; // Master to Slave Data
    wire [31:0] wb_s2m_dat; // Slave to Master Data
    wire        wb_we;
    wire [3:0]  wb_sel;
    wire        wb_stb;
    wire        wb_cyc;
    wire        wb_ack;

    // Instantiate Wishbone Master
    wb_master master_u (
        .clk_i   (clk),
        .rst_i   (rst),
        .adr_o   (wb_adr),
        .dat_o   (wb_m2s_dat),
        .dat_i   (wb_s2m_dat),
        .we_o    (wb_we),
        .sel_o   (wb_sel),
        .stb_o   (wb_stb),
        .cyc_o   (wb_cyc),
        .ack_i   (wb_ack),
        .req_i   (cpu_req),
        .write_i (cpu_write),
        .addr_i  (cpu_addr),
        .wdata_i (cpu_wdata),
        .rdata_o (cpu_rdata),
        .ack_o   (cpu_ack)
    );

    // Instantiate Wishbone Slave
    wb_slave slave_u (
        .clk_i   (clk),
        .rst_i   (rst),
        .adr_i   (wb_adr),
        .dat_i   (wb_m2s_dat),
        .dat_o   (wb_s2m_dat),
        .we_i    (wb_we),
        .sel_i   (wb_sel),
        .stb_i   (wb_stb),
        .cyc_i   (wb_cyc),
        .ack_o   (wb_ack)
    );
endmodule
