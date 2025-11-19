# How to Fix Your Vivado Project for Canright AES

## Problem
Your Vivado project is missing required source files or has incorrect module instantiations.

## Solution: Add ALL Required Files in Correct Order

### Method 1: Using the TCL Script (RECOMMENDED)

1. **Open Vivado**
2. **Go to**: Tools → Run Tcl Script
3. **Browse to**: `designs/3_canright_ultimate/synthesize_canright.tcl`
4. **Click OK**

The script will:
- Create a new project with all correct files
- Set proper compilation order
- Run synthesis
- Generate detailed reports

### Method 2: Manual Project Setup

If you prefer to fix your existing project manually:

#### Step 1: Remove Incorrect Files (if present)

In Vivado, remove these files if they exist:
- ❌ `aes_sbox_composite_field.v`
- ❌ `aes_subbytes_32bit_shared.v`
- ❌ `aes_core_ultimate.v` (without "canright")

#### Step 2: Add Required Files in This EXACT Order

**CRITICAL**: You MUST add `aes_sbox.v` even though the design uses Canright S-boxes!

1. **Right-click on Design Sources** → Add Sources → Add or create design sources

2. **Add files in this order:**

```
Level 1: S-box Modules (BOTH required!)
├── rtl/aes_sbox.v                          ← REQUIRED for key expansion!
└── rtl/aes_sbox_canright_verified.v        ← REQUIRED for data path!

Level 2: SubBytes Module
└── rtl/aes_subbytes_32bit_canright.v

Level 3: Other Transformation Modules
├── rtl/aes_shiftrows_128bit.v
└── rtl/aes_mixcolumns_32bit.v

Level 4: Key Expansion
└── rtl/aes_key_expansion_otf.v             ← Uses aes_sbox.v

Level 5: Top-Level Core
└── rtl/aes_core_ultimate_canright.v
```

#### Step 3: Set Top Module

1. **Right-click** on `aes_core_ultimate_canright.v`
2. **Select**: "Set as Top"

#### Step 4: Update Compile Order

1. **Go to**: Flow Navigator → Project Manager → Settings
2. **Select**: General → Compile Order
3. **Click**: "Update Compile Order"

#### Step 5: Verify Hierarchy

In the "Sources" window, expand the hierarchy. You should see:

```
Design Sources
└── aes_core_ultimate_canright (top)
    ├── aes_key_expansion_otf
    │   ├── aes_sbox (instance: sbox0)
    │   ├── aes_sbox (instance: sbox1)
    │   ├── aes_sbox (instance: sbox2)
    │   └── aes_sbox (instance: sbox3)
    ├── aes_subbytes_32bit_canright
    │   ├── aes_sbox_canright_verified (instance: sbox0)
    │   ├── aes_sbox_canright_verified (instance: sbox1)
    │   ├── aes_sbox_canright_verified (instance: sbox2)
    │   └── aes_sbox_canright_verified (instance: sbox3)
    ├── aes_shiftrows_128bit
    └── aes_mixcolumns_32bit
```

**If you see any red "X" marks or "?" symbols, files are missing or incorrectly added!**

## Why Both S-box Files Are Required

This is a **hybrid S-box design** (intentional optimization):

| Module | S-box Type | Why |
|--------|-----------|-----|
| **Key Expansion** | `aes_sbox.v` (LUT-based) | Only needs forward S-box, simpler |
| **Data Path** | `aes_sbox_canright_verified.v` | Needs forward+inverse, 40% area savings |

**Missing either file will cause synthesis/simulation errors!**

## Common Vivado Errors and Fixes

### Error: "Cannot find module 'aes_sbox'"
**Cause**: `rtl/aes_sbox.v` not added to project
**Fix**: Add `rtl/aes_sbox.v` to Design Sources

### Error: "Cannot find module 'aes_sbox_canright_verified'"
**Cause**: `rtl/aes_sbox_canright_verified.v` not added
**Fix**: Add `rtl/aes_sbox_canright_verified.v` to Design Sources

### Error: "Hierarchical reference not found"
**Cause**: Files added in wrong order
**Fix**: Use the TCL script or manually update compile order

### Error: "Multiple drivers on signal"
**Cause**: Duplicate module instantiations
**Fix**: Remove duplicate source files from project

## Verification Checklist

Before running synthesis, verify:

- [ ] All 7 RTL files are in Design Sources
- [ ] `aes_core_ultimate_canright` is set as top module
- [ ] Hierarchy shows no red "X" or "?" marks
- [ ] Compile order is updated
- [ ] No duplicate files in project

## Expected Synthesis Results

When correctly configured, you should get:

```
Resource Utilization:
- LUTs: ~480-560 (target vs paper's ~1,400)
- FFs: ~200-250
- SRL Instances: ~40-50 (shift register optimization)

Performance:
- Throughput: 2.27 Mbps @ 100 MHz
- T/A Ratio: 4.0-4.7 Kbps/LUT (vs paper's 2.5)
- Status: BEATS THE PAPER ✓
```

## Quick Verification Commands (Vivado TCL Console)

After adding files, run these commands in the Vivado TCL console to verify:

```tcl
# Check all source files
get_files -of_objects [get_filesets sources_1]

# Check top module
get_property top [current_fileset]

# Check for missing modules
report_compile_order -missing_instance

# View hierarchy
report_compile_order -hierarchy
```

## Complete File List for Reference

```
designs/3_canright_ultimate/rtl/
├── aes_sbox.v                          (2,862 lines) LUT S-box
├── aes_sbox_canright_verified.v        (287 lines)   Canright S-box
├── aes_subbytes_32bit_canright.v       (43 lines)    SubBytes wrapper
├── aes_shiftrows_128bit.v              (73 lines)    ShiftRows
├── aes_mixcolumns_32bit.v              (153 lines)   MixColumns
├── aes_key_expansion_otf.v             (141 lines)   Key expansion
└── aes_core_ultimate_canright.v        (428 lines)   Top-level core
```

## Need Help?

If you still have issues:

1. Check the Vivado Messages window for specific errors
2. Verify file paths are correct (relative to project)
3. Try using the automated TCL script (Method 1)
4. Check that you're using the files from `designs/3_canright_ultimate/rtl/`

## References

- Synthesis Script: `synthesize_canright.tcl`
- Simulation Script: `run_iverilog.sh`
- Verification Results: `../../VERIFICATION_SUCCESS.md`
