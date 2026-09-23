# Traffic Light Controller in Verilog

An RTL implementation of a single-road traffic light controller using a synchronous finite state machine (FSM). The project is intentionally compact and beginner-friendly while demonstrating synthesizable Verilog, state timing, reset behavior, simulation, and waveform verification.

## Project Overview

The controller continuously follows this sequence:

```text
GREEN -> YELLOW -> RED -> GREEN -> ...
```

Each state drives exactly one output light. A clocked counter keeps the active state for its configured duration, and a synchronous active-high reset returns the controller to `GREEN`.

## Objectives

- Model a real-world control problem with an FSM.
- Separate sequential state/counter logic from combinational next-state and output logic.
- Use clean, synthesizable Verilog RTL.
- Verify state sequence, timing, reset, and one-hot light outputs in simulation.

## Features

- Three Moore FSM states: `STATE_GREEN`, `STATE_YELLOW`, and `STATE_RED`.
- Parameterized timing: green = 5 cycles, yellow = 2 cycles, red = 5 cycles by default.
- Synchronous active-high reset.
- Self-checking testbench with VCD waveform generation.
- GTKWave-friendly internal `current_state` and `cycle_count` signals.

## FSM State Table

| State | Red | Yellow | Green | Duration |
|---|---:|---:|---:|---:|
| `STATE_GREEN` | 0 | 0 | 1 | 5 clock cycles |
| `STATE_YELLOW` | 0 | 1 | 0 | 2 clock cycles |
| `STATE_RED` | 1 | 0 | 0 | 5 clock cycles |

An FSM is a good fit because the controller has a small, finite set of operating modes and a deterministic transition sequence. The state register remembers the current mode, while combinational logic determines the next mode and output values.

## How It Works

At every rising edge of `clk`, the sequential block either applies reset or updates `current_state` and `cycle_count`. While a state is active, the counter increments. On the final cycle for that state, `next_state` changes and the counter resets to zero. Outputs are Moore-style combinational signals derived only from `current_state`, so exactly one light is asserted for every valid state.

The timing values can be changed at instantiation:

```verilog
traffic_light_controller #(
	.GREEN_CYCLES(10),
	.YELLOW_CYCLES(3),
	.RED_CYCLES(10)
) dut (...);
```

## Inputs and Outputs

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | System clock. State and counter update on its rising edge. |
| `reset` | Input | Synchronous active-high reset; starts in green. |
| `red` | Output | High only during `STATE_RED`. |
| `yellow` | Output | High only during `STATE_YELLOW`. |
| `green` | Output | High only during `STATE_GREEN`. |

## Repository Structure

```text
TRAFFIC-LIGHT-CONTROLLER-VERILOG/
├── rtl/
│   └── traffic_light_controller.v
├── tb/
│   └── traffic_light_controller_tb.v
├── waveform/
│   └── traffic_light_waveform.svg
├── docs/
│   └── block_diagram.svg
└── README.md
```

The block diagram represents the data flow `clock/reset -> FSM and counter -> traffic-light outputs`. The included SVG references are editable versions of the requested visuals. Export them to PNG for the portfolio using any SVG-capable editor, for example `docs/block_diagram.png` and `waveform/traffic_light_waveform.png`. The waveform should show `clk`, `reset`, `current_state`, `cycle_count`, `red`, `yellow`, and `green` across multiple complete sequences.

## Simulation

Install [Icarus Verilog](https://steveicarus.github.io/iverilog/) and [GTKWave](https://gtkwave.sourceforge.net/), then run from the repository root:

```sh
iverilog -g2012 -o traffic_sim rtl/traffic_light_controller.v tb/traffic_light_controller_tb.v
vvp traffic_sim
```

The testbench writes `traffic_light_waveform.vcd` in the repository root. Open it with:

```sh
gtkwave traffic_light_waveform.vcd
```

In GTKWave, add `clk`, `reset`, `dut.current_state`, `dut.cycle_count`, `red`, `yellow`, and `green`. The console should report:

```text
PASS: traffic light FSM timing, sequence, and one-hot outputs verified.
```

## Expected Behavior

After reset, `green=1`, `yellow=0`, and `red=0`. After five active green clock cycles the controller enters yellow for two cycles, then red for five cycles, and returns to green. The sequence repeats continuously, and no more than one light is high at a time.

## Technologies Used

- Verilog HDL
- RTL finite state machine design
- Icarus Verilog simulation
- GTKWave waveform inspection

## Future Improvements

- Two-way intersection control
- Pedestrian crossing request
- Emergency vehicle priority
- Night mode
- Traffic density input and sensors
- Additional parameterized timing profiles
- FPGA implementation with board-level LEDs

## Portfolio Verification Checklist

For a GitHub project screenshot, include the passing simulator console and a GTKWave view containing the state/counter signals and the repeating `GREEN -> YELLOW -> RED` outputs. Export the included SVG references as `waveform/traffic_light_waveform.png` and `docs/block_diagram.png` before publishing the portfolio repository.