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
	
	repeat(16) @(posedge SCLK); // wait for transaction to end
	if(slave.iSPI.cmd != 0000) begin
		$display("Slave received wrong command. Expected 0x0000, got 0x%x", slave.iSPI.cmd);
	end
	
	// send garbage and check received garbage
	@(negedge clk);
	cmd = 16'hABCD; 
	wrt = 1;
	@(negedge clk);
	wrt = 0;
	
	repeat(16) @(posedge SCLK); // wait for transaction to end
	if(slave.iSPI.cmd != 16'hABCD) begin
		$display("Slave received wrong command. Expected 0xABCD, got 0x%x", slave.iSPI.cmd);
	end

	$stop();
	
	
	
	
end





endmodule
