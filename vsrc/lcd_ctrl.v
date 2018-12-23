//////////////////////////////////////////////////////////////////////////////////
// Company: Private
// Engineer: JunkaiZhan
// 
// Create Date: 2018-12-20
// Design Name: Image Recognition
// Module Name: lcd controller with spi interface
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

/* **************************************************

commands:
1: initialization 
2: clear - red
3: clear - green
4: clear - blue
5: show image

************************************************** */

module lcd_ctrl(
    clk, rstn, 
    command, valid_in, busy, error, // control 
    fifo_rd_en, fifo_rd_data, fifo_empty, // fifo interface
    rst_lcd, scl_lcd, sda_lcd,
    cs_lcd, rs_lcd, led_lcd
);

// Parameter Declarations -------------------------------------
parameter COMM_WIDTH = 3;
parameter FRAME_SIZE_WIDTH = 21;
parameter DATA_WIDTH = 8;

// command
localparam INITIAL     = 3'd1;
localparam CLEAR_RED   = 3'd2;
localparam CLEAR_GREEN = 3'd3;
localparam CLEAR_BLUE  = 3'd4;
localparam SHOW_IMAGE  = 3'd5;

localparam STATE_WIDTH = 2;
localparam IDLE = 2'b00;
localparam TRA1 = 2'b01;
localparam TRA2 = 2'b10;
localparam ERROR = 2'b11;

parameter INITIAL_DONE_NUM = 85;
parameter FLASH_DONE_NUM = 153611;

// Interface Declarations -------------------------------------
input clk, rstn;

input [COMM_WIDTH - 1 : 0] command;
input valid_in;
output busy;
output error;

output fifo_rd_en;
input [DATA_WIDTH - 1 : 0] fifo_rd_data;
input fifo_empty;

output rst_lcd, scl_lcd, sda_lcd;
output cs_lcd, rs_lcd, led_lcd;

// Reg and Wire Declarations -----------------------------------

// interface
reg busy;
reg fifo_rd_en;
assign error = state == ERROR;

// sub module connection
wire index_or_data;
reg valid_driver;
wire [DATA_WIDTH - 1 : 0] data_driver;
wire done_driver;

reg [DATA_WIDTH : 0] data_temp;
assign index_or_data = data_temp[DATA_WIDTH];
assign data_driver = data_temp[DATA_WIDTH - 1 : 0];

// clear sequence
wire [DATA_WIDTH : 0] clear_seq [0 : 16];
assign clear_seq[0]  = 9'h02A;
assign clear_seq[1]  = 9'h100; // X start
assign clear_seq[2]  = 9'h100; 
assign clear_seq[3]  = 9'h100; // X end
assign clear_seq[4]  = 9'h1EF;
assign clear_seq[5]  = 9'h02B; 
assign clear_seq[6]  = 9'h100; // Y start
assign clear_seq[7]  = 9'h100;
assign clear_seq[8]  = 9'h101; // Y end
assign clear_seq[9]  = 9'h13F;
assign clear_seq[10] = 9'h02C; 
assign clear_seq[11] = 9'h1F8; // RED
assign clear_seq[12] = 9'h100;
assign clear_seq[13] = 9'h107; // GREEN
assign clear_seq[14] = 9'h1E0;
assign clear_seq[15] = 9'h100; // BLUE
assign clear_seq[16] = 9'h11F;

