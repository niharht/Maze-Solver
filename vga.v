`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:38 03/19/2013 
// Design Name: 
// Module Name:    vga640x480 
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
 module vga(
	input wire clk,
	input wire dclk,			//pixel clock: 25MHz
	input wire clk_player,
	input wire clk_moving_obs,
	input wire clr,			//asynchronous reset
	input wire left,
	input wire right,
	input wire up,
	input wire down,
	output wire finish_led,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output wire [15:0] steps,
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue	//blue vga output
	
	);

//
wire [3:0] player_pos_x;
wire [3:0] player_pos_y;
wire moving_obs_show;

//calling game_logic to get y_pos, x_pos
game_logic game(
	.clk(clk), 
	.clk_player(clk_player), 
	.clk_moving_obs(clk_moving_obs), 
	.reset(clr), 
	.right(right), 
	.left(left), 
	.up(up), 
	.down(down),
	.player_pos_x(player_pos_x),
	.player_pos_y(player_pos_y), 
	.steps(steps), 
	.moving_obs_show(moving_obs_show),
	.finish_led(finish_led));

//value corresponding to vga pixel for v_pos, h_pos
wire [15:0] h_pos; 
wire [15:0] v_pos;
assign  h_pos = 20 + 40*player_pos_x +hbp;
assign  v_pos = 20 + 40*player_pos_y +vbp;


// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;





// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge dclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =

always @(*)
begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		
		
		if( hc>=hbp && hc<=(hbp+40))   //left border
		begin
			red=3'b000;
			green=3'b000;
			blue=2'b11;
		end
		
		else if ( (hc >= (hbp+600) && hc <(hbp+640)) )   //right border
		begin
			red=3'b000;
			green=3'b000;
			blue=2'b11;
		end 
		
		else if( hc>=(hbp+40) && hc<(hbp+600) && (vc<vbp+40 || vc>=vfp-40))  //top and bottom borders
		begin
			red=3'b000;
			green=3'b000;
			blue=2'b11;
		end
		
		//next else if blocks are for path in white
		
		//starting point= green
		else if ( ( hc>(hbp+40) && hc<(hbp+80)) && (vc>= vbp +40 && vc<=vbp +80) && !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
		//path part 1
		else if ( ( hc>=(hbp+80) && hc<=(hbp+240)) && (vc>=vbp+40 && vc<=vbp+80) && !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10) )
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//path part 2
		else if( ( hc>=(hbp+200) && hc<=(hbp+240)) && ( vc>vbp+80 && vc<vbp+240) && !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//path part 3
		else if (( hc>(hbp+240) && hc<(hbp+400)) && (vc>= vbp+120 && vc<vbp+160) && !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//path part 4
		else if (( hc>(hbp+240) && hc<(hbp+400)) && (vc> vbp+200 && vc<vbp+240) && !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//path part 5
		else if ( ( hc>=(hbp+120) && hc<(hbp+240)) && (vc> vbp +200 && vc<vbp +240) && !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//path part 6
		else if ( ( hc>=(hbp+120) && hc<=(hbp+160)) && (vc> vbp +200 && vc<=vbp +360) && !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//static obstacle number 1
		else if ( ( hc>=(hbp+200) && hc<=(hbp+240)) && (vc>= vbp +240 && vc<=vbp +280)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b000;
			blue = 2'b00;
		end
		
		//path 7
		else if ( ( hc>=(hbp+200) && hc<=(hbp+240)) && (vc>vbp +280 && vc<=vbp +320)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//path part 8
		else if ( ( hc>=(hbp+160) && hc<=(hbp+320)) && (vc>= vbp +320 && vc<=vbp +360)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//path part 9
		else if ( ( hc>=(hbp+280) && hc<=(hbp+320)) && (vc>= vbp +360 && vc<=vbp +480)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//path part 10
		else if ( ( hc>=(hbp+320) && hc<(hbp+480)) && (vc>= vbp +400 && vc<=vbp +440)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//moving obstacle
		else if( ( hc>=hbp+480 && hc<hbp+520) && ((vc>= vbp +400 && vc<=vbp +440)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10)))
		begin
			if(moving_obs_show)
			begin
				red = 3'b111;
				green = 3'b000;
				blue = 2'b00;
			end
			else
			begin
				red = 3'b111;
				green = 3'b111;
				blue = 2'b11;
			end
		end
		
		//path 13
		else if ( ( hc>=(hbp+520) && hc<=(hbp+560)) && (vc>= vbp +400 && vc<=vbp +440)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//stable obstacle 2
		else if ( ( hc>=(hbp+360) && hc<=(hbp+400)) && (vc> vbp +280 && vc<=vbp +320)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b000;
			blue = 2'b00;
		end
		
		
		//path part 11
		else if ( ( hc>=(hbp+360) && hc<=(hbp+400)) && (vc>= vbp +120 && vc<=vbp +280)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//stable obstacle 2
		else if ( ( hc>=(hbp+360) && hc<=(hbp+400)) && (vc> vbp +280 && vc<=vbp +320)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b000;
			blue = 2'b00;
		end
		
		//path part 12
		else if ( ( hc>=(hbp+360) && hc<=(hbp+400)) && (vc> vbp +320 && vc<vbp +400) && !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		
		//ending point
		else if ( ( hc>=(hbp+560) && hc<(hbp+600)) && (vc>= vbp +400 && vc<=vbp +440)&& !(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10))
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
		
		//if block for where player is
		else if(hc>=h_pos-10 &&hc<=h_pos+10 && vc>=v_pos-10 &&vc<=v_pos+10)
		begin
			red = 3'b111;
			green = 3'b000;
			blue = 2'b11;
		end
		
		else
		begin
			red=3'b000;
			green=3'b000;
			blue=2'b00;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
	//$display("h position is %d",h_pos);
	//$display("v position is %d",v_pos);
end
 

endmodule