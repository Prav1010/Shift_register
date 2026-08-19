# Parameterized Shift Register

A configurable shift register implemented in Verilog/SystemVerilog, supporting variable bit-width (4, 8, 16, or 32 bits), variable pipeline depth (1 to 8 stages), parallel and serial load modes, and selectable shift direction (left or right). Built as a reusable RTL block for chip-design portfolio purposes, with a full self-checking testbench and simulation flow using Xilinx Vivado.

## Block Diagram
    parallel_in [WIDTH-1:0]
          |
          v


## Port Description

| Port | Direction | Width | Description |
|------|-----------|-------|--------------|
| clk | input | 1 | System clock |
| rst_n | input | 1 | Active-low asynchronous reset |
| en | input | 1 | Enable signal — register holds value when low |
| load | input | 1 | 1 = parallel load mode, 0 = serial shift mode |
| serial_in | input | 1 | Serial data input |
| parallel_in | input | WIDTH | Parallel data input |
| parallel_out | output | WIDTH | Parallel data output (last stage) |
| serial_out | output | 1 | Serial data output (MSB or LSB of last stage, depending on direction) |

## Parameters

| Parameter | Values | Description |
|-----------|--------|--------------|
| WIDTH | 4, 8, 16, 32 | Bit-width of the register |
| DEPTH | 1–8 | Number of pipeline stages |
| DIR | 0 or 1 | Shift direction: 0 = right, 1 = left |

## Usage Example

```verilog
shift_register #(
    .WIDTH(8),
    .DEPTH(4),
    .DIR(1)
) u_shift_reg (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .load(load),
    .serial_in(serial_in),
    .parallel_in(parallel_in),
    .parallel_out(parallel_out),
    .serial_out(serial_out)
);
```

## Simulation Results

The testbench (`tb/shift_register_tb.sv`) runs 5 self-checking tests:
1. Reset behavior
2. Parallel load
3. Serial shift
4. Hold (enable low)
5. Reload after hold

All tests print PASS/FAIL to the simulation log, with a final summary. Waveforms are saved to `sim/results/waveforms.vcd` and can be viewed in Vivado's waveform viewer or GTKWave.

## How to Run

```bash
cd sim
./run.sh
```

This compiles the RTL and testbench, elaborates the design, and runs the simulation using Xilinx Vivado's simulator (`xvlog`, `xelab`, `xsim`). Results and waveforms are saved in `sim/results/`.

## Repository Structure        