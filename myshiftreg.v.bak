module myshiftreg(reset_n, loadData, shiftEnabled, dataBus, shiftClk, shiftComplete, shiftMSB);
	
	parameter bitLength = 8; // Default width
	input reset_n; // Active low reset.
	input loadData; // Active high data load.
	input shiftEnabled;
	input [bitLength - 1:0] dataBus; // Input data bus,
	input shiftClk; // Input clock.
	
	output reg shiftComplete; // Shift complete flag
	output shiftMSB; // LSB output
	
	reg [bitLength - 1:0] shiftValue;
	integer shiftCounter;
	
	
	// Set the LSB to be output.
	assign shiftMSB = shiftValue[7];
	
	
	// Set an always block to utilise the main system clock.
	always @(negedge(shiftClk))
	begin
		// Create the reset logic
		if(reset_n == 1'b0)
			begin
				shiftValue <= 8'b00000000;
				shiftCounter <= 0;
				shiftComplete <= 1'b0;
			end
		else if(loadData == 1'b1)
			begin
				shiftValue <= dataBus;
				shiftCounter <= (bitLength - 1'b1);
				shiftComplete <= 1'b0;
			end
		else if ((shiftEnabled == 1'b1) && (shiftComplete == 1'b0))
			begin
				shiftValue <= shiftValue << 1'b1;
				shiftCounter <= shiftCounter - 1'b1;
				// Check to see whether the count is complete
				if(shiftCounter == 1'b0)
				shiftComplete <= 1'b1;
			end
		else
			begin
				// Latched condition
				shiftValue <= shiftValue;
				// Check to see whether the count is complete
				if(shiftCounter == 1'b0)
				shiftComplete <= 1'b1;
			end
	end
endmodule
