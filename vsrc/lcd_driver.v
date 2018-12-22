//////////////////////////////////////////////////////////////////////////////////
// Company: Private
// Engineer: JunkaiZhan
// 
// Create Date: 2018-12-20
// Design Name: Image Recognition
// Module Name: lcd driver with spi interface
// Target Devices: ASIC/FPGA
// Tool Version: 
// Description: 
// 
// Dependencies: 
// 
// Revision: 
// Revision 0.01 - File Created
//
// //////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module lcd_driver(
    clk, rstn, index_or_data, // 0 - index, 1 - data
    valid_in, data_in, done,
    rst_lcd, scl_lcd, sda_lcd,
    cs_lcd, rs_lcd, led_lcd
);

// Parameter Declarations --------------------------------------
parameter DATA_WIDTH = 9;

localparam IDLE  = 3'd0;
localparam INDEX = 3'd1;
localparam DATA  = 3'd2;
localparam TRA_1 = 3'd3;
localparam TRA_2 = 3'd4;
localparam TRA_3 = 3'd5;
localparam DONE  = 3'd6;

// Interface Declarations --------------------------------------
input clk, rstn;
input valid_in, index_or_data;
input [DATA_WIDTH - 1 : 0] data_in;
output rst_lcd, scl_lcd, sda_lcd;
output cs_lcd, rs_lcd, led_lcd;
output done;

assign rst_lcd = rstn;
assign led_lcd = 1'b1;

// Reg and Wire Declarations -----------------------------------
reg [2 : 0] state;
reg [2 : 0] next_state;
reg [DATA_WIDTH - 1 : 0] seq;
reg [3 : 0] counter;
reg start;

wire counter_is_zero;
assign counter_is_zero = ~|counter;

wire valid_bit;
assign valid_bit = seq[DATA_WIDTH - 1];

assign done = state == DONE;

// Seq Logic ---------------------------------------------------
always @ (posedge clk or negedge rstn) begin
    if(!rstn) state <= IDLE;
    else state <= next_state;
end

always @ (*) begin
    case(state)
    IDLE: begin
        if(valid_in && !index_or_data) next_state = INDEX;
        else if(valid_in && index_or_data) next_state = DATA;
        else next_state = IDLE
    end
    INDEX: begin next_state = TRA_1; end
    DATA:  begin next_state = TRA_1; end
    TRA_1: begin next_state = TRA_2; end
    TRA_2: begin next_state = TRA_3; end
    TRA_3: begin
        if(counter_is_zero) next_state = DONE;
        else next_state = TRA_1;
    end
    DONE: begin next_state = IDLE; end
end

always @ (*) begin
    case(state)
    IDLE:  begin cs_lcd = 1'b1; scl_lcd = 1'b1; end
    INDEX: begin cs_lcd = 1'b0; rs_lcd  = 1'b0; end
    DATA:  begin cs_lcd = 1'b0; rs_lcd  = 1'b1; end
    TRA_1: begin cs_lcd = 1'b0; scl_lcd = 1'b1; sda_lcd = valid_bit; end
    TRA_2: begin cs_lcd = 1'b0; scl_lcd = 1'b0; sda_lcd = valid_bit; end
    TRA_3: begin cs_lcd = 1'b0; scl_lcd = 1'b1; sda_lcd = valid_bit; end
    DONE:  begin cs_lcd = 1'b1; end
    default: begin cs_lcd = 1'b1; end
    endcase 
end

always @ (posedge clk or negedge rstn) begin
    if(!rstn) begin seq <= 'b0; end
    else begin
        if(valid_in && (state == IDLE)) seq <= data_in;
        else if(state == TRA_3) seq <= seq << 1;
    end
end

always @ (posedge clk or negedge rstn) begin
    if(!rstn) counter <= 'd0;
    else begin
        if(state == TRA_1) counter <= counter - 1'b1;
        else if(valid_in) counter <= DATA_WIDTH;
    end
end

endmodule
