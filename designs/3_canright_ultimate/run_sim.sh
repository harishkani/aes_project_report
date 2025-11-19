#!/bin/bash
# ==============================================================================
# Simple simulation script for AES Canright Ultimate Design
# ==============================================================================

echo "========================================="
echo "AES Canright Ultimate - Simulation"
echo "========================================="

# Change to design directory
cd "$(dirname "$0")"

# Clean previous simulation
echo "Cleaning previous simulation files..."
rm -rf xsim.dir .Xil *.jou *.log *.pb *.wdb 2>/dev/null

# Compile all source files
echo ""
echo "Compiling source files..."

# S-box modules
xvlog rtl/aes_sbox.v || exit 1
xvlog rtl/aes_sbox_canright_verified.v || exit 1

# AES transformation modules
xvlog rtl/aes_subbytes_32bit_canright.v || exit 1
xvlog rtl/aes_shiftrows_128bit.v || exit 1
xvlog rtl/aes_mixcolumns_32bit.v || exit 1

# Key expansion
xvlog rtl/aes_key_expansion_otf.v || exit 1

# Top-level core
xvlog rtl/aes_core_ultimate_canright.v || exit 1

# Testbench
xvlog tb/tb_aes_ultimate_canright.v || exit 1

# Elaborate
echo ""
echo "Elaborating design..."
xelab -debug typical tb_aes_ultimate_canright -s sim || exit 1

# Run simulation
echo ""
echo "Running simulation..."
echo "========================================="
xsim sim -runall

echo ""
echo "========================================="
echo "Simulation complete!"
echo "========================================="
