module A2D_test(clk, RST_n, SS_n, SCLK, MOSI, MISO, LED);
input clk, RST_n;
input MISO;
output SS_n, SCLK, MOSI;
output reg [7:0] LED;

reg strt_cnv;
wire rst_n;
wire cnv_cmplt;
wire [11:0] res;

typedef enum reg {RQ, WAIT} state_t;
state_t state, nxt_state;

reset_synch iRS(.RST_n(RST_n), .clk(clk), .rst_n(rst_n));
A2D_intf iA2D(.clk(clk), .rst_n(rst_n),
	.strt_cnv(strt_cnv), .chnnl(3'b000), 
	.SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO),
	.res(res), .cnv_cmplt(cnv_cmplt));

//LED FF
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) LED <= 8'b10101010;
	else if (cnv_cmplt) LED <= res[11:4];
	else LED <= LED;
	
end
	
//FSM//
always_ff @(posedge clk, negedge rst_n)
	if (!rst_n) state <= RQ;
	else state <= nxt_state;
	
always_comb begin
	strt_cnv = 0;
	nxt_state = RQ;
	
	case(state)
		RQ: 
			begin
				nxt_state = WAIT;
				strt_cnv = 1;
			end
	
		WAIT: 
			if (cnv_cmplt) nxt_state = RQ;
			else nxt_state = WAIT;
	endcase
end

endmodule