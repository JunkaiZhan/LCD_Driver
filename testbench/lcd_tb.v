//////////////////////////////////////////////////////////////////////////////////
// Company: Private
// Engineer: JunkaiZhan
// 
// Create Date: 2018-12-22
// Design Name: Image Recognition
// Module Name: lcd controller with SPI interface
// Target Devices: ASIC/FPGA
// Tool Version: 
// Description: 
//      Testbench
// Dependencies: 
//      lcd_ctrl.v
// Revision: 
// Revision 0.01 - File Created
//
////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module lcd_tb();

// Parameter Declarations 
parameter time_cycle = 10;

// Interface Declaration
reg clk, rstn;
reg [2:0] command;
reg valid_in;
reg [7:0] fifo_rd_data;
reg fifo_empty;

wire busy;
wire error;
wire fifo_rd_en;

wire rst_lcd;
wire scl_lcd;
wire sda_lcd;
wire cs_lcd;
wire rs_lcd;
wire led_lcd;

// Design Under Test
lcd_ctrl dut(
    .clk(clk),
    .rstn(rstn),
    .command(command),
    .valid_in(valid_in),
    .busy(busy),
    .error(error),
    .fifo_rd_en(fifo_rd_en),
    .fifo_rd_data(fifo_rd_data),
    .fifo_empty(fifo_empty),
    .rst_lcd(rst_lcd),
    .scl_lcd(scl_lcd),
    .sda_lcd(sda_lcd),
    .cs_lcd(cd__lcd),
    .rs_lcd(rs_lcd),
    .led_lcd(led_lcd)
);

// clock and reset_n
initial begin
    clk = 1;
    rstn = 1;
    #(time_cycle*2) rstn = 0;
    #(time_cycle*2) rstn = 1;
end

always begin
    #(time_cycle/2) clk = ~clk;
end

// dump out file and variables
initial begin
    $dumpfile("./sim/lcd_wv.vcd");
    $dumpvars(0, dut);
end

// logic
initial begin
    
    // command 1: initial
    command = 3'd1;
    valid_in = 1'b1;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #time_cycle;
    command = 3'd1;
    valid_in = 1'b0;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #(time_cycle*1000);

    // command 2: clear_red
    command = 3'd2;
    valid_in = 1'b1;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #time_cycle;
    command = 3'd2;
    valid_in = 1'b0;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #(time_cycle*1000);

    // command 3: clear_green
    command = 3'd3;
    valid_in = 1'b1;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #time_cycle;
    command = 3'd3;
    valid_in = 1'b0;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #(time_cycle*1000);
    
    // command 4: clear_blue
    command = 3'd4;
    valid_in = 1'b1;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #time_cycle;
    command = 3'd4;
    valid_in = 1'b0;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #(time_cycle*1000);

    // command 5: show_imaage
    command = 3'd5;
    valid_in = 1'b1;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #time_cycle;
    command = 3'd5;
    valid_in = 1'b0;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #(time_cycle*1000);

    // command 5: show_imaage failed
    command = 3'd5;
    valid_in = 1'b1;
    fifo_rd_data = 8'h9a;
    fifo_empty = 1'b1;
    #time_cycle;
    command = 3'd5;
    valid_in = 1'b0;
    fifo_rd_data = 8'h9a;
    fifo_empty = 1'b1;
    #(time_cycle*1000);

    // command 5: show_imaage change fifo data
    command = 3'd5;
    valid_in = 1'b1;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #time_cycle;
    command = 3'd5;
    valid_in = 1'b0;
    fifo_rd_data = 8'haa;
    fifo_empty = 1'b0;
    #(time_cycle*10);
    fifo_rd_data = 8'h94;
    #(time_cycle*10);
    fifo_rd_data = 8'hb3;
    #(time_cycle*10);
    fifo_rd_data = 8'h26;
    #(time_cycle*600);

    #(time_cycle*100);
    $finish;
end

endmodule
