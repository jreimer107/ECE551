module cmd_cfgP_tb();



reg clk, rst_n;
reg cmd_rdy;
reg [7:0] cmd;
reg [15:0] data;
reg [7:0] batt;
reg inertial_cal;
reg cal_done;
reg cnv_cmplt;

wire clr_cmd_rdy

// CommMaster to UART_wrapper ports
wire TX_RX, RX_TX;





always begin

	#5 clk = ~clk;

end

// time out
initial begin 

	#100000 
	$display("Timed out.");
	$stop();

end

// test
initial begin 

	clk = 0;
	rst_n = 0;
	
	@(negedge clk);


end




endmodule
