task automatic send_cmd_task(ref reg clk,
                   input reg [7:0] cmd_num,
                   ref reg send_cmd,
                   ref reg [7:0] cmd_to_copter);
    begin
        cmd_to_copter = cmd_num;
        @(negedge clk)
        send_cmd = 1;
        @(negedge clk)
        send_cmd = 0;
    end
endtask
//not working if resp_rdy is a wire? don't use right now.
task automatic check_response_task(ref logic resp_rdy);
    begin
    //wait for response
        fork : chk
            begin
                // Timeout check
                #3000000
                $display("%t : timeout", $time);
                $stop;
                disable chk;
            end
            begin
                // Wait on signal
                @(posedge resp_rdy);
                $display("%t : resp received", $time);
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
            $display("BAD POSACK RECEIVED. FAILURE. %h",resp);
            $stop;
        end
    end
endtask

task check_batt_task(input reg [7:0] resp, input reg [7:0] expected);
    begin
        if(resp == expected)begin
            $display("batt Received.");
        end else begin
            $display("BAD BATT RECEIVED. FAILURE. %h",resp);
            $stop;
        end
    end
endtask

task automatic init_task(ref reg clk, ref reg RST_n, ref reg send_cmd);
    begin
        clk = 1;
        @(posedge clk)RST_n = 0;
        @(posedge clk)RST_n = 1;
        send_cmd = 0;
    end
endtask

task check_thrust_task(input reg [8:0] thrust, input reg [15:0] expected);
begin
        if(thrust == expected[8:0])begin
            $display("thrust set correctly.");
        end else begin
            $display("BAD THRUST SET. FAILURE. %h",thrust);
            $stop;
        end
    end
endtask

task check_pry_task(input reg [15:0] pry , input reg [15:0] expected);
begin
        if(pry == expected)begin
            $display("value set correctly.");
        end else begin
            $display("BAD VALUE SET. FAILURE. %h. expected = %h",pry, expected);
            $stop;
        end
    end
endtask

