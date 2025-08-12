`timescale 1ns / 1ps

module clk_div #(
	parameter FREQ_IN=12000000,
	// Assumed to be lower than FREQ_IN
	parameter FREQ_OUT=1
)(
	input wire clk_in,
	output reg clk_out
);
	reg[32-1:0] counter;

	initial begin
		counter <= 0;
		clk_out <= 0;
	end

	always @(posedge clk_in) begin
		counter = counter + 1;
		// Doubled because this triggers an XOR on a posedge
		// Prevents rise from being too short
		if (counter == FREQ_IN / (2 * FREQ_OUT)) begin
			clk_out <= ~clk_out;
			counter <= 0;
		end
	end
endmodule
