module SPI_mstr16(clk, rst_n, wrt, cmd, MISO, rd_data, SS_n, SCLK, MOSI, done);

// internal signals
input clk, rst_n, wrt;
input [15:0] cmd;
output reg done;
output [15:0] rd_data;
reg MISO_smpl; // flopped MISO sample

// signals for the interface
input MISO;
output reg SS_n;
output SCLK, MOSI;

// flops and counters
reg [3:0] bitcnt;
reg [4:0] sclk_div;
reg [15:0] shft_reg;

// state machine signals
typedef enum reg [1:0] {IDLE, FRT_PCH, ACTIVE, BCK_PCH} state_t;
state_t state, nxt_state; // create state machine
reg rst_cnt, shft, smpl;
reg set_done, clr_done;

// continuous output assignments
assign SCLK = sclk_div[4];
assign MOSI = shft_reg[15];
assign rd_data[15:0] = shft_reg[15:0];

//TODO: should these be part of the SM?
//Do we care if they work when there isn't data?
//Devin: this might be clever - we will see when the tb is written

// these signals were put here instead of in the state machine
assign smpl = (sclk_div == 5'b01111);
assign shft = (sclk_div == 5'b11111);

// state machine flops
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) state <= IDLE;
	else state <= nxt_state;
end

// state machine comb
always_comb begin
	
	nxt_state = IDLE;
	rst_cnt = 0;
	SS_n = 0;
	clr_done = 0;
	set_done = 0;
	
	case(state)
		IDLE: begin
			SS_n = 1;
			if (wrt) begin
				nxt_state = FRT_PCH;
				rst_cnt = 1;
				clr_done = 1;
			end
		end

		
		FRT_PCH: 
			if (shft) nxt_state = ACTIVE;
			else nxt_state = FRT_PCH;
			
		ACTIVE: 
			if (&bitcnt) begin
				nxt_state = BCK_PCH;
				rst_cnt = 1;
			end
			else nxt_state = ACTIVE;
		
		BCK_PCH: 
			if (shft) begin
				nxt_state = IDLE;
				set_done = 1;
			end
			else nxt_state = BCK_PCH;
			
	endcase
	
end

// sclk_div counter
always_ff @(posedge clk, negedge rst_n) begin
	if (rst_cnt) sclk_div <= 5'b10111; // this value front porches for 8 clocks
	else sclk_div <= sclk_div + 1;
end


// sampler flop
always_ff @(posedge clk, negedge rst_n) begin

	if (smpl) begin
		MISO_smpl <= MISO;
	end
	
end

// data shift register
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n) begin
		shft_reg <= 0;
	end
	
	else if (wrt) begin
		shft_reg <= cmd;
	end
	
	else if (shft) begin
		shft_reg <= {shft_reg[14:0], MISO_smpl};
	end

end

// Bit counter
always_ff@(posedge clk, negedge rst_n) begin
	if (!rst_n) bitcnt <= 0;
	else if (rst_cnt) bitcnt <= 0;
	else if (smpl) bitcnt <= bitcnt + 1;
end


// SRFF done signal
always_ff @(posedge clk, negedge rst_n) begin

	if(!rst_n) begin
		done <= 0;
	end
	
	else if (clr_done) begin
		done <= 0;
	end
	else if (set_done) begin
		done <= 1;
	end

end

endmodule
