`timescale 1ns/1ps

// Synchronous FSM traffic light controller.
module traffic_light_controller #(
    parameter integer GREEN_CYCLES  = 5,
    parameter integer YELLOW_CYCLES = 2,
    parameter integer RED_CYCLES    = 5
) (
    input  wire clk,
    input  wire reset,
    output reg  red,
    output reg  yellow,
    output reg  green
);

    localparam [1:0] STATE_GREEN  = 2'b00;
    localparam [1:0] STATE_YELLOW = 2'b01;
    localparam [1:0] STATE_RED    = 2'b10;

    reg [1:0] current_state;
    reg [1:0] next_state;
    integer cycle_count;
    integer state_duration;

    // Select the duration associated with the active state.
    always @* begin
        case (current_state)
            STATE_GREEN:  state_duration = GREEN_CYCLES;
            STATE_YELLOW: state_duration = YELLOW_CYCLES;
            STATE_RED:    state_duration = RED_CYCLES;
            default:      state_duration = GREEN_CYCLES;
        endcase
    end

    // The state transition logic advances after the final cycle.
    always @* begin
        next_state = current_state;

        if (cycle_count >= state_duration - 1) begin
            case (current_state)
                STATE_GREEN:  next_state = STATE_YELLOW;
                STATE_YELLOW: next_state = STATE_RED;
                STATE_RED:    next_state = STATE_GREEN;
                default:      next_state = STATE_GREEN;
            endcase
        end
    end

    // Synchronous, active-high reset starts the sequence at green.
    always @(posedge clk) begin
        if (reset) begin
            current_state <= STATE_GREEN;
            cycle_count   <= 0;
        end else begin
            current_state <= next_state;
            if (next_state != current_state)
                cycle_count <= 0;
            else
                cycle_count <= cycle_count + 1;
        end
    end

    // Moore outputs: exactly one light is active for every valid state.
    always @* begin
        red    = 1'b0;
        yellow = 1'b0;
        green  = 1'b0;

        case (current_state)
            STATE_GREEN:  green  = 1'b1;
            STATE_YELLOW: yellow = 1'b1;
            STATE_RED:    red    = 1'b1;
            default:      green  = 1'b1;
        endcase
    end

endmodule
