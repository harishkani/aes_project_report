# Vivado Source File List for Canright Ultimate Design

## Required RTL Files (in dependency order)

### 1. S-box Modules
```
rtl/aes_sbox.v                      # Standard LUT-based S-box (used by key expansion)
rtl/aes_sbox_canright.v             # Consolidated Canright S-box (all 13 modules in one file)
```

**Note**: The Canright S-box implementation is provided as a single consolidated file containing all 13 Galois Field arithmetic modules. This simplifies project setup compared to managing 12 separate sub-module files.

### 2. AES Operation Modules
```
rtl/aes_subbytes_32bit_canright.v   # SubBytes using Canright S-box
rtl/aes_shiftrows_128bit.v          # ShiftRows transformation
rtl/aes_mixcolumns_32bit.v          # MixColumns transformation
rtl/aes_key_expansion_otf.v         # On-the-fly key expansion (uses LUT S-box)
```

### 3. Top-level Core
```
rtl/aes_core_ultimate_canright.v    # Top-level AES core
```

### 4. Testbench
```
tb/tb_aes_ultimate_canright.v       # Comprehensive testbench
```

## Common Errors and Solutions

### Error: "module aes_sbox not found"
**Cause**: `aes_sbox.v` is not included in simulation sources
**Solution**: Ensure `rtl/aes_sbox.v` is added to simulation sources. This is used by the key expansion module.

### Error: "module GF_SQ_2 not found" (or other GF modules)
**Cause**: Consolidated Canright S-box file not included
**Solution**: Ensure `rtl/aes_sbox_canright.v` is added to sources. This file contains all 13 Canright modules.

### Error: "module aes_sbox_canright not found"
**Cause**: Missing the consolidated Canright S-box file
**Solution**: Add `rtl/aes_sbox_canright.v` which contains all Galois Field arithmetic modules.

## Quick Setup Commands

### Using Vivado GUI:
1. Right-click "Design Sources" → Add Sources → Add or create design sources
2. Add all files from the list above
3. Right-click "Simulation Sources" → Add Sources → Add or create simulation sources
4. Add the testbench file

### Using Vivado TCL:
See `add_sources.tcl` script for automated setup.

## File Count Summary
- S-box modules: 2 files (1 LUT + 1 consolidated Canright)
- AES operation modules: 5 files
- Testbench: 1 file
- **Total: 8 files**

## Design Philosophy

This design uses a **consolidated single-file approach** for the Canright S-box implementation. All 13 Galois Field arithmetic modules (GF_SQ_2, GF_SCLW_2, GF_INV_4, GF_INV_8, etc.) are contained within `aes_sbox_canright.v`. This simplifies project management by reducing the file count from 19 to 8 total files, making it much easier to set up and maintain.
