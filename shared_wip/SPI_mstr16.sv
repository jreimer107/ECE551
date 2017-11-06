//module SPI_mstr16(clk, rst_n, wrt, cmd, MISO, rd_data, SS_n, SCLK, MOSI, done);

//// internal signals
//input clk, rst_n, wrt;
//input [15:0] cmd;
//output reg done;
//output [15:0] rd_data;
//reg MISO_smpl; // flopped MISO sample

//// signals for the interface
//input MISO;
//output reg SS_n;
//output SCLK, MOSI;

//// flops and counters
//reg [4:0] bitcnt;
//reg [4:0] sclk_div;
//reg [15:0] shft_reg;

//// state machine signals
//typedef enum reg [1:0] {IDLE, FRT_PCH, ACTIVE, BCK_PCH} state_t;
//state_t state, nxt_state; // create state machine
//reg rst_cnt, shft, smpl;
//reg set_done, clr_done;

//// continuous output assignments
//assign SCLK = sclk_div[4];
//assign MOSI = shft_reg[15];
//assign rd_data[15:0] = shft_reg[15:0];

////TODO: should these be part of the SM?
////Do we care if they work when there isn't data?
////Devin: this might be clever - we will see when the tb is written

////// these signals were put here instead of in the state machine
////assign smpl = (sclk_div == 5'b01111);
////assign shft = (sclk_div == 5'b11111);

//// state machine flops
//always_ff @(posedge clk, negedge rst_n) begin
//	if (!rst_n) state <= IDLE;
//	else state <= nxt_state;
//end

//// state machine comb
//always_comb begin
//	
//	nxt_state = IDLE;
//	rst_cnt = 0;
//	SS_n = 0;
//	smpl = 0;
//	shft = 0;
//	clr_done = 0;
//	set_done = 0;
//	
//	case(state)
//		IDLE: begin
//			if (wrt) begin
//				nxt_state = FRT_PCH;
//				rst_cnt = 1;
//				clr_done = 1;
//			end
//			else begin
//				SS_n = 1;
//			end
//		end

//		FRT_PCH: begin
//			if (sclk_div == 5'b11111) begin 
//				nxt_state = ACTIVE;
//			end		
//			else begin
//				nxt_state = FRT_PCH;
//			end
//		end

//		ACTIVE: begin
//			if (bitcnt == 5'b01111) begin
//				nxt_state = BCK_PCH;
//			end
//			else if (sclk_div == 5'b01111) begin
//				nxt_state = ACTIVE;
//				smpl = 1;
//			end
//			else if (sclk_div == 5'b11111) begin
//				nxt_state = ACTIVE;
//				shft = 1;
//			end
//			
//			
//			else begin
//				nxt_state = ACTIVE;
//			end
//		end

//		BCK_PCH: begin
//			SS_n = 1;
//			if (sclk_div == 5'b01111) begin
//				nxt_state = IDLE;
//				set_done = 1;
//			end
//			else begin
//				nxt_state = BCK_PCH;
//			end
//		end
//			
//	endcase
//	
//end

//// sclk_div counter
//always_ff @(posedge clk, negedge rst_n) begin
//	if (rst_cnt) sclk_div <= 5'b10111; // this value front porches for 8 clocks
//	else if (state == IDLE) sclk_div <= sclk_div;
//	else sclk_div <= sclk_div + 1;
//end


//// sampler flop
//always_ff @(posedge clk, negedge rst_n) begin

//	if (smpl) begin
//		MISO_smpl <= MISO;
//	end
//	
//end

//// data shift register
//always_ff @(posedge clk, negedge rst_n) begin

//	if (!rst_n) begin
//		shft_reg <= 0;
//	end
//	
//	else if (wrt) begin
//		shft_reg <= cmd;
//	end
//	
//	else if (shft) begin
//		shft_reg <= {shft_reg[14:0], MISO_smpl};
//	end

//end

//// Bit counter
//always_ff@(posedge clk, negedge rst_n) begin
//	if (!rst_n) bitcnt <= 0;
//	else if (rst_cnt) bitcnt <= 0;
//	else if (shft) bitcnt <= bitcnt + 1;
//end


//// SRFF done signal
//always_ff @(posedge clk, negedge rst_n) begin

//	if(!rst_n) begin
//		done <= 0;
//	end
//	
//	else if (clr_done) begin
//		done <= 0;
//	end
//	else if (set_done) begin
//		done <= 1;
//	end

//end

//endmodule

module SPI_mstr16(clk, rst_n, wrt, cmd, MISO, rd_data, SS_n, SCLK, MOSI, done);
input clk, rst_n, wrt, MISO;
input [15:0] cmd;
output reg done, SS_n, SCLK, MOSI;
output reg [15:0] rd_data;

reg [4:0] bitcnt;
reg [4:0] sclk_div;
reg [15:0] shift_reg;
reg rst_cnt, shft, smpl, MISO_smpl, set_done, clr_done;
typedef enum reg [1:0] {IDLE, FRT_PCH, ACTIVE, BCK_PCH} state_t;
state_t state, nxt_state;

assign SCLK = !SS_n ? sclk_div[4] : 1'b1;
assign MOSI = shift_reg[15];
assign rd_data = shift_reg;

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
	else if (smpl) bitcnt <= bitcnt + 1;
end

//SM
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) state <= IDLE;
	else state <= nxt_state;
end
always_comb begin
	nxt_state = IDLE;
	rst_cnt = 0;
	set_done = 0;
	clr_done = 0;
	SS_n = 0;
	smpl = 0;
	shft = 0;
	
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
			if (sclk_div == 5'b01111) begin
				nxt_state = ACTIVE;
				smpl = 1;
				end
			else nxt_state = FRT_PCH;
			
		ACTIVE: begin
			if (bitcnt == 5'h10) begin
				nxt_state = BCK_PCH;
				
			end
			else nxt_state = ACTIVE;
			
			if (sclk_div == 5'b01111) smpl = 1;
			if (sclk_div == 5'b11111) shft = 1;
		end
		
		BCK_PCH:
			if (sclk_div == 5'b11111) begin
				nxt_state = IDLE;
				set_done = 1;
				shft = 1;
				rst_cnt = 1;
			end
			else nxt_state = BCK_PCH;
	endcase
end

//Done FF
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) done <= 1'b0;
	else if (set_done) done <= 1'b1;
	else if (clr_done) done <= 1'b0;
end

endmodule				
