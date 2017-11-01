module SPI_mstr16(clk, rst_n, wrt, cmd, MISO, rd_data, SS_n, SCLK, MOSI, done);
input clk, rst_n, wrt, MISO;
input [15:0] cmd;
output reg done, SS_n, SCLK, MOSI;
output reg [15:0] rd_data;

reg [3:0] bitcnt;
reg [4:0] sclk_div;
reg [15:0] shift_reg;
reg rst_cnt, shift, smpl, MISO_smpl;
typedef enum reg [1:0] {IDLE, FRT_PCH, ACTIVE, BCK_PCH} state_t;
state_t state, nxt_state;

assign SCLK = sclk_div[4];
assign MOSI = shift_reg[15];
//TODO: should these be part of the SM?
//Do we care if they work when there isn't data?
assign smpl = sclk_div == 5'b01111;
assign shft = sclk_div == 5'b11111;

//SCLK counter
always_ff @(posedge clk) begin
	if (rst_cnt) sclk_div <= 5'b10111;
	else sclk_div <= sclk_div + 1;
end

//Shift Register
always_ff @(posedge clk)
	if (smpl) MISO_smpl <= MISO;
always_ff @(posedge clk) begin
	if (wrt) shift_reg <= cmd;
	else if (shft) shift_reg <= {shift_reg[14:0], MISO_smpl};
end

//Bit counter
always_ff@(posedge clk, negedge rst_n) begin
	if (!rst_n) bitcnt <= 0;
	else if (rst_cnt) bitcnt <= 0;
	else if (shft) bitcnt <= bitcnt + 1;
end

//SM
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) state <= IDLE;
	else state <= nxt_state;
end
always_comb begin
	nxt_state = IDLE;
	rst_cnt = 0;
	done = 0;
	SS_n = 0;
	
	case(state)
		IDLE: begin
			SS_n = 1;
			if (wrt) begin
				nxt_state = FRT_PCH;
				rst_cnt = 1;
			end
		end
		
		FRT_PCH: if (smpl) nxt_state = ACTIVE;
		else nxt_state = FRT_PCH;
			
		ACTIVE: if (&bitcnt) begin
			nxt_state = BCK_PCH;
			rst_cnt = 1;
		end
		else nxt_state = ACTIVE;
		
		BCK_PCH: if (smpl) begin
			nxt_state = IDLE;
			done = 1;
		end
		else nxt_state = BCK_PCH;
	endcase
end

endmodule
			
				