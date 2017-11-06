module CommMaster(clk, rst_n, cmd, snd_cmd, data, TX, RX,
	resp, resp_rdy); 

input clk, rst_n;
input snd_cmd;			//Signal to send command
input [7:0] cmd;		//First byte
input [15:0] data;		//Second and third bytes

output [7:0] resp;
output resp_rdy;

input RX;				//Communication signals
output TX;

reg [15:0] data_reg; 	//Flops to hold data
reg [7:0] tx_data; 		//Muxed signal into tx_data

// state machine signals
typedef enum reg [1:0] {IDLE, CMD, DATA_HI, DATA_LO} state_t;
state_t state, next_state;
reg trmt, tx_done, frm_snt, set_done, clr_done;
reg [1:0] sel;


// instantiate UART
UART uart	(	.clk(clk), .rst_n(rst_n),
				.trmt(trmt), .tx_data(tx_data), .tx_done(tx_done),
				.TX(TX), .RX(RX), .rx_data(), .rx_rdy(), .clr_rx_rdy()
			); // ignore rx_data and rx_rdy


// mux to select what UART is transmitting
assign tx_data = sel[1] ? cmd : 
				 sel[0] ? data[15:8] : 
				 data[7:0];



// state machine flops
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) state <= IDLE;
	else state <= next_state;
end


// state machine comb
always_comb begin
	// default signals
	next_state = IDLE;
	trmt = 0;
	sel = 0;
	set_done = 0;
	clr_done = 0;
	
	case(state)
	
		IDLE: begin	
			if (snd_cmd) begin
				next_state = CMD;
				trmt = 1;
				clr_done = 1;
				sel = 2;
			end
		end
		
		
		CMD: begin
			if (tx_done) begin
				next_state = DATA_HI;
				trmt = 1;
				sel = 1;
			end
			else next_state = CMD;
		end
		
		DATA_HI: begin
			if (tx_done) begin
				next_state = DATA_LO;
				trmt = 1;
			end
			else next_state = DATA_HI;
		
		end
		
		DATA_LO: begin
			if (tx_done) begin
				next_state = IDLE;
				set_done = 1;
			end
			else next_state = DATA_LO;
		end
	endcase
	
	
	
end

// srff frm_snt signal
always_ff @(posedge clk, negedge rst_n) begin

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





