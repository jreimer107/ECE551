module UART_tx(clk, rst_n, tx_data, trmt, TX, tx_done);

input clk;
input rst_n;
input trmt;
input[7:0] tx_data;
output TX;
output reg tx_done;

// flops
reg [3:0] shift_counter;
reg [11:0] baud_counter;
reg [8:0] shift_data;

// state machine signals
typedef enum {IDLE, ACTIVE} state_t;
reg state;
reg next_state;
reg load;
reg transmitting;
reg shift;
reg set_done;
reg clr_done;

assign TX = shift_data[0];

// state machine logic
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n) begin
		state <= IDLE;
	end

	else begin
		state <= next_state;	
	end

end

// state machine comb
always_comb begin

	load = 0;
	transmitting = 0;
	shift = 0;
	set_done = 0;
	clr_done = 0;
	
	case(state)
		IDLE:
			if (trmt) begin
				next_state = ACTIVE;
				load = 1;
				clr_done = 1;
			end
			else begin
				next_state = IDLE;
			end
		
		ACTIVE:
			if (baud_counter == 2604) begin
				next_state = ACTIVE;
				transmitting = 1;
				shift = 1;
			end
			else if (shift_counter == 9) begin
				next_state = IDLE;
				shift = 1;
				set_done = 1;
			end
			else begin
				next_state = ACTIVE;
				transmitting = 1;
			end
			
		
	endcase
	
end

// tx_done flop
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		tx_done <= 0;
	end
	
	else if (set_done) begin
		tx_done <= 1;
	end
	else if (clr_done) begin 
		tx_done <= 0;
	end
	else begin 
		tx_done <= tx_done;
	end
	
end


// shift counter
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n) begin
		shift_counter <= 0;
	end
	
	else if (load) begin
		shift_counter <= 0;
	end
	else if (shift) begin
		shift_counter <= shift_counter + 1;
	end
	else begin
		shift_counter <= shift_counter;
	end	
end

// baud counter 
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n) begin
		baud_counter <= 0;
	end
	else if (shift || load) begin
		baud_counter <= 0;	
	end
	else if (transmitting) begin
		baud_counter <= baud_counter + 1;
	end
	else begin
		baud_counter <= baud_counter;
	end
end

// shift data
always_ff @(posedge clk, negedge rst_n) begin

	// probably don't need to reset this
	if (!rst_n) begin
		shift_data <= 9'b111111111; // fill with idle bits
	end

	else if (load) begin
		shift_data <= {tx_data[7:0], 1'b0};
	end
	else if (shift) begin
		shift_data <= {1'b1, shift_data[8:1]};
	end
	else begin
		shift_data <= shift_data;
	end
end

endmodule

