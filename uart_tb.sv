`timescale 1ns / 1ps

module uart_tb #(
	parameter DATA_BITS = 8
);
	// Inputs
	reg enable;
	reg clk;
	reg[DATA_BITS-1:0] tx_input;
	reg new_data;
	// Outputs
	wire tx_wire;
	wire ready;
	// Test Variables
	integer suite = 0;
	integer test = 0;
	integer passed = 0;
	integer failed = 0;
	reg[(DATA_BITS+2)-1:0] expected;
	reg[(DATA_BITS+2)-1:0] actual;

	// Geneate log file
	initial begin
		$dumpfile("uart_tb.vcd");
		$dumpvars(0);
	end

	// Initialize unit under test
	uart #(
		.DATA_BITS(DATA_BITS),
		.BAUD(9600),
		.SYS_CLK(12000000)
	) uut(
		.enable(enable),
		.clk(clk),
		.tx_input(tx_input),
		.new_data(new_data),
		.tx_wire(tx_wire),
		.ready(ready)
	);

	// Generate system clock
	// 1 / 12 MHz = 83 ns
	always begin
		clk = 0;
		#42;
		clk = 1;
		#41;
	end

	initial begin
		suite++;
		test++;
		$write("=== TEST SUITE %0d: BASICS ===\n", suite);
		$write("\tTest %0d.%0d: No Input...", suite, test);
		tx_input = 'hx;
		new_data = 0;
		expected = 10'b1111111111;

		#10;
		for (integer i = 0; i < DATA_BITS+2; i++) begin
			// 1 / 9600 baud = 104167 ns
			actual[i] = tx_wire;
			#104167;
		end
		new_data = 0;
		#10;

		if (actual === expected) begin
			$write("Passed!\n");
			passed++;
		end else begin
			$write("Failed! (Expected %b, Got %b)\n", expected, actual);
			failed++;
		end

		test++;
		$write("=== TEST SUITE %0d: BASICS ===\n", suite);
		$write("\tTest %0d.%0d: Send 0x00...", suite, test);
		tx_input = 'h00;
		new_data = 1;
		expected = 10'b0000000000;

		#10;
		for (integer i = 0; i < DATA_BITS+2; i++) begin
			// 1 / 9600 baud = 104167 ns
			actual[i] = tx_wire;
			#104167;
		end
		new_data = 0;

		if (actual === expected) begin
			$write("Passed!\n");
			passed++;
		end else begin
			$write("Failed! (Expected %b, Got %b)\n", expected, actual);
			failed++;
		end

		test++;
		$write("=== TEST SUITE %0d: BASICS ===\n", suite);
		$write("\tTest %0d.%0d: Send 0xA5...", suite, test);
		tx_input = 'hA5;
		new_data = 1;
		expected = 10'b0101001010;

		#10;
		for (integer i = 0; i < DATA_BITS+2; i++) begin
			// 1 / 9600 baud = 104167 ns
			actual[i] = tx_wire;
			#104167;
		end
		new_data = 0;

		if (actual === expected) begin
			$write("Passed!\n");
			passed++;
		end else begin
			$write("Failed! (Expected %b, Got %b)\n", expected, actual);
			failed++;
		end

		$write("\n=== ALL TESTS COMPLETED ===\n");
		$write("Passed %0d / %0d tests\n", passed, passed + failed);
		$finish;
	end
endmodule
