`timescale 1ns / 1ps

 module game_logic( clk, clk_player, clk_moving_obs, reset, right, left, up, down, player_pos_x, player_pos_y, steps, moving_obs_show, finish_led
    );
	
	// inputs
	input wire clk, clk_player, clk_moving_obs, reset, right, left, up, down;

	// outputs
	output reg  [3:0]  player_pos_x;
	output reg  [3:0]  player_pos_y;
	output reg  [15:0] steps;
	output reg moving_obs_show;
  
	// constants for state machine
	parameter RIGHT  = 3'b000;
	parameter LEFT   = 3'b001;
	parameter UP 	  = 3'b010;
	parameter DOWN   = 3'b011;
	parameter NONE   = 3'b100;
	parameter RESET  = 3'b101;
	parameter FINISH = 3'b110;

	// obstacle detection flag
	reg collision_flag;

	// finish state variables
	output reg finish_led;
	reg [31:0] finish_timer;


	// Maze and Obstacles
	/*parameter [15:0] maze [11:0] =
	{ 
		15'b1111111111111111,
		15'b1000001111111111,
		15'b1111101111111111,
		15'b1111100000111111,											 
		15'b1111101110111111,										 
		15'b1110000000111111,											 		
		15'b1110101110111111,										 
		15'b1110101110111111,										 
		15'b1110000010111111,										 
		15'b1111111010111111,										 
		15'b1111111000000001,											 
		15'b1111111111111111
	};*/
	
	parameter [11:0] maze [14:0] =
	{
		12'b111111111111,
		12'b101111111111,
		12'b101111111111,
		12'b101111111111,
		12'b101111111111,
		12'b101111111111,
		12'b100000000111,
		12'b101111010111,
		12'b100011010111,
		12'b111011010111,
		12'b111000000001,
		12'b111011011101,
		12'b111000011101,
		12'b111111111101,
		12'b111111111101,
		12'b111111111111
	};
	
	/*
	parameter STATIC_1_OBS_X 	= 4'b0101;
	parameter STATIC_1_OBS_Y 	= 4'b0110;
	parameter STATIC_2_OBS_X 	= 4'b1001;
	parameter STATIC_2_OBS_Y 	= 4'b0111;
	parameter MOVING_OBS_X 		= 4'b1100;
	parameter MOVING_OBS_Y 		= 4'b1010;
	parameter FINISH_POSITION_X = 4'b1110;
	parameter FINISH_POSITION_Y = 4'b1010;
	*/

	
	// state machine regs
	reg [2:0] curr_state;
	reg [2:0] next_state;

	
	// always block to know when to update curr_state
	always @ (posedge clk)
	begin
		curr_state <= next_state;
	end
	
	// always block state machine
	always @ (posedge clk_player or posedge reset)
			
	begin
		// Reset machine if reset button is pressed	
		if (reset || curr_state == RESET)
		begin
			steps <= 4'b0000;
			player_pos_x <= 4'b0001;
			player_pos_y <= 4'b0001;
			collision_flag <= 1'b0;
			finish_led <= 1'b0;
			finish_timer <= 'd0;
			next_state <= NONE;
		end
		
		// State Machine
		else
		begin
			case (curr_state)
				RIGHT:
					begin
						// Collision with obstacle
						if ((((player_pos_x + 4'b0001) == 4'b0101) && (player_pos_y == 4'b0110)) ||
							(((player_pos_x + 4'b0001) == 4'b1001) && (player_pos_y == 4'b0111)) ||
							((moving_obs_show == 1'b1 && (player_pos_x + 4'b0001) == 4'b1100) && (player_pos_y == 4'b1010)))
						begin
							collision_flag <= 1'b1;
						end
						
						// Move to new position as long as there is no wall there
						else if (player_pos_x < 4'b1111 && maze[player_pos_x + 4'b0001][player_pos_y] == 1'b0)
						begin
							player_pos_x <= player_pos_x + 4'b0001;
							steps <= steps + 1;
						end

						else
						begin
							player_pos_x <= player_pos_x;
						end
					end
				LEFT:
					begin
						// Collision with obstacle
						if ((((player_pos_x - 4'b0001) == 4'b0101) && (player_pos_y == 4'b0110)) ||
							(((player_pos_x - 4'b0001) == 4'b1001) && (player_pos_y == 4'b0111)) ||
							((moving_obs_show == 1'b1 && (player_pos_x - 4'b0001) == 4'b1100) && (player_pos_y == 4'b1010)))
						begin
							collision_flag <= 1'b1;
						end
						
						// Move to new position as long as there is no wall there
						else if (player_pos_x > 4'b0000 && maze[player_pos_x - 4'b0001][player_pos_y] == 1'b0)
						begin
							player_pos_x <= player_pos_x - 4'b0001;
							steps <= steps + 1;
						end
						
						else
						begin
							player_pos_x <= player_pos_x;
						end

					end
				DOWN:
					begin
						// Collision with obstacle
						if ((((player_pos_x) == 4'b0101) && (player_pos_y + 4'b0001 == 4'b0110)) ||
							(((player_pos_x) == 4'b1001) && (player_pos_y + 4'b0001 == 4'b0111)) ||
							((moving_obs_show == 1'b1 && (player_pos_x == 4'b1100) && (player_pos_y  + 4'b0001 == 4'b1010))))
						begin
							collision_flag <= 1'b1;
						end
						
						// Move to new position as long as there is no wall there
						else if (player_pos_y < 4'b1011 && maze[player_pos_x][player_pos_y  + 4'b0001] == 1'b0)
						begin
							player_pos_y <= player_pos_y + 4'b0001;
							steps <= steps + 1;
						end

						else
						begin
							player_pos_y <= player_pos_y;
						end
					end
				UP:
					begin
						// Collision with obstacle
						if ((((player_pos_x) == 4'b0101) && (player_pos_y - 4'b0001 == 4'b0110)) ||
							(((player_pos_x) == 4'b1001) && (player_pos_y - 4'b0001 == 4'b0111)) ||
							((moving_obs_show == 1'b1 && (player_pos_x == 4'b1100) && (player_pos_y - 4'b0001 == 4'b1010))))
						begin
							collision_flag <= 1'b1;
						end
						
						// Move to new position as long as there is no wall there
						else if (player_pos_y > 4'b0000 && maze[player_pos_x][player_pos_y - 4'b0001] == 1'b0)
						begin
							player_pos_y <= player_pos_y - 4'b0001;
							steps <= steps + 1;
						end

						else
						begin
							player_pos_y <= player_pos_y;
						end
					end
				NONE: 
				begin
					if (moving_obs_show == 1'b1 && player_pos_x == 4'b1100 && player_pos_y == 4'b1010)
						collision_flag <= 1'b1;
				end

				FINISH:
				begin
					// after five seconds
					if (finish_timer >= 'd20 -1)
					begin
						next_state <= RESET;
					end

					// not five seconds yet
					else
					begin
						finish_led <= 1'b1;
						finish_timer <= finish_timer + 1'b1;
						collision_flag <= 1'b1;
					end

				end
			endcase 

			// Next State
			if (collision_flag)
			begin
				next_state <= RESET;
			end

			else if (player_pos_x == 4'b1110 && player_pos_y == 4'b1010 && finish_led == 1'b0)
			begin
				next_state <= FINISH;
			end

			else if (right)
			begin
				next_state <= RIGHT;
			end

			else if (left)
			begin
				next_state <= LEFT;
			end

			else if (up)
			begin
				next_state <= UP;
			end

			else if (down)
			begin
				next_state <= DOWN;
			end

			else
			begin
				next_state <= NONE;
			end

		end
		//$display("y position is %d",player_pos_y);
		//$display("x position is %d",player_pos_x);
		//$display("steps are is %d",steps);
	end

	always @ (posedge clk_moving_obs or posedge reset)
	begin
		if (reset)
			moving_obs_show <= 1'b0;
		else
			moving_obs_show <= ~moving_obs_show;
	end


endmodule