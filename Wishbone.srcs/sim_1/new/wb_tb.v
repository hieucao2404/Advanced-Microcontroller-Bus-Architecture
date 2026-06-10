`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 04:30:12 PM
// Design Name: 
// Module Name: wb_tb
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


module wb_tb(

    );
    // ---------------------------------------------------------
    // 1. Signals & Instantiation
    // ---------------------------------------------------------
    reg         clk;
    reg         rst;

    // CPU Interface Signals
    reg         cpu_req;
    reg         cpu_write;
    reg  [31:0] cpu_addr;
    reg  [31:0] cpu_wdata;
    wire [31:0] cpu_rdata;
    wire        cpu_ack;

    // Instantiate the Device Under Test (DUT)
    wb_top dut (
        .clk       (clk),
        .rst       (rst),
        .cpu_req   (cpu_req),
        .cpu_write (cpu_write),
        .cpu_addr  (cpu_addr),
        .cpu_wdata (cpu_wdata),
        .cpu_rdata (cpu_rdata),
        .cpu_ack   (cpu_ack)
    );

    // ---------------------------------------------------------
    // 2. Clock Generation (100 MHz)
    // ---------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // ---------------------------------------------------------
    // 3. Test Sequence
    // ---------------------------------------------------------
    initial begin
        // Optional: Generate a VCD file for waveform viewing (GTKWave/ModelSim)
        $dumpfile("wishbone_waves.vcd");
        $dumpvars(0, wb_tb);

        // Initialize CPU inputs to zero
        rst       = 1'b1;
        cpu_req   = 1'b0;
        cpu_write = 1'b0;
        cpu_addr  = 32'h0;
        cpu_wdata = 32'h0;

        // Hold reset for 20ns, then release
        #20 rst = 1'b0;
        #20;

        // =========================================================
        // TEST 1: READ INITIAL DATA
        // Target: Slave Register 0 (Address 0x0)
        // Expected Data: 0xA5A5A5A5 (set in the slave initialization)
        // =========================================================
        $display("[%0t] Starting TEST 1: Read Register 0", $time);
        @(posedge clk);
        cpu_req   = 1'b1;
        cpu_write = 1'b0;
        cpu_addr  = 32'h0000_0000;

        // Wait until Master asserts ACK
        wait(cpu_ack == 1'b1);
        @(posedge clk); 
        
        // Drop the request
        cpu_req = 1'b0; 

        // Verify Output
        if (cpu_rdata == 32'hA5A5A5A5)
            $display(" ---> [PASS] Read Data = 0x%0h", cpu_rdata);
        else
            $display(" ---> [FAIL] Read Data = 0x%0h (Expected: 0xA5A5A5A5)", cpu_rdata);

        #30; // Idle gap between transactions

        // =========================================================
        // TEST 2: WRITE NEW DATA
        // Target: Slave Register 2 (Address 0x8)
        // Note: The slave decodes address bits [3:2]. 
        // 0x0 = Reg 0, 0x4 = Reg 1, 0x8 = Reg 2
        // =========================================================
        $display("[%0t] Starting TEST 2: Write to Register 2", $time);
        @(posedge clk);
        cpu_req   = 1'b1;
        cpu_write = 1'b1;
        cpu_addr  = 32'h0000_0008; 
        cpu_wdata = 32'hDEADBEEF;

        wait(cpu_ack == 1'b1);
        @(posedge clk);
        
        cpu_req   = 1'b0;
        cpu_write = 1'b0; // Reset write flag
        $display(" ---> Write Transaction Completed.");

        #30; // Idle gap

        // =========================================================
        // TEST 3: READ BACK WRITTEN DATA
        // Target: Slave Register 2 (Address 0x8)
        // Expected Data: 0xDEADBEEF
        // =========================================================
        $display("[%0t] Starting TEST 3: Read back Register 2", $time);
        @(posedge clk);
        cpu_req   = 1'b1;
        cpu_write = 1'b0;
        cpu_addr  = 32'h0000_0008;

        wait(cpu_ack == 1'b1);
        @(posedge clk);
        
        cpu_req = 1'b0;

        // Verify Output
        if (cpu_rdata == 32'hDEADBEEF)
            $display(" ---> [PASS] Read Data = 0x%0h", cpu_rdata);
        else
            $display(" ---> [FAIL] Read Data = 0x%0h (Expected: 0xDEADBEEF)", cpu_rdata);

        // =========================================================
        // END OF SIMULATION
        // =========================================================
        #50;
        $display("[%0t] Simulation Finished.", $time);
        $finish;
    end
endmodule
