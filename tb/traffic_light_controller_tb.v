`timescale 1ns/1ps

module traffic_light_controller_tb;

    localparam integer GREEN_CYCLES  = 5;
    localparam integer YELLOW_CYCLES = 2;
    localparam integer RED_CYCLES    = 5;

    reg clk;
    reg reset;
    wire red;
    wire yellow;
    wire green;

    integer errors;
    integer cycle;

    traffic_light_controller #(
        .GREEN_CYCLES(GREEN_CYCLES),
        .YELLOW_CYCLES(YELLOW_CYCLES),
        .RED_CYCLES(RED_CYCLES)
    ) dut (
        .clk(clk),
        .reset(reset),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    always #5 clk = ~clk;

    task check_lights;
        input expected_red;
        input expected_yellow;
        input expected_green;
        input [127:0] expected_state;
        begin
            if ({red, yellow, green} !== {expected_red, expected_yellow, expected_green}) begin
                $display("ERROR at %0t: expected %s lights, got RYG=%b%b%b", $time,
                         expected_state, red, yellow, green);
                errors = errors + 1;
            end
            if ((red + yellow + green) > 1) begin
                $display("ERROR at %0t: more than one light is active", $time);
                errors = errors + 1;
            end
        end
    endtask

    task check_one_hot;
        begin
            if ((red + yellow + green) !== 1) begin
                $display("ERROR at %0t: expected exactly one active light, got RYG=%b%b%b", $time,
                         red, yellow, green);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        errors = 0;

        $dumpfile("traffic_light_waveform.vcd");
        $dumpvars(0, traffic_light_controller_tb);

        repeat (2) @(posedge clk);
        #1;
        check_lights(1'b0, 1'b0, 1'b1, "GREEN");

        reset = 1'b0;

        for (cycle = 1; cycle <= GREEN_CYCLES - 1; cycle = cycle + 1) begin
            @(posedge clk); #1;
            check_lights(1'b0, 1'b0, 1'b1, "GREEN");
        end
        @(posedge clk); #1;
        check_lights(1'b0, 1'b1, 1'b0, "YELLOW");

        for (cycle = 1; cycle <= YELLOW_CYCLES - 1; cycle = cycle + 1) begin
            @(posedge clk); #1;
            check_lights(1'b0, 1'b1, 1'b0, "YELLOW");
        end
        @(posedge clk); #1;
        check_lights(1'b1, 1'b0, 1'b0, "RED");

        for (cycle = 1; cycle <= RED_CYCLES - 1; cycle = cycle + 1) begin
            @(posedge clk); #1;
            check_lights(1'b1, 1'b0, 1'b0, "RED");
        end
        @(posedge clk); #1;
        check_lights(1'b0, 1'b0, 1'b1, "GREEN");

        // Run another complete cycle to prove continuous operation.
        repeat (GREEN_CYCLES + YELLOW_CYCLES + RED_CYCLES) begin
            @(posedge clk); #1;
            check_one_hot;
        end

        if (errors == 0)
            $display("PASS: traffic light FSM timing, sequence, and one-hot outputs verified.");
        else
            $display("FAIL: %0d error(s) detected.", errors);

        $finish;
    end

endmodule
