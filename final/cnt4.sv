module cnt4(en, rst_n, clk, cnt);
input en, rst_n, clk;
output reg [3:0] cnt;

//If enabled, count up 1 each clock
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		cnt <= 4'h0;
	else if (en)
		cnt <= cnt + 1;
end

endmodule
	
		
