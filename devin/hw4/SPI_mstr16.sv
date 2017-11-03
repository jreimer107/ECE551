module SPI_mstr16(clk, rst_n, wrt, cmd, done, rd_data, SS_n, SCLK, MOSI, MISO);

// signals we use
input clk, rst_n, wrt;
input [15:0] cmd;
output done;
output [15:0] rd_data;

// signals for the interface
input MISO;
output SS_n, SCLK, MOSI;

reg MISO_smpl;

// flops
reg [4:0] sclk_div;
reg [15:0] shft_reg;

// state machine signals
reg rst_cnt;
reg wrt;
reg shft;
reg smpl;

// state machine flops


// state machine comb



// sampler flop
always_ff @(posedge clk, negedge rst_n) begin

	if (smpl) begin
		MISO_smpl <= MISO;
	end
	
end

// sclk_div counter
always_ff @(posedge clk, negedge rst_n) begin
	
	if (rst_cnt) begin
		sclk_div <= 5'b10111; // this value creates our front porch
	end	
	
	else begin
		sclk_div <= sclk_div + 1; 
	end	

end

// data shift register
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n) begin
		shft_reg <= 0;
	end
	
	else if (wrt) begin
		shft_reg <= cmd[15:0];
	end
	
	else if (shft) begin
		shft_reg <= {shft_reg[14:0], MISO_smpl};
	end
	
	else begin
		shft_reg <= shft_reg;
	end

end







assign SCLK = sclk_div[4];
assign MOSI = shft_reg[15];

endmodule
