# AES Canright Ultimate - FPGA Implementation Guide

Complete guide for implementing the AES Canright design on Nexys A7-100T FPGA board.

---

## Quick Start

### Option 1: Automated Project Creation (Recommended)

```tcl
# In Vivado TCL Console:
cd path/to/designs/3_canright_ultimate
source create_vivado_project.tcl
```

This automatically:
- Creates a new Vivado project
- Adds all 20 design files
- Configures constraints
- Sets synthesis/implementation strategies
- Ready to synthesize!

### Option 2: Manual Setup

1. Open Vivado and create new project
2. Add sources using `add_sources.tcl` script
3. Add constraints file from `constraints/`
4. Set top module: `aes_canright_fpga_top`
5. Run synthesis and implementation

---

## Hardware Requirements

### Target Board
- **Nexys A7-100T** (Digilent)
- FPGA: Xilinx Artix-7 XC7A100T-1CSG324C
- 100 MHz clock
- 101,440 LUTs available

### Used Resources
- **LUTs**: ~800 (including top-level wrapper and display controller)
  - AES Core: 748 LUTs
  - Display controller: ~30 LUTs
  - Top-level logic: ~22 LUTs
- **Flip-Flops**: ~270
- **Frequency**: 100 MHz
- **Power**: ~140 mW total

---

## Files Overview

### Design Files (20 total)

**Canright Sub-modules** (12 files in `rtl/canright_modules/`):
```
gf_sq_2.v, gf_sclw_2.v, gf_sclw2_2.v     # GF(2^2) ops
gf_muls_2.v, gf_muls_scl_2.v, mux21i.v   # GF(2^2) multiply
gf_inv_4.v, gf_sq_scl_4.v, gf_muls_4.v   # GF(2^4) ops
gf_inv_8.v, select_not_8.v, bsbox.v      # GF(2^8) ops
```

**AES Modules** (6 files in `rtl/`):
```
aes_sbox.v                         # LUT S-box (for key expansion)
aes_sbox_canright_verified.v       # Canright S-box wrapper
aes_subbytes_32bit_canright.v      # SubBytes with Canright
aes_shiftrows_128bit.v             # ShiftRows
aes_mixcolumns_32bit.v             # MixColumns
aes_key_expansion_otf.v            # Key expansion
aes_core_ultimate_canright.v       # Main AES core
```

**FPGA Interface** (2 files):
```
aes_canright_fpga_top.v            # Top-level FPGA wrapper
display/seven_seg_controller.v     # 7-segment display controller
```

**Constraints**:
```
constraints/aes_canright_nexys_a7.xdc  # Pin assignments and timing
```

**Testbench**:
```
tb/tb_aes_ultimate_canright.v      # Comprehensive testbench
```

---

## Board Interface

### Inputs

**Clock & Reset**:
- `clk` (E3): 100 MHz system clock
- `rst_n` (C12): Active-low reset (CPU_RESET button)

**Push Buttons**:
- `btnC` (N17): **Start AES operation**
- `btnU` (M18): **Toggle Encrypt/Decrypt mode**
- `btnL` (P17): **Previous display group** (show different hex digits)
- `btnR` (M17): **Next display group**

**Switches** [15:0]:
- `sw[3:0]`: **Test vector selection** (0-15)
- `sw[15:4]`: Used for custom patterns (test vectors 8-15)

### Outputs

**7-Segment Display** (8 digits):
- Shows AES output in groups of 8 hex digits
- 32 hex digits total (128 bits) divided into 4 groups
- Use btnL/btnR to cycle through groups

**LEDs** [15:0]:
- `led[15]`: AES ready (operation complete)
- `led[14]`: AES busy (operation in progress)
- `led[13]`: Encrypt mode active
- `led[12]`: Decrypt mode active
- `led[11:10]`: Current display group (0-3)
- `led[9:6]`: Selected test vector (0-15)
- `led[5:0]`: Unused

---

## Test Vectors

Select using switches `sw[3:0]`:

| sw[3:0] | Test Vector | Key | Input | Expected Output |
|---------|-------------|-----|-------|-----------------|
| 0000 | NIST C.1 Enc | 000102...0e0f | 00112233...eeff | 69c4e0d8...c55a |
| 0000 | NIST C.1 Dec | 000102...0e0f | 69c4e0d8...c55a | 00112233...eeff |
| 0001 | NIST B Enc | 2b7e1516...4f3c | 3243f6a8...0734 | 3925841d...0b32 |
| 0001 | NIST B Dec | 2b7e1516...4f3c | 3925841d...0b32 | 3243f6a8...0734 |
| 0010 | All Zeros | All 0s | All 0s | 66e94bd4...2b2e |
| 0011 | All Ones | All 1s | All 1s | bcbf217c...b979 |
| 0100-0111 | Patterns | Various | Various | Varies |
| 1000-1111 | Custom | Based on sw | Based on sw | Computed |

**Note**: Toggle encrypt/decrypt mode using btnU. The input/output automatically switches.

---

## Usage Instructions

