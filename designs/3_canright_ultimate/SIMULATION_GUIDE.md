# AES Canright Ultimate - Simulation Guide

## Required Files for Simulation

To properly simulate the AES Canright Ultimate design, you need to compile **ALL** of the following files in this exact order:

### 1. S-box Modules (Base Dependencies)
```
rtl/aes_sbox.v                          # LUT-based S-box for key expansion
rtl/aes_sbox_canright_verified.v        # Canright composite field S-box for data path
```

### 2. AES Transformation Modules
```
rtl/aes_subbytes_32bit_canright.v       # SubBytes using Canright S-boxes
rtl/aes_shiftrows_128bit.v              # ShiftRows transformation
rtl/aes_mixcolumns_32bit.v              # MixColumns transformation
```

### 3. Key Expansion
```
rtl/aes_key_expansion_otf.v             # On-the-fly key expansion
```

### 4. Top-Level Core
```
rtl/aes_core_ultimate_canright.v        # AES core with Canright S-boxes
```

### 5. Testbench
```
tb/tb_aes_ultimate_canright.v           # Integration testbench
```

## Simulation with Icarus Verilog

```bash
# Compile all files
iverilog -o sim.vvp \
    rtl/aes_sbox.v \
    rtl/aes_sbox_canright_verified.v \
    rtl/aes_subbytes_32bit_canright.v \
    rtl/aes_shiftrows_128bit.v \
    rtl/aes_mixcolumns_32bit.v \
    rtl/aes_key_expansion_otf.v \
    rtl/aes_core_ultimate_canright.v \
    tb/tb_aes_ultimate_canright.v

# Run simulation
vvp sim.vvp
```

## Simulation with Vivado XSim

```bash
# Compile
xvlog rtl/aes_sbox.v
xvlog rtl/aes_sbox_canright_verified.v
xvlog rtl/aes_subbytes_32bit_canright.v
xvlog rtl/aes_shiftrows_128bit.v
xvlog rtl/aes_mixcolumns_32bit.v
xvlog rtl/aes_key_expansion_otf.v
xvlog rtl/aes_core_ultimate_canright.v
xvlog tb/tb_aes_ultimate_canright.v

# Elaborate
xelab -debug typical tb_aes_ultimate_canright -s sim

# Run
xsim sim -runall
```

## Common Issues

### Issue: All outputs show 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

**Cause**: Missing source files in compilation. The `aes_sbox.v` module MUST be included even though the data path uses Canright S-boxes, because the key expansion module uses the LUT-based S-box.

**Solution**: Ensure ALL files listed above are compiled in the correct order.

### Issue: Module not found errors

**Cause**: Files compiled out of order or missing dependencies.

**Solution**: Follow the exact compilation order shown above.

## Expected Test Results

When properly simulated, you should see:
- **Total Tests**: 10
- **Tests Passed**: 10
- **Tests Failed**: 0
- **Success Rate**: 100%

All NIST FIPS 197 test vectors should pass.