// initialization sequence
wire [DATA_WIDTH : 0] init_seq [0 : (INITIAL_DONE_NUM - 1)];
assign init_seq[0]  = 9'h011;
assign init_seq[1]  = 9'h100;
assign init_seq[2]  = 9'h0CF;
assign init_seq[3]  = 9'h100;
assign init_seq[4]  = 9'h1C1;
assign init_seq[5]  = 9'h130;
assign init_seq[6]  = 9'h0ED;
assign init_seq[7]  = 9'h164;
assign init_seq[8]  = 9'h103;
assign init_seq[9]  = 9'h112;
assign init_seq[10] = 9'h181;
assign init_seq[11] = 9'h0E8;
assign init_seq[12] = 9'h185;
assign init_seq[13] = 9'h111;
assign init_seq[14] = 9'h178;
assign init_seq[15] = 9'h0F6;
assign init_seq[16] = 9'h101;
assign init_seq[17] = 9'h130;
assign init_seq[18] = 9'h100;
assign init_seq[19] = 9'h0CB;
assign init_seq[20] = 9'h139;
assign init_seq[21] = 9'h12C;
assign init_seq[22] = 9'h100;
assign init_seq[23] = 9'h134;
assign init_seq[24] = 9'h105;
assign init_seq[25] = 9'h0F7;
assign init_seq[26] = 9'h120;
assign init_seq[27] = 9'h0EA;
assign init_seq[28] = 9'h100;
assign init_seq[29] = 9'h100;
assign init_seq[30] = 9'h0C0;
assign init_seq[31] = 9'h120;
assign init_seq[32] = 9'h0C1;
assign init_seq[33] = 9'h111;
assign init_seq[34] = 9'h0C5;
assign init_seq[35] = 9'h131;
assign init_seq[36] = 9'h13C;
assign init_seq[37] = 9'h0C7;
assign init_seq[38] = 9'h1A9;
assign init_seq[39] = 9'h03A;
assign init_seq[40] = 9'h155;
assign init_seq[41] = 9'h1E8;
assign init_seq[42] = 9'h0B1;
assign init_seq[43] = 9'h100;
assign init_seq[44] = 9'h118;
assign init_seq[45] = 9'h0B4;
assign init_seq[46] = 9'h100;
assign init_seq[47] = 9'h100;
assign init_seq[48] = 9'h0F2;
assign init_seq[49] = 9'h100;
assign init_seq[50] = 9'h026;
assign init_seq[51] = 9'h101;
assign init_seq[52] = 9'h0E0;
assign init_seq[53] = 9'h10F;
assign init_seq[54] = 9'h117;
assign init_seq[55] = 9'h114;
assign init_seq[56] = 9'h109;
assign init_seq[57] = 9'h10C;
assign init_seq[58] = 9'h106;
assign init_seq[59] = 9'h143;
assign init_seq[60] = 9'h175;
assign init_seq[61] = 9'h136;
assign init_seq[62] = 9'h108;
assign init_seq[63] = 9'h113;
assign init_seq[64] = 9'h105;
assign init_seq[65] = 9'h110;
assign init_seq[66] = 9'h10B;
assign init_seq[67] = 9'h108;
assign init_seq[68] = 9'h0E1;
assign init_seq[69] = 9'h100;
assign init_seq[70] = 9'h11F;
assign init_seq[71] = 9'h123;
assign init_seq[72] = 9'h103;
assign init_seq[73] = 9'h10E;
assign init_seq[74] = 9'h104;
assign init_seq[75] = 9'h139;
assign init_seq[76] = 9'h125;
assign init_seq[77] = 9'h14D;
assign init_seq[78] = 9'h106;
assign init_seq[79] = 9'h10D;
assign init_seq[80] = 9'h10B;
assign init_seq[81] = 9'h133;
assign init_seq[82] = 9'h137;
assign init_seq[83] = 9'h10F;
assign init_seq[84] = 9'h029;

// Logic -------------------------------------------------------
reg [STATE_WIDTH - 1 : 0] state;
reg [STATE_WIDTH - 1 : 0] next_state;

// buffer
reg [COMM_WIDTH -  1 : 0] command_r;
reg [FRAME_SIZE_WIDTH - 1 : 0] frame_size_r;

always @ (posedge clk or negedge rstn) begin
    if(!rstn) begin
        command_r <= 'b0;
        busy <= 1'b0;
    end else begin
        if(valid_in && !busy) begin
            command_r <= command;
            busy <= 1'b1;
        end else if(command_done || state == ERROR) begin 
            command_r <= 'b0;
            busy <= 1'b0;
        end
    end
end

// state machine

reg [17:0] seq_counter;

