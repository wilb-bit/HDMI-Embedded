module statei2c (

	//input clk400k,
	input clk50,
	//input clock25,
	input resetSwitch_n,
   input switchR, switchG, switchB,  

	output LED,
	output SDA,
	output SCL,

	output [23:0] HDMI_D, // RGBchannel
	output Vsync,  // vsync
	output Hsync,  // hsync
	output HDMI_DE,  // dataEnable
	output HDMI_CLK // vgaClock


);
	// CLOCKS
	wire reset;
	assign reset = ~resetSwitch_n;
	wire clock25; 
	wire clk8;
	wire clk400k;	
	
	pll25MHz pll_25(
  .refclk(clk50),
  .rst(reset), 
  .outclk_0(clock25)
  );

  pll8MHz pllclk(
	.refclk(clk50),   //  refclk.clk
	.rst(reset),      //   reset.reset
	.outclk_0(clk8)  // outclk0.clk
	);
	
	clock400k clk80 (

	.clock5(clk8), 
	.clock400k(clk400k)

);

	assign HDMI_CLK = clock25;
	
	reg inc;
	reg resetInc_n;
	wire	[15:0]  Iq;


increment i2c (
	.inc(inc),
	.reset_n(resetInc_n),
	.clk50(clk50),
	.value(Iq)
		
);


	reg resetShift_n;
	reg loadEn;
	reg shiftEn;
	reg [7:0] dataBus;
	wire shiftComplete;
	wire MSB;

	
myshiftreg shift1(
	.reset_n(resetShift_n), 
	.loadData(loadEn), 
	.shiftEnabled(shiftEn), 
	.dataBus(dataBus), 
	.shiftClk(clk400k), 
	.shiftComplete(shiftComplete), 
	.shiftMSB(MSB)
	
);

	
	reg HDMI_reset;


//vgaHdmi hdmi (
//  // input
//  .clock      (clock25),
//  .clock50    (clk50),
//  .reset      (HDMI_reset), 
//  .hsync      (Hsync),
//  .vsync      (Vsync),
//  .switchR    (switchR),
//  .switchG    (switchG),
//  .switchB    (switchB),
//
//  // output
//  .dataEnable (HDMI_DE),
//  .vgaClock   (),
//  .RGBchannel (HDMI_D)
//);

hdmi hdmioutp(
	.reset_n(~HDMI_reset),
	.clk25(clock25),
	.clk50(clk50),
	.switchR    (switchR),
   .switchG    (switchG),
   .switchB    (switchB),
	.Data(HDMI_D),
	.outVsync(Vsync),
	.outHsync(Hsync),
	.outDE(HDMI_DE)

);
	
	
	
	reg [7:0] slaveAddress = 8'b01110010;
	wire [7:0] con = Iq [15:8];
	wire [7:0] data = Iq [7:0];
	reg regLED;
	reg regSCL;
	reg regSDA;
	reg [5:0] currentstate;
	reg [5:0] nextState;

parameter beginning= 6'b000000;
parameter increment= 6'b000001;
parameter conS1= 6'b000010;
parameter conS2= 6'b000011;
parameter conS3= 6'b000100;
parameter conS4= 6'b000101;
parameter startS1= 6'b000110;
parameter startS2= 6'b000111;
parameter startS3= 6'b001000;
parameter startS4= 6'b001001;
parameter stopS1= 6'b001010;
parameter stopS2= 6'b001011;
parameter stopS3= 6'b001100;
parameter stopS4= 6'b001101;
parameter slaveS1= 6'b001110;
parameter slaveS2= 6'b001111;
parameter slaveS3= 6'b010000;
parameter slaveS4= 6'b010001;
parameter dataS1= 6'b010010;
parameter dataS2= 6'b010011;
parameter dataS3= 6'b010100;
parameter dataS4= 6'b010101;
parameter ackS1= 6'b010110;
parameter ackS2= 6'b010111;
parameter ackS3= 6'b011000;
parameter ackS4= 6'b011001;
parameter hdmiTrans= 6'b011011;
parameter ackS1b= 6'b011100;
parameter ackS2b= 6'b011101;
parameter ackS3b= 6'b011110;
parameter ackS4b= 6'b011111;
parameter ackS1c= 6'b100000;
parameter ackS2c= 6'b100001;
parameter ackS3c= 6'b100010;
parameter ackS4c= 6'b100011;



