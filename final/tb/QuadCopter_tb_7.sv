//EMERGENCY LAND TEST//

`include "tb_tasks.sv"	// maybe have a separate file with tasks to help with testing

module QuadCopter_tb_7();
			
//// Interconnects to DUT/support defined as type wire /////
wire SS_n,SCLK,MOSI,MISO,INT;
wire SS_A2D_n,SCLK_A2D,MOSI_A2D,MISO_A2D;
wire RX,TX;
wire [7:0] resp;				// response from DUT
wire cmd_sent, resp_rdy;
wire frnt_ESC, back_ESC, left_ESC, rght_ESC;

////// Stimulus is declared as type reg ///////
reg clk, RST_n;
reg [7:0] cmd_to_copter;		// command to Copter via wireless link
reg [15:0] data;				// data associated with command
reg send_cmd;					// asserted to initiate sending of command (to your CommMaster)
reg clr_resp_rdy;				// asserted to knock down resp_rdy
reg [15:0] sample;
/////// declare any localparams here /////


////////////////////////////////////////////////////////////////
// Instantiate Physical Model of Copter with Inertial sensor //
//////////////////////////////////////////////////////////////	
CycloneIV iQuad(.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI),.INT(INT),
                .frnt_ESC(frnt_ESC),.back_ESC(back_ESC),.left_ESC(left_ESC),
				.rght_ESC(rght_ESC));				  

///////////////////////////////////////////////////
// Instantiate Model of A2D for battery voltage //
/////////////////////////////////////////////////
ADC128S iA2D(.clk(clk),.rst_n(RST_n),.SS_n(SS_A2D_n),.SCLK(SCLK_A2D),
             .MISO(MISO_A2D),.MOSI(MOSI_A2D));			
	 
////// Instantiate DUT ////////
QuadCopter #(3) iDUT(.clk(clk),.RST_n(RST_n),.SS_n(SS_n),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO),
                .INT(INT),.RX(RX),.TX(TX),.LED(),.FRNT(frnt_ESC),.BCK(back_ESC),
				.LFT(left_ESC),.RGHT(rght_ESC),.SS_A2D_n(SS_A2D_n),.SCLK_A2D(SCLK_A2D),
				.MOSI_A2D(MOSI_A2D),.MISO_A2D(MISO_A2D));


//// Instantiate Master UART (used to send commands to Copter) //////
CommMaster iMSTR(.clk(clk), .rst_n(RST_n), .RX(TX), .TX(RX),
                 .cmd(cmd_to_copter), .data(data), .send_cmd(send_cmd),
			     .frm_snt(cmd_sent), .resp_rdy(resp_rdy), .resp(resp));

reg resp_rdy_f;
always_ff @(posedge clk) resp_rdy_f <= resp_rdy;

initial begin
    init_task(clk,RST_n,send_cmd);
    
    //CALIBRATE//
    send_cmd_task(clk, 8'h06, send_cmd, cmd_to_copter); // calibrate
    //wait for response
    fork : cal
        begin
            // Timeout check
            #300000000
            $display("%t : timeout waiting for calibration", $time);
            $stop;
            disable cal;
        end
        begin
            // Wait on signal
            @(posedge resp_rdy);
            $display("calibration done");
            disable cal;
        end
    join
    
    //THRUST//
    data = 16'h01FF;    
    send_cmd_task(clk,3'd5,send_cmd,cmd_to_copter);

    //wait for response
    fork : chk
        begin
            // Timeout check
            #3000000
            $display("%t : timeout waiting to set thrust", $time);
            $stop;
            disable chk;
        end
        begin
            // Wait on signal
            @(posedge resp_rdy);
            $display("cmd 5 resp received");
            disable chk;
        end
    join

    check_posack_task(resp);
    check_thrust_task(iDUT.ifly.thrst,data);
    
    
    //AIRBORNE//
    // check that it eventually gets off the ground
    fork : detect_air
        begin
            // Timeout check
            #300000000
            $display("%t : timeout waiting for airborne", $time);
            $stop;
            disable detect_air;
        end
        begin
            // Wait on signal
            @(posedge iQuad.airborne);
            $display("detected airborne");
            disable detect_air;
        end
    join
 
    
    ///////////////SET to nonzero////////////////////////
    //Set pitch
    data = 16'h0050;  
    send_cmd_task(clk,3'd2,send_cmd,cmd_to_copter);
    check_response_task(resp_rdy_f);
    check_posack_task(resp);

    //Set roll
    send_cmd_task(clk,3'd3,send_cmd,cmd_to_copter);
    check_response_task(resp_rdy_f);
    check_posack_task(resp);
    
    //Set yaw
    send_cmd_task(clk,3'd4,send_cmd,cmd_to_copter);
    check_response_task(resp_rdy_f);
    check_posack_task(resp);
    
    #300000000
    sample = iDUT.iNEMO.iII.yaw;
    sample = iDUT.iNEMO.iII.roll;
    sample = iDUT.iNEMO.iII.ptch;
    ////////////////EMERLAND////////////////////
    data = 16'h0000;
    send_cmd_task(clk, 3'd7, send_cmd, cmd_to_copter);
    
    //wait for response
    check_response_task(resp_rdy_f);

    //Check for all zeros
    check_posack_task(resp);


    
    #400000000
//    
//    #30000000
//    //TODO:These should be from ifly(fight control) but there is a weird error
//    $display("Checking thrust.");
//    check_thrust_task(iDUT.ifly.thrst,data);
//    $display("Checking pitch.");
//    check_pry_task(iDUT.iNEMO.ptch_rt,data);
//    $display("Checking roll.");
//    check_pry_task(iDUT.iNEMO.roll_rt,data);
//    $display("Checking yaw.");
//    check_pry_task(iDUT.iNEMO.yaw_rt,data);
        
    //check values 
    $display("PITCH");
    check_pry_task(sample, 16'h0000, iDUT.iNEMO.iII.ptch);
    $display("ROLL");
    check_pry_task(sample, 16'h0000, iDUT.iNEMO.iII.roll);
    $display("YAW");
    check_pry_task(sample, 16'h0000, iDUT.iNEMO.iII.yaw);

    $display("Emergency land test passed");
    $stop;
 
end

always
  #10 clk = ~clk;

endmodule	