wire command_done;
assign command_done = (command_r == INITIAL) ? 
        ((seq_counter == INITIAL_DONE_NUM) && done_driver):
        ((seq_counter == FLASH_DONE_NUM) && done_driver);

always @ (posedge clk or negedge rstn) begin
    if(!rstn) state <= IDLE;
    else state <= next_state;
end

always @ (*) begin
    case(state)
    IDLE: begin
        if(busy) begin
            next_state = TRA1;
        end else begin 
            next_state = IDLE;
        end
    end
    TRA1: begin next_state = TRA2; end
    TRA2: begin 
        if(command_done) next_state = IDLE;
        else if(done_driver) begin
            if(command_r == SHOW_IMAGE && fifo_empty) next_state = ERROR;
            else next_state = TRA1;
        end
        else next_state = TRA2;
    end
    ERROR: begin next_state = IDLE; end
    default: begin next_state = IDLE; end
    endcase
end

always @ (*) begin
    case(state)
    IDLE: begin
        valid_driver = 1'b0;
        fifo_rd_en = 1'b0;
    end
    TRA1: begin
        case(command_r) 
        INITIAL: begin
            valid_driver = 1'b1;
            data_temp = init_seq[index];
            fifo_rd_en = 0; 
        end
        CLEAR_RED, CLEAR_GREEN, CLEAR_BLUE: begin 
            valid_driver = 1'b1;
            data_temp = clear_seq[index]; 
            fifo_rd_en = 0; 
        end
        SHOW_IMAGE: begin
            valid_driver = 1'b1;
            data_temp = (index >= 11) ? {1'b1, fifo_rd_data} : clear_seq[index]; 
            fifo_rd_en = (index >= 11);
        end
        default: begin 
            valid_driver = 1'b0;
            data_temp = 'b0; 
            fifo_rd_en = 0; 
        end
        endcase
    end
    TRA2: begin
        valid_driver = 1'b0;
        fifo_rd_en = 1'b0;
    end
    ERROR: begin
        valid_driver = 1'b0;
        data_temp = 'b0; 
        fifo_rd_en = 0;
    end
    endcase
end

always @ (posedge clk or negedge rstn) begin
    if(!rstn) begin
        seq_counter <= 'b0;
    end else begin
        if(state == IDLE || command_done) begin
            seq_counter <= 'b0;
        end else if(command_r != INITIAL && seq_counter == FLASH_DONE_NUM) begin
            seq_counter <= FLASH_DONE_NUM;
        end else if(command == INITIAL && seq_counter == INITIAL_DONE_NUM) begin
            seq_counter <= INITIAL_DONE_NUM;
        end else if(state == TRA1) begin
            seq_counter <= seq_counter + 1'b1; 
        end
    end
end

reg [6:0] index; // range 0~127
always @ (posedge clk or negedge rstn) begin
    if(!rstn) index <= 'b0;
    else begin 
        if(state == IDLE || command_done) begin
            index <= 'b0;
        end else if(state == TRA1) begin
            if(command_r == SHOW_IMAGE && index == 11) index <= 11;
            else if(command_r == CLEAR_RED && index == 12) index <= 11;
            else if(command_r == CLEAR_GREEN && index == 10) index <= 13;
            else if(command_r == CLEAR_GREEN && index == 14) index <= 13;
            else if(command_r == CLEAR_BLUE && index == 10) index <= 15;
            else if(command_r == CLEAR_BLUE && index == 16) index <= 15;
            else index <= index + 1'b1;
        end
    end
end

// Sub Module --------------------------------------------------
lcd_driver lcd_driver(
    .clk(clk),
    .rstn(rstn),
    .index_or_data(index_or_data),
    .valid_in(valid_driver),
    .data_in(data_driver),
    .done(done_driver),
    .rst_lcd(rst_lcd),
    .scl_lcd(scl_lcd),
    .sda_lcd(sda_lcd),
    .cs_lcd(cs_lcd),
    .rs_lcd(rs_lcd),
    .led_lcd(led_lcd)
);

endmodule 
