# Synthesis Constraints

This directory contains Xilinx Design Constraints (XDC) files for synthesis and implementation.

## Files

### aes_con.xdc
**Pin Constraints for Nexys A7-100T Board**

Defines:
- Clock input (100 MHz on pin E3)
- Reset button (CPU_RESETN on pin C12)
- Push buttons (btnC, btnU, btnL, btnR)
- Switches (sw[15:0])
- LEDs (led[15:0])
- 7-segment display (an[7:0], seg[6:0])
- Configuration options

**Target Device**: XC7A100TCSG324-1 (Artix-7)

### aes_srl_optimization.xdc ⭐
**Optimization Constraints for Ultimate Design**

Defines:
1. **Shift Register Extraction**
   - Targets round key storage (`rk_shift_reg`)
   - Pipeline stages (`state_col_pipe`, `temp_col_pipe`)
   - ShiftRows/MixColumns pipelines

2. **Synthesis Directives**
   - `SHREG_EXTRACT YES` - Enable SRL primitive usage
   - `SRL_STYLE SRL` - Force SRL32 inference
   - `SHREG_MIN_SIZE 3` - Minimum chain length for SRL

3. **Timing Constraints**
   - 100 MHz system clock (10ns period)
   - Input/output delays (2ns)
   - False paths for reset

4. **Hierarchy Preservation**
   - `KEEP_HIERARCHY SOFT` for core module
   - Allows optimization while preserving structure

## Usage

Both constraint files are automatically applied by the synthesis script:

```tcl
add_files -fileset constrs_1 -norecurse {
    ../constraints/aes_con.xdc
    ../constraints/aes_srl_optimization.xdc
}
```

## Key Optimization Attributes

### Shift Register Extraction

```verilog
(* shreg_extract = "yes" *)
(* srl_style = "srl" *)
reg [31:0] rk_shift_reg [0:43];
```

This tells Vivado to:
- Extract shift register chains
- Use SRL32 primitives (32-bit shift registers)
- Save ~300-400 LUTs vs flip-flop implementation

### Expected SRL Instances

- Round key storage: 44 words × 32 bits = ~44 SRL32s
- Pipeline stages: Multiple smaller SRLs
- **Total expected**: 150-200 SRL instances

## Verification

After synthesis, check SRL extraction:

```bash
# In Vivado TCL console
report_utilization -cells [get_cells -hierarchical -filter {REF_NAME =~ SRL*}]
```

Or review the generated report:
```bash
cat ../scripts/reports_ultimate/srl_instances_ultimate.txt
```

## Notes

- Composite field S-boxes use pure logic (not LUT/RAM based)
- Clock gating uses BUFGCE primitives (instantiated in RTL)
- Timing constraints assume 100 MHz operation (10ns period)
