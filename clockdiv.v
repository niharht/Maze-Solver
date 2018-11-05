`timescale 1ns / 1ps
module clockdiv(
	input wire clk,		//master clock: 50MHz
	input wire clr,		//asynchronous reset
	output wire dclk,		//pixel clock: 25MHz
	output wire segclk,	//7-segment clock: 381.47Hz
	output reg clk_player,
	output reg clk_moving_obs
	);

reg [31:0] a;  //1hz
reg [31:0] b;

// 17-bit counter variable
reg [16:0] q;

// Clock divider --
// Each bit in q is a clock signal that is
// only a fraction of the master clock.
always @(posedge clk or posedge clr)
begin
	// reset condition
	if (clr == 1)
		q <= 0;
	// increment counter by one
	else
		q <= q + 1;
end

//1Hz clock
always @(posedge clk or posedge clr)
begin
	if(clr == 1)
	begin
		clk_player <= 0;
		a <= 0;
	end

	else if( a == 'd50000000 -1)
	begin
		clk_player <= 1;
		a <= 0;
	end

	else
	begin
		clk_player <= 0;
		a <= a + 1;
	end

end

//Hz clock
always @(posedge clk or posedge clr)
begin
	if(clr == 1)
	begin
		clk_moving_obs <= 0;
		b <= 0;
	end

	else if( b == 'd250000000 -1)
	begin
		clk_moving_obs <= 1;
		b <= 0;
	end

	else
	begin
		clk_moving_obs <= 0;
		b <= b + 1;
	end

end

// 50Mhz ÷ 2^17 = 381.47Hz
assign segclk = q[16];

// 50Mhz ÷ 2^1 = 25MHz
assign dclk = q[1];

endmodule