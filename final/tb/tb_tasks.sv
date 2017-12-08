task send_cmd_task(input reg [7:0] cmd_num,
                   output reg send_cmd,
                   output reg cmd_to_copter);
    begin
        cmd_to_copter = cmd_num;
        send_cmd = 1;
    end
endtask

task check_response_task(input reg resp_rdy);
    begin
    fork : chk
        begin
            // Timeout check
            #1000000
            $display("%t : timeout", $time);
            $stop;
            disable chk;
        end
        begin
            // Wait on signal
            @(posedge resp_rdy);
            disable chk;
        end
    join
    end
endtask

task check_posack_task(input reg [7:0] resp);
    begin
        if(resp == 8'ha5)begin
            $display("PosAck Received.");
        end else begin
            $display("PosAck not received.");
            $stop;
        end
    end
endtask

task check_batt_task(input reg [7:0] resp);
    begin
        if(resp == 8'hc0)begin
            $display("batt Received.");
        end else begin
            $display("batt not received.");
            $stop;
        end
    end
endtask
