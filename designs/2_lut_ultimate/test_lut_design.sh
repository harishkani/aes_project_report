#!/bin/bash
# Test LUT Ultimate Design

echo "Testing LUT Ultimate Design..."
cd "$(dirname "$0")"

# Clean
rm -f sim.vvp

# Compile
iverilog -g2012 -o sim.vvp \
    rtl/aes_sbox.v \
    rtl/aes_inv_sbox.v \
    rtl/aes_subbytes_32bit_shared.v \
    rtl/aes_shiftrows_128bit.v \
    rtl/aes_mixcolumns_32bit.v \
    rtl/aes_key_expansion_otf.v \
    rtl/aes_core_ultimate.v \
    tb/tb_aes_ultimate.v

if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

# Run
vvp sim.vvp
