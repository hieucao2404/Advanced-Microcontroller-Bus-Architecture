`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2026 02:38:05 PM
// Design Name: 
// Module Name: ahb_top
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


module ahb_top(
    input hclk,
    input hresetn,
    input enable,
    input [31:0] data_in_a,
    input [31:0] data_in_b,
    input [31:0] addr,
    input wr,
    input [1:0] slave_sel,
    output [31:0] data_out
    );
    
    wire [1:0] sel;
    wire [31:0] haddr;
    wire hwrite;
    wire [3:0]hprot;
    wire [2:0]hsize;
    wire [2:0] hburst;
    wire [1:0] htrans;
    wire hmastlock = 1'b0;
    
    wire [31:0] hwdata;
    wire hready;
        
    //slave_1
    wire [31:0] hrdata_1;
    wire hreadyout_1;
    wire hresp_1;
    //slave_2
    wire [31:0] hrdata_2;
    wire hreadyout_2;
    wire hresp_2;
    //slave_3
    wire [31:0] hrdata_3;
    wire hreadyout_3;
    wire hresp_3;
    //slave_4
    wire [31:0] hrdata_4;
    wire hreadyout_4;
    wire hresp_4;
    
    //decoder
    wire hsel_1;
    wire hsel_2;
    wire hsel_3;
    wire hsel_4;
    
    //multiplexer
    wire [31:0] hrdata;
    wire hreadyout;
    wire hresp;
    
    //ahb master
    ahb_master master(.hclk(hclk),.hresetn(hresetn),.enable(enable),.data_in_a(data_in_a)
    ,.data_in_b(data_in_b),.addr(addr),.wr(wr),.hreadyout(hreadyout)
    ,.hresp(hresp),.hrdata(hrdata),.slave_sel(slave_sel)  
    ,.sel(sel), .haddr(haddr),.hsize(hsize),.hwrite(hwrite),.hburst(hburst)
    ,.hprot(hprot),.htrans(htrans),.hready(hready)
    ,.hwdata(hwdata),.dout(data_out)); 
    
    //decoder
    decoder decoder(.sel(sel),.hsel_1(hsel_1),.hsel_2(hsel_2),.hsel_3(hsel_3),.hsel_4(hsel_4));
    
    //ahb_slave1
    ahb_slave slave_1(.hclk(hclk),.hresetn(hresetn),.hsel(hsel_1),.haddr(haddr)
    ,.hwrite(hwrite),.hsize(hsize),.hburst(hburst),.hprot(hprot)
    ,.htrans(htrans),.hmastlock(hmastlock),.hready(hready)
    ,.hwdata(hwdata),.hreadyout(hreadyout_1),.hresp(hresp_1)
    ,.hrdata(hrdata_1));
    
    //ahb_slave2
    ahb_slave slave_2(.hclk(hclk),.hresetn(hresetn),.hsel(hsel_2),.haddr(haddr)
    ,.hwrite(hwrite),.hsize(hsize),.hburst(hburst),.hprot(hprot)
    ,.htrans(htrans),.hmastlock(hmastlock),.hready(hready)
    ,.hwdata(hwdata),.hreadyout(hreadyout_2),.hresp(hresp_2)
    ,.hrdata(hrdata_2));
    
    //ahb_slave3
    ahb_slave slave_3(.hclk(hclk),.hresetn(hresetn),.hsel(hsel_3),.haddr(haddr)
    ,.hwrite(hwrite),.hsize(hsize),.hburst(hburst),.hprot(hprot)
    ,.htrans(htrans),.hmastlock(hmastlock),.hready(hready)
    ,.hwdata(hwdata),.hreadyout(hreadyout_3),.hresp(hresp_3)
    ,.hrdata(hrdata_3));
    
    //ahb_slave4
    ahb_slave slave_4(.hclk(hclk),.hresetn(hresetn),.hsel(hsel_4),.haddr(haddr)
    ,.hwrite(hwrite),.hsize(hsize),.hburst(hburst),.hprot(hprot)
    ,.htrans(htrans),.hmastlock(hmastlock),.hready(hready)
    ,.hwdata(hwdata),.hreadyout(hreadyout_4),.hresp(hresp_4)
    ,.hrdata(hrdata_4));
    
    //multiplexer
    multiplexer mux(.hrdata_1(hrdata_1),.hrdata_2(hrdata_2),.hrdata_3(hrdata_3)
                    ,.hrdata_4(hrdata_4),.hreadyout_1(hreadyout_1),.hreadyout_2(hreadyout_2)
                    ,.hreadyout_3(hreadyout_3),.hreadyout_4(hreadyout_4)
                    ,.hresp_1(hresp_1),.hresp_2(hresp_2),.hresp_3(hresp_3),.hresp_4(hresp_4)
                    ,.sel(sel),.hrdata(hrdata),.hreadyout(hreadyout),.hresp(hresp)); 
    
endmodule
