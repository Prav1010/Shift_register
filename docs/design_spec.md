# Design Specification: Parameterized Shift Register

## 1. Overview

This document describes the design, architecture, and verification plan for a configurable shift register module. The design targets reuse across multiple bit-widths and pipeline depths, commonly needed in data serialization/deserialization blocks, SPI/UART interfaces, and general-purpose datapath shifting logic.

## 2. Requirements

| ID | Requirement |
|----|-------------|
| R1 | Support configurable width: 4, 8, 16, or 32 bits |
| R2 | Support configurable depth: 1 to 8 pipeline stages |
| R3 | Support parallel load mode (load full width in one clock) |
| R4 | Support serial load mode (shift in one bit per clock) |
| R5 | Support configurable shift direction: left or right |
| R6 | Provide both parallel and serial outputs |
| R7 | Asynchronous active-low reset clears all stages to 0 |
| R8 | Enable signal (`en`) gates all state updates |

## 3. Architecture

The design consists of `DEPTH` pipeline stages, each `WIDTH` bits wide, implemented as an array of registers (`stage[0:DEPTH-1]`).

- **stage[0]** is the "input" stage — it receives either `parallel_in` (load mode) or the shifted value (serial mode).
- Each subsequent stage receives the value from the stage before it on every clock edge (pipe

  line behavior).
- **stage[DEPTH-1]** drives both `parallel_out` and `serial_out`.

### 3.1 Load Mode (load = 1)
`stage[0]` is loaded directly from `parallel_in`. All other stages shift forward from the previous stage (pipeline advance).

### 3.2 Serial Shift Mode (load = 0)
`stage[0]` shifts in `serial_in`:
- If `DIR = 1` (left): `stage[0] <= {stage[0][WIDTH-2:0], serial_in}` — MSB shifts out over stages, new bit enters at LSB.
- If `DIR = 0` (right): `stage[0] <= {serial_in, stage[0][WIDTH-1:1]}` — LSB shifts out over stages, new bit enters at MSB.

### 3.3 Hold (en = 0)
No stage updates occur; all registers retain their current value.

### 3.4 Reset (rst_n = 0)
Asynchronous, active-low. All stages are cleared to 0 immediately, regardless of clock.

## 4. Timing

- All state updates occur on the **rising edge** of `clk`.
- Reset is **asynchronous** — it takes effect immediately on `rst_n` going low, independent of `clk`.
- Signal priority per clock edge: `rst_n` > `en` > `load` > shift.

## 5. Parameter Table

| Parameter | Type | Default | Valid Range | Description |
|-----------|------|---------|-------------|--------------|
| WIDTH | int | 8 | 4, 8, 16, 32 | Register bit-width |
| DEPTH | int | 4 | 1–8 | Number of pipeline stages |
| DIR | int (0/1) | 1 | 0 or 1 | 0 = right shift, 1 = left shift |

## 6. Verification Plan

| Test | Purpose | Pass Criteria |
|------|---------|----------------|
| Reset | Confirm all stages clear on rst_n=0 | parallel_out = 0 after reset |
| Parallel Load | Confirm parallel_in loads into stage[0] and propagates | parallel_out matches loaded value after DEPTH cycles |
| Serial Shift Left | Confirm correct left-shift behavior | Output bit pattern matches expected shift sequence |
| Serial Shift Right | Confirm correct right-shift behavior | Output bit pattern matches expected shift sequence |
| Hold | Confirm no change when en=0 | parallel_out unchanged across clock edges |
| Reload | Confirm design can re-enter load mode after hold/shift | New parallel_in value correctly loaded |
| Width Sweep | Confirm design works at WIDTH = 4, 8, 16, 32 | All widths pass same test sequence |
| Depth Sweep | Confirm design works at DEPTH = 1 and DEPTH = 8 (edge cases) | Pipeline propagation correct at min/max depth |

## 7. Known Limitations / Future Work

- Current testbench uses a fixed WIDTH=8, DEPTH=4, DIR=1 configuration; width/depth sweep tests should be added as separate testbench instances or a parameterized test harness.
- No support currently for simultaneous load + shift in the same cycle (load takes priority).
- Synchronous reset variant not implemented (only asynchronous reset supported).