initial begin
currentstate = beginning;
end

always @(posedge(clk400k)) //change to 400k
begin: stateMemory
// Update the state variable on the clock transition.
currentstate <= nextState;
end

//////////////////////////////////////////

always @(currentstate,shiftComplete,Iq) //,Iq,switch
begin: nextStatelogic

case(currentstate)
	beginning:
		begin 
			
			nextState =startS1;					
					
		end
		
	increment:
		begin
			//if (Iq != 0)
					nextState =startS2; 
			//else 
					//nextState =increment;
			
		end
	
	startS1:
		begin
					nextState =startS2;
			
		end
		
	startS2:
		begin
					nextState =startS3;
			
		end
	
	startS3:
		begin
					nextState =startS4;
			
		end
	
	startS4:
		begin
					nextState =slaveS1;
		end
		
	slaveS1:
		begin

					nextState =slaveS2;
			
		end
		
	slaveS2:
		begin
					nextState =slaveS3;
			
		end
	
	slaveS3:
		begin
					nextState =slaveS4;
			
		end
	
	slaveS4:
		begin
		if(shiftComplete)
					nextState =ackS1;
		else
					nextState =slaveS1;
			
		end

	ackS1:
		begin
					nextState =ackS2;
			
		end
		
	ackS2:
		begin
					nextState =ackS3;
			
		end

	ackS3:
		begin
					nextState =ackS4;
			
		end
		
	ackS4:
		begin
					nextState =conS1;
			
		end
		
	conS1:
		begin

					nextState =conS2;
			
		end
		
	conS2:
		begin
					nextState =conS3;
			
		end
	
	conS3:
		begin
					nextState =conS4;
			
		end
	
	conS4:
		begin
				if(shiftComplete)
					nextState =ackS1b;
		else
					nextState =conS1;
			
		end
	
	ackS1b:
		begin
					nextState =ackS2b;
			
		end
		
	ackS2b:
		begin
					nextState =ackS3b;
			
		end

	ackS3b:
		begin
					nextState =ackS4b;
			
		end
		
	ackS4b:
		begin
					nextState =dataS1;
			
		end

	dataS1:
		begin

					nextState =dataS2;
			
		end
		
	dataS2:
		begin
					nextState =dataS3;
			
		end
	
	dataS3:
		begin
					nextState =dataS4;
			
		end
	
	dataS4:
		begin
				if(shiftComplete)
					nextState =ackS1c;
		else
					nextState =dataS1;
			
		end
		
	ackS1c:
		begin
					nextState =ackS2c;
			
		end
		
	ackS2c:
		begin
					nextState =ackS3c;
			
		end

	ackS3c:
		begin
					nextState =ackS4c;
			
		end
		
	ackS4c:
		begin
					nextState =stopS1;
			
		end
		
	stopS1:
		begin
					nextState =stopS2;
			
		end
		
	stopS2:
		begin
					nextState =stopS3;
			
		end
	
	stopS3:
		begin
					nextState =stopS4;
			
		end
	
	stopS4:
		begin
				if (Iq == 16'b1111101001111101)
				nextState =hdmiTrans;
				else
					nextState =increment;
			
		end
	
	hdmiTrans:
		nextState =hdmiTrans;
		
	default:
		begin
					nextState =beginning;
		
		end
		
endcase

end
////////////////////////////////LEDS
always @(currentstate,slaveAddress,MSB,con,data)
begin: outputLogic


case(currentstate)
	beginning:
		begin 
				regSCL = 1'b0;
				regSDA = 1'b0;
				
				resetInc_n = 0;
				inc = 0;
				
				resetShift_n = 1'b0;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = 8'b00000000;
				regLED = 0;
				HDMI_reset = 1'b1;
		end
	increment:
		begin 
				regSCL = 1'b0;
				regSDA = 1'b1;
				
				resetInc_n = 1;
				inc = 1;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
	
	startS1:
		begin 
				regSCL = 1'b0;
				regSDA = 1'b1;
				
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	startS2:
		begin 
				regSCL = 1'b1;
				regSDA = 1'b1;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b1;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	startS3:
		begin 
				regSCL = 1'b1;
				regSDA = 1'b0;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	startS4:
		begin 
				regSCL = 1'b0;
				regSDA = 1'b0;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
	
	slaveS1:
		begin 
				regSCL = 1'b0;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	slaveS2:
		begin 
				regSCL = 1'b1;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	slaveS3:
		begin 
				regSCL = 1'b1;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	slaveS4:
		begin 
				regSCL = 1'b0;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b1;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
	
	ackS1:
		begin
				regSCL = 1'b0;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b1;
				shiftEn = 1'b0;
				dataBus = con;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	ackS2:
		begin
				regSCL = 1'b1;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = con;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	ackS3:
		begin
				regSCL = 1'b1;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = con;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	ackS4:
		begin
				regSCL = 1'b0;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = con;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
//
	conS1:
		begin 
				regSCL = 1'b0;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = con;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	conS2:
		begin 
				regSCL = 1'b1;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = con;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	conS3:
		begin 
				regSCL = 1'b1;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = con;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	conS4:
		begin 
				regSCL = 1'b0;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b1;
				dataBus = con;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
	
	ackS1b:
		begin
				regSCL = 1'b0;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b1;
				shiftEn = 1'b0;
				dataBus = data;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	ackS2b:
		begin
				regSCL = 1'b1;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = data;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	ackS3b:
		begin
				regSCL = 1'b1;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = data;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	ackS4b:
		begin
				regSCL = 1'b0;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = data;
				regLED = 0;
				HDMI_reset = 1'b1;
				
		end
		
		//	
	
	dataS1:
		begin 
				regSCL = 1'b0;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = data;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	dataS2:
		begin 
				regSCL = 1'b1;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = data;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	dataS3:
		begin 
				regSCL = 1'b1;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = data;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	dataS4:
		begin 
				regSCL = 1'b0;
				regSDA = MSB;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b1;
				dataBus = data;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
	
	ackS1c:
		begin
				regSCL = 1'b0;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	ackS2c:
		begin
				regSCL = 1'b1;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	ackS3c:
		begin
				regSCL = 1'b1;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
		
	ackS4c:
		begin
				regSCL = 1'b0;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;

		end
	//	
	stopS1:
		begin 
				regSCL = 1'b0;
				regSDA = 1'b0;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	stopS2:
		begin 
				regSCL = 1'b1;
				regSDA = 1'b0;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	stopS3:
		begin 
				regSCL = 1'b1;
				regSDA = 1'b1;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
	stopS4:
		begin 
				regSCL = 1'b0;
				regSDA = 1'b1;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 0;
				HDMI_reset = 1'b1;
				

		end
		
	hdmiTrans:
		begin
				regSCL = 1'b0;
				regSDA = 1'bz;
				resetInc_n = 1;
				inc = 0;
				
				resetShift_n = 1'b1;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = slaveAddress;
				regLED = 1;
				HDMI_reset = 1'b0;

		end
		
	default:
		begin
				regSCL = 1'b0;
				regSDA = 1'b0;
				
				resetInc_n = 0;
				inc = 0;
				
				resetShift_n = 1'b0;
				loadEn = 1'b0;
				shiftEn = 1'b0;
				dataBus = 8'b00000000;
				regLED = 0;
				HDMI_reset = 1'b1;


		end
		
endcase

end

assign LED = regLED;

assign SCL = regSCL;
assign SDA = regSDA;


endmodule