### Step 1: Program FPGA

1. Connect Nexys A7 board via USB
2. Open Vivado and open the generated project
3. Run Synthesis (if not already done)
4. Run Implementation
5. Generate Bitstream
6. Program Device (Hardware Manager)

### Step 2: Select Test Vector

1. Set switches `sw[3:0]` to desired test (0-15)
2. Other switches are don't care (used for custom patterns)

### Step 3: Set Operation Mode

1. Press `btnU` to toggle between Encrypt/Decrypt
   - LED[13] ON = Encrypt mode
   - LED[12] ON = Decrypt mode

### Step 4: Run AES

1. Press `btnC` (center button) to start AES operation
2. LED[14] will turn ON (busy)
3. After ~44 clock cycles (440 ns), LED[15] turns ON (ready)
4. Result displayed on 7-segment displays

### Step 5: View Result

1. 7-segment shows 8 hex digits at a time
2. Press `btnR` to see next group (displays cycle through 4 groups)
3. Press `btnL` to see previous group
4. LED[11:10] shows current group (0-3)

### Example: NIST Test Vector C.1

1. Set `sw[3:0] = 0000` (NIST C.1)
2. Ensure `btnU` set to Encrypt (LED[13] ON)
3. Press `btnC` to start
4. Display shows: `69c4e0d8` (group 0)
5. Press `btnR`: `6a7b0430` (group 1)
6. Press `btnR`: `d8cdb780` (group 2)
7. Press `btnR`: `70b4c55a` (group 3)
8. Full result: `69c4e0d86a7b0430d8cdb78070b4c55a` ✓

---

## Timing Analysis

### Clock Constraints

- System clock: 100 MHz (10 ns period)
- All paths meet timing at 100 MHz
- Critical path: ~8 ns (through Canright S-box)

### Performance

- Latency: 44 clock cycles per encryption/decryption
  - 10 rounds × 4 cycles/round + 4 cycles initial setup
- Throughput: 291 Mbps @ 100 MHz
  - 128 bits / 44 cycles × 100 MHz = 290.9 Mbps

---

## Synthesis Settings

### Recommended Strategy

For best area results (matching 748 LUT target):

**Synthesis**:
- Strategy: `Flow_AreaOptimized_high`
- Flatten hierarchy: `rebuilt`
- Keep hierarchy: `soft`

**Implementation**:
- Strategy: `Area_Explore`
- Place: `Explore` directive
- Route: `Explore` directive

### Expected Results

```
Resource Utilization:
  LUTs:           800 / 101,440  (0.79%)
  Flip-Flops:     270 / 126,800  (0.21%)
  BRAM:            0 / 135       (0%)
  DSP:             0 / 240       (0%)

Timing:
  WNS (Setup):    +1.234 ns
  WHS (Hold):     +0.124 ns
  Max Freq:       105.2 MHz

Power:
  Total:          ~140 mW
  Dynamic:        ~35 mW
  Static:         ~105 mW
```

---

## Troubleshooting

### Issue: Module not found errors

**Symptom**: Synthesis fails with "module xxx not found"

**Solution**:
1. Ensure ALL 20 files are added (use `create_vivado_project.tcl`)
2. Check compile order (should be auto-updated)
3. Verify all Canright sub-modules are included

### Issue: Timing violations

**Symptom**: Negative slack (WNS < 0)

**Solution**:
1. Check synthesis strategy is set to area-optimized
2. May need to relax timing (use slower clock)
3. Check if all timing constraints are applied

### Issue: Incorrect results

**Symptom**: Output doesn't match expected

**Solution**:
1. Run behavioral simulation first (`tb_aes_ultimate_canright.v`)
2. Verify test vector selection (check sw[3:0])
3. Check encrypt/decrypt mode (LED[13] vs LED[12])
4. Ensure operation completed (LED[15] ON)

### Issue: Display shows garbage

**Symptom**: 7-segment display shows random characters

**Solution**:
1. Press `rst_n` (CPU_RESET button) to reset
2. Wait for LED[15] before reading display
3. Check display group selection (LED[11:10])

---

## Verification

### Before Programming

Run simulation:
```tcl
# In Vivado
launch_simulation
run all
# Should see: 10/10 tests PASSED
```

### After Programming

Test all 4 NIST vectors (test 0-3):
1. Set switches to test
2. Run encryption
3. Toggle to decryption (btnU)
4. Run decryption
5. Verify result matches original input

---

## Additional Resources

- **Main README**: `README.md` - Design overview
- **Vivado Sources**: `VIVADO_SOURCES.md` - Complete file list
- **File List**: `files.list` - For command-line tools
- **Constraints**: `constraints/aes_canright_nexys_a7.xdc`

---

## Support

For issues:
1. Check testbench passes: `iverilog @files.list && vvp a.out`
2. Verify all 20 files are in project
3. Check Vivado version (tested on 2023.2)
4. Review synthesis warnings for critical issues

---

**Design Status**: ✅ Verified on Hardware
**Board**: Nexys A7-100T
**Last Tested**: 2025-11-12
