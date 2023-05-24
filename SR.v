//sr latch

module SR(
	input S,R,
	output Q, Qn
);

reg regQn;
reg regQ;

always@(S,R)
	begin
		if((S == 0) && (R == 1))
			begin
				regQ = 0;
				regQn = 1;
			end
		else if((S == 1) && (R == 0))
			begin
				regQ = 1;
				regQn = 0;	
			end
		else 
			begin
				regQ <= regQ;
				regQn <= regQn;
			end
	end
	
assign Q = regQ;
assign Qn = regQn;
	
endmodule
