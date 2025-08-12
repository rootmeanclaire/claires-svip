`timescale 1ns / 1ps

module uart #(
	// Can be 5-9 for compliance with spec
	parameter DATA_BITS = 8,
	// Data transmission rate, bits per second
	parameter BAUD = 9600,
	// System clock frequency in hertz
	parameter SYS_CLK = 12000000
)(
	input wire enable,
	input wire clk,
	// The data to transmit
	input wire[DATA_BITS-1:0] tx_input,
	// The write to output the UART signal
	output reg tx_wire,
	// Indicates whether the module is ready to receive new data
	output reg ready
);
	// Clock for the output signal
	wire clk_uart;
	// Index of the bit in the transmission stream
	reg[3:0] i_bit;

	// Divide down the system clock to the right frequency
	clk_div #(
		.FREQ_IN(SYS_CLK),
		.FREQ_OUT(BAUD)
	) divider (
		.clk_in(clk),
		.clk_out(clk_uart)
	);

	initial begin
		// Idle high
		tx_wire <= 1;
		// Ready to transmit
		ready <= 1;
		// Transmission index at 0
		i_bit <= 0;
	end

	always @(posedge clk_uart) begin
		if (enable) begin
			// If ready to start a new transmission
			if (i_bit == 0 && ready) begin
				ready <= 0;
				i_bit <= 1;
				tx_wire <= 0;
			end
			// If transmission in progress
			else if (i_bit > 0 && ~ready) begin
				// If data
				if (i_bit < DATA_BITS - 1) begin
					tx_wire = tx_input[i_bit];
					i_bit = i_bit + 1;
				end
				// If stop bit
				else begin
					tx_wire <= 1;
					ready <= 1;
				end
			end
			// Else: A tranmission is being asked for, but must wait for the
			// current transmission to finish
		end
	end
endmodule
