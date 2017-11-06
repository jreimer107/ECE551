module UART_rx(clk, rst_n, RX, clr_rdy, rx_data, rdy);

input clk;
input rst_n;
input RX;
input clr_rdy;
output [7:0] rx_data;
output reg rdy;

//flops
reg [3:0] shift_counter;
reg [11:0] baud_counter;
reg [8:0] shift_data;

reg RX_stable;
reg RX_unstable;

// state machine signals
typedef enum {IDLE, ACTIVE} state_t;
reg state;
reg next_state;
reg start;
reg receiving;
reg shift;
reg set_rdy_int; // named as below for consistency
reg clr_rdy_int; // cannot have the same name as above

assign rx_data[7:0] = shift_data[7:0];

// state machine flops
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
	end

	else begin
		state <= next_state;
	end
end

// state machine comb
always_comb begin

	start = 0;
	receiving = 0;
	shift = 0;
	set_rdy_int = 0;	
	clr_rdy_int = 0;
					
	case(state)
		IDLE:
			if(RX_stable == 0) begin
				next_state = ACTIVE;
				shift = 1;
				start = 1;
				clr_rdy_int = 1;
			end
			else begin 
				next_state = IDLE;
			end
				
		ACTIVE:
			if(baud_counter == 0) begin
				next_state = ACTIVE;
				receiving = 1;
				shift = 1;
			end
			else if (shift_counter == 9) begin
				next_state = IDLE;
				set_rdy_int = 1;
			end
			else begin 
				next_state = ACTIVE;
				receiving = 1;
			end
		
	endcase

end

// rdy flop
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		rdy <= 0;
	end
	
	else if (clr_rdy || clr_rdy_int) begin
		rdy <= 0;
	end
	else if (set_rdy_int) begin 
		rdy <= 1;
	end
	else begin 
		rdy <= rdy;
	end
	
end

// RX_stable flops
always_ff @(posedge clk, negedge rst_n) begin

	if(!rst_n) begin
		RX_unstable <= 1;
		RX_stable <=1;
	end
	else begin
		RX_unstable <= RX;
		RX_stable <= RX_unstable;
	end
end

// shift counter
always_ff @(posedge clk, negedge rst_n) begin

	if(!rst_n) begin
		shift_counter <= 0;
	end
	
	else begin
		
		if (start) begin
			shift_counter <= 0;
		end
		else if (shift) begin
			shift_counter <= shift_counter + 1;
		end
		else begin
			shift_counter <= shift_counter;
		end
		
	end

end

// baud counter
always_ff @(posedge clk, negedge rst_n) begin

	if(!rst_n) begin
		baud_counter <= 0;
	end

	else begin
		if (shift && start) begin
			baud_counter <= 3906;
		end
		else if (shift && !start) begin
			baud_counter <= 2604;
		end			
		else if (receiving) begin
			baud_counter <= baud_counter - 1;
		end
		else begin
			baud_counter <= baud_counter;
		end
	end
end

// shift register
always_ff @(posedge clk, negedge rst_n) begin
	
	// probably don't need to reset this
	if (!rst_n) begin
		
	end
	
	else begin
		
		if (shift) begin
			shift_data <= {RX_stable, shift_data[8:1]};
		end
		else begin
			shift_data <= shift_data;
		end
		
	end
	
end










endmodule
