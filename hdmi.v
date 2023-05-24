module hdmi (
	input reset_n,
	input clk25,
	input clk50,
	input switchR, switchG, switchB,
	
	output [23:0] Data,
	output outVsync,
	output outHsync,
	output outDE

);

reg Vsync;
reg Hsync;
reg DE;
reg [23:0] D;
wire [9:0] Vcount;
wire [9:0] Hcount;
wire TC_V;
wire TC_H;

myCount #(10,799) countH (

	.CEP(reset_n), // Count enable
	.PE_n(reset_n), // Parallel load enable
	.Dn(10'b0000000001), // Parallel load value
	.clock50(clk25), // System clock
	
	.Qn_out(Hcount), // Current count value
	.TC_out(TC_H) // Count Complete

);

myCount #(10,524) countV (

	.CEP(reset_n), // Count enable
	.PE_n(reset_n), // Parallel load enable
	.Dn(10'b0000000000), // Parallel load value
	.clock50(TC_H), // System clock
	
	.Qn_out(Vcount), // Current count value
	.TC_out(TC_V) // Count Complete

);



always@(posedge(clk25))
begin
	if(Vcount >= 491) //verticle back porch
	begin
		DE = 0;
		Vsync = 1;
		if(Hcount >= 751) //horizontal back porch
		Hsync = 1;
		else if (Hcount >= 655) //horizontal sync
		Hsync = 0;
		else  //horizontal front porch-active
		Hsync = 1;		
	end
	else if (Vcount >=489) //verticle sync
	begin
		DE = 0;
		Vsync = 0;
		if(Hcount >= 751) //horizontal back porch
		Hsync = 1;
		else if (Hcount >= 655) //horizontal sync
		Hsync = 0;
		else //horizontal front porch-active
		Hsync = 1;	
	end
	else if (Vcount >=480) //verticle front porch
	begin
		DE = 0;
		Vsync = 1;
		if(Hcount >= 751) //horizontal back porch
		Hsync = 1;
		else if (Hcount >= 655) //horizontal sync
		Hsync = 0;
		else  //horizontal front porch-active
		Hsync = 1;	
	end
	else if(Hcount >= 751) //verticle active, horizontal back porch
	begin
		DE = 0;
		Hsync = 1;
		Vsync = 1;
	end
	else if(Hcount >= 655) //verticle active, horizontal sync
	begin
		DE = 0;
		Hsync = 0;
		Vsync = 1;
	end
	else if(Hcount >= 639) //verticle active, horizontal front porch
	begin
		DE = 0;
		Hsync = 1;
		Vsync = 1;
	end
	else						//verticle active, horizontal active
	begin
	DE = 1;
	Hsync = 1;
	Vsync = 1;
	end
end

assign outVsync = Vsync;
assign outHsync = Hsync;
assign outDE = DE;

	reg [5:0] Iaddress;
	wire [7:0] Iq;

red33 redy (

	.aclr(1'b0),
	.address(Iaddress),
	.clock(clk50),
	.rden(1'b1),
	.q(Iq)

);


always@(posedge(clk25),negedge(reset_n))
begin
	if(reset_n == 1'b0)
		begin
			D <= 0;
			Iaddress <= 0;
		end
	else if(Hcount <= 2 && Vcount <= 2)
		begin
			D [23:16] <= Iq;
			D [15:0] <= 0;
			Iaddress <= Iaddress+1'b1;
		end
	else if(Vcount >= 2)
		begin
			D <= 0;
			Iaddress <= 0;
		end
		else
		begin
			Iaddress <= Iaddress;
			D <= 0;
		end
end
	
	assign Data = D;
	//assign Data[23:16] = (switchR)? 8'd255 : 8'd0;
	//assign Data[15:8] = (switchG)? 8'd255 : 8'd0;
	//assign Data[7:0] = (switchB)? 8'd255 : 8'd0;
	

endmodule
