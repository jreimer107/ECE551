module CommTB();
reg clk, rst_n;
reg snd_cmd, cmd_rdy, clr_cmd_rdy;
reg [7:0] cmd_in, cmd_out;	//In thru CommMstr, out thru UART_wrapper.
reg [15:0] data_in, data_out;
reg TX_RX, RX_TX; 			//Communication signals

reg resp_rdy;				//Response signals
reg [7:0] resp;

CommMaster iCM(.clk(clk), .rst_n(rst_n), .cmd(cmd_in), .snd_cmd(snd_cmd), .data(data_in), .TX(TX_RX), 
	.RX(RX_TX), .resp(resp), .resp_rdy(resp_rdy));
UART_wrapper iUW(.clk(clk), .rst_n(rst_n), .clr_cmd_rdy(clr_cmd_rdy), .cmd_rdy(cmd_rdy), .cmd(cmd_out),
	.data(data_out), .RX(TX_RX), .TX(RX_TX), .snd_resp(resp_rdy), .resp_sent(),  .resp(resp));

always #5 clk = ~clk;


initial begin
	repeat (100000) @(posedge clk);
	$display("Timed out");
	$stop();
end


initial begin
	clk = 0;
	rst_n = 0;
	@(negedge clk) rst_n = 1;
	
	//Command and Data: AB CDCD
	repeat(10) @(posedge clk);
	cmd_in = 8'hAB;
	data_in = 16'hCDCD;
	snd_cmd = 1;
	@(posedge clk) snd_cmd = 0;
	
	@(posedge cmd_rdy);
	repeat(50) @(posedge clk);
	if (cmd_in != cmd_out) begin
		$display("Expected cmd_out of 'AB', got %x", cmd_out);
		$stop();
	end
	if (data_in != data_out) begin
		$display("Expected data_out of 'CDCD', got %x", data_out);
		$stop();
	end
	
	
	
	$display("Test passed.");
	$stop();

end

endmodule
