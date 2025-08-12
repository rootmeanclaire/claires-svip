`timescale 1ns / 1ps

module clk_div_tb;
	// Inputs
	reg clk_in = 0;
	// Outputs
	wire clk_out;
	// Test Variables
	integer suite = 0;
	integer test = 0;
	integer counter = 0;
	integer expected;
	integer cycles;

	// Geneate log file
	initial begin
		$dumpfile("clk_div_log.vcd");
		$dumpvars(0);
	end

	// Initialize unit under test
	clk_div #(
		// 1 / 50 ns = 20 MHz
		.FREQ_IN(20000000),
		// 1 / 1 ms = 10 MHz
		.FREQ_OUT(10000000)
	) uut(
		.clk_in(clk_in),
		.clk_out(clk_out)
	);

	always @(posedge clk_out) begin
		counter = counter + 1;
	end

	initial begin
		suite++;
		test++;
		cycles = 100;
		$write("=== TEST SUITE %0d: 2x Division ===\n", suite);
		$write("\tTest %0d.%0d: 100 cycles @ 20 Mhz...", suite, test);
		counter = 0;
		expected = cycles / 2;

		// Generate input clock
		// Cycles multiplied by 2 because each iteration is half of a period
		for (integer i = 0; i < 2*cycles; i++) begin
			// Two passes to complete one full cycle
			clk_in = ~clk_in;
			// 1 / (2 * 25) ns = 20 MHz
			#25;
		end

		if (counter === expected) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected %0d, Got %0d)\n", expected, counter);
		end
	end
endmodule
