# Vivado Source File List for Canright Ultimate Design

## Required RTL Files (in dependency order)

### 1. Canright S-box Sub-modules (GF arithmetic)
These must be added first as they have no dependencies:
```
rtl/canright_modules/gf_sq_2.v
rtl/canright_modules/gf_sclw_2.v
rtl/canright_modules/gf_sclw2_2.v
rtl/canright_modules/gf_muls_2.v
rtl/canright_modules/gf_muls_scl_2.v
rtl/canright_modules/mux21i.v
```

### 2. GF(2^4) Operations
Depend on GF(2^2) modules:
```
rtl/canright_modules/gf_inv_4.v
rtl/canright_modules/gf_sq_scl_4.v
rtl/canright_modules/gf_muls_4.v
```

### 3. GF(2^8) and Selection Modules
Depend on lower-level modules:
```
rtl/canright_modules/gf_inv_8.v
rtl/canright_modules/select_not_8.v
```

### 4. Core Canright S-box
Depends on all above modules:
```
rtl/canright_modules/bsbox.v
```

### 5. S-box Wrappers
```
rtl/aes_sbox.v                      # Standard LUT-based S-box (used by key expansion)
rtl/aes_sbox_canright_verified.v    # Canright S-box wrapper
```

### 6. AES Operation Modules
```
rtl/aes_subbytes_32bit_canright.v   # Uses aes_sbox_canright_verified
rtl/aes_shiftrows_128bit.v
rtl/aes_mixcolumns_32bit.v
rtl/aes_key_expansion_otf.v         # Uses aes_sbox (LUT-based)
```

### 7. Top-level Core
```
rtl/aes_core_ultimate_canright.v    # Top-level AES core
```

### 8. Testbench
```
tb/tb_aes_ultimate_canright.v
```

## Common Errors and Solutions

### Error: "module aes_sbox not found"
**Cause**: `aes_sbox.v` is not included in simulation sources
**Solution**: Ensure `rtl/aes_sbox.v` is added to simulation sources. This is used by the key expansion module.

### Error: "module GF_SQ_2 not found" (or other GF modules)
**Cause**: Canright sub-modules not included
**Solution**: Add all files from `rtl/canright_modules/` directory

### Error: Multiple module definitions
**Cause**: Using `include directives (old approach)
**Solution**: This design uses module instantiation. All files must be added to sources individually.

## Quick Setup Commands

### Using Vivado GUI:
1. Right-click "Design Sources" → Add Sources → Add or create design sources
2. Add all files from the list above
3. Right-click "Simulation Sources" → Add Sources → Add or create simulation sources
4. Add the testbench file

### Using Vivado TCL:
See `add_sources.tcl` script for automated setup.

## File Count Summary
- Canright sub-modules: 12 files
- AES operation modules: 6 files
- Testbench: 1 file
- **Total: 19 files**
