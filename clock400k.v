module clock400k (

	input clock5, // System clock
	output clock400k

);

wire TC_out; // Count Complete
reg reg400k;
reg [2:0] Dn;
reg CEP;
reg PE_n;
reg [2:0] currentState;
reg [2:0] nextState;
wire [2:0] Qn_out;

variableCounter #(3) count0 (

	.CEP(CEP), // Count enable
	.PE_n(PE_n), // Parallel load enable
	.Dn(Dn), // Parallel load value
	.clock50(clock5), // System clock
	
	.Qn_out(Qn_out), // Current count value
	.TC_out(TC_out) // Count Complete

);

parameter resetOn = 3'b000;
parameter clockOff = 3'b001;
parameter clockOn = 3'b010;
parameter set = 3'b011;
parameter resetOff = 3'b100;


always @(posedge(clock5))
	begin : stateMemory
		currentState <= nextState;
	end

always @(posedge(clock5),posedge(TC_out))
	begin : nextStateLogic
	
		case(currentState)
			set:
				begin
					nextState = clockOff;
				end

			resetOff:
				begin
					nextState = clockOff;
				end
				
			resetOn:
				begin
					nextState = clockOn;
				end
				
			clockOn:
				begin
					if (TC_out == 1'b1)
						nextState = resetOff;
					else
						nextState = clockOn;
				end
				
			clockOff:
				begin
					if (TC_out == 1'b1)
						nextState = resetOn;
					else
						nextState = clockOff;
				end
				
			default:
				begin
					nextState = set;
				end
endcase
end

always @(posedge(clock5),posedge(TC_out))
	begin : outputLogic
		
		case(currentState)
			set:
				begin
					Dn = 3'b001;
					CEP = 0;
					PE_n = 0;
					reg400k = 0;
				end
		
			resetOff:
				begin
					Dn = 3'b001;
					CEP = 0;
					PE_n = 0;
					reg400k = 0;

				end
			
			resetOn:
				begin
					Dn = 3'b001;
					CEP = 0;
					PE_n = 0;
					reg400k = 1;
				end
			
			clockOff:
				begin
					Dn = 3'b001;
					CEP = 1;
					PE_n = 1;
					reg400k = 0;
				end
				
			clockOn:
				begin
					Dn = 3'b001;
					CEP = 1;
					PE_n = 1;
					reg400k = 1;
				end
				
			default:
				begin
					Dn = 3'b001;
					CEP = 0;
					PE_n = 0;
					reg400k = 0;
				end
endcase
end

assign clock400k = reg400k;


endmodule
