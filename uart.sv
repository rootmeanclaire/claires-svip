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
	// Set high when the contents of the input register are ready to be sent
	// Cleared automatically when transmission begins
	input wire new_data,
	// The write to output the UART signal
	output reg tx_wire,
	// Indicates whether the module is ready to receive new data
	output wire ready
);
	// Clock for the output signal
	wire clk_uart;
	// Index of the bit in the transmission stream
	reg[3:0] i_bit;
	enum {
		// Not transmitting, ready to begin transmission
		IDLE,
		// Begin transmission
		START,
		// Send data bits
		DATA,
		// End transmission
		STOP
	} state;

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
		// Transmission index at 0
		i_bit <= 0;
	end

	always @(posedge clk_uart && new_data) begin
		state <= START;
	end

	always @(posedge clk_uart) begin
		case (state)
			START: begin
				state <= DATA;
				// Send start bit
				tx_wire <= 0;
				// Set bit position to LSB, first data bit
				i_bit <= 0;
			end
			DATA: begin
				// Write data bit onto the transmission line
				tx_wire = tx_input[i_bit];
				// Queue up index to next bit
				i_bit++;
				// All data bits transmitted
				if (i_bit == DATA_BITS) state = STOP;
			end
			STOP: begin
				state <= IDLE;
				tx_wire <= 1;
			end
		endcase
	end

	assign ready = (state == IDLE);
endmodule
