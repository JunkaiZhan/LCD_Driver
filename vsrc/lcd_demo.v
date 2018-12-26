`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/23/2018 03:51:30 PM
// Design Name: 
// Module Name: lcd_demo
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


module lcd_demo(
    clk, rstn,
    led, color,
    cs_lcd, rs_lcd,
    scl_lcd, sda_lcd,
    rst_lcd, led_lcd,
    busy, led_cs, led_rs, led_scl, led_sda, led_rst, led_led
 );

// interface 
input clk, rstn;
input [7:0] color;
output reg [7:0] led;
output cs_lcd, rs_lcd;
output scl_lcd, sda_lcd;
output rst_lcd, led_lcd;
output busy;

output led_cs, led_rs, led_scl, led_sda, led_rst, led_led;
assign led_cs = cs_lcd;
assign led_rs = rs_lcd;
assign led_scl = scl_lcd;
assign led_sda = sda_lcd;
assign led_rst = rst_lcd;
assign led_led = led_lcd;

// warer light
parameter COUNT_WIDTH = 24;

reg [COUNT_WIDTH - 1 : 0] clk_counter;
always @ (posedge clk or negedge rstn) begin
    if(!rstn) clk_counter <= 'b0;
    else clk_counter <= clk_counter + 1'b1;
end

wire clk_div;
assign clk_div = clk_counter[COUNT_WIDTH - 1];

always @ (posedge clk_div or negedge rstn) begin
    if(!rstn) begin 
        led <= 8'b000_0001;
    end else begin
        led <= {led[0], led[7:1]};
    end
end

// ---------------------------------------------------------

reg [2:0] command;
reg valid_in;
wire busy;
wire error;
wire fifo_rd_en;

parameter IDLE          = 4'd0;
parameter INITIAL_1     = 4'd1;
parameter INITIAL_2     = 4'd2;
parameter INITIAL_3     = 4'd3;
parameter CLEAR_RED_1   = 4'd4;
parameter CLEAR_RED_2   = 4'd5;
parameter CLEAR_RED_3   = 4'd6;
parameter CLEAR_GREEN_1 = 4'd7;
parameter CLEAR_GREEN_2 = 4'd8;
parameter CLEAR_GREEN_3 = 4'd9;
parameter CLEAR_BLUE_1  = 4'd10;
parameter CLEAR_BLUE_2  = 4'd11;
parameter CLEAR_BLUE_3  = 4'd12;
parameter SHOW_IMAGE_1  = 4'd13;
parameter SHOW_IMAGE_2  = 4'd14;
parameter SHOW_IMAGE_3  = 4'd15;

localparam COM_IDLE        = 3'd0;
localparam COM_INITIAL     = 3'd1;
localparam COM_CLEAR_RED   = 3'd2;
localparam COM_CLEAR_GREEN = 3'd3;
localparam COM_CLEAR_BLUE  = 3'd4;
localparam COM_SHOW_IMAGE  = 3'd5;

reg [3:0] state;
reg [3:0] next_state;

always @ (posedge clk_div or negedge rstn) begin
    if(!rstn) state <= IDLE;
    else state <= next_state;
end
    
always @ (*) begin
    case(state)
    IDLE:          begin command = COM_IDLE; valid_in = 1'b0; end
    INITIAL_1:     begin command = COM_INITIAL; valid_in = 1'b0; end    
    INITIAL_2:     begin command = COM_INITIAL; valid_in = 1'b1; end
    INITIAL_3:     begin command = COM_INITIAL; valid_in = 1'b0; end
    CLEAR_RED_1:   begin command = COM_CLEAR_RED; valid_in = 1'b0; end
    CLEAR_RED_2:   begin command = COM_CLEAR_RED; valid_in = 1'b1; end    
    CLEAR_RED_3:   begin command = COM_CLEAR_RED; valid_in = 1'b0; end
    CLEAR_GREEN_1: begin command = COM_CLEAR_GREEN; valid_in = 1'b0; end
    CLEAR_GREEN_2: begin command = COM_CLEAR_GREEN; valid_in = 1'b1; end
    CLEAR_GREEN_3: begin command = COM_CLEAR_GREEN; valid_in = 1'b0; end
    CLEAR_BLUE_1:  begin command = COM_CLEAR_BLUE; valid_in = 1'b0; end
    CLEAR_BLUE_2:  begin command = COM_CLEAR_BLUE; valid_in = 1'b1; end
    CLEAR_BLUE_3:  begin command = COM_CLEAR_BLUE; valid_in = 1'b0; end
    SHOW_IMAGE_1:  begin command = COM_SHOW_IMAGE; valid_in = 1'b0; end
    SHOW_IMAGE_2:  begin command = COM_SHOW_IMAGE; valid_in = 1'b1; end
    SHOW_IMAGE_3:  begin command = COM_SHOW_IMAGE; valid_in = 1'b0; end
    default: begin command = COM_IDLE; valid_in = 1'b0; end
    endcase
end

always @ (*) begin
    case(state)
    IDLE:          begin if(!busy) next_state = INITIAL_1; else next_state = IDLE; end 
    INITIAL_1:     begin next_state = INITIAL_2; end
    INITIAL_2:     begin next_state = INITIAL_3; end
    INITIAL_3:     begin if(!busy) next_state = CLEAR_RED_1; else next_state = INITIAL_3; end
    CLEAR_RED_1:   begin next_state = CLEAR_RED_2; end
    CLEAR_RED_2:   begin next_state = CLEAR_RED_3; end 
    CLEAR_RED_3:   begin if(!busy) next_state = CLEAR_GREEN_1; else next_state = CLEAR_RED_3; end
    CLEAR_GREEN_1: begin next_state = CLEAR_GREEN_2; end
    CLEAR_GREEN_2: begin next_state = CLEAR_GREEN_3; end 
    CLEAR_GREEN_3: begin if(!busy) next_state = CLEAR_BLUE_1; else next_state = CLEAR_GREEN_3; end 
    CLEAR_BLUE_1:  begin next_state = CLEAR_BLUE_2; end
    CLEAR_BLUE_2:  begin next_state = CLEAR_BLUE_3; end 
    CLEAR_BLUE_3:  begin if(!busy) next_state = SHOW_IMAGE_1; else next_state = CLEAR_BLUE_3; end
    SHOW_IMAGE_1:  begin next_state = SHOW_IMAGE_2; end
    SHOW_IMAGE_2:  begin next_state = SHOW_IMAGE_3; end
    SHOW_IMAGE_3:  begin if(!busy) next_state = SHOW_IMAGE_1; else next_state = SHOW_IMAGE_3; end
    default: begin next_state = IDLE; end
    endcase
end

// sub module declarations ---------------------------------
lcd_ctrl lcd_ctrl(
    .clk(clk), 
    .rstn(rstn), 
    .command(command), 
    .valid_in(valid_in),
    .busy(busy),
    .error(error),
    .fifo_rd_en(fifo_rd_en),
    .fifo_rd_data(color),
    .fifo_empty(1'b0),
    .rst_lcd(rst_lcd), 
    .scl_lcd(scl_lcd), 
    .sda_lcd(sda_lcd),
    .cs_lcd(cs_lcd), 
    .rs_lcd(rs_lcd),
    .led_lcd(led_lcd)
);   

endmodule
