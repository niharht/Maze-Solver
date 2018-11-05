`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:25 03/19/2013 
// Design Name: 
// Module Name:    NERP_demo_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module maze(
	input wire clk,			//master clock = 50MHz
	input wire clr,			//right-most pushbutton for reset
	input wire right,
	input wire left,
	input wire up,
	input wire down,
	output wire finish_led,
	output wire [6:0] a_to_g,	//7-segment display LEDs
	output wire [3:0] an,	//7-segment display anode enable
	output wire dp,			//7-segment display decimal point
	output wire [2:0] red,	//red vga output - 3 bits
	output wire [2:0] green,//green vga output - 3 bits
	output wire [1:0] blue,	//blue vga output - 2 bits
	output wire hsync,		//horizontal sync out
	output wire vsync			//vertical sync out
	);

// 7-segment clock interconnect
wire segclk;

// VGA display clock interconnect
wire dclk;
wire clk_player;
wire clk_moving_obs;
//steps
wire  [15:0] steps;
wire [15:0] seg7_rep;

//debounced buttons
wire up_debounced, down_debounced, right_debounced, left_debounced;

debouncer d_up(.clk(clk), .button(up), .button_debounced(up_debounced));
debouncer d_down(.clk(clk), .button(down), .button_debounced(down_debounced));
debouncer d_right(.clk(clk), .button(right), .button_debounced(right_debounced));
debouncer d_left(.clk(clk), .button(left),.button_debounced(left_debounced));

// disable the 7-segment decimal points
assign dp = 1;

// generate 7-segment clock & display clock
clockdiv U1(
	.clk(clk),
	.clr(clr),
	.segclk(segclk),
	.dclk(dclk),
	.clk_player(clk_player),
	.clk_moving_obs(clk_moving_obs)
	);
    

// VGA controller
vga U3(
	.clk(clk),
	.dclk(dclk),
	.clk_player(clk_player),
	.clk_moving_obs(clk_moving_obs),
	.clr(clr),
	.left(left_debounced),
	.right(right_debounced),
	.up(up_debounced),
	.down(down_debounced),
	.finish_led(finish_led),
	.hsync(hsync),
	.vsync(vsync),
	.steps(steps),
	.red(red),
	.green(green),
	.blue(blue)
	);

step_to_seg7 S(.clk(clk), .steps(steps), .seg7_rep(seg7_rep));
seg7decimal D(.x(seg7_rep),
    .clk(clk),
    .clr(clr),
    .a_to_g(a_to_g),
    .an(an),
    .dp(dp)); 

endmodule