#!/bin/bash
# Simulation run script for parameterized shift register
# Uses Xilinx Vivado simulator (xvlog, xelab, xsim)

set -e

mkdir -p results
cd results

echo "=== Compiling RTL and Testbench ==="
xvlog --sv ../../rtl/shift_register_pkg.sv
xvlog --sv ../../rtl/shift_register.v
xvlog --sv ../../tb/shift_register_tb.sv

echo "=== Elaborating design ==="
xelab shift_register_tb -s shift_register_tb_sim

echo "=== Running simulation ==="
xsim shift_register_tb_sim -runall

echo "=== Simulation complete ==="
echo "Waveform saved as waveforms.vcd in sim/results/"

cd ..