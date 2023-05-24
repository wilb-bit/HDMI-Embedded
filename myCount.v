
module myCount(CEP, PE_n, Dn, clock50, Qn_out, TC_out);

parameter counterwidth = 5; //specify the size/duration of counter
parameter countFinish = 25;
//parameter offset = 0;

	input CEP;// Count enable
	input PE_n; // Parallel load enable
	input [counterwidth-1:0] Dn; // Parallel load value
	input clock50; // System clock
	output [counterwidth-1:0] Qn_out; // Current count value
	output TC_out; // Count Complete
	reg regTC;


// Rather than using a 'state machine' approach, using arithmetic operations
reg  [counterwidth-1:0] counterValue;

always @(posedge(clock50), negedge(PE_n))
	begin
		// First setup the reset characteristics
		if(PE_n == 1'b0)
			begin
				// Preload functionality.
				counterValue[counterwidth-1:0] = Dn[counterwidth-1:0];
				regTC = 0;
			end
		else if(CEP == 1'b1)
			begin
				// The count is active, so check to
				// see whether it has expired.
				if(counterValue == countFinish)
					begin
						counterValue = 0;
						regTC = 1;
					end
				else
					begin
						counterValue = counterValue + 1'b1;
						regTC = 0;
					end
			end
		else
			begin
				// Hold condition.
			counterValue = counterValue;
			regTC = regTC;
			end
	end
	
// Final assignment
assign Qn_out = counterValue;
assign TC_out = regTC;
endmodule
