module inert_intf_tb();

reg clk, rst_n;

// inputs to inert_intf
reg strt_cal;

// motor speed inputs
reg [10:0] frnt_spd, bck_spd, lft_spd, rght_spd;

// outputs from inert_intf
wire vld, cal_done;
wire [15:0] ptch, roll, yaw;

// wires between inert_intf and CycloneIV
wire INT, SS_n, SCLK, MOSI, MISO

// wires between ESCs and CycloneIV
wire frnt, bck, lft, rght;

// instantiate ESCs
ESCs escs(	.clk(clk), .rst_n(rst_n),
			.frnt_spd(frnt_spd), .bck_spd(bck_spd), .lft_spd(lft_spd), .rght_spd(rght_spd),
			.frnt(frnt), .bck(bck), .lft(lft), .rght(rght));

// instantiate quadcopter model
CycloneIV model(	.SS_n(SS_n), .INT(INT), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), 
					.frnt_ESC(frnt), .back_ESC(bck), .left_ESC(lft), .rght_ESC(rght));

// instantiate DUT
inert_intf iDUT(	.clk(clk), .rst_n(rst_n),
					.SS_n(SS_n), .INT(INT), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), 
					.vld(vld), .cal_done(cal_done), 
					.ptch(ptch), .roll(roll), .yaw(yaw));




always begin

	#5 clk = ~clk;

end

initial begin

	// default all signals and reset
	clk = 0;
	rst_n = 0;
	strt_cal = 0;
	frnt_spd = 0;
	bck_spd = 0;
	lft_spd = 0;
	rght_spd = 0;
	

	@(negedge clk);
	@(negedge clk);
	rst_n = 1;
	
	strt_cal = 1;
	@(negedge clk);
	strt_cal = 0;
	repeat (100) @(negedge clk); // give it some time to do a calibration
	

	
	
end










endmodule