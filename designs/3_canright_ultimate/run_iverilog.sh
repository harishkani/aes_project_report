#!/bin/bash
# ==============================================================================
# Icarus Verilog Simulation Script for AES Canright Ultimate Design
# ==============================================================================

echo "========================================="
echo "AES Canright Ultimate - IVerilog Simulation"
echo "========================================="

# Change to design directory
cd "$(dirname "$0")"

# Clean previous simulation
echo "Cleaning previous simulation files..."
rm -f sim.vvp sim.vcd 2>/dev/null

# Compile all source files in dependency order
echo ""
echo "Compiling source files with Icarus Verilog..."

iverilog -g2012 -o sim.vvp \
    -y rtl \
    -I rtl \
    rtl/aes_sbox.v \
    rtl/aes_sbox_canright_verified.v \
    rtl/aes_subbytes_32bit_canright.v \
    rtl/aes_shiftrows_128bit.v \
    rtl/aes_mixcolumns_32bit.v \
    rtl/aes_key_expansion_otf.v \
    rtl/aes_core_ultimate_canright.v \
    tb/tb_aes_ultimate_canright.v

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Compilation failed!"
    exit 1
fi

# Run simulation
echo ""
echo "Running simulation..."
echo "========================================="
vvp sim.vvp

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Simulation failed!"
    exit 1
fi

echo ""
echo "========================================="
echo "Simulation complete!"
echo "========================================="
