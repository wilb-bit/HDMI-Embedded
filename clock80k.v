module clock80k (

	input clock8, // System clock
	output clock80k

);

wire TC_out; // Count Complete
reg reg80k;
reg [5:0] Dn;
reg CEP;
reg PE_n;
reg [2:0] currentState;
reg [2:0] nextState;
wire [5:0] Qn_out;

variableCounter #(6) count0 (

	.CEP(CEP), // Count enable
	.PE_n(PE_n), // Parallel load enable
	.Dn(Dn), // Parallel load value
	.clock50(clock8), // System clock
	
	.Qn_out(Qn_out), // Current count value
	.TC_out(TC_out) // Count Complete

);

parameter resetOn = 3'b000;
parameter clockOff = 3'b001;
parameter clockOn = 3'b010;
parameter set = 3'b011;
parameter resetOff = 3'b100;


always @(posedge(clock8))
	begin : stateMemory
		currentState <= nextState;
	end

always @(posedge(clock8),posedge(TC_out))
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

always @(posedge(clock8),posedge(TC_out))
	begin : outputLogic
		
		case(currentState)
			set:
				begin
					Dn = 17;
					CEP = 0;
					PE_n = 0;
					reg80k = 0;
				end
		
			resetOff:
				begin
					Dn = 17;
					CEP = 0;
					PE_n = 0;
					reg80k = 0;

				end
			
			resetOn:
				begin
					Dn = 17;
					CEP = 0;
					PE_n = 0;
					reg80k = 1;
				end
			
			clockOff:
				begin
					Dn = 17;
					CEP = 1;
					PE_n = 1;
					reg80k = 0;
				end
				
			clockOn:
				begin
					Dn = 17;
					CEP = 1;
					PE_n = 1;
					reg80k = 1;
				end
				
			default:
				begin
					Dn = 17;
					CEP = 0;
					PE_n = 0;
					reg80k = 0;
				end
endcase
end

assign clock80k = reg80k;


endmodule
