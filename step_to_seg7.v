// CSM152A
//
// Carol Nihar Charlotte  
// 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module step_to_seg7(clk, steps, seg7_rep);
  
  input clk;
  input [15:0] steps;
  
  output reg [15:0] seg7_rep;
  
  always @ (posedge clk)
	begin
    seg7_rep[15:12] <= 4'b0000; // divide by 1000
    seg7_rep[11:8]  <= 4'b0000; // divide by 100
    seg7_rep[7:4] <= (steps / 4'b1010); // divide by 10
    seg7_rep[3:0]  <= (steps % 4'b1010); // modulo by 10
	end
endmodule
