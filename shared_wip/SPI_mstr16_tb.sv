module SPI_mstr16_tb();

reg clk, rst_n, wrt, MISO;
reg [15:0] cmd;
wire done, SS_n, SCLK, MOSI;
wire [15:0] rd_data;

always begin 
	clk = ~clk
end

initial begin
	
	clk = 0;
	rst_n = 0;
	
	@(negedge clk)
	rst_n = 1;
	
	
	
	
end





endmodule
