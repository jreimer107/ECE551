module CommTB();
reg clk, rst_n;
reg snd_cmd, cmd_rdy;
reg [7:0] cmd_in, cmd_out;	//In thru CommMstr, out thru UART_wrapper.
reg [15:0] data_in, data_out;
reg TX_RX, RX_TX; 			//Communication signals

reg resp_rdy;				//Response signals
reg [7:0] resp;

always #5 clk = ~clk;

initial begin
	clk = 0;
	rst_n = 1;
	


end

endmodule
