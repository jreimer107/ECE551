module SPI_mstr16_tb();

reg clk, rst_n, wrt;
reg [15:0] cmd;
wire done, SS_n, SCLK, MISO, MOSI;
wire [15:0] rd_data;

// instantiate DUT
SPI_mstr16 master(.clk(clk), .rst_n(rst_n), .wrt(wrt), .MISO(MISO), .cmd(cmd), .done(done), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .rd_data(rd_data));

// instantiate slave SPI device 
ADC128S slave(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI));

always begin 
	#5 clk = ~clk;
end

initial begin
	
	clk = 0;
	rst_n = 0;
	
	@(negedge clk);
	rst_n = 1;
	
	// request a reading of channel 0
	@(negedge clk);
	cmd = 16'h0000; 
	wrt = 1;
	@(negedge clk);
	wrt = 0;
	
	@(posedge done); // wait for transaction to end
	if(slave.iSPI.cmd !== 16'h0000) begin
		$display("Slave received wrong command. Expected 0x0000, got 0x%x", slave.iSPI.cmd);
		$stop();
	end
	
	// send garbage and check that slave received the garbage
	@(negedge clk);
	cmd = 16'hABCD; 
	wrt = 1;
	@(negedge clk);
	wrt = 0;
	
	@(posedge done); // wait for transaction to end
	if(slave.iSPI.shft_reg_rx !== 16'hABCD) begin
		$display("Slave received wrong command. Expected 0xABCD, got 0x%x", slave.iSPI.cmd);
		$stop();
	end
		
	// check what we received from reading channel 0
	if(rd_data !== 16'h0C00) begin
		$display("Expceted 0x0C00 from channel 0 read #1, received %x", rd_data);
		$stop();		
	end
	
	@(negedge clk);
	wrt = 1;
	@(negedge clk);
	wrt = 0;

	@(posedge done); // wait for transaction to end
	// check what we received from reading channel 0 again
	if(rd_data !== 16'h0C00) begin
		$display("Expceted 0x0C00 from channel 0 read #2, received %x", rd_data);
		$stop();		
	end
	

	@(negedge clk);
	wrt = 1;
	@(negedge clk);
	wrt = 0;
	
	@(posedge done); // wait for transaction to end
	// check what we received from reading channel 0 again
	if(rd_data !== 16'h0BF0) begin
		$display("Expceted 0x0BF0 from channel 0 read #3, received %x", rd_data);
		$stop();		
	end

	@(negedge clk);
	wrt = 1;
	@(negedge clk);
	wrt = 0;
	
	@(posedge done); // wait for transaction to end
	// check what we received from reading channel 0 again
	if(rd_data !== 16'h0BF0) begin
		$display("Expceted 0x0BF0 from channel 0 read #4, received %x", rd_data);
		$stop();		
	end
	
	@(negedge clk);
	wrt = 1;
	@(negedge clk);
	wrt = 0;
	
	@(posedge done); // wait for transaction to end
	// check what we received from reading channel 0 again
	if(rd_data !== 16'h0BE0) begin
		$display("Expceted 0x0BE0 from channel 0 read #5, received %x", rd_data);
		$stop();		
	end



	repeat (200) @(negedge clk);

	$display("Test passed.");
	$stop();
	
	
	
	
end





endmodule
