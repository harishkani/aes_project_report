# RTL Source Files

This directory contains all Verilog RTL source files for the AES-128 FPGA implementation.

## Directory Structure

```
rtl/
├── core/          # AES core implementations
├── modules/       # Transformation modules (S-box, ShiftRows, MixColumns, KeyExp)
├── display/       # Display controller
└── aes_fpga_top.v # Top-level FPGA module
```

## Core Implementations (`core/`)

### aes_core_ultimate.v ⭐ **MAIN DESIGN**
- Ultimate optimized AES core
- SRL optimization + Clock gating + S-box sharing
- Target: 500-600 LUTs, 3.8-4.5 Kbps/LUT
- Status: Architecture verified, ready for synthesis

### aes_core_optimized_srl.v
- SRL-optimized design (shift register primitives only)
- ~1,500 LUTs, 1.51 Kbps/LUT
- Intermediate optimization step

### aes_core_fixed.v
- Original baseline design
- 2,132 LUTs, 1.06 Kbps/LUT
- Reference implementation

## Transformation Modules (`modules/`)

### S-box Implementations
- **aes_sbox.v**: Forward S-box (LUT-based, 256×8)
- **aes_inv_sbox.v**: Inverse S-box (LUT-based, 256×8)
- **aes_sbox_composite_field.v**: Composite field S-box (GF(2^4)^2) - *debugging*
- **aes_subbytes_32bit_shared.v**: 32-bit SubBytes wrapper (currently using LUT)
- **aes_subbytes_32bit.v**: Original 32-bit SubBytes
- **aes_subbytes_32bit_lut_shared.v**: Alternative LUT wrapper

### Other Transformations
- **aes_shiftrows_128bit.v**: Full 128-bit ShiftRows/InvShiftRows
- **aes_mixcolumns_32bit.v**: 32-bit MixColumns/InvMixColumns (column-wise)
- **aes_key_expansion_otf.v**: On-the-fly key expansion (4-word window)

## Display Controller (`display/`)

### seven_seg_controller.v
- 7-segment display multiplexing
- Shows AES output in groups of 8 hex digits
- Interfaces with Nexys A7 board

## Top-Level Module

### aes_fpga_top.v ⭐
- Top-level wrapper for Nexys A7-100T board
- Interfaces: buttons, switches, LEDs, 7-segment display
- Instantiates ultimate AES core
- Test vector selection logic

## Module Hierarchy

```
aes_fpga_top
├── aes_core_ultimate
│   ├── BUFGCE (×3) - Clock gating
│   ├── aes_key_expansion_otf
│   │   └── aes_sbox (×4)
│   ├── aes_subbytes_32bit_shared
│   │   ├── aes_sbox (×4)
│   │   └── aes_inv_sbox (×4)
│   ├── aes_shiftrows_128bit
│   └── aes_mixcolumns_32bit
└── seven_seg_controller
```

## Usage

These files are referenced by the synthesis script in `../scripts/synthesize_ultimate.tcl`.

For simulation, compile in bottom-up order:
1. Basic modules (S-boxes)
2. Transformation modules (SubBytes, ShiftRows, MixColumns, KeyExp)
3. Core implementations
4. Top-level wrapper

Example:
```bash
iverilog -o sim \
    modules/aes_sbox.v \
    modules/aes_inv_sbox.v \
    modules/aes_subbytes_32bit_shared.v \
    modules/aes_shiftrows_128bit.v \
    modules/aes_mixcolumns_32bit.v \
    modules/aes_key_expansion_otf.v \
    core/aes_core_ultimate.v \
    aes_fpga_top.v
```
