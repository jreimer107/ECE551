module A2D_intf_tb();

reg clk, rst_n;

reg [2:0] chnnl;
reg strt_cnv;

wire cnv_cmplt;
wire [11:0] res;

wire SS_n, SCLK, MOSI, MISO;


A2D_intf iDUT(	.clk(clk), .rst_n(rst_n), 
				.strt_cnv(strt_cnv), .chnnl(chnnl), 
				.SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO),
				.cnv_cmplt(cnv_cmplt), .res(res));


ADC128S a2d(	.clk(clk), .rst_n(rst_n), 
				.SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));
				
				


always begin 

	#5 clk = ~clk;

end

// timeout
initial begin
	
	repeat (100000) @(posedge clk);
	$display("timed out");
	$stop();

end

// test 
initial begin

	clk = 0;
	rst_n = 0;
	@(negedge clk);
	rst_n = 1;
	@(negedge clk);
	
	// request a reading of channel 0
	@(negedge clk);
	chnnl = 0;
	strt_cnv = 1;
	@(negedge clk);
	strt_cnv = 0;
	
	// wait for transaction to end
	@(posedge cnv_cmplt); 
	if (res !== 12'hC00) begin
		$display("expected 0xC00, received %x", res);
		$stop();
	end

	// request a reading of channel 0
	@(negedge clk);
	chnnl = 0;
	strt_cnv = 1;
	@(negedge clk);
	strt_cnv = 0;
	
	// wait for transaction to end
	@(posedge cnv_cmplt); 
	if (res !== 12'hBF0) begin
		$display("expected 0xBF0, received %x", res);
		$stop();
	end
	
	// request a reading of channel 0
	@(negedge clk);
	chnnl = 0;
	strt_cnv = 1;
	@(negedge clk);
	strt_cnv = 0;
	
	// wait for transaction to end
	@(posedge cnv_cmplt); 
	if (res !== 12'hBE0) begin
		$display("expected 0xBE0, received %x", res);
		$stop();
	end
	
	// request a reading of channel 0
	@(negedge clk);
	chnnl = 0;
	strt_cnv = 1;
	@(negedge clk);
	strt_cnv = 0;
	
	// wait for transaction to end
	@(posedge cnv_cmplt); 
	if (res !== 12'hBD0) begin
		$display("expected 0xBD0, received %x", res);
		$stop();
	end

	// request a reading of channel 0
	@(negedge clk);
	chnnl = 0;
	strt_cnv = 1;
	@(negedge clk);
	strt_cnv = 0;
	
	// wait for transaction to end
	@(posedge cnv_cmplt); 
	if (res !== 12'hBC0) begin
		$display("expected 0xBC0, received %x", res);
		$stop();
	end

	$display("test passed.");
	$stop();


end

endmodule
