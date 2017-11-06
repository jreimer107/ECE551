module flght_cntrl_io_tb();

reg clk, rst_n;
reg vld;
reg inertial_cal;
reg [15:0] d_ptch, d_roll, d_yaw;
reg [15:0] ptch, roll, yaw;
reg [8:0] thrst;


///////////////////////////////////////
// Declare wires for outputs of DUT //
/////////////////////////////////////
wire [10:0] frnt_spd,bck_spd,lft_spd,rght_spd;

localparam CAL_SPEED = 11'h1B0;		// speed to run motors at during inertial calibration
localparam MIN_RUN_SPEED = 13'h200;	// minimum speed while running  

//////////////////////
// Instantiate DUT //
////////////////////
  flght_cntrl iDUT(.clk(clk),.rst_n(rst_n),.vld(vld),.d_ptch(d_ptch),.d_roll(d_roll),
                   .d_yaw(d_yaw),.ptch(ptch),.roll(roll),.yaw(yaw),.thrst(thrst),
                   .inertial_cal(inertial_cal),.frnt_spd(frnt_spd),.bck_spd(bck_spd),
				   .lft_spd(lft_spd),.rght_spd(rght_spd));

// file io
integer i; // loop index
integer f_stim;
integer f_resp;
reg [107:0] stim;
reg [43:0] resp;

reg [107:0] stims [0:999];
reg [43:0] resps [0:999];



always begin 
	#5 clk = ~clk;
end

initial begin

	// setup files and memory
 	$readmemh("flght_cntrl_stim.hex", stims);
	$readmemh("flght_cntrl_resp.hex", resps);

	// wait a sec
	clk = 0;
	repeat(2) @(negedge clk);
 
	for (i = 0; i < 1000; i++) begin

		stim = stims[i];
		resp = resps[i]; 
				
		rst_n = stim[107];
		vld = stim[106];
		inertial_cal = stim[105];
		d_ptch[15:0] = stim[104:89];
		d_roll[15:0] = stim[88:73];
		d_yaw[15:0] = stim[72:57]; 
		ptch[15:0] = stim[56:41];
		roll[15:0] = stim[40:25];
		yaw[15:0] = stim[24:9];
		thrst[8:0] = stim[8:0];
		
		@(posedge clk);
		#1;
		
		if (frnt_spd != resp[43:33]) begin
			$display("frnt_spd incorrect at input set %x", i);
			$stop();
		end
		
		if (bck_spd != resp[32:22]) begin
			$display("bck_spd incorrect at input set %x", i);
			$stop();
		end
		
		if (lft_spd != resp[21:11]) begin
			$display("lft_spd should be %x, is actually %x", resp[21:11], lft_spd);
			$stop();
		end
		
		if (rght_spd != resp[10:0]) begin
			$display("rght_spd should be %x, is actually %x", resp[10:0], rght_spd);
			$stop();
		end

	end 
	$display("Works correctly");
	$stop();
end





endmodule
