module debouncer(
	input clk, 
	input button,  
 	output reg button_debounced 
);

reg button_sync_0;
always @(posedge clk) button_sync_0 <= button; 
reg button_sync_1;
always @(posedge clk) button_sync_1 <= button_sync_0;

// Debounce the switch
reg [15:0] button_cnt;
always @(posedge clk)
if(button_debounced==button_sync_1)
	button_cnt <= 0;
else
begin
	button_cnt <= button_cnt + 1'b1;  
	if(button_cnt == 16'hffff) button_debounced <= ~button_debounced;  
end
endmodule
