module ESC_interface(clk, rst_n, SPEED, OFF, PWM);

input clk;
input rst_n;
input [10:0] SPEED;
input [9:0] OFF;
output reg PWM;

wire [12:0] compensated_speed;
wire [17:0] setting;

// counter
reg [20:0] counter;

// set and rst
reg set;
reg rst;

// combinational logic
assign compensated_speed = SPEED + OFF;
assign setting = (compensated_speed << 4) + 16'd5000;

// counter
always_ff @(posedge clk, negedge rst_n) begin

	if(!rst_n) begin
		counter = 0; 
	end
	else begin
		counter = counter + 1;
	end
	
	// used blocking assignments above so this could be in the counter logic
	if (&counter) begin
		set = 1;
	end
	else begin
		set = 0;
	end
	
	if (counter[16:0] >= setting) begin
		rst = 1;
	end
	else begin
		rst = 0;
	end
		
end

// PWM output
always_ff @(posedge clk, negedge rst_n) begin

	// output flop
	if(!rst_n) begin
		PWM <= 0; 
	end
	else if (rst) begin
		PWM <= 0;
	end
	else if (set) begin
		PWM <= 1;
	end
	// otherwise hold value
	

end

endmodule
