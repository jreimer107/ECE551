module CommMaster(clk, rst_n, cmd, snd_cmd, data, resp, resp_rdy, TX, RX);

input clk, rst_n;
input snd_cmd;
input [7:0] cmd;
input [15:0] data;

output [7:0] resp;
output resp_rdy;

input RX;
output TX;

reg [15:0] data_reg; // flops to hold data
reg [7:0] tx_data; // muxed signal into tx_data

// state machine signals
typedef enum {IDLE, CMD, DATA_HI, DATA_LO} state_t;
state_t state;
reg next_state;
reg trmt, tx_done, frm_snt, set_done, clr_done;
reg [1:0] sel;


// instantiate UART
UART uart	(	.clk(clk), .rst_n(rst_n),
				.trmt(trmt), .tx_data(tx_data) .tx_done(tx_done),
			)


// assign statements
assign tx_data =	sel[1] ? cmd : 
					sel[0] ? data[15:8] : 
					data[7:0]; // mux to select cmd and data


// state machine flops
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n) begin
		state <= IDLE;
	end
	
	else state <= next_state;

end


// state machine comb
always_comb begin
	
	// default signals
	next_state = IDLE;
	trmt = 0;
	sel = 0;
	
	case(state)
	
		IDLE: begin	
			if (snd_cmd) begin
				next_state = CMD;
				sel = 0;
				trmt = 1;
			end
		end
		
		
		CMD: begin
			if (tx_done) begin
				next_state = DATA_HI;
				sel = 1;
				trmt = 1;
			
			end
			
			else begin 
				next_state = CMD;
			end
		end
		
		DATA_HI: begin
		
			if (tx_done) begin
				next_state = DATA_LO;
				sel = 2;
				trmt = 1;
			
			end
			
			else begin 
				next_state = DATA_HI;
			end
		
		end
		
		DATA_LO: begin
			if (tx_done) begin
				next_state = IDLE;		
			end
			
			else begin 
				next_state = DATA_LO;
			end
		end
	
	
	
	
end

// srff frm_snt signal
always_ff @posedge clk, negedge rst_n) begin

	if 		(!rst_n) frm_snt <= 0;
	else if (clr_done) frm_snt <= 0;
	else if (set_done) frm_snt <= 1;

end

// data register
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n) data_reg <= 0;
	else if (snd_cmd) data_reg <= data;

end




endmodule